import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Acces au service de notifications de la plateforme.
///
/// L'interface est abstraite pour deux raisons : elle isole le reste de
/// l'application du SDK Firebase, et elle permet de tester l'enregistrement des
/// appareils sans emulateur ni projet Firebase.
abstract class PushService {
  /// Prepare le SDK. Retourne `false` si les notifications sont indisponibles.
  ///
  /// L'indisponibilite n'est pas une erreur : tant que Firebase n'est pas
  /// configure, ou sur un appareil sans Google Play Services, l'application
  /// doit fonctionner normalement, simplement sans rappels.
  Future<bool> initialize();

  /// Demande la permission puis retourne le jeton de cet appareil.
  ///
  /// Retourne `null` si l'utilisateur refuse, ou si le service est
  /// indisponible.
  Future<String?> obtainToken();

  /// Jetons emis par FCM lorsqu'il renouvelle celui de l'appareil.
  ///
  /// S'y abonner est indispensable : un jeton renouvele et non transmis fait
  /// cesser les notifications sans le moindre message d'erreur.
  Stream<String> get tokenRefreshes;

  /// Valeur attendue par le serveur : `ANDROID`, `IOS` ou `WEB`.
  String get platformName;
}

/// Implementation reelle, adossee a Firebase Cloud Messaging.
class FirebasePushService implements PushService {
  FirebasePushService({this._messaging});

  FirebaseMessaging? _messaging;
  bool _ready = false;

  @override
  Future<bool> initialize() async {
    if (_ready) return true;

    try {
      // Sans options explicites : sur Android, la configuration vient de
      // `google-services.json`, depose par `flutterfire configure`. Tant que ce
      // fichier est absent, cet appel echoue — et c'est precisement le cas que
      // l'on rattrape ci-dessous.
      await Firebase.initializeApp();
      _messaging ??= FirebaseMessaging.instance;
      _ready = true;
      return true;
    } on Object catch (error) {
      // Volontairement large : un SDK natif peut remonter a peu pres n'importe
      // quoi, et aucune de ces pannes ne justifie d'empecher l'application de
      // demarrer. Les notifications sont un confort, pas une fonction vitale.
      debugPrint('Notifications indisponibles : $error');
      _ready = false;
      return false;
    }
  }

  @override
  Future<String?> obtainToken() async {
    final messaging = _messaging;
    if (!_ready || messaging == null) return null;

    try {
      final settings = await messaging.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        return null;
      }
      return await messaging.getToken();
    } on Object catch (error) {
      debugPrint('Jeton de notification indisponible : $error');
      return null;
    }
  }

  @override
  Stream<String> get tokenRefreshes {
    final messaging = _messaging;
    if (!_ready || messaging == null) return const Stream<String>.empty();
    return messaging.onTokenRefresh;
  }

  @override
  String get platformName {
    if (kIsWeb) return 'WEB';
    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS || TargetPlatform.macOS => 'IOS',
      _ => 'ANDROID',
    };
  }
}
