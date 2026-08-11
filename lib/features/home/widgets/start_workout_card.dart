import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/ui/app_button.dart';
import '../../../core/ui/app_panel.dart';
import '../../../l10n/app_localizations.dart';
import '../../tracking/models/sport_mode.dart';

class StartWorkoutCard extends StatelessWidget {
  const StartWorkoutCard({
    super.key,
    required this.selectedSport,
    required this.onStartWorkout,
    this.locked = false,
  });

  final SportMode selectedSport;
  final VoidCallback? onStartWorkout;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppPanel(
      color: AppColors.dark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(selectedSport.icon, color: AppColors.accent, size: 34),
          const SizedBox(height: 18),
          Text(
            selectedSport.label(l10n),
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.todayDistance,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 18),
          if (locked) ...[
            Row(
              children: [
                const Icon(
                  Icons.lock_outline_rounded,
                  color: Colors.white70,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.moduleLockedShort,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          AppButton.primary(
            label: l10n.startWorkout,
            icon: locked
                ? Icons.lock_outline_rounded
                : Icons.play_arrow_rounded,
            onPressed: locked ? null : onStartWorkout,
          ),
        ],
      ),
    );
  }
}
