import 'package:latlong2/latlong.dart';

import 'tracking_point.dart';

class TrackingSessionDraft {
  const TrackingSessionDraft({
    required this.startedAt,
    required this.endedAt,
    required this.elapsed,
    required this.distanceMeters,
    required this.elevationGainMeters,
    required this.points,
    required this.hasPause,
  });

  final DateTime startedAt;
  final DateTime endedAt;
  final Duration elapsed;
  final double distanceMeters;
  final double elevationGainMeters;
  final List<TrackingPoint> points;
  final bool hasPause;

  bool get canUploadGpsTrack => points.length >= 2;

  DateTime get apiEndedAt => startedAt.add(elapsed);

  double get averageSpeedKmh {
    final hours = elapsed.inSeconds / 3600;
    if (hours <= 0) return 0;
    return (distanceMeters / 1000) / hours;
  }

  double get maxSpeedKmh {
    final fastest = fastestPoint;
    if (fastest?.speed == null) return 0;
    return fastest!.speed! * 3.6;
  }

  TrackingPoint? get fastestPoint {
    TrackingPoint? fastest;
    var maxSpeedMps = 0.0;
    for (final point in points) {
      final speed = point.speed ?? 0;
      if (speed > maxSpeedMps) {
        maxSpeedMps = speed;
        fastest = point;
      }
    }
    return fastest;
  }

  int get paceSecondsPerKm {
    if (distanceMeters <= 0 || elapsed.inSeconds <= 0) return 0;
    return (elapsed.inSeconds / (distanceMeters / 1000)).round();
  }

  List<LatLng> get routePoints {
    return points.map((point) => point.latLng).toList(growable: false);
  }

  List<Map<String, dynamic>> get apiGpsPoints {
    if (!canUploadGpsTrack) return const [];
    return points.map((point) => point.toApiJson()).toList(growable: false);
  }
}
