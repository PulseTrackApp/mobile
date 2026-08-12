import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_flutter/core/api/api_config.dart';
import 'package:mobile_flutter/core/api/auth_token_store.dart';
import 'package:mobile_flutter/core/api/pulse_track_api.dart';

void main() {
  late Dio dio;
  late _RecordingServer server;
  late PulseTrackApi api;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    server = _RecordingServer();
    dio = Dio(BaseOptions(baseUrl: 'https://exemple.test/api/v1/'));
    dio.httpClientAdapter = server;
    api = PulseTrackApi(
      config: const ApiConfig(baseUrl: 'https://exemple.test/api/v1'),
      dio: dio,
    );
  });

  test('demande un code de reinitialisation de mot de passe', () async {
    await api.requestPasswordResetCode(email: 'nico@gymflow.test');

    expect(server.lastMethod, 'POST');
    expect(server.lastPath, 'auth/forgot-password');
    expect(server.lastData, {'email': 'nico@gymflow.test'});
  });

  test('envoie le code et le nouveau mot de passe', () async {
    await api.resetPassword(code: 'ABCD1234', newPassword: 'nouveau123');

    expect(server.lastMethod, 'POST');
    expect(server.lastPath, 'auth/reset-password');
    expect(server.lastData, {'code': 'ABCD1234', 'newPassword': 'nouveau123'});
  });

  test('renvoie le code de confirmation email', () async {
    await api.resendVerificationEmail(email: 'nico@gymflow.test');

    expect(server.lastMethod, 'POST');
    expect(server.lastPath, 'auth/resend-verification');
    expect(server.lastData, {'email': 'nico@gymflow.test'});
  });

  test('verifie l email avec le code recu', () async {
    await api.verifyEmail(code: 'ABCD1234');

    expect(server.lastMethod, 'POST');
    expect(server.lastPath, 'auth/verify-email');
    expect(server.lastData, {'code': 'ABCD1234'});
  });

  test('change le mot de passe et remplace les jetons', () async {
    server.responseStatus = 200;
    server.responseBody =
        '{"accessToken":"new-access","tokenType":"Bearer","expiresInSeconds":86400,'
        '"refreshToken":"new-refresh","refreshExpiresInSeconds":2592000,'
        '"userId":"user-1","email":"nico@gymflow.test",'
        '"profileCompleted":true,"emailVerified":true}';
    final tokenStore = AuthTokenStore();
    api = PulseTrackApi(
      config: const ApiConfig(baseUrl: 'https://exemple.test/api/v1'),
      dio: dio,
      tokenStore: tokenStore,
    );

    await api.changePassword(
      currentPassword: 'ancien123',
      newPassword: 'nouveau123',
    );

    expect(server.lastMethod, 'POST');
    expect(server.lastPath, 'me/password');
    expect(server.lastData, {
      'currentPassword': 'ancien123',
      'newPassword': 'nouveau123',
    });
    expect(tokenStore.accessToken, 'new-access');
    expect(tokenStore.refreshToken, 'new-refresh');
    expect(tokenStore.emailVerified, isTrue);
  });

  test('supprime le compte avec le mot de passe', () async {
    await api.deleteAccount(password: 'secret123');

    expect(server.lastMethod, 'DELETE');
    expect(server.lastPath, 'me');
    expect(server.lastData, {'password': 'secret123'});
  });
}

class _RecordingServer implements HttpClientAdapter {
  String? lastMethod;
  String? lastPath;
  Object? lastData;
  int responseStatus = 204;
  String responseBody = '';

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastMethod = options.method;
    lastPath = options.path;
    lastData = options.data;
    return ResponseBody.fromString(
      responseBody,
      responseStatus,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
