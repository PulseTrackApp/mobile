import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_formatters.dart';
import '../../../core/api/api_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/app_button.dart';
import '../../../core/ui/app_panel.dart';
import '../../../core/ui/app_stat_row.dart';
import '../../../core/ui/app_top_bar.dart';
import '../../../core/ui/celebration_overlay.dart';
import '../../../l10n/app_localizations.dart';
import '../../tracking/controllers/tracking_controller.dart';
import '../../tracking/models/calorie_estimator.dart';
import '../../tracking/models/sport_mode.dart';
import '../../tracking/models/tracking_state.dart';
import '../models/workout_challenge.dart';
import '../models/workout_rating.dart';
import '../widgets/map_preview.dart';
import '../widgets/metric_hero.dart';
import 'session_summary_screen.dart';

class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({
    super.key,
    required this.selectedSport,
    this.initialChallenge,
  });

  final SportMode selectedSport;
  final WorkoutChallenge? initialChallenge;

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  late final TrackingController _trackingController;
  final _challengeDistanceController = TextEditingController(text: '5');
  final _challengeMinutesController = TextEditingController(text: '30');
  double? _weightKg;
  PersonalRecordSnapshot? _records;
  WorkoutChallenge? _activeChallenge;
  bool _challengeMode = false;
  bool _challengeHalfAlerted = false;
  bool _challengeApproachAlerted = false;
  bool _challengeDeadlineAlerted = false;
  bool _challengeCompletedAlerted = false;
  bool _distanceRecordAlerted = false;

  TrackingState get _trackingState => _trackingController.state;

  @override
  void initState() {
    super.initState();
    _trackingController = TrackingController()..addListener(_onTrackingChanged);
    final initialChallenge = widget.initialChallenge;
    if (initialChallenge != null) {
      _challengeMode = initialChallenge.hasDistanceTarget;
      if (initialChallenge.hasDistanceTarget) {
        _challengeDistanceController.text = formatKm(
          initialChallenge.targetDistanceMeters,
        );
      }
      if (initialChallenge.hasTimeLimit) {
        _challengeMinutesController.text = initialChallenge
            .targetDuration
            .inMinutes
            .toString();
      }
    }
    _loadWeightKg();
    _loadRecords();
  }

  @override
  void dispose() {
    _trackingController.removeListener(_onTrackingChanged);
    _trackingController.dispose();
    _challengeDistanceController.dispose();
    _challengeMinutesController.dispose();
    super.dispose();
  }

  void _onTrackingChanged() {
    if (!mounted) return;
    setState(() {});
    _handleChallengeAlerts(_trackingController.state);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = _trackingState;
    final isLive = state.status == TrackingStatus.running;
    final challenge = state.hasStarted ? _activeChallenge : _previewChallenge();

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
          if (!state.hasStarted) ...[
            _ChallengeSetupPanel(
              enabled: _challengeMode,
              distanceController: _challengeDistanceController,
              minutesController: _challengeMinutesController,
              routeChallenge: widget.initialChallenge,
              onEnabledChanged: (value) {
                setState(() => _challengeMode = value);
              },
            ),
            const SizedBox(height: 18),
          ] else if (challenge?.hasDistanceTarget == true) ...[
            _ChallengeLivePanel(challenge: challenge!, state: state),
            const SizedBox(height: 18),
          ],
          MapPreview(
            label: challenge?.hasReferenceRoute == true
                ? l10n.challengeRouteGuide
                : isLive
                ? l10n.liveRoute
                : l10n.routePreview,
            isLive: isLive,
            routePoints: state.routePoints,
            referenceRoutePoints: challenge?.referenceRoutePoints ?? const [],
            fitRoute: challenge?.hasReferenceRoute == true,
          ),
          const SizedBox(height: 18),
          _TrackingControls(
            status: state.status,
            onStart: _start,
            onPause: _requestPause,
            onResume: _resume,
            onFinish: _requestFinish,
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

  Future<void> _loadRecords() async {
    if (!ref.read(authTokenStoreProvider).isAuthenticated) return;

    try {
      // Les records courants du sport, et non ceux des statistiques : celles-ci
      // bornent leurs records a une periode et appartiennent au module STATS,
      // ferme par defaut. L'apercu etait donc vide sur la plupart des comptes.
      final sports = await ref
          .read(pulseTrackApiProvider)
          .getRecords(sport: widget.selectedSport.apiSportType);
      if (mounted) {
        setState(
          () => _records = PersonalRecordSnapshot.fromSportRecords(sports),
        );
      }
    } catch (_) {
      // Les records motivent l'UI, mais ne doivent jamais bloquer le tracking.
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
    final challenge = _configuredChallenge();
    if (_challengeMode && challenge?.hasDistanceTarget != true) {
      _showMessage(AppLocalizations.of(context).challengeFieldsRequired);
      return;
    }

    try {
      _resetChallengeAlerts();
      _activeChallenge = challenge;
      await _trackingController.start();
    } on TrackingException catch (error) {
      _showTrackingError(error.issue);
    }
  }

  Future<void> _resume() async {
    try {
      await _trackingController.resume();
    } on TrackingException catch (error) {
      _showTrackingError(error.issue);
    }
  }

  Future<void> _requestPause() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await _confirmTrackingAction(
      title: l10n.confirmPauseTitle,
      body: l10n.confirmPauseBody,
      actionLabel: l10n.confirmPauseAction,
      actionIcon: Icons.pause_rounded,
    );
    if (confirmed != true || !mounted) return;
    _trackingController.pause();
  }

  Future<void> _requestFinish() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await _confirmTrackingAction(
      title: l10n.confirmFinishTitle,
      body: l10n.confirmFinishBody,
      actionLabel: l10n.confirmFinishAction,
      actionIcon: Icons.stop_rounded,
      destructive: true,
    );
    if (confirmed != true || !mounted) return;
    _finish();
  }

  Future<bool?> _confirmTrackingAction({
    required String title,
    required String body,
    required String actionLabel,
    required IconData actionIcon,
    bool destructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            ),
            FilledButton.icon(
              style: destructive
                  ? FilledButton.styleFrom(backgroundColor: AppColors.danger)
                  : null,
              onPressed: () => Navigator.of(context).pop(true),
              icon: Icon(actionIcon),
              label: Text(actionLabel),
            ),
          ],
        );
      },
    );
  }

  void _finish() {
    final draft = _trackingController.finish();
    final challenge = _activeChallenge;
    _activeChallenge = null;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SessionSummaryScreen(
          selectedSport: widget.selectedSport,
          track: draft,
          challenge: challenge,
        ),
      ),
    );
  }

  WorkoutChallenge? _previewChallenge() {
    return _configuredChallenge(allowInvalidDistanceTarget: true);
  }

  WorkoutChallenge? _configuredChallenge({
    bool allowInvalidDistanceTarget = false,
  }) {
    final routeChallenge = widget.initialChallenge;
    final referenceRoutePoints =
        routeChallenge?.referenceRoutePoints ?? const [];
    final sourceWorkoutId = routeChallenge?.sourceWorkoutId;
    final sourceTitle = routeChallenge?.sourceTitle;

    final distanceKm = parseLocalizedDouble(_challengeDistanceController.text);
    final minutes = parseLocalizedDouble(_challengeMinutesController.text);
    final hasValidTarget = distanceKm > 0 && minutes > 0;

    if (_challengeMode && (hasValidTarget || allowInvalidDistanceTarget)) {
      return WorkoutChallenge(
        targetDistanceMeters: distanceKm > 0 ? distanceKm * 1000 : 0,
        targetDuration: minutes > 0
            ? Duration(minutes: minutes.round())
            : Duration.zero,
        referenceRoutePoints: referenceRoutePoints,
        sourceWorkoutId: sourceWorkoutId,
        sourceTitle: sourceTitle,
      );
    }

    if (referenceRoutePoints.length >= 2) {
      return WorkoutChallenge.routeReplay(
        referenceRoutePoints: referenceRoutePoints,
        sourceWorkoutId: sourceWorkoutId,
        sourceTitle: sourceTitle,
      );
    }

    return null;
  }

  void _resetChallengeAlerts() {
    _challengeHalfAlerted = false;
    _challengeApproachAlerted = false;
    _challengeDeadlineAlerted = false;
    _challengeCompletedAlerted = false;
    _distanceRecordAlerted = false;
  }

  void _handleChallengeAlerts(TrackingState state) {
    if (state.status != TrackingStatus.running) return;

    final l10n = AppLocalizations.of(context);
    final challenge = _activeChallenge;
    if (challenge?.hasDistanceTarget == true) {
      final progress = challenge!.progressFor(state.distanceMeters);
      if (!_challengeHalfAlerted && progress >= 0.5 && progress < 1) {
        _challengeHalfAlerted = true;
        _showMessage(l10n.challengeHalfway);
      }

      if (!_challengeApproachAlerted && challenge.hasTimeLimit) {
        final remaining = challenge.remainingFor(state.elapsed);
        final approachSeconds = (challenge.targetDuration.inSeconds * 0.2)
            .round()
            .clamp(60, 300);
        if (remaining > Duration.zero &&
            remaining.inSeconds <= approachSeconds &&
            progress < 1) {
          _challengeApproachAlerted = true;
          _showMessage(l10n.challengeDeadlineApproaching);
        }
      }

      if (!_challengeDeadlineAlerted &&
          challenge.isDeadlineMissedBy(
            distanceMeters: state.distanceMeters,
            elapsed: state.elapsed,
          )) {
        _challengeDeadlineAlerted = true;
        _showMessage(l10n.challengeDeadlineMissed);
      }

      if (!_challengeCompletedAlerted &&
          challenge.isCompletedBy(
            distanceMeters: state.distanceMeters,
            elapsed: state.elapsed,
          )) {
        _challengeCompletedAlerted = true;
        showCelebration(
          context,
          title: l10n.challengeTargetReachedTitle,
          message: l10n.challengeTargetReachedBody,
        );
      }
    }

    final records = _records;
    if (!_distanceRecordAlerted &&
        records != null &&
        records.longestDistanceMeters > 0 &&
        state.distanceMeters > records.longestDistanceMeters) {
      _distanceRecordAlerted = true;
      showCelebration(
        context,
        title: l10n.recordCelebrationTitle,
        message: l10n.distanceRecordCelebrationBody,
      );
    }
  }

  void _showTrackingError(TrackingIssue issue) {
    final l10n = AppLocalizations.of(context);
    final message = switch (issue) {
      TrackingIssue.locationDisabled => l10n.currentLocationUnavailable,
      TrackingIssue.permissionDenied => l10n.locationPermissionDenied,
    };

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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

class _ChallengeSetupPanel extends StatelessWidget {
  const _ChallengeSetupPanel({
    required this.enabled,
    required this.distanceController,
    required this.minutesController,
    required this.routeChallenge,
    required this.onEnabledChanged,
  });

  final bool enabled;
  final TextEditingController distanceController;
  final TextEditingController minutesController;
  final WorkoutChallenge? routeChallenge;
  final ValueChanged<bool> onEnabledChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasRouteGuide = routeChallenge?.hasReferenceRoute == true;

    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events_outlined, color: AppColors.accent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.challengeModeTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Switch(value: enabled, onChanged: onEnabledChanged),
            ],
          ),
          if (hasRouteGuide) ...[
            const SizedBox(height: 12),
            _RouteReplayNotice(challenge: routeChallenge!),
          ],
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: enabled
                ? Padding(
                    key: const ValueKey('challenge-fields'),
                    padding: const EdgeInsets.only(top: 14),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final horizontal = constraints.maxWidth >= 380;
                        final distanceField = TextFormField(
                          controller: distanceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: l10n.challengeDistanceTarget,
                            suffixText: l10n.kilometersUnit,
                            prefixIcon: const Icon(Icons.route_rounded),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                        final minutesField = TextFormField(
                          controller: minutesController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: l10n.challengeTimeLimit,
                            suffixText: l10n.minutesUnit,
                            prefixIcon: const Icon(Icons.timer_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );

                        if (horizontal) {
                          return Row(
                            children: [
                              Expanded(child: distanceField),
                              const SizedBox(width: 10),
                              Expanded(child: minutesField),
                            ],
                          );
                        }

                        return Column(
                          children: [
                            distanceField,
                            const SizedBox(height: 10),
                            minutesField,
                          ],
                        );
                      },
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey('challenge-empty')),
          ),
        ],
      ),
    );
  }
}

