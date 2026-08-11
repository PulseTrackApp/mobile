import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_formatters.dart';
import '../../../core/api/api_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/app_button.dart';
import '../../../core/ui/app_stat_row.dart';
import '../../../core/ui/app_top_bar.dart';
import '../../../l10n/app_localizations.dart';
import '../../tracking/controllers/tracking_controller.dart';
import '../../tracking/models/calorie_estimator.dart';
import '../../tracking/models/sport_mode.dart';
import '../../tracking/models/tracking_state.dart';
import '../widgets/map_preview.dart';
import '../widgets/metric_hero.dart';
import 'session_summary_screen.dart';

class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key, required this.selectedSport});

  final SportMode selectedSport;

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  late final TrackingController _trackingController;
  double? _weightKg;

  TrackingState get _trackingState => _trackingController.state;

  @override
  void initState() {
    super.initState();
    _trackingController = TrackingController()..addListener(_onTrackingChanged);
    _loadWeightKg();
  }

  @override
  void dispose() {
    _trackingController.removeListener(_onTrackingChanged);
    _trackingController.dispose();
    super.dispose();
  }

  void _onTrackingChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = _trackingState;
    final isLive = state.status == TrackingStatus.running;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppTopBar(),
          const SizedBox(height: 28),
          Text(
            l10n.trackingTitle,
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 8),
          Text(
            state.hasStarted ? l10n.notConnectedYet : l10n.activityReadyBody,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 18),
          MetricHero(
            selectedSport: widget.selectedSport,
            statusLabel: _statusLabel(state.status, l10n),
            elapsedTime: _formatDuration(state.elapsed),
            distance: _formatDistance(state.distanceMeters),
            pace: formatPace(state.paceSecondsPerKm, l10n),
          ),
          const SizedBox(height: 18),
          MapPreview(
            label: isLive ? l10n.liveRoute : l10n.routePreview,
            isLive: isLive,
            routePoints: state.routePoints,
          ),
          const SizedBox(height: 18),
          _TrackingControls(
            status: state.status,
            onStart: _start,
            onPause: _trackingController.pause,
            onResume: _resume,
            onFinish: _finish,
          ),
          const SizedBox(height: 18),
          _LiveDetailsPanel(
            state: state,
            hasStarted: state.hasStarted,
            caloriesLabel: _formatCalories(state),
          ),
        ],
      ),
    );
  }

  Future<void> _loadWeightKg() async {
    if (!ref.read(authTokenStoreProvider).isAuthenticated) return;

    try {
      final profile = await ref.read(pulseTrackApiProvider).getProfile();
      final weight = jsonDouble(profile, 'currentWeightKg');
      if (mounted && weight > 0) {
        setState(() => _weightKg = weight);
      }
    } catch (_) {
      // La session GPS reste utilisable meme si le profil n'est pas charge.
    }
  }

  String _statusLabel(TrackingStatus status, AppLocalizations l10n) {
    return switch (status) {
      TrackingStatus.idle => l10n.gpsWaiting,
      TrackingStatus.locating => l10n.gpsWaiting,
      TrackingStatus.running => l10n.liveSession,
      TrackingStatus.paused => l10n.pausedSession,
    };
  }

  Future<void> _start() async {
    try {
      await _trackingController.start();
    } on TrackingException {
      _showTrackingError();
    }
  }

  Future<void> _resume() async {
    try {
      await _trackingController.resume();
    } on TrackingException {
      _showTrackingError();
    }
  }

  void _finish() {
    final draft = _trackingController.finish();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SessionSummaryScreen(
          selectedSport: widget.selectedSport,
          track: draft,
        ),
      ),
    );
  }

  void _showTrackingError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).currentLocationUnavailable),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  String _formatDistance(double meters) {
    return '${formatKm(meters)} km';
  }

  String _formatCalories(TrackingState state) {
    final weightKg = _weightKg;
    if (!state.hasStarted || weightKg == null) return '--';

    final calories = estimateWorkoutCalories(
      sport: widget.selectedSport,
      averageSpeedKmh: state.averageSpeedKmh,
      movingDuration: state.elapsed,
      weightKg: weightKg,
    );
    if (calories <= 0) return '--';
    return '~$calories kcal';
  }
}

class _TrackingControls extends StatelessWidget {
  const _TrackingControls({
    required this.status,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onFinish,
  });

  final TrackingStatus status;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (status == TrackingStatus.idle || status == TrackingStatus.locating) {
      return AppButton.primary(
        label: status == TrackingStatus.locating ? l10n.gpsWaiting : l10n.start,
        icon: Icons.play_arrow_rounded,
        onPressed: status == TrackingStatus.locating ? null : onStart,
      );
    }

    return Row(
      children: [
        Expanded(
          child: AppButton.secondary(
            label: status == TrackingStatus.running ? l10n.pause : l10n.resume,
            icon: status == TrackingStatus.running
                ? Icons.pause_rounded
                : Icons.play_arrow_rounded,
            onPressed: status == TrackingStatus.running ? onPause : onResume,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AppButton.primary(
            label: l10n.finish,
            icon: Icons.stop_rounded,
            onPressed: onFinish,
          ),
        ),
      ],
    );
  }
}

class _LiveDetailsPanel extends StatelessWidget {
  const _LiveDetailsPanel({
    required this.state,
    required this.hasStarted,
    required this.caloriesLabel,
  });

  final TrackingState state;
  final bool hasStarted;
  final String caloriesLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        AppStatRow(
          icon: Icons.speed_rounded,
          color: AppColors.gps,
          label: l10n.currentSpeed,
          value: hasStarted ? _formatSpeed(state.currentSpeedKmh) : '--',
        ),
        const SizedBox(height: 10),
        AppStatRow(
          icon: Icons.local_fire_department_rounded,
          color: AppColors.danger,
          label: l10n.estimatedCalories,
          value: caloriesLabel,
        ),
        const SizedBox(height: 10),
        AppStatRow(
          icon: Icons.landscape_outlined,
          color: AppColors.accent,
          label: l10n.elevation,
          value: hasStarted
              ? '${state.elevationGainMeters.toStringAsFixed(0)} m'
              : '--',
        ),
        const SizedBox(height: 10),
        AppStatRow(
          icon: Icons.location_on_outlined,
          color: AppColors.primary,
          label: l10n.routePoints,
          value: hasStarted ? state.points.length.toString() : '--',
        ),
      ],
    );
  }

  String _formatSpeed(double speedKmh) {
    return '${speedKmh.toStringAsFixed(1)} km/h';
  }
}
