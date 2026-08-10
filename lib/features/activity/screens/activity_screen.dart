import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/ui/app_button.dart';
import '../../../core/ui/app_stat_row.dart';
import '../../../core/ui/app_top_bar.dart';
import '../../../l10n/app_localizations.dart';
import '../../tracking/models/sport_mode.dart';
import '../widgets/map_preview.dart';
import '../widgets/metric_hero.dart';
import 'session_summary_screen.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key, required this.selectedSport});

  final SportMode selectedSport;

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  _TrackingStatus _status = _TrackingStatus.idle;
  Duration _elapsed = Duration.zero;
  Timer? _timer;

  bool get _hasStarted => _status != _TrackingStatus.idle;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isLive = _status == _TrackingStatus.running;

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
            _hasStarted ? l10n.notConnectedYet : l10n.activityReadyBody,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 18),
          MetricHero(
            selectedSport: widget.selectedSport,
            statusLabel: _statusLabel(l10n),
            elapsedTime: _formatDuration(_elapsed),
            distance: l10n.emptyDistanceKm,
            pace: l10n.emptyPace,
          ),
          const SizedBox(height: 18),
          MapPreview(
            label: isLive ? l10n.liveRoute : l10n.routePreview,
            isLive: isLive,
          ),
          const SizedBox(height: 18),
          _TrackingControls(
            status: _status,
            onStart: _start,
            onPause: _pause,
            onResume: _resume,
            onFinish: _finish,
          ),
          const SizedBox(height: 18),
          _LiveDetailsPanel(hasStarted: _hasStarted),
        ],
      ),
    );
  }

  String _statusLabel(AppLocalizations l10n) {
    return switch (_status) {
      _TrackingStatus.idle => l10n.gpsWaiting,
      _TrackingStatus.running => l10n.liveSession,
      _TrackingStatus.paused => l10n.pausedSession,
    };
  }

  void _start() {
    setState(() {
      _status = _TrackingStatus.running;
      _elapsed = Duration.zero;
    });
    _startTimer();
  }

  void _pause() {
    _timer?.cancel();
    setState(() => _status = _TrackingStatus.paused);
  }

  void _resume() {
    setState(() => _status = _TrackingStatus.running);
    _startTimer();
  }

  void _finish() {
    final summaryDuration = _elapsed;
    _timer?.cancel();
    setState(() {
      _status = _TrackingStatus.idle;
      _elapsed = Duration.zero;
    });
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SessionSummaryScreen(
          selectedSport: widget.selectedSport,
          elapsed: summaryDuration,
        ),
      ),
    );
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _elapsed += const Duration(seconds: 1));
    });
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
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

  final _TrackingStatus status;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (status == _TrackingStatus.idle) {
      return AppButton.primary(
        label: l10n.start,
        icon: Icons.play_arrow_rounded,
        onPressed: onStart,
      );
    }

    return Row(
      children: [
        Expanded(
          child: AppButton.secondary(
            label: status == _TrackingStatus.running ? l10n.pause : l10n.resume,
            icon: status == _TrackingStatus.running
                ? Icons.pause_rounded
                : Icons.play_arrow_rounded,
            onPressed: status == _TrackingStatus.running ? onPause : onResume,
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
  const _LiveDetailsPanel({required this.hasStarted});

  final bool hasStarted;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        AppStatRow(
          icon: Icons.speed_rounded,
          color: AppColors.gps,
          label: l10n.currentSpeed,
          value: hasStarted ? '0.0 km/h' : '--',
        ),
        const SizedBox(height: 10),
        AppStatRow(
          icon: Icons.local_fire_department_rounded,
          color: AppColors.danger,
          label: l10n.estimatedCalories,
          value: hasStarted ? '0 kcal' : '--',
        ),
        const SizedBox(height: 10),
        AppStatRow(
          icon: Icons.landscape_outlined,
          color: AppColors.accent,
          label: l10n.elevation,
          value: hasStarted ? '0 m' : '--',
        ),
        const SizedBox(height: 10),
        AppStatRow(
          icon: Icons.location_on_outlined,
          color: AppColors.primary,
          label: l10n.routePoints,
          value: hasStarted ? '0' : '--',
        ),
      ],
    );
  }
}

enum _TrackingStatus { idle, running, paused }