class _ChallengeLivePanel extends StatelessWidget {
  const _ChallengeLivePanel({required this.challenge, required this.state});

  final WorkoutChallenge challenge;
  final TrackingState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final progress = challenge.progressFor(state.distanceMeters);
    final remaining = challenge.remainingFor(state.elapsed);

    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flag_rounded, color: AppColors.accent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.challengeLiveTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppProgressBar(value: progress, color: AppColors.accent),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ChallengeChip(
                icon: Icons.route_rounded,
                label: l10n.challengeProgressLabel(
                  '${formatKm(state.distanceMeters)} ${l10n.kilometersUnit}',
                  '${formatKm(challenge.targetDistanceMeters)} ${l10n.kilometersUnit}',
                ),
              ),
              if (challenge.hasTimeLimit)
                _ChallengeChip(
                  icon: Icons.timer_outlined,
                  label: l10n.challengeRemainingTime(
                    _formatChallengeDuration(remaining),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChallengeChip extends StatelessWidget {
  const _ChallengeChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.22)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.accent),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteReplayNotice extends StatelessWidget {
  const _RouteReplayNotice({required this.challenge});

  final WorkoutChallenge challenge;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sourceTitle = challenge.sourceTitle;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.gps.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gps.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.route_outlined, color: AppColors.gps),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.challengeRouteReplayActive,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sourceTitle == null || sourceTitle.isEmpty
                        ? l10n.challengeRouteReplayBody
                        : sourceTitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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

String _formatChallengeDuration(Duration duration) {
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  if (duration.inHours > 0) {
    return '${duration.inHours}:$minutes:$seconds';
  }
  return '$minutes:$seconds';
}
