import 'sport_mode.dart';

int estimateWorkoutCalories({
  required SportMode sport,
  required double averageSpeedKmh,
  required Duration movingDuration,
  required double weightKg,
}) {
  final movingHours = movingDuration.inSeconds / 3600;
  if (movingHours <= 0 || weightKg <= 0) return 0;

  return (_metFor(sport, averageSpeedKmh) * weightKg * movingHours).round();
}

double _metFor(SportMode sport, double speedKmh) {
  return switch (sport) {
    SportMode.walk => _walkMet(speedKmh),
    SportMode.run => _runMet(speedKmh),
    SportMode.ride => _rideMet(speedKmh),
  };
}

double _walkMet(double speedKmh) {
  if (speedKmh < 4.0) return 2.8;
  if (speedKmh < 5.5) return 3.5;
  if (speedKmh < 6.5) return 5.0;
  return 6.3;
}

double _runMet(double speedKmh) {
  if (speedKmh < 8.0) return 6.0;
  if (speedKmh < 9.7) return 9.8;
  if (speedKmh < 11.3) return 11.0;
  if (speedKmh < 12.9) return 11.8;
  if (speedKmh < 14.5) return 12.8;
  return 14.5;
}

double _rideMet(double speedKmh) {
  if (speedKmh < 16.0) return 4.0;
  if (speedKmh < 19.3) return 6.8;
  if (speedKmh < 22.5) return 8.0;
  if (speedKmh < 25.7) return 10.0;
  return 12.0;
}
