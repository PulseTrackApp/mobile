enum ApiSportType {
  run('RUN'),
  ride('RIDE'),
  walk('WALK'),
  other('OTHER');

  const ApiSportType(this.value);

  final String value;
}

enum ApiStatsPeriod {
  week('WEEK'),
  month('MONTH'),
  year('YEAR'),
  lifetime('LIFETIME');

  const ApiStatsPeriod(this.value);

  final String value;
}

enum ApiCoachingTone {
  encouraging('ENCOURAGING'),
  factual('FACTUAL'),
  demanding('DEMANDING');

  const ApiCoachingTone(this.value);

  final String value;
}
