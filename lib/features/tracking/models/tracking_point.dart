import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class TrackingPoint {
  const TrackingPoint({
    required this.latitude,
    required this.longitude,
    required this.recordedAt,
    this.altitude,
    this.accuracy,
    this.speed,
  });

  factory TrackingPoint.fromPosition(Position position) {
    return TrackingPoint(
      latitude: position.latitude,
      longitude: position.longitude,
      altitude: position.altitude,
      accuracy: position.accuracy,
      speed: position.speed <= 0 ? null : position.speed,
      recordedAt: position.timestamp.toUtc(),
    );
  }

  final double latitude;
  final double longitude;
  final double? altitude;
  final double? accuracy;
  final double? speed;
  final DateTime recordedAt;

  LatLng get latLng => LatLng(latitude, longitude);

  Map<String, dynamic> toApiJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      if (altitude != null) 'altitude': altitude,
      if (accuracy != null) 'accuracy': accuracy,
      if (speed != null) 'speed': speed,
      'recordedAt': recordedAt.toIso8601String(),
    };
  }
}
