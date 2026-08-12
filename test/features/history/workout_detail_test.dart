import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_flutter/features/history/models/workout_detail.dart';

void main() {
  test('lit une seance detaillee avec son trace GPS', () {
    final workout = WorkoutDetail.fromJson({
      'summary': {
        'id': 'workout-1',
        'sportType': 'RUN',
        'startedAt': '2026-08-11T16:00:00Z',
        'endedAt': '2026-08-11T16:30:00Z',
        'movingDurationSeconds': 1800,
        'distanceMeters': 5000,
        'averagePaceSecondsPerKm': 360,
        'averageSpeedKmh': 10,
        'maxSpeedKmh': 14,
        'elevationGainMeters': 20,
        'caloriesBurned': 320,
        'perceivedEffort': 7,
        'feeling': 'GOOD',
        'note': 'Bonne sortie.',
      },
      'gpsPoints': [
        {
          'position': 0,
          'latitude': 12.371,
          'longitude': -1.52,
          'speed': 2.5,
          'recordedAt': '2026-08-11T16:00:00Z',
        },
        {
          'position': 1,
          'latitude': 12.372,
          'longitude': -1.521,
          'speed': 3.2,
          'recordedAt': '2026-08-11T16:01:00Z',
        },
      ],
    });

    expect(workout.id, 'workout-1');
    expect(workout.hasRoute, isTrue);
    expect(workout.routePoints, hasLength(2));
    expect(workout.effectivePaceSecondsPerKm, 360);
    expect(workout.effectiveMaxSpeedKmh, 14);
  });

  test(
    'reprend le pic depuis les vitesses GPS si le resume ne le fournit pas',
    () {
      final workout = WorkoutDetail.fromJson({
        'id': 'workout-2',
        'sportType': 'WALK',
        'movingDurationSeconds': 600,
        'distanceMeters': 1000,
        'gpsPoints': [
          {'latitude': 12.371, 'longitude': -1.52, 'speed': 1.2},
          {'latitude': 12.372, 'longitude': -1.521, 'speed': 2.0},
        ],
      });

      expect(workout.effectiveAverageSpeedKmh, 6);
      expect(workout.effectivePaceSecondsPerKm, 600);
      expect(workout.effectiveMaxSpeedKmh, 7.2);
    },
  );
}
