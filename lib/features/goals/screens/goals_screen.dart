import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/ui/app_panel.dart';
import '../../../l10n/app_localizations.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.goalsTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.targetsHeadline,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 18),
              _GoalCard(
                icon: Icons.route_rounded,
                color: AppColors.primary,
                title: l10n.weeklyDistanceTarget,
                value: '20 km',
                progress: 0,
              ),
              const SizedBox(height: 10),
              _GoalCard(
                icon: Icons.calendar_month_rounded,
                color: AppColors.gps,
                title: l10n.weeklySessionsTarget,
                value: '0 / 4',
                progress: 0,
              ),
              const SizedBox(height: 10),
              _GoalCard(
                icon: Icons.local_fire_department_rounded,
                color: AppColors.danger,
                title: l10n.weeklyCaloriesTarget,
                value: '0 / 1800 kcal',
                progress: 0,
              ),
              const SizedBox(height: 10),
              _GoalCard(
                icon: Icons.timer_outlined,
                color: AppColors.gps,
                title: l10n.weeklyTrainingTimeTarget,
                value: '0 / 4 h',
                progress: 0,
              ),
              const SizedBox(height: 10),
              _GoalCard(
                icon: Icons.monitor_weight_outlined,
                color: AppColors.accent,
                title: l10n.weightTarget,
                value: '-- kg',
                progress: 0,
              ),
              const SizedBox(height: 10),
              _GoalCard(
                icon: Icons.speed_rounded,
                color: AppColors.primary,
                title: l10n.performanceTarget,
                value: '5 km',
                progress: 0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
    required this.progress,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String value;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(value, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Theme.of(context).colorScheme.outlineVariant,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
