import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/ui/app_metric_tile.dart';
import '../../../core/ui/app_panel.dart';
import '../../../l10n/app_localizations.dart';
import '../../tracking/models/sport_mode.dart';

class MetricHero extends StatelessWidget {
  const MetricHero({
    super.key,
    required this.selectedSport,
    required this.statusLabel,
    required this.elapsedTime,
    required this.distance,
    required this.pace,
  });

  final SportMode selectedSport;
  final String statusLabel;
  final String elapsedTime;
  final String distance;
  final String pace;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppPanel(
      color: AppColors.dark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(selectedSport.icon, color: AppColors.accent, size: 36),
              const Spacer(),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Text(
                    statusLabel,
                    style: Theme.of(
                      context,
                    ).textTheme.labelLarge?.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            elapsedTime,
            style: Theme.of(
              context,
            ).textTheme.displaySmall?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppDarkMetric(label: l10n.distance, value: distance),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppDarkMetric(label: l10n.pace, value: pace),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
