import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_flutter/features/tracking/models/calorie_estimator.dart';
import 'package:mobile_flutter/features/tracking/models/sport_mode.dart';

void main() {
  test('estimates run calories from MET, weight and active duration', () {
    final calories = estimateWorkoutCalories(
      sport: SportMode.run,
      averageSpeedKmh: 10,
      movingDuration: const Duration(minutes: 30),
      weightKg: 80,
    );

    expect(calories, 440);
  });

  test('returns zero without active duration or weight', () {
    expect(
      estimateWorkoutCalories(
        sport: SportMode.walk,
        averageSpeedKmh: 5,
        movingDuration: Duration.zero,
        weightKg: 80,
      ),
      0,
    );
    expect(
      estimateWorkoutCalories(
        sport: SportMode.ride,
        averageSpeedKmh: 20,
        movingDuration: const Duration(hours: 1),
        weightKg: 0,
      ),
      0,
    );
  });
}
