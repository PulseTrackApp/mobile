import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_flutter/core/api/auth_session.dart';
import 'package:mobile_flutter/core/api/auth_token_store.dart';
import 'package:mobile_flutter/core/api/pulse_track_api.dart';
import 'package:mobile_flutter/core/push/push_registrar.dart';
import 'package:mobile_flutter/core/push/push_service.dart';

void main() {
  late _FakePushService pushService;
  late _RecordingApi api;
  late AuthTokenStore tokenStore;

  setUp(() {
    // Point d'entree de test fourni par le paquet : il remplace la plateforme
    // native par une implementation en memoire, sans quoi le moindre `save()`
    // echouerait faute de canal de plateforme sous `flutter test`.
    FlutterSecureStorage.setMockInitialValues({});
    pushService = _FakePushService();
    api = _RecordingApi();
    tokenStore = AuthTokenStore();
  });

  PushRegistrar registrar() =>
      PushRegistrar(pushService: pushService, api: api, tokenStore: tokenStore);

  test('enregistre l appareil quand une session est deja ouverte', () async {
    await tokenStore.save(_session());

    await registrar().start();

    expect(api.registered, [('jeton-appareil', 'ANDROID')]);
  });

  test('n enregistre rien tant que personne n est connecte', () async {
    await registrar().start();

    // L'endpoint exige un jeton d'acces : appeler sans session ne ferait que
    // recolter une 401.
    expect(api.registered, isEmpty);
  });

  test('enregistre des que l utilisateur se connecte', () async {
    final subject = registrar()..dispose();
    await registrar().start();
    expect(api.registered, isEmpty);

    await tokenStore.save(_session());
    await pumpEventQueue();

    expect(api.registered, [('jeton-appareil', 'ANDROID')]);
    subject.dispose();
  });

  test('ne renvoie pas deux fois le meme jeton pour le meme compte', () async {
    await tokenStore.save(_session());
    await registrar().start();

    // `AuthTokenStore` notifie a chaque sauvegarde, donc a chaque
    // renouvellement de session : sans garde, chacune relancerait un appel.
    await tokenStore.save(_session());
    await pumpEventQueue();

    expect(api.registered, hasLength(1));
  });

  test('renvoie le jeton lorsque FCM le renouvelle', () async {
    await tokenStore.save(_session());
    await registrar().start();

    pushService.emitRefreshedToken('jeton-renouvele');
    await pumpEventQueue();

    // Un jeton renouvele et non transmis fait cesser les notifications sans le
    // moindre message d'erreur.
    expect(api.registered, [
      ('jeton-appareil', 'ANDROID'),
      ('jeton-renouvele', 'ANDROID'),
    ]);
  });

  test('reenregistre apres un changement de compte', () async {
    await tokenStore.save(_session(userId: 'utilisateur-1'));
    await registrar().start();

    await tokenStore.save(_session(userId: 'utilisateur-2'));
    await pumpEventQueue();

    // Meme appareil, autre compte : le serveur doit transferer la propriete du
    // jeton, sinon le premier compte continue de recevoir les rappels.
    expect(api.registered, hasLength(2));
  });

  test('ne fait rien quand les notifications sont indisponibles', () async {
    pushService.available = false;
    await tokenStore.save(_session());

    await registrar().start();

    expect(api.registered, isEmpty);
  });

  test('n echoue pas quand la permission est refusee', () async {
    pushService.token = null;
    await tokenStore.save(_session());

    await expectLater(registrar().start(), completes);
    expect(api.registered, isEmpty);
  });

  test('n interrompt pas l application si le serveur refuse', () async {
    api.failRegistration = true;
    await tokenStore.save(_session());

    // Ne pas recevoir de rappel est un desagrement ; empecher l'utilisateur
    // d'entrer dans l'application en serait un autre.
    await expectLater(registrar().start(), completes);
  });

  test('desinscrit l appareil avant la deconnexion', () async {
    await tokenStore.save(_session());
    final subject = registrar();
    await subject.start();

    await subject.unregister();

    expect(api.unregistered, ['jeton-appareil']);
  });

  test('ne desinscrit rien si plus personne n est connecte', () async {
    final subject = registrar();
    await subject.start();

    await subject.unregister();

    expect(api.unregistered, isEmpty);
  });

  test('laisse la deconnexion aboutir meme sans reseau', () async {
    await tokenStore.save(_session());
    final subject = registrar();
    await subject.start();
    api.failUnregistration = true;

    await expectLater(subject.unregister(), completes);
  });
}

AuthSession _session({String userId = 'utilisateur-1'}) {
  return AuthSession(
    accessToken: 'jeton-acces',
    tokenType: 'Bearer',
    expiresIn: const Duration(hours: 24),
    refreshToken: 'jeton-renouvellement',
    refreshExpiresIn: const Duration(days: 30),
    userId: userId,
    email: 'nicolas@gymflow.test',
    profileCompleted: true,
    emailVerified: true,
  );
}

class _FakePushService implements PushService {
  bool available = true;
  String? token = 'jeton-appareil';

  final _refreshes = StreamController<String>.broadcast();

  void emitRefreshedToken(String value) => _refreshes.add(value);

  @override
  Future<bool> initialize() async => available;

  @override
  Future<String?> obtainToken() async => available ? token : null;

  @override
  Stream<String> get tokenRefreshes => _refreshes.stream;

  @override
  String get platformName => 'ANDROID';
}

class _RecordingApi implements PulseTrackApi {
  final List<(String, String)> registered = [];
  final List<String> unregistered = [];

  bool failRegistration = false;
  bool failUnregistration = false;

  @override
  Future<void> registerDeviceToken({
    required String token,
    required String platform,
  }) async {
    if (failRegistration) throw Exception('serveur indisponible');
    registered.add((token, platform));
  }

  @override
  Future<void> unregisterDeviceToken(String token) async {
    if (failUnregistration) throw Exception('reseau coupe');
    unregistered.add(token);
  }

  /// Seules les deux methodes ci-dessus sont exercees ici : le reste du client
  /// n'a pas a etre reimplemente pour tester l'enregistrement des appareils.
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
