import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_contract.dart';
import '../../../core/api/api_formatters.dart';
import '../../../core/api/api_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/app_panel.dart';
import '../../../core/ui/app_stat_row.dart';
import '../../../l10n/app_localizations.dart';
import '../../tracking/models/sport_mode.dart';

class WorkoutHistoryScreen extends ConsumerStatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  ConsumerState<WorkoutHistoryScreen> createState() =>
      _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends ConsumerState<WorkoutHistoryScreen> {
  SportMode? _selectedSport;
  Future<Map<String, dynamic>>? _future;

  @override
  void initState() {
    super.initState();
    _future = _loadWorkouts();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.workoutHistoryTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.sessionsOverview,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 18),
              AppPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.filters,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: SportMode.values
                          .map(
                            (sport) => FilterChip(
                              label: Text(sport.label(l10n)),
                              selected: _selectedSport == sport,
                              onSelected: (_) {
                                setState(() {
                                  _selectedSport = _selectedSport == sport
                                      ? null
                                      : sport;
                                  _future = _loadWorkouts();
                                });
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              FutureBuilder<Map<String, dynamic>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return AppPanel(
                      child: Text(
                        l10n.apiUnexpectedError,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  }

                  final sessions = pageContent(snapshot.data);
                  final calories = sessions.fold<int>(
                    0,
                    (sum, workout) => sum + jsonInt(workout, 'caloriesBurned'),
                  );
                  final distance = sessions.fold<double>(
                    0,
                    (sum, workout) =>
                        sum + jsonDouble(workout, 'distanceMeters'),
                  );
                  final movingSeconds = sessions.fold<int>(
                    0,
                    (sum, workout) =>
                        sum + jsonInt(workout, 'movingDurationSeconds'),
                  );

                  return Column(
                    children: [
                      AppStatRow(
                        icon: Icons.local_fire_department_rounded,
                        color: AppColors.danger,
                        label: l10n.caloriesBurned,
                        value: '$calories kcal',
                      ),
                      const SizedBox(height: 10),
                      AppStatRow(
                        icon: Icons.route_rounded,
                        color: AppColors.gps,
                        label: l10n.totalDistance,
                        value: formatMetersAsKm(distance, l10n),
                      ),
                      const SizedBox(height: 10),
                      AppStatRow(
                        icon: Icons.timer_outlined,
                        color: AppColors.accent,
                        label: l10n.movingTime,
                        value: formatDurationShort(movingSeconds, l10n),
                      ),
                      const SizedBox(height: 18),
                      AppPanel(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.recentSessions,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 10),
                            if (sessions.isEmpty)
                              Text(
                                l10n.noSessionsYet,
                                style: Theme.of(context).textTheme.bodyMedium,
                              )
                            else
                              ...sessions.map((workout) {
                                return _WorkoutListItem(workout: workout);
                              }),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _loadWorkouts() {
    return ref
        .read(pulseTrackApiProvider)
        .listWorkouts(
          sport: _selectedSport == null
              ? null
              : ApiSportType.values.firstWhere(
                  (sport) => sport.value == _selectedSport!.apiValue,
                ),
        );
  }
}

class _WorkoutListItem extends StatelessWidget {
  const _WorkoutListItem({required this.workout});

  final Map<String, dynamic> workout;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sport = jsonString(workout, 'sportType') ?? '';
    final startedAt = jsonString(workout, 'startedAt') ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.directions_run_rounded, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sport, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(startedAt, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Text(
            formatMetersAsKm(jsonDouble(workout, 'distanceMeters'), l10n),
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ],
      ),
    );
  }
}
