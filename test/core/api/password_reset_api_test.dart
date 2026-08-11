import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_flutter/core/api/api_config.dart';
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
}

class _RecordingServer implements HttpClientAdapter {
  String? lastMethod;
  String? lastPath;
  Object? lastData;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastMethod = options.method;
    lastPath = options.path;
    lastData = options.data;
    return ResponseBody.fromString('', 204);
  }

  @override
  void close({bool force = false}) {}
}
