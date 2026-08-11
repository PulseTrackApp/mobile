import '../../l10n/app_localizations.dart';

enum AppModule {
  workouts('WORKOUTS'),
  bodyCheckins('BODY_CHECKINS'),
  goals('GOALS'),
  stats('STATS'),
  weeklySummary('WEEKLY_SUMMARY'),
  coach('COACH'),
  export('EXPORT'),
  push('PUSH');

  const AppModule(this.apiValue);

  final String apiValue;

  static AppModule? fromApiValue(Object? value) {
    if (value == null) return null;
    final text = value.toString();
    for (final module in values) {
      if (module.apiValue == text) return module;
    }
    return null;
  }

  String label(AppLocalizations l10n) {
    return switch (this) {
      AppModule.workouts => l10n.moduleWorkouts,
      AppModule.bodyCheckins => l10n.moduleBodyCheckins,
      AppModule.goals => l10n.moduleGoals,
      AppModule.stats => l10n.moduleStats,
      AppModule.weeklySummary => l10n.moduleWeeklySummary,
      AppModule.coach => l10n.moduleCoach,
      AppModule.export => l10n.moduleExport,
      AppModule.push => l10n.modulePush,
    };
  }
}
