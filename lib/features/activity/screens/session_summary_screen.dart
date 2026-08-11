import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_error.dart';
import '../../../core/api/api_formatters.dart';
import '../../../core/api/api_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/app_button.dart';
import '../../../core/ui/app_panel.dart';
import '../../../core/ui/app_stat_row.dart';
import '../../../l10n/app_localizations.dart';
import '../../tracking/models/calorie_estimator.dart';
import '../../tracking/models/sport_mode.dart';
import '../../tracking/models/tracking_session_draft.dart';
import '../widgets/map_preview.dart';

class SessionSummaryScreen extends ConsumerStatefulWidget {
  const SessionSummaryScreen({
    super.key,
    required this.selectedSport,
    required this.track,
  });

  final SportMode selectedSport;
  final TrackingSessionDraft track;

  @override
  ConsumerState<SessionSummaryScreen> createState() =>
      _SessionSummaryScreenState();
}

class _SessionSummaryScreenState extends ConsumerState<SessionSummaryScreen> {
  final _noteController = TextEditingController();
  int _effort = 5;
  _Feeling _feeling = _Feeling.good;
  bool _isSaving = false;
  late final Future<double?> _weightFuture;

  @override
  void initState() {
    super.initState();
    _weightFuture = _loadWeightKg();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

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
                value: _formatDuration(widget.track.elapsed),
              ),
              const SizedBox(height: 10),
              AppStatRow(
                icon: Icons.route_rounded,
                color: AppColors.gps,
                label: l10n.distance,
                value: '${formatKm(widget.track.distanceMeters)} km',
              ),
              const SizedBox(height: 10),
              FutureBuilder<double?>(
                future: _weightFuture,
                builder: (context, snapshot) {
                  return AppStatRow(
                    icon: Icons.local_fire_department_rounded,
                    color: AppColors.danger,
                    label: l10n.estimatedCalories,
                    value: _formatCalories(snapshot.data),
                  );
                },
              ),
              const SizedBox(height: 10),
              AppStatRow(
                icon: Icons.speed_rounded,
                color: AppColors.accent,
                label: l10n.averageSpeed,
                value:
                    '${widget.track.averageSpeedKmh.toStringAsFixed(1)} km/h',
              ),
              const SizedBox(height: 10),
              AppStatRow(
                icon: Icons.landscape_outlined,
                color: AppColors.primary,
                label: l10n.elevation,
                value:
                    '${widget.track.elevationGainMeters.toStringAsFixed(0)} m',
              ),
              const SizedBox(height: 18),
              MapPreview(
                label: l10n.routePreview,
                isLive: false,
                routePoints: widget.track.routePoints,
              ),
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
                    DropdownButtonFormField<_Feeling>(
                      initialValue: _feeling,
                      decoration: InputDecoration(
                        labelText: l10n.feeling,
                        prefixIcon: const Icon(Icons.mood_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: _Feeling.values.map((feeling) {
                        return DropdownMenuItem<_Feeling>(
                          value: feeling,
                          child: Text(feeling.label),
                        );
                      }).toList(),
                      onChanged: (feeling) {
                        if (feeling != null) {
                          setState(() => _feeling = feeling);
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _noteController,
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
                label: _isSaving ? l10n.saving : l10n.saveWorkout,
                icon: Icons.save_outlined,
                onPressed: _isSaving ? null : _saveWorkout,
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

  Future<double?> _loadWeightKg() async {
    if (!ref.read(authTokenStoreProvider).isAuthenticated) return null;

    try {
      final profile = await ref.read(pulseTrackApiProvider).getProfile();
      final weight = jsonDouble(profile, 'currentWeightKg');
      return weight > 0 ? weight : null;
    } catch (_) {
      return null;
    }
  }

  String _formatCalories(double? weightKg) {
    if (weightKg == null) return '--';

    final calories = estimateWorkoutCalories(
      sport: widget.selectedSport,
      averageSpeedKmh: widget.track.averageSpeedKmh,
      movingDuration: widget.track.elapsed,
      weightKg: weightKg,
    );
    if (calories <= 0) return '--';
    return '~$calories kcal';
  }

  Future<void> _saveWorkout() async {
    final l10n = AppLocalizations.of(context);

    setState(() => _isSaving = true);
    try {
      await ref.read(pulseTrackApiProvider).createWorkout({
        'sportType': widget.selectedSport.apiValue,
        'startedAt': widget.track.startedAt.toIso8601String(),
        'endedAt': widget.track.apiEndedAt.toIso8601String(),
        'distanceMeters': widget.track.distanceMeters,
        'perceivedEffort': _effort,
        'feeling': _feeling.apiValue,
        if (_noteController.text.trim().isNotEmpty)
          'note': _noteController.text.trim(),
        'gpsPoints': widget.track.apiGpsPoints,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.workoutSavedApi)));
      Navigator.of(context).pop();
    } on ApiProblem catch (problem) {
      _showMessage('${l10n.apiErrorPrefix} ${problem.message}');
    } catch (_) {
      _showMessage(l10n.apiUnexpectedError);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

enum _Feeling {
  great('GREAT', 'Great'),
  good('GOOD', 'Good'),
  ok('OK', 'OK'),
  tired('TIRED', 'Tired'),
  exhausted('EXHAUSTED', 'Exhausted');

  const _Feeling(this.apiValue, this.label);

  final String apiValue;
  final String label;
}
