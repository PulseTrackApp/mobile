import 'package:latlong2/latlong.dart';

class WorkoutChallenge {
  const WorkoutChallenge({
    this.targetDistanceMeters = 0,
    this.targetDuration = Duration.zero,
    this.referenceRoutePoints = const [],
    this.sourceWorkoutId,
    this.sourceTitle,
    this.challengeId,
    this.routeId,
  });

  /// Défi tel que le serveur l'a enregistré.
  ///
  /// [challengeId] est ce qui permet de le régler à l'arrivée : il part avec la
  /// séance, et le serveur rend le verdict dans la même réponse. Sans lui, le
  /// défi resterait ouvert et l'appréciation ne serait jamais calculée.
  factory WorkoutChallenge.fromServer(Map<String, dynamic> json) {
    final seconds = (json['targetDurationSeconds'] as num?)?.toInt() ?? 0;
    return WorkoutChallenge(
      challengeId: json['id']?.toString(),
      routeId: json['routeId']?.toString(),
      sourceTitle: json['title']?.toString(),
      targetDistanceMeters:
          (json['targetDistanceMeters'] as num?)?.toDouble() ?? 0,
      targetDuration: Duration(seconds: seconds),
    );
  }

  factory WorkoutChallenge.distanceTime({
    required double targetDistanceMeters,
    required Duration targetDuration,
  }) {
    return WorkoutChallenge(
      targetDistanceMeters: targetDistanceMeters,
      targetDuration: targetDuration,
    );
  }

  factory WorkoutChallenge.routeReplay({
    required List<LatLng> referenceRoutePoints,
    String? sourceWorkoutId,
    String? sourceTitle,
  }) {
    return WorkoutChallenge(
      referenceRoutePoints: referenceRoutePoints,
      sourceWorkoutId: sourceWorkoutId,
      sourceTitle: sourceTitle,
    );
  }

  final double targetDistanceMeters;
  final Duration targetDuration;
  final List<LatLng> referenceRoutePoints;
  final String? sourceWorkoutId;
  final String? sourceTitle;

  /// Identifiant du defi cote serveur, quand il en vient un. Nul pour un defi
  /// improvise depuis l'ecran de course : celui-la n'est pas enregistre, et rien
  /// ne sera regle a l'arrivee.
  final String? challengeId;

  /// Parcours rejoue, quand la course reprend un circuit enregistre.
  final String? routeId;

  bool get hasDistanceTarget => targetDistanceMeters > 0;
  bool get hasTimeLimit => targetDuration > Duration.zero;
  bool get hasReferenceRoute => referenceRoutePoints.length >= 2;
  bool get isActive => hasDistanceTarget || hasReferenceRoute;

  double progressFor(double distanceMeters) {
    if (!hasDistanceTarget) return 0;
    return (distanceMeters / targetDistanceMeters).clamp(0, 1).toDouble();
  }

  Duration remainingFor(Duration elapsed) {
    if (!hasTimeLimit) return Duration.zero;
    final remaining = targetDuration - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  bool isCompletedBy({
    required double distanceMeters,
    required Duration elapsed,
  }) {
    if (!hasDistanceTarget) return false;
    if (distanceMeters < targetDistanceMeters) return false;
    return !hasTimeLimit || elapsed <= targetDuration;
  }

  bool isDeadlineMissedBy({
    required double distanceMeters,
    required Duration elapsed,
  }) {
    if (!hasDistanceTarget || !hasTimeLimit) return false;
    return elapsed > targetDuration && distanceMeters < targetDistanceMeters;
  }

  WorkoutChallenge copyWith({
    double? targetDistanceMeters,
    Duration? targetDuration,
    List<LatLng>? referenceRoutePoints,
    String? sourceWorkoutId,
    String? sourceTitle,
    String? challengeId,
    String? routeId,
  }) {
    return WorkoutChallenge(
      targetDistanceMeters: targetDistanceMeters ?? this.targetDistanceMeters,
      targetDuration: targetDuration ?? this.targetDuration,
      referenceRoutePoints: referenceRoutePoints ?? this.referenceRoutePoints,
      sourceWorkoutId: sourceWorkoutId ?? this.sourceWorkoutId,
      sourceTitle: sourceTitle ?? this.sourceTitle,
      challengeId: challengeId ?? this.challengeId,
      routeId: routeId ?? this.routeId,
    );
  }
}
