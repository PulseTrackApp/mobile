import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_flutter/core/api/api_config.dart';
import 'package:mobile_flutter/core/api/api_error.dart';
import 'package:mobile_flutter/core/api/pulse_track_api.dart';

void main() {
  late Dio dio;
  late _FakeServer server;
  late PulseTrackApi api;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    server = _FakeServer();
    dio = Dio(BaseOptions(baseUrl: 'https://exemple.test/api/v1/'));
    dio.httpClientAdapter = server;
    api = PulseTrackApi(
      config: const ApiConfig(baseUrl: 'https://exemple.test/api/v1'),
      dio: dio,
    );
  });

  test('lit les modules utilisateur depuis le contrat /me/modules', () async {
    server.body = '''
      {
        "modules": [
          {"module": "WORKOUTS", "enabled": true},
          {"module": "COACH", "enabled": false}
        ]
      }
    ''';

    final modules = await api.getModules();

    expect(server.lastPath, 'me/modules');
    expect(modules, hasLength(2));
    expect(modules.first['module'], 'WORKOUTS');
    expect(modules.last['enabled'], false);
  });

  test('reconnait une erreur module-locked', () {
    final problem = ApiProblem.fromJson({
      'type': 'https://pulsetrack.app/problems/module-locked',
      'title': 'Fonctionnalite non activee',
      'status': 403,
      'detail': "Le module COACH n'est pas active sur ce compte.",
      'module': 'COACH',
    });

    expect(problem.isModuleLocked, isTrue);
    expect(problem.module, 'COACH');
  });
}

class _FakeServer implements HttpClientAdapter {
  String body = '{}';
  String? lastPath;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastPath = options.path;
    return ResponseBody.fromString(
      body,
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
