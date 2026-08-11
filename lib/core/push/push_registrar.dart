import 'dart:async';

import 'package:flutter/foundation.dart';

import '../api/auth_token_store.dart';
import '../api/pulse_track_api.dart';
import 'push_service.dart';

/// Fait le lien entre le jeton d'appareil fourni par FCM et le serveur.
///
/// Deux moments comptent, et ils ne se produisent pas dans le meme ordre selon
/// les sessions : l'appareil obtient un jeton, et l'utilisateur se connecte.
/// L'enregistrement n'est possible qu'une fois les deux acquis, puisque
/// l'endpoint exige un jeton d'acces. Cette classe attend donc les deux, dans
/// n'importe quel ordre.
///
/// Aucune de ses defaillances ne remonte a l'appelant : ne pas recevoir de
/// rappel est un desagrement, empecher l'utilisateur d'entrer dans
/// l'application en serait un autre.
class PushRegistrar {
  PushRegistrar({
    required this._pushService,
    required this._api,
    required this._tokenStore,
    bool Function()? canRegister,
    this.accessListenable,
  }) : _canRegister = canRegister ?? _alwaysRegister;

  final PushService _pushService;
  final PulseTrackApi _api;
  final AuthTokenStore _tokenStore;
  final bool Function() _canRegister;
  final Listenable? accessListenable;

  StreamSubscription<String>? _refreshSubscription;
  String? _deviceToken;

  /// Jeton deja transmis, avec le compte pour lequel il l'a ete.
  ///
  /// Sans cette memoire, chaque notification de `AuthTokenStore` — il en emet a
  /// chaque sauvegarde de session, donc a chaque renouvellement — relancerait
  /// un appel reseau identique.
  String? _registeredToken;
  String? _registeredForUserId;

  bool _started = false;

  /// Demarre le service, s'abonne aux renouvellements et enregistre l'appareil
  /// si une session est deja ouverte.
  Future<void> start() async {
    if (_started) return;
    _started = true;

    final available = await _pushService.initialize();
    if (!available) return;

    _refreshSubscription = _pushService.tokenRefreshes.listen((token) {
      _deviceToken = token;
      // Un jeton renouvele doit repartir au serveur meme s'il remplace un
      // jeton deja enregistre : on efface donc la memoire avant de resynchroniser.
      _registeredToken = null;
      unawaited(_synchronize());
    });

    _tokenStore.addListener(_onAuthenticationChanged);
    accessListenable?.addListener(_onAuthenticationChanged);

    _deviceToken = await _pushService.obtainToken();
    await _synchronize();
  }

  /// Retire l'appareil de la liste des destinataires.
  ///
  /// A appeler <strong>avant</strong> la deconnexion : l'endpoint exige un
  /// jeton d'acces, qui n'existera plus une fois la session effacee.
  Future<void> unregister() async {
    final token = _deviceToken;
    if (token == null || !_tokenStore.isAuthenticated) return;

    try {
      await _api.unregisterDeviceToken(token);
    } on Object catch (error) {
      // Sans reseau, la deconnexion doit rester possible. Le serveur nettoiera
      // de lui-meme : FCM repond 404 pour un jeton d'application desinstallee,
      // et le jeton est alors supprime.
      debugPrint('Desinscription des notifications impossible : $error');
    } finally {
      _registeredToken = null;
      _registeredForUserId = null;
    }
  }

  void dispose() {
    _tokenStore.removeListener(_onAuthenticationChanged);
    accessListenable?.removeListener(_onAuthenticationChanged);
    unawaited(_refreshSubscription?.cancel());
    _refreshSubscription = null;
  }

  void _onAuthenticationChanged() => unawaited(_synchronize());

  Future<void> _synchronize() async {
    final token = _deviceToken;
    final userId = _tokenStore.userId;

    if (token == null || !_tokenStore.isAuthenticated || userId == null) {
      return;
    }
    if (!_canRegister()) {
      return;
    }
    if (_registeredToken == token && _registeredForUserId == userId) {
      return;
    }

    try {
      await _api.registerDeviceToken(
        token: token,
        platform: _pushService.platformName,
      );
      _registeredToken = token;
      _registeredForUserId = userId;
    } on Object catch (error) {
      // Reessaye a la prochaine occasion : ouverture de l'application,
      // reconnexion, ou renouvellement du jeton par FCM.
      debugPrint('Enregistrement des notifications impossible : $error');
    }
  }
}

bool _alwaysRegister() => true;
