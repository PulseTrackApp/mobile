enum WorkoutShareMode {
  routeOnly,
  routeWithData;

  bool get includesData => this == routeWithData;

  String get fileSuffix => switch (this) {
    routeOnly => 'parcours',
    routeWithData => 'seance',
  };
}
