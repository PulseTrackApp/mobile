import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'auth_session.dart';

class AuthTokenStore extends ChangeNotifier {
  AuthTokenStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _accessTokenKey = 'gymflow_access_token';
  static const _refreshTokenKey = 'gymflow_refresh_token';
  static const _emailKey = 'gymflow_email';
  static const _userIdKey = 'gymflow_user_id';
  static const _displayNameKey = 'gymflow_display_name';
  static const _profileCompletedKey = 'gymflow_profile_completed';
  static const _emailVerifiedKey = 'gymflow_email_verified';

  final FlutterSecureStorage _storage;

  String? _accessToken;
  String? _refreshToken;
  String? _email;
  String? _userId;
  String? _displayName;
  bool _profileCompleted = false;
  bool _emailVerified = false;
  bool _paymentRequired = false;
  bool _upgradeRequired = false;
  String? _minimumVersion;
  String? _storeUrl;
  int _sessionExpiredNoticeId = 0;
  int _paymentRequiredNoticeId = 0;

  String? get accessToken => _accessToken;

  String? get refreshToken => _refreshToken;

  String? get email => _email;

  String? get userId => _userId;

  String? get displayName => _displayName;

  bool get profileCompleted => _profileCompleted;

  bool get emailVerified => _emailVerified;

  bool get isAuthenticated => _accessToken != null && _accessToken!.isNotEmpty;

  bool get paymentRequired => _paymentRequired;

  /// Vrai quand l'API a refusé cette version de l'application (`426`).
  bool get upgradeRequired => _upgradeRequired;

  /// Version minimale exigée, telle que le serveur l'a annoncée.
  String? get minimumVersion => _minimumVersion;

  /// Adresse du magasin ; `null` si le serveur n'en a pas configuré.
  String? get storeUrl => _storeUrl;

  int get sessionExpiredNoticeId => _sessionExpiredNoticeId;

  int get paymentRequiredNoticeId => _paymentRequiredNoticeId;

  Future<void> restore() async {
    _accessToken = await _storage.read(key: _accessTokenKey);
    _refreshToken = await _storage.read(key: _refreshTokenKey);
    _email = await _storage.read(key: _emailKey);
    _userId = await _storage.read(key: _userIdKey);
    _displayName = await _storage.read(key: _displayNameKey);
    _profileCompleted =
        (await _storage.read(key: _profileCompletedKey)) == 'true';
    _emailVerified = (await _storage.read(key: _emailVerifiedKey)) == 'true';
  }

  Future<void> save(AuthSession session) async {
    _accessToken = session.accessToken;
    _refreshToken = session.refreshToken;
    _email = session.email;
    _userId = session.userId;
    _profileCompleted = session.profileCompleted;
    _emailVerified = session.emailVerified;
    _paymentRequired = false;

    await Future.wait([
      _storage.write(key: _accessTokenKey, value: session.accessToken),
      _storage.write(key: _refreshTokenKey, value: session.refreshToken),
      _storage.write(key: _emailKey, value: session.email),
      _storage.write(key: _userIdKey, value: session.userId),
      _storage.write(
        key: _profileCompletedKey,
        value: session.profileCompleted.toString(),
      ),
      _storage.write(
        key: _emailVerifiedKey,
        value: session.emailVerified.toString(),
      ),
    ]);
    notifyListeners();
  }

  void markPaymentRequired() {
    _paymentRequired = true;
    _paymentRequiredNoticeId++;
    notifyListeners();
  }

  /// L'API refuse cette version de l'application.
  ///
  /// Volontairement **non lié à la session** : le refus s'applique aussi à la
  /// connexion et à l'inscription, donc l'écran de mise à jour doit pouvoir
  /// s'afficher sur une application où personne n'est connecté.
  void markUpgradeRequired({String? minimumVersion, String? storeUrl}) {
    if (_upgradeRequired &&
        _minimumVersion == minimumVersion &&
        _storeUrl == storeUrl) {
      return;
    }
    _upgradeRequired = true;
    _minimumVersion = minimumVersion;
    _storeUrl = storeUrl;
    notifyListeners();
  }

  /// Après une mise à jour, ou pour laisser retenter : rien ne se débloque tant
  /// que le serveur refuse toujours, mais l'écran ne doit pas être une prison.
  void clearUpgradeRequired() {
    if (!_upgradeRequired) return;
    _upgradeRequired = false;
    notifyListeners();
  }

  void clearPaymentRequired() {
    if (!_paymentRequired) return;
    _paymentRequired = false;
    notifyListeners();
  }

  Future<void> markProfileCompleted({String? displayName}) async {
    final normalizedDisplayName = displayName?.trim();
    if (normalizedDisplayName != null && normalizedDisplayName.isNotEmpty) {
      _displayName = normalizedDisplayName;
    }
    if (_profileCompleted) {
      if (normalizedDisplayName != null && normalizedDisplayName.isNotEmpty) {
        await _storage.write(
          key: _displayNameKey,
          value: normalizedDisplayName,
        );
        notifyListeners();
      }
      return;
    }

    _profileCompleted = true;
    await Future.wait([
      _storage.write(key: _profileCompletedKey, value: 'true'),
      if (normalizedDisplayName != null && normalizedDisplayName.isNotEmpty)
        _storage.write(key: _displayNameKey, value: normalizedDisplayName),
    ]);
    notifyListeners();
  }

  Future<void> markEmailVerified() async {
    if (_emailVerified) return;
    _emailVerified = true;
    await _storage.write(key: _emailVerifiedKey, value: 'true');
    notifyListeners();
  }

  Future<void> clear() async {
    _clearInMemorySession();
    _paymentRequired = false;
    await _deleteStoredSession();
    notifyListeners();
  }

  Future<void> expireSession() async {
    _clearInMemorySession();
    _paymentRequired = false;
    _sessionExpiredNoticeId++;
    await _deleteStoredSession();
    notifyListeners();
  }

  void _clearInMemorySession() {
    _accessToken = null;
    _refreshToken = null;
    _email = null;
    _userId = null;
    _displayName = null;
    _profileCompleted = false;
    _emailVerified = false;
  }

  Future<void> _deleteStoredSession() {
    return Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
      _storage.delete(key: _emailKey),
      _storage.delete(key: _userIdKey),
      _storage.delete(key: _displayNameKey),
      _storage.delete(key: _profileCompletedKey),
      _storage.delete(key: _emailVerifiedKey),
    ]);
  }
}
