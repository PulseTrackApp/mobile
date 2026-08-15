import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/ui/app_panel.dart';
import '../../../l10n/app_localizations.dart';

class WeeklyTargetCard extends StatelessWidget {
  const WeeklyTargetCard({
    super.key,
    this.progressLabel,
    this.progress = 0,
    this.appreciation,
  });

  final String? progressLabel;
  final double progress;
  final String? appreciation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flag_rounded, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.weeklyGoal,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(
                progressLabel ?? l10n.weeklyGoalProgress,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 14),
          AppProgressBar(value: progress.clamp(0, 1)),
          if (appreciation != null && appreciation!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              appreciation!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
