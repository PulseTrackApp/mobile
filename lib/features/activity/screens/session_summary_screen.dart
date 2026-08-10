import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/ui/app_button.dart';
import '../../../core/ui/app_panel.dart';
import '../../../core/ui/app_stat_row.dart';
import '../../../l10n/app_localizations.dart';
import '../../tracking/models/sport_mode.dart';
import '../widgets/map_preview.dart';

class SessionSummaryScreen extends StatefulWidget {
  const SessionSummaryScreen({
    super.key,
    required this.selectedSport,
    required this.elapsed,
  });

  final SportMode selectedSport;
  final Duration elapsed;

  @override
  State<SessionSummaryScreen> createState() => _SessionSummaryScreenState();
}

class _SessionSummaryScreenState extends State<SessionSummaryScreen> {
  int _effort = 5;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.sessionSummaryTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppPanel(
                color: AppColors.dark,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(widget.selectedSport.icon, color: AppColors.accent),
                    const SizedBox(height: 14),
                    Text(
                      widget.selectedSport.label(l10n),
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.workoutSavedDraft,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              AppStatRow(
                icon: Icons.timer_outlined,
                color: AppColors.primary,
                label: l10n.elapsedTime,
                value: _formatDuration(widget.elapsed),
              ),
              const SizedBox(height: 10),
              AppStatRow(
                icon: Icons.route_rounded,
                color: AppColors.gps,
                label: l10n.distance,
                value: '0.00 km',
              ),
              const SizedBox(height: 10),
              AppStatRow(
                icon: Icons.local_fire_department_rounded,
                color: AppColors.danger,
                label: l10n.estimatedCalories,
                value: '0 kcal',
              ),
              const SizedBox(height: 10),
              AppStatRow(
                icon: Icons.speed_rounded,
                color: AppColors.accent,
                label: l10n.averageSpeed,
                value: '0.0 km/h',
              ),
              const SizedBox(height: 18),
              MapPreview(label: l10n.routePreview, isLive: true),
              const SizedBox(height: 18),
              AppPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.perceivedEffort,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(10, (index) {
                        final value = index + 1;
                        return ChoiceChip(
                          label: Text('$value'),
                          selected: _effort == value,
                          onSelected: (_) => setState(() => _effort = value),
                        );
                      }),
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: l10n.feeling,
                        hintText: l10n.sessionNotesHint,
                        prefixIcon: const Icon(Icons.mood_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: l10n.sessionNote,
                        hintText: l10n.sessionNotesHint,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              AppButton.primary(
                label: l10n.saveWorkout,
                icon: Icons.save_outlined,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.workoutSavedDraft)),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}
