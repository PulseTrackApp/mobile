class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    required this.refreshToken,
    required this.refreshExpiresIn,
    required this.userId,
    required this.email,
    required this.profileCompleted,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      accessToken: json['accessToken']?.toString() ?? '',
      tokenType: json['tokenType']?.toString() ?? 'Bearer',
      expiresIn: Duration(seconds: _intOrZero(json['expiresInSeconds'])),
      refreshToken: json['refreshToken']?.toString() ?? '',
      refreshExpiresIn: Duration(
        seconds: _intOrZero(json['refreshExpiresInSeconds']),
      ),
      userId: json['userId']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      profileCompleted: _boolOrFalse(json['profileCompleted']),
    );
  }

  final String accessToken;
  final String tokenType;
  final Duration expiresIn;
  final String refreshToken;
  final Duration refreshExpiresIn;
  final String userId;
  final String email;
  final bool profileCompleted;
}

int _intOrZero(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

bool _boolOrFalse(Object? value) {
  if (value is bool) return value;
  if (value is String) return value.toLowerCase() == 'true';
  return false;
}
