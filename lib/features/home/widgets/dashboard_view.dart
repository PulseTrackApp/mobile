import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_formatters.dart';
import '../../../core/api/api_providers.dart';
import '../../../core/modules/app_module.dart';
import '../../../core/modules/module_access_controller.dart';
import '../../../core/modules/module_providers.dart';
import '../../../core/ui/app_top_bar.dart';
import '../../../core/ui/current_user_summary.dart';
import '../../../l10n/app_localizations.dart';
import '../../menu/screens/menu_screen.dart';
import '../../tracking/models/sport_mode.dart';
import 'personal_progress_card.dart';
import 'sport_picker.dart';
import 'start_workout_card.dart';
import 'today_metrics.dart';
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
    if (isAuthenticated && !moduleAccess.isLoading) {
      final signature = _signature(moduleAccess);
      if (_moduleAccessSignature != signature) {
        _moduleAccessSignature = signature;
        _future = null;
      }
      _future ??= _loadDashboard(moduleAccess);
    } else {
      _moduleAccessSignature = null;
      _future = null;
    }
    final workoutsEnabled = moduleAccess.isEnabled(AppModule.workouts);

    return SingleChildScrollView(
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
                    return WeeklyTargetCard(
                      progressLabel: data?.goalLabel,
                      progress: data?.goalProgress ?? 0,
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

  Future<_DashboardData> _loadDashboard(ModuleAccessState moduleAccess) async {
    final api = ref.read(pulseTrackApiProvider);
    final coachEnabled = moduleAccess.isEnabled(AppModule.coach);
    final results = await Future.wait<Object?>([
      moduleAccess.isEnabled(AppModule.weeklySummary)
          ? api.getWeeklySummary(zone: gymFlowDefaultZone)
          : Future<Map<String, dynamic>>.value(const {}),
      moduleAccess.isEnabled(AppModule.bodyCheckins)
          ? api.getBodyProgress()
          : Future<Map<String, dynamic>>.value(const {}),
      coachEnabled
          ? _ignoreCoachError(api.getCoachSettings())
          : Future<Map<String, dynamic>?>.value(null),
      coachEnabled
          ? _ignoreCoachError(api.getLatestCoachMessage())
          : Future<Map<String, dynamic>?>.value(null),
    ]);

    final summary = results[0] as Map<String, dynamic>;
    final body = results[1] as Map<String, dynamic>;
    final coachSettings = results[2] as Map<String, dynamic>?;
    final coach = results[3] as Map<String, dynamic>?;
    final goals = jsonList(summary, 'goals');
    final firstGoal = goals.isEmpty ? null : goals.first;
    final currentValue = firstGoal == null
        ? 0.0
        : jsonDouble(firstGoal, 'currentValue');
    final targetValue = firstGoal == null
        ? 0.0
        : jsonDouble(firstGoal, 'targetValue');
    final unit = jsonString(firstGoal, 'unit') ?? '';
    final completionPercent = firstGoal == null
        ? 0.0
        : jsonDouble(firstGoal, 'completionPercent') / 100;

    return _DashboardData(
      distanceMeters: jsonDouble(summary, 'distanceMeters'),
      movingDurationSeconds: jsonInt(summary, 'movingDurationSeconds'),
      caloriesBurned: jsonInt(summary, 'caloriesBurned'),
      goalProgress: completionPercent,
      goalLabel: firstGoal == null
          ? null
          : '${currentValue.toStringAsFixed(1)} / ${targetValue.toStringAsFixed(1)} $unit',
      currentWeightKg: jsonDouble(body, 'currentWeightKg') == 0
          ? null
          : jsonDouble(body, 'currentWeightKg'),
      coachPreview: jsonString(coach, 'content'),
      coachStatus: _coachStatus(coachEnabled, coachSettings),
    );
  }

  Future<Object?> _ignoreCoachError(Future<Object?> request) async {
    try {
      return await request;
    } catch (_) {
      return null;
    }
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

  String _signature(ModuleAccessState moduleAccess) {
    return AppModule.values
        .map((module) => '${module.apiValue}:${moduleAccess.isEnabled(module)}')
        .join('|');
  }
}

class _DashboardData {
  const _DashboardData({
    required this.distanceMeters,
    required this.movingDurationSeconds,
    required this.caloriesBurned,
    required this.goalProgress,
    required this.goalLabel,
    required this.currentWeightKg,
    required this.coachPreview,
    required this.coachStatus,
  });

  final double distanceMeters;
  final int movingDurationSeconds;
  final int caloriesBurned;
  final double goalProgress;
  final String? goalLabel;
  final double? currentWeightKg;
  final String? coachPreview;
  final CoachPreviewStatus coachStatus;
}
