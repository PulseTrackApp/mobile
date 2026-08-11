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

  final FlutterSecureStorage _storage;

  String? _accessToken;
  String? _refreshToken;
  String? _email;
  String? _userId;
  String? _displayName;
  bool _profileCompleted = false;

  String? get accessToken => _accessToken;

  String? get refreshToken => _refreshToken;

  String? get email => _email;

  String? get userId => _userId;

  String? get displayName => _displayName;

  bool get profileCompleted => _profileCompleted;

  bool get isAuthenticated => _accessToken != null && _accessToken!.isNotEmpty;

  Future<void> restore() async {
    _accessToken = await _storage.read(key: _accessTokenKey);
    _refreshToken = await _storage.read(key: _refreshTokenKey);
    _email = await _storage.read(key: _emailKey);
    _userId = await _storage.read(key: _userIdKey);
    _displayName = await _storage.read(key: _displayNameKey);
    _profileCompleted =
        (await _storage.read(key: _profileCompletedKey)) == 'true';
  }

  Future<void> save(AuthSession session) async {
    _accessToken = session.accessToken;
    _refreshToken = session.refreshToken;
    _email = session.email;
    _userId = session.userId;
    _profileCompleted = session.profileCompleted;

    await Future.wait([
      _storage.write(key: _accessTokenKey, value: session.accessToken),
      _storage.write(key: _refreshTokenKey, value: session.refreshToken),
      _storage.write(key: _emailKey, value: session.email),
      _storage.write(key: _userIdKey, value: session.userId),
      _storage.write(
        key: _profileCompletedKey,
        value: session.profileCompleted.toString(),
      ),
    ]);
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

  Future<void> clear() async {
    _accessToken = null;
    _refreshToken = null;
    _email = null;
    _userId = null;
    _displayName = null;
    _profileCompleted = false;

    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
      _storage.delete(key: _emailKey),
      _storage.delete(key: _userIdKey),
      _storage.delete(key: _displayNameKey),
      _storage.delete(key: _profileCompletedKey),
    ]);
    notifyListeners();
  }
}
