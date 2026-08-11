import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Android manifest declares foreground location tracking requirements',
    () {
      final manifest = File(
        'android/app/src/main/AndroidManifest.xml',
      ).readAsStringSync();

      expect(manifest, contains('android.permission.ACCESS_FINE_LOCATION'));
      expect(manifest, contains('android.permission.ACCESS_COARSE_LOCATION'));
      expect(
        manifest,
        isNot(contains('android.permission.ACCESS_BACKGROUND_LOCATION')),
      );
      expect(manifest, contains('android.permission.FOREGROUND_SERVICE'));
      expect(
        manifest,
        contains('android.permission.FOREGROUND_SERVICE_LOCATION'),
      );
      expect(manifest, contains('android.permission.WAKE_LOCK'));
      expect(
        manifest,
        contains('com.baseflow.geolocator.GeolocatorLocationService'),
      );
      expect(manifest, contains('android:foregroundServiceType="location"'));
    },
  );
}
