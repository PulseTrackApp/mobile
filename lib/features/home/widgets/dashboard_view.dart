import 'package:flutter/material.dart';

import '../../../core/ui/app_top_bar.dart';
import '../../../l10n/app_localizations.dart';
import '../../menu/screens/menu_screen.dart';
import '../../tracking/models/sport_mode.dart';
import 'personal_progress_card.dart';
import 'sport_picker.dart';
import 'start_workout_card.dart';
import 'today_metrics.dart';
import 'weekly_target_card.dart';

class DashboardView extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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
          const SizedBox(height: 28),
          Text(
            l10n.readyForNextSession,
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 18),
          SportPicker(selectedSport: selectedSport, onChanged: onSportChanged),
          const SizedBox(height: 18),
          StartWorkoutCard(
            selectedSport: selectedSport,
            onStartWorkout: onStartWorkout,
          ),
          const SizedBox(height: 18),
          const TodayMetrics(),
          const SizedBox(height: 18),
          const WeeklyTargetCard(),
          const SizedBox(height: 18),
          const PersonalProgressCard(),
        ],
      ),
    );
  }
}
