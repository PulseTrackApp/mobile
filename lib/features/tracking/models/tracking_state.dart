import 'package:latlong2/latlong.dart';

import 'tracking_point.dart';

enum TrackingStatus { idle, locating, running, paused }

class TrackingState {
  const TrackingState({
    required this.status,
    required this.elapsed,
    required this.distanceMeters,
    required this.elevationGainMeters,
    required this.currentSpeedMps,
    required this.points,
  });

  factory TrackingState.idle() {
    return const TrackingState(
      status: TrackingStatus.idle,
      elapsed: Duration.zero,
      distanceMeters: 0,
      elevationGainMeters: 0,
      currentSpeedMps: 0,
      points: [],
    );
  }

  final TrackingStatus status;
  final Duration elapsed;
  final double distanceMeters;
  final double elevationGainMeters;
  final double currentSpeedMps;
  final List<TrackingPoint> points;

  bool get hasStarted =>
      status != TrackingStatus.idle || elapsed > Duration.zero || points.isNotEmpty;

  double get currentSpeedKmh => currentSpeedMps <= 0 ? 0 : currentSpeedMps * 3.6;

  double get averageSpeedKmh {
    final hours = elapsed.inSeconds / 3600;
    if (hours <= 0) return 0;
    return (distanceMeters / 1000) / hours;
  }

  int get paceSecondsPerKm {
    if (distanceMeters <= 0 || elapsed.inSeconds <= 0) return 0;
    return (elapsed.inSeconds / (distanceMeters / 1000)).round();
  }

  List<LatLng> get routePoints {
    return points.map((point) => point.latLng).toList(growable: false);
  }

  TrackingState copyWith({
    TrackingStatus? status,
    Duration? elapsed,
    double? distanceMeters,
    double? elevationGainMeters,
    double? currentSpeedMps,
    List<TrackingPoint>? points,
  }) {
    return TrackingState(
      status: status ?? this.status,
      elapsed: elapsed ?? this.elapsed,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      elevationGainMeters: elevationGainMeters ?? this.elevationGainMeters,
      currentSpeedMps: currentSpeedMps ?? this.currentSpeedMps,
      points: points ?? this.points,
    );
  }
}
