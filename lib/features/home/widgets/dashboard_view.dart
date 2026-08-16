import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_settings_controller.dart';
import '../../../core/api/api_contract.dart';
import '../../../core/api/api_formatters.dart';
import '../../../core/api/api_providers.dart';
import '../../../core/modules/app_module.dart';
import '../../../core/modules/module_access_controller.dart';
import '../../../core/modules/module_providers.dart';
import '../../../core/ui/app_refresh_scroll_view.dart';
import '../../../core/ui/app_top_bar.dart';
import '../../../core/ui/current_user_summary.dart';
import '../../../core/user/current_user_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../menu/screens/menu_screen.dart';
import '../../pricing/widgets/update_available_banner.dart';
import '../../tracking/models/sport_mode.dart';
import 'personal_progress_card.dart';
import 'sport_picker.dart';
import 'start_workout_card.dart';
import 'today_metrics.dart';
import 'week_calendar_card.dart';
import 'weekly_target_card.dart';

class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({
    super.key,
    required this.selectedSport,
    required this.onSportChanged,
    required this.onStartWorkout,
  });

  final SportMode selectedSport;
  final ValueChanged<SportMode> onSportChanged;
  final VoidCallback onStartWorkout;

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView> {
  Future<_DashboardData>? _future;
  String? _moduleAccessSignature;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokenStore = ref.watch(authTokenStoreProvider);
    final moduleAccess = ref.watch(moduleAccessControllerProvider).state;
    final isAuthenticated = tokenStore.isAuthenticated;
    final fallbackWeeklyTargetKm = AppSettingsScope.of(context).weeklyTargetKm;
    if (isAuthenticated && !moduleAccess.isLoading) {
      final signature = _signature(moduleAccess, widget.selectedSport);
      if (_moduleAccessSignature != signature) {
        _moduleAccessSignature = signature;
        _future = null;
      }
      _future ??= _loadDashboard(
        moduleAccess,
        fallbackWeeklyTargetKm,
        l10n,
        widget.selectedSport,
      );
    } else {
      _moduleAccessSignature = null;
      _future = null;
    }
    final workoutsEnabled = moduleAccess.isEnabled(AppModule.workouts);

    return AppRefreshScrollView(
      onRefresh: _refresh,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTopBar(
            trailing: IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const Scaffold(
                      body: SafeArea(child: MenuScreen(showCloseButton: true)),
                    ),
                  ),
                );
              },
              tooltip: l10n.openMenu,
              icon: const Icon(Icons.menu_rounded),
            ),
          ),
          const SizedBox(height: 18),
          const UpdateAvailableBanner(),
          const CurrentUserSummary(),
          const SizedBox(height: 24),
          Text(
            l10n.readyForNextSession,
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 18),
          SportPicker(
            selectedSport: widget.selectedSport,
            onChanged: widget.onSportChanged,
          ),
          const SizedBox(height: 18),
          StartWorkoutCard(
            selectedSport: widget.selectedSport,
            locked: !workoutsEnabled,
            onStartWorkout: workoutsEnabled ? widget.onStartWorkout : null,
          ),
          const SizedBox(height: 18),
          if (!isAuthenticated)
            const TodayMetrics()
          else
            FutureBuilder<_DashboardData>(
              future: _future,
              builder: (context, snapshot) {
                final data = snapshot.data;
                return Column(
                  children: [
                    TodayMetrics(
                      distanceKm: formatKm(data?.distanceMeters ?? 0),
                      movingTime: formatDurationShort(
                        data?.movingDurationSeconds ?? 0,
                        l10n,
                      ),
                      pace: data == null || data.distanceMeters <= 0
                          ? l10n.emptyPace
                          : formatPace(
                              (data.movingDurationSeconds /
                                      (data.distanceMeters / 1000))
                                  .round(),
                              l10n,
                            ),
                    ),
                    if (snapshot.hasError) ...[
                      const SizedBox(height: 10),
                      Text(
                        l10n.apiUnexpectedError,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                );
              },
            ),
          const SizedBox(height: 18),
          isAuthenticated
              ? FutureBuilder<_DashboardData>(
                  future: _future,
                  builder: (context, snapshot) {
                    final data = snapshot.data;
                    return WeekCalendarCard(
                      days: data?.weekDays ?? const [],
                      activeDayCount: data?.activeDayCount ?? 0,
                      streak: data?.activeDayStreak ?? 0,
                      best: data?.bestEffort,
                    );
                  },
                )
              : const WeekCalendarCard(),
          const SizedBox(height: 18),
          isAuthenticated
              ? FutureBuilder<_DashboardData>(
                  future: _future,
                  builder: (context, snapshot) {
                    final data = snapshot.data;
                    return WeeklyTargetCard(
                      progressLabel: data?.goalLabel,
                      progress: data?.goalProgress ?? 0,
                      appreciation: data?.goalAppreciation,
                    );
                  },
                )
              : const WeeklyTargetCard(),
          const SizedBox(height: 18),
          isAuthenticated
              ? FutureBuilder<_DashboardData>(
                  future: _future,
                  builder: (context, snapshot) {
                    final data = snapshot.data;
                    return PersonalProgressCard(
                      calories: '${data?.caloriesBurned ?? 0} kcal',
                      currentWeight: data?.currentWeightKg == null
                          ? '-- kg'
                          : '${data!.currentWeightKg!.toStringAsFixed(1)} kg',
                      coachPreview: data?.coachPreview,
                      coachStatus:
                          data?.coachStatus ?? CoachPreviewStatus.checking,
                    );
                  },
                )
              : const PersonalProgressCard(),
        ],
      ),
    );
  }

  Future<_DashboardData> _loadDashboard(
    ModuleAccessState moduleAccess,
    int fallbackWeeklyTargetKm,
    AppLocalizations l10n,
    SportMode sport,
  ) async {
    final api = ref.read(pulseTrackApiProvider);
    final coachEnabled = moduleAccess.isEnabled(AppModule.coach);
    final results = await Future.wait<Object?>([
      moduleAccess.isEnabled(AppModule.weeklySummary)
          ? _ignoreDashboardError(
              api.getWeeklySummary(zone: gymFlowDefaultZone),
            )
          : Future<Map<String, dynamic>>.value(const {}),
      _ignoreDashboardError(
        api.getStats(period: ApiStatsPeriod.week, zone: gymFlowDefaultZone),
      ),
      moduleAccess.isEnabled(AppModule.goals)
          ? _ignoreDashboardError(api.getGoals())
          : Future<List<Map<String, dynamic>>>.value(const []),
      moduleAccess.isEnabled(AppModule.bodyCheckins)
          ? api.getBodyProgress()
          : Future<Map<String, dynamic>>.value(const {}),
      coachEnabled
          ? _ignoreCoachError(api.getCoachSettings())
          : Future<Map<String, dynamic>?>.value(null),
      coachEnabled
          ? _ignoreCoachError(api.getLatestCoachMessage())
          : Future<Map<String, dynamic>?>.value(null),
      // Les records vivent sous le module des seances : les demander sans lui
      // rapporterait un refus de module, pas une liste vide.
      moduleAccess.isEnabled(AppModule.workouts)
          ? _ignoreDashboardError(api.getRecords(sport: sport.apiSportType))
          : Future<List<Map<String, dynamic>>>.value(const []),
    ]);

    final summary = (results[0] as Map<String, dynamic>?) ?? const {};
    final weekStats = results[1] as Map<String, dynamic>?;
    final activeGoals = (results[2] as List<Map<String, dynamic>>?) ?? const [];
    final body = results[3] as Map<String, dynamic>;
    final coachSettings = results[4] as Map<String, dynamic>?;
    final coach = results[5] as Map<String, dynamic>?;
    final records = (results[6] as List<Map<String, dynamic>>?) ?? const [];
    final summaryTotals = jsonMap(summary, 'totals') ?? summary;
    final statsTotals = jsonMap(weekStats, 'totals') ?? weekStats;
    final goals = jsonList(summary, 'goals');
    final firstGoal =
        _weeklyDistanceGoal(goals) ?? _weeklyDistanceGoal(activeGoals);
    final weeklyDistanceMeters = _firstPositiveDouble([
      jsonDouble(summaryTotals, 'distanceMeters'),
      jsonDouble(summary, 'distanceMeters'),
      jsonDouble(statsTotals, 'distanceMeters'),
      _currentGoalDistanceMeters(firstGoal),
    ]);
    final movingDurationSeconds = _firstPositiveInt([
      jsonInt(summaryTotals, 'movingDurationSeconds'),
      jsonInt(summary, 'movingDurationSeconds'),
      jsonInt(statsTotals, 'movingDurationSeconds'),
    ]);
    final caloriesBurned = _firstPositiveInt([
      jsonInt(summaryTotals, 'caloriesBurned'),
      jsonInt(summary, 'caloriesBurned'),
      jsonInt(statsTotals, 'caloriesBurned'),
    ]);
    final currentValue = firstGoal == null
        ? weeklyDistanceMeters / 1000
        : jsonDouble(firstGoal, 'currentValue');
    final targetValue = firstGoal == null
        ? fallbackWeeklyTargetKm.toDouble()
        : jsonDouble(firstGoal, 'targetValue');
    final unit = jsonString(firstGoal, 'unit') ?? '';
    final completionPercent = firstGoal == null
        ? (fallbackWeeklyTargetKm <= 0
              ? 0.0
              : weeklyDistanceMeters / (fallbackWeeklyTargetKm * 1000))
        : jsonDouble(firstGoal, 'completionPercent') / 100;

    return _DashboardData(
      distanceMeters: weeklyDistanceMeters,
      movingDurationSeconds: movingDurationSeconds,
      caloriesBurned: caloriesBurned,
      goalProgress: completionPercent,
      goalLabel: firstGoal == null
          ? '${formatKm(weeklyDistanceMeters)} / $fallbackWeeklyTargetKm ${l10n.kilometersUnit}'
          : '${currentValue.toStringAsFixed(1)} / ${targetValue.toStringAsFixed(1)} $unit',
      goalAppreciation: _goalAppreciation(
        l10n: l10n,
        progress: completionPercent,
        currentKm: currentValue,
        targetKm: targetValue,
      ),
      currentWeightKg: jsonDouble(body, 'currentWeightKg') == 0
          ? null
          : jsonDouble(body, 'currentWeightKg'),
      coachPreview: jsonString(coach, 'content'),
      coachStatus: _coachStatus(coachEnabled, coachSettings),
      weekDays: _weekDays(summary),
      activeDayStreak: jsonInt(summary, 'activeDayStreak'),
      bestEffort: _bestEffort(records, l10n),
    );
  }

  /// Les sept jours du bilan hebdomadaire.
  ///
  /// Le serveur les renvoie toujours tous, du lundi au dimanche, jours vides
  /// compris. On ne filtre donc rien : c'est justement l'absence de sport qui
  /// doit se voir.
  List<WeekDay> _weekDays(Map<String, dynamic> summary) {
    final days = jsonList(summary, 'days');
    final parsed = <WeekDay>[];
    for (final day in days) {
      final date = DateTime.tryParse(jsonString(day, 'date') ?? '');
      if (date == null) continue;
      parsed.add(
        WeekDay(
          date: date,
          sessionCount: jsonInt(day, 'sessionCount'),
          distanceMeters: jsonDouble(day, 'distanceMeters'),
        ),
      );
    }
    return parsed;
  }

  /// Le record a mettre en avant pour le sport affiche.
  ///
  /// La plus longue sortie d'abord : c'est le chiffre qu'on retient d'une
  /// pratique. A defaut la meilleure allure, puis le premier record venu — mieux
  /// vaut un record moins parlant que pas de record du tout.
  ///
  /// Le libelle vient du serveur ; seule la valeur est mise en forme ici, parce
  /// que son unite depend de la categorie et que le serveur envoie un nombre brut.
  BestEffort? _bestEffort(
    List<Map<String, dynamic>> sportRecords,
    AppLocalizations l10n,
  ) {
    if (sportRecords.isEmpty) return null;
    final entries = jsonList(sportRecords.first, 'records');
    if (entries.isEmpty) return null;

    Map<String, dynamic>? pick(String kind) {
      for (final entry in entries) {
        if (jsonString(entry, 'kind') == kind) return entry;
      }
      return null;
    }

    final record =
        pick('LONGEST_DISTANCE') ??
        pick('BEST_AVERAGE_PACE') ??
        pick('LONGEST_MOVING_DURATION') ??
        entries.first;

    final value = jsonDouble(record, 'value');
    final label = jsonString(record, 'label') ?? '';
    final formatted = switch (jsonString(record, 'unit')) {
      'm' => formatKm(value),
      's' => formatDurationShort(value.round(), l10n),
      's/km' => formatPace(value.round(), l10n),
      _ => value.toStringAsFixed(0),
    };
    return BestEffort(label: label, value: formatted);
  }

  Future<void> _refresh() async {
    final tokenStore = ref.read(authTokenStoreProvider);
    if (!tokenStore.isAuthenticated) return;

    await ref.read(moduleAccessControllerProvider).refresh();
    ref.invalidate(currentUserProvider);
    if (!mounted) return;

    final moduleAccess = ref.read(moduleAccessControllerProvider).state;
    if (moduleAccess.isLoading) return;

    final future = _loadDashboard(
      moduleAccess,
      AppSettingsScope.of(context).weeklyTargetKm,
      AppLocalizations.of(context),
      widget.selectedSport,
    );
    setState(() {
      _moduleAccessSignature = _signature(moduleAccess, widget.selectedSport);
      _future = future;
    });

    try {
      await future;
    } catch (_) {
      // Le FutureBuilder affiche deja l'etat d'erreur.
    }
  }

  Future<Object?> _ignoreCoachError(Future<Object?> request) async {
    try {
      return await request;
    } catch (_) {
      return null;
    }
  }

  Future<Object?> _ignoreDashboardError(Future<Object?> request) async {
    try {
      return await request;
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic>? _weeklyDistanceGoal(List<Map<String, dynamic>> goals) {
    for (final goal in goals) {
      if (jsonString(goal, 'type') == 'WEEKLY_DISTANCE') return goal;
    }
    return goals.isEmpty ? null : goals.first;
  }

  double _currentGoalDistanceMeters(Map<String, dynamic>? goal) {
    if (goal == null || jsonString(goal, 'type') != 'WEEKLY_DISTANCE') return 0;
    final current = jsonDouble(goal, 'currentValue');
    final unit = (jsonString(goal, 'unit') ?? '').toLowerCase();
    return unit == 'm' ? current : current * 1000;
  }

  double _firstPositiveDouble(List<double> values) {
    for (final value in values) {
      if (value > 0) return value;
    }
    return 0;
  }

  int _firstPositiveInt(List<int> values) {
    for (final value in values) {
      if (value > 0) return value;
    }
    return 0;
  }

  String _goalAppreciation({
    required AppLocalizations l10n,
    required double progress,
    required double currentKm,
    required double targetKm,
  }) {
    if (targetKm <= 0) return l10n.weeklyGoalNoTarget;
    if (progress >= 1) return l10n.weeklyGoalReached;
    if (progress >= 0.75) return l10n.weeklyGoalAlmost;
    if (progress >= 0.45) return l10n.weeklyGoalStrong;
    final remaining = (targetKm - currentKm).clamp(0, targetKm).toDouble();
    return l10n.weeklyGoalRemaining('${remaining.toStringAsFixed(1)} km');
  }

  CoachPreviewStatus _coachStatus(
    bool coachEnabled,
    Map<String, dynamic>? settings,
  ) {
    if (!coachEnabled) return CoachPreviewStatus.locked;
    return jsonBool(settings, 'usable')
        ? CoachPreviewStatus.ready
        : CoachPreviewStatus.unavailable;
  }

  /// Ce qui, en changeant, oblige a recharger.
  ///
  /// Le sport en fait partie depuis que le tableau de bord affiche un record :
  /// sans lui, changer de sport laisserait la meilleure performance de la course
  /// affichee sous le velo.
  String _signature(ModuleAccessState moduleAccess, SportMode sport) {
    final modules = AppModule.values
        .map((module) => '${module.apiValue}:${moduleAccess.isEnabled(module)}')
        .join('|');
    return '$modules|sport:${sport.apiSportType.value}';
  }
}

class _DashboardData {
  const _DashboardData({
    required this.distanceMeters,
    required this.movingDurationSeconds,
    required this.caloriesBurned,
    required this.goalProgress,
    required this.goalLabel,
    required this.goalAppreciation,
    required this.currentWeightKg,
    required this.coachPreview,
    required this.coachStatus,
    required this.weekDays,
    required this.activeDayStreak,
    required this.bestEffort,
  });

  final double distanceMeters;
  final int movingDurationSeconds;
  final int caloriesBurned;
  final double goalProgress;
  final String? goalLabel;
  final String? goalAppreciation;
  final double? currentWeightKg;
  final String? coachPreview;
  final CoachPreviewStatus coachStatus;
  final List<WeekDay> weekDays;
  final int activeDayStreak;
  final BestEffort? bestEffort;

  /// Jours de la semaine ayant vu au moins une seance.
  int get activeDayCount => weekDays.where((day) => day.isActive).length;
}
