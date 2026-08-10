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
  });

  final SportMode selectedSport;
  final VoidCallback onStartWorkout;

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
          AppButton.primary(
            label: l10n.startWorkout,
            icon: Icons.play_arrow_rounded,
            onPressed: onStartWorkout,
          ),
        ],
      ),
    );
  }
}
