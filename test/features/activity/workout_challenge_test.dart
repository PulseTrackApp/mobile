import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_flutter/features/activity/models/workout_challenge.dart';

void main() {
  test('valide un defi distance temps atteint avant echeance', () {
    final challenge = WorkoutChallenge.distanceTime(
      targetDistanceMeters: 5000,
      targetDuration: const Duration(minutes: 30),
    );

    expect(challenge.progressFor(2500), 0.5);
    expect(
      challenge.isCompletedBy(
        distanceMeters: 5100,
        elapsed: const Duration(minutes: 29),
      ),
      isTrue,
    );
  });

  test('detecte une echeance ratee quand la distance manque', () {
    final challenge = WorkoutChallenge.distanceTime(
      targetDistanceMeters: 5000,
      targetDuration: const Duration(minutes: 30),
    );

    expect(
      challenge.isDeadlineMissedBy(
        distanceMeters: 4200,
        elapsed: const Duration(minutes: 31),
      ),
      isTrue,
    );
  });
}
