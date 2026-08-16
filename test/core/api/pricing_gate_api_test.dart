import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_flutter/core/api/api_config.dart';
import 'package:mobile_flutter/core/api/api_error.dart';
import 'package:mobile_flutter/core/api/auth_token_store.dart';
import 'package:mobile_flutter/core/api/billing_models.dart';
import 'package:mobile_flutter/core/api/pulse_track_api.dart';

/// Le verrou de version et le mur de paiement, vus du client.
///
/// Le test le plus important est le premier : sans les deux en-têtes de version,
/// le serveur ne pourra jamais activer le refus des anciennes APK sans fermer
/// l'application à tout le monde en même temps.
void main() {
  late Dio dio;
  late _FakeServer server;
  late AuthTokenStore tokenStore;
  late PulseTrackApi api;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    server = _FakeServer();
    dio = Dio(BaseOptions(baseUrl: 'https://exemple.test/api/v1/'));
    dio.httpClientAdapter = server;
    tokenStore = AuthTokenStore();
    api = PulseTrackApi(
      config: const ApiConfig(baseUrl: 'https://exemple.test/api/v1'),
      tokenStore: tokenStore,
      dio: dio,
    );
  });

  test('annonce sa version et sa plateforme à chaque requête', () async {
    server.body = '{"modules": []}';

    await api.getModules();

    // Ce sont les deux seuls en-têtes que le serveur regarde. Leur absence est
    // précisément ce qui identifiera les applications trop anciennes.
    expect(server.lastHeaders?['X-GymFlow-Client-Version'], isNotNull);
    expect(server.lastHeaders?['X-GymFlow-Platform'], isNotNull);
  });

  test('lit le catalogue de tarifs et son état « à venir »', () async {
    server.body = '''
      [
        {
          "code": "MONTHLY", "name": "Mensuel", "description": "Sans engagement.",
          "priceAmount": 2000, "currency": "FCFA", "priceLabel": "2000 FCFA / mois",
          "period": "MONTHLY", "availability": "COMING_SOON", "highlighted": false,
          "features": ["Séances illimitées"]
        }
      ]
    ''';

    final plans = await api.getBillingPlans();

    expect(server.lastPath, 'billing/plans');
    expect(plans, hasLength(1));
    expect(plans.first.code, 'MONTHLY');
    // Le prix est mis en forme par le serveur : le client ne recompose rien.
    expect(plans.first.priceLabel, '2000 FCFA / mois');
    expect(plans.first.isComingSoon, isTrue);
    expect(plans.first.features.first, 'Séances illimitées');
  });

  test('lit le droit d\'usage et distingue accès et application du verrou', () async {
    server.body = '''
      {
        "status": "EXPIRED", "accessGranted": false, "enforced": false,
        "endsOn": "2026-09-15", "daysLeft": 0, "planCode": null,
        "headline": "Abonnement à renouveler",
        "message": "Ton accès est arrivé à échéance."
      }
    ''';

    final state = await api.getSubscription();

    expect(state.status, SubscriptionStatus.expired);
    expect(state.accessGranted, isFalse);
    // Expiré mais le serveur ne l'applique pas encore : rien ne doit bloquer.
    expect(state.enforced, isFalse);
    expect(state.mustPayNow, isFalse);
  });

  test('bascule le store en « mise à jour requise » sur un 426', () async {
    server.status = 426;
    server.body = '''
      {
        "type": "https://pulsetrack.app/problems/client-upgrade-required",
        "title": "Mise à jour requise",
        "status": 426,
        "detail": "Cette version n'est plus acceptée.",
        "minimumVersion": "2.0.0",
        "currentVersion": null,
        "storeUrl": "https://play.google.com/store/apps/details?id=gymflow"
      }
    ''';

    await expectLater(api.getModules(), throwsA(isA<ApiProblem>()));

    expect(tokenStore.upgradeRequired, isTrue);
    expect(tokenStore.minimumVersion, '2.0.0');
    expect(tokenStore.storeUrl, contains('play.google.com'));
    // Le refus de version ne doit pas être confondu avec un mur de paiement.
    expect(tokenStore.paymentRequired, isFalse);
  });

  test('bascule le store en « paiement requis » sur un 402', () async {
    server.status = 402;
    server.body = '''
      {
        "type": "https://pulsetrack.app/problems/subscription-required",
        "title": "Abonnement requis",
        "status": 402,
        "detail": "Ton accès est arrivé à échéance.",
        "subscriptionStatus": "EXPIRED",
        "suggestedPlan": {"code": "YEARLY", "priceLabel": "20000 FCFA / an"}
      }
    ''';

    await expectLater(api.getModules(), throwsA(isA<ApiProblem>()));

    expect(tokenStore.paymentRequired, isTrue);
    expect(tokenStore.upgradeRequired, isFalse);
  });

  test('distingue une session expirée d\'une absence de session', () {
    final expired = ApiProblem.fromJson({
      'type': 'https://pulsetrack.app/problems/token-expired',
      'title': 'Session expirée',
      'status': 401,
      'detail': 'Ta session a expiré.',
    });
    final anonymous = ApiProblem.fromJson({
      'type': 'https://pulsetrack.app/problems/unauthenticated',
      'title': 'Authentification requise',
      'status': 401,
      'detail': 'Cette ressource demande une session valide.',
    });

    expect(expired.isSessionExpired, isTrue);
    expect(expired.isUnauthenticated, isFalse);
    expect(anonymous.isUnauthenticated, isTrue);
    expect(anonymous.isSessionExpired, isFalse);
    // Les deux restent des 401 : le renouvellement silencieux doit s'appliquer.
    expect(expired.isUnauthorized, isTrue);
    expect(anonymous.isUnauthorized, isTrue);
  });

  test('n\'ouvre pas le mur de paiement sur une erreur qui parle d\'abonnement', () {
    // Le texte ne fait pas foi : seuls le code et le `type` décident.
    final problem = ApiProblem.fromJson({
      'type': 'https://pulsetrack.app/problems/business-rule',
      'title': 'Règle métier non respectée',
      'status': 422,
      'detail': "Cet abonnement requis n'existe pas.",
    });

    expect(problem.isPaymentRequired, isFalse);
  });

  test('conserve les propriétés hors RFC posées par le serveur', () {
    final problem = ApiProblem.fromJson({
      'type': 'https://pulsetrack.app/problems/client-upgrade-required',
      'title': 'Mise à jour requise',
      'status': 426,
      'detail': 'Trop ancienne.',
      'minimumVersion': '3.1.0',
      'storeUrl': 'https://exemple.test/store',
    });

    expect(problem.minimumVersion, '3.1.0');
    expect(problem.storeUrl, 'https://exemple.test/store');
    expect(problem.extensions.containsKey('title'), isFalse);
  });
}

class _FakeServer implements HttpClientAdapter {
  String body = '{}';
  int status = 200;
  String? lastPath;
  Map<String, dynamic>? lastHeaders;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastPath = options.path;
    lastHeaders = Map<String, dynamic>.from(options.headers);
    return ResponseBody.fromString(
      body,
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
