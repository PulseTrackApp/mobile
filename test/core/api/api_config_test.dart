import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_flutter/core/api/api_config.dart';

void main() {
  group('ApiConfig', () {
    test('uses GymFlow API by default', () {
      expect(
        ApiConfig.fromEnvironment().dioBaseUrl,
        'https://api.gymflow.millogo-studio.com/api/v1/',
      );
    });

    test('adds api version to a root URL', () {
      const config = ApiConfig(
        baseUrl: 'https://api.gymflow.millogo-studio.com/',
      );

      expect(
        config.dioBaseUrl,
        'https://api.gymflow.millogo-studio.com/api/v1/',
      );
    });

    test('keeps an explicit api v1 URL unchanged', () {
      const config = ApiConfig(
        baseUrl: 'https://api.gymflow.millogo-studio.com/api/v1',
      );

      expect(
        config.dioBaseUrl,
        'https://api.gymflow.millogo-studio.com/api/v1/',
      );
    });
  });
}
