import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/ui/app_panel.dart';
import '../../../core/ui/app_stat_row.dart';
import '../../../l10n/app_localizations.dart';
import '../../tracking/models/sport_mode.dart';

class WorkoutHistoryScreen extends StatelessWidget {
  const WorkoutHistoryScreen({super.key});

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
              AppStatRow(
                icon: Icons.local_fire_department_rounded,
                color: AppColors.danger,
                label: l10n.caloriesBurned,
                value: '0 kcal',
              ),
              const SizedBox(height: 10),
              AppStatRow(
                icon: Icons.route_rounded,
                color: AppColors.gps,
                label: l10n.totalDistance,
                value: '0.00 km',
              ),
              const SizedBox(height: 10),
              AppStatRow(
                icon: Icons.timer_outlined,
                color: AppColors.accent,
                label: l10n.movingTime,
                value: '0 h',
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
                              selected: false,
                              onSelected: (_) {},
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
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
                    Text(
                      l10n.noSessionsYet,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
