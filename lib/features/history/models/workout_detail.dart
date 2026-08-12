import 'package:latlong2/latlong.dart';

import '../../../core/api/api_formatters.dart';

class WorkoutDetail {
  const WorkoutDetail({
    required this.id,
    required this.sportType,
    required this.startedAt,
    required this.endedAt,
    required this.durationSeconds,
    required this.movingDurationSeconds,
    required this.distanceMeters,
    required this.averagePaceSecondsPerKm,
    required this.averageSpeedKmh,
    required this.maxSpeedKmh,
    required this.elevationGainMeters,
    required this.caloriesBurned,
    required this.perceivedEffort,
    required this.feeling,
    required this.note,
    required this.gpsPoints,
  });

  factory WorkoutDetail.fromJson(Map<String, dynamic> json) {
    final summary = jsonMap(json, 'summary') ?? json;
    final gpsPoints = jsonList(json, 'gpsPoints')
        .map(WorkoutGpsPoint.fromJson)
        .where((point) => point.hasPosition)
        .toList(growable: false);

    return WorkoutDetail(
      id: jsonString(summary, 'id') ?? '',
      sportType: jsonString(summary, 'sportType') ?? '',
      startedAt: _dateTimeOrNull(jsonString(summary, 'startedAt')),
      endedAt: _dateTimeOrNull(jsonString(summary, 'endedAt')),
      durationSeconds: jsonInt(summary, 'durationSeconds'),
      movingDurationSeconds: jsonInt(summary, 'movingDurationSeconds'),
      distanceMeters: jsonDouble(summary, 'distanceMeters'),
      averagePaceSecondsPerKm: jsonInt(summary, 'averagePaceSecondsPerKm'),
      averageSpeedKmh: jsonDouble(summary, 'averageSpeedKmh'),
      maxSpeedKmh: jsonDouble(summary, 'maxSpeedKmh'),
      elevationGainMeters: jsonDouble(summary, 'elevationGainMeters'),
      caloriesBurned: jsonInt(summary, 'caloriesBurned'),
      perceivedEffort: jsonInt(summary, 'perceivedEffort'),
      feeling: jsonString(summary, 'feeling'),
      note: jsonString(summary, 'note'),
      gpsPoints: gpsPoints,
    );
  }

  final String id;
  final String sportType;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final int durationSeconds;
  final int movingDurationSeconds;
  final double distanceMeters;
  final int averagePaceSecondsPerKm;
  final double averageSpeedKmh;
  final double maxSpeedKmh;
  final double elevationGainMeters;
  final int caloriesBurned;
  final int perceivedEffort;
  final String? feeling;
  final String? note;
  final List<WorkoutGpsPoint> gpsPoints;

  Duration get movingDuration {
    if (movingDurationSeconds > 0) {
      return Duration(seconds: movingDurationSeconds);
    }
    if (durationSeconds > 0) {
      return Duration(seconds: durationSeconds);
    }
    final started = startedAt;
    final ended = endedAt;
    if (started != null && ended != null && ended.isAfter(started)) {
      return ended.difference(started);
    }
    return Duration.zero;
  }

  int get effectivePaceSecondsPerKm {
    if (averagePaceSecondsPerKm > 0) return averagePaceSecondsPerKm;
    if (distanceMeters <= 0 || movingDuration.inSeconds <= 0) return 0;
    return (movingDuration.inSeconds / (distanceMeters / 1000)).round();
  }

  double get effectiveAverageSpeedKmh {
    if (averageSpeedKmh > 0) return averageSpeedKmh;
    final hours = movingDuration.inSeconds / 3600;
    if (hours <= 0) return 0;
    return (distanceMeters / 1000) / hours;
  }

  double get effectiveMaxSpeedKmh {
    if (maxSpeedKmh > 0) return maxSpeedKmh;
    return _maxSensorSpeedMps() * 3.6;
  }

  WorkoutGpsPoint? get fastestPoint {
    WorkoutGpsPoint? fastest;
    var maxSpeedMps = 0.0;
    for (final point in gpsPoints) {
      if (point.speedMps > maxSpeedMps) {
        maxSpeedMps = point.speedMps;
        fastest = point;
      }
    }
    return fastest;
  }

  double _maxSensorSpeedMps() {
    var maxSpeedMps = 0.0;
    for (final point in gpsPoints) {
      if (point.speedMps > maxSpeedMps) maxSpeedMps = point.speedMps;
    }
    return maxSpeedMps;
  }

  List<LatLng> get routePoints {
    return gpsPoints.map((point) => point.latLng).toList(growable: false);
  }

  bool get hasRoute => routePoints.length >= 2;
}

class WorkoutGpsPoint {
  const WorkoutGpsPoint({
    required this.position,
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.accuracy,
    required this.speedMps,
    required this.recordedAt,
  });

  factory WorkoutGpsPoint.fromJson(Map<String, dynamic> json) {
    return WorkoutGpsPoint(
      position: jsonInt(json, 'position'),
      latitude: jsonDouble(json, 'latitude'),
      longitude: jsonDouble(json, 'longitude'),
      altitude: jsonDouble(json, 'altitude'),
      accuracy: jsonDouble(json, 'accuracy'),
      speedMps: jsonDouble(json, 'speed'),
      recordedAt: _dateTimeOrNull(jsonString(json, 'recordedAt')),
    );
  }

  final int position;
  final double latitude;
  final double longitude;
  final double altitude;
  final double accuracy;
  final double speedMps;
  final DateTime? recordedAt;

  bool get hasPosition {
    return latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }

  double get speedKmh => speedMps * 3.6;

  LatLng get latLng => LatLng(latitude, longitude);
}

DateTime? _dateTimeOrNull(String? value) {
  if (value == null || value.isEmpty) return null;
  return DateTime.tryParse(value)?.toLocal();
}
