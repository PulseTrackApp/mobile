import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/api/api_error.dart';
import '../../../core/api/api_formatters.dart';
import '../../../core/api/api_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/app_button.dart';
import '../../../core/ui/app_panel.dart';
import '../../../core/ui/app_refresh_scroll_view.dart';
import '../../../core/ui/pulse_track_logo.dart';
import '../../../l10n/app_localizations.dart';
import '../../activity/models/workout_share_mode.dart';
import '../../activity/widgets/map_preview.dart';
import '../../activity/widgets/workout_share_choice_sheet.dart';
import '../../tracking/models/sport_mode.dart';
import '../models/workout_detail.dart';

class WorkoutDetailScreen extends ConsumerStatefulWidget {
  const WorkoutDetailScreen({
    super.key,
    required this.workoutId,
    this.initialWorkout,
  });

  final String workoutId;
  final Map<String, dynamic>? initialWorkout;

  @override
  ConsumerState<WorkoutDetailScreen> createState() =>
      _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends ConsumerState<WorkoutDetailScreen> {
  final _shareCardKey = GlobalKey();
  late Future<WorkoutDetail> _future;
  bool _isSharing = false;
  WorkoutShareMode _shareMode = WorkoutShareMode.routeWithData;

  @override
  void initState() {
    super.initState();
    final initialWorkout = widget.initialWorkout;
    _future = initialWorkout == null
        ? _loadWorkout()
        : Future.value(WorkoutDetail.fromJson(initialWorkout));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.workoutDetailTitle)),
      body: SafeArea(
        child: FutureBuilder<WorkoutDetail>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 12),
                    Text(l10n.loadingWorkout),
                  ],
                ),
              );
            }

            if (snapshot.hasError) {
              return _WorkoutLoadError(
                message: _errorMessage(snapshot.error, l10n),
                onRetry: _refresh,
              );
            }

            final workout = snapshot.data!;
            return AppRefreshScrollView(
              onRefresh: _refresh,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  RepaintBoundary(
                    key: _shareCardKey,
                    child: _WorkoutDetailShareCard(
                      workout: workout,
                      shareMode: _shareMode,
                    ),
                  ),
                  const SizedBox(height: 14),
                  AppButton.secondary(
                    label: _isSharing
                        ? l10n.sharingWorkoutImage
                        : l10n.shareSavedWorkout,
                    icon: Icons.ios_share_rounded,
                    onPressed: _isSharing ? null : () => _shareWorkout(workout),
                  ),
                  const SizedBox(height: 18),
                  _HighlightsPanel(workout: workout),
                  const SizedBox(height: 18),
                  _TimelinePanel(workout: workout),
                  const SizedBox(height: 18),
                  _WorkoutDataPanel(workout: workout),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<WorkoutDetail> _loadWorkout() async {
    final json = await ref
        .read(pulseTrackApiProvider)
        .getWorkout(widget.workoutId);
    return WorkoutDetail.fromJson(json);
  }

  Future<void> _refresh() async {
    final future = _loadWorkout();
    setState(() => _future = future);

    try {
      await future;
    } catch (_) {}
  }

  Future<void> _shareWorkout(WorkoutDetail workout) async {
    final l10n = AppLocalizations.of(context);
    final selectedMode = await showWorkoutShareChoiceSheet(context);
    if (selectedMode == null || !mounted) return;

    final previousMode = _shareMode;
    setState(() {
      _shareMode = selectedMode;
      _isSharing = true;
    });

    try {
      await WidgetsBinding.instance.endOfFrame;
      final boundary =
          _shareCardKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) {
        _showMessage(l10n.shareWorkoutUnavailable);
        return;
      }

      if (!mounted) return;
      final pixelRatio = MediaQuery.devicePixelRatioOf(context).clamp(2.0, 3.0);
      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();

      final bytes = byteData?.buffer.asUint8List();
      if (bytes == null || bytes.isEmpty) {
        _showMessage(l10n.shareWorkoutUnavailable);
        return;
      }

      final stamp = (workout.startedAt ?? DateTime.now())
          .toIso8601String()
          .replaceAll(RegExp(r'[:.]'), '-');
      final fileName = 'gymflow-${selectedMode.fileSuffix}-$stamp.png';
      await SharePlus.instance.share(
        ShareParams(
          title: l10n.shareWorkoutTitle,
          subject: l10n.shareWorkoutTitle,
          text: selectedMode.includesData
              ? _shareText(workout, l10n)
              : l10n.shareRouteOnlyText,
          files: [XFile.fromData(bytes, mimeType: 'image/png', name: fileName)],
          fileNameOverrides: [fileName],
        ),
      );
    } catch (_) {
      _showMessage(l10n.shareWorkoutUnavailable);
    } finally {
      if (mounted) {
        setState(() {
          _shareMode = previousMode;
          _isSharing = false;
        });
      }
    }
  }

  String _shareText(WorkoutDetail workout, AppLocalizations l10n) {
    return [
      l10n.shareWorkoutTitle,
      '${l10n.distance}: ${formatMetersAsKm(workout.distanceMeters, l10n)}',
      '${l10n.elapsedTime}: ${_formatDuration(workout.movingDuration)}',
      '${l10n.pace}: ${formatPace(workout.effectivePaceSecondsPerKm, l10n)}',
      '${l10n.averageSpeed}: ${_formatSpeed(workout.effectiveAverageSpeedKmh)}',
      '${l10n.maxSpeed}: ${_formatSpeed(workout.effectiveMaxSpeedKmh)}',
    ].join('\n');
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _WorkoutDetailShareCard extends StatelessWidget {
  const _WorkoutDetailShareCard({
    required this.workout,
    required this.shareMode,
  });

  final WorkoutDetail workout;
  final WorkoutShareMode shareMode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sport = SportMode.fromApiValue(workout.sportType);
    final includeData = shareMode.includesData;

    return AppPanel(
      padding: EdgeInsets.all(includeData ? 16 : 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (includeData) ...[
            _ShareHeader(
              title: sport?.label(l10n) ?? workout.sportType,
              subtitle: _formatDateTime(context, workout.startedAt),
              icon: sport?.icon ?? Icons.fitness_center_rounded,
            ),
            const SizedBox(height: 14),
          ],
          if (workout.hasRoute)
            MapPreview(
              label: l10n.routeReplay,
              routePoints: workout.routePoints,
              framed: false,
              interactive: false,
              fitRoute: true,
              aspectRatio: includeData ? 0.82 : 0.64,
              showLocateButton: false,
              showCurrentMarker: false,
              highlightMarkers: _workoutMapHighlights(l10n, workout),
            )
          else
            _NoRoutePanel(),
          if (includeData) ...[
            const SizedBox(height: 14),
            _WorkoutMetricsGrid(workout: workout),
          ],
        ],
      ),
    );
  }
}

class _WorkoutMetricsGrid extends StatelessWidget {
  const _WorkoutMetricsGrid({required this.workout});

  final WorkoutDetail workout;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = 6.0;
        final tileWidth = (constraints.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            _MetricTile(
              width: tileWidth,
              icon: Icons.route_rounded,
              label: l10n.distance,
              value: formatMetersAsKm(workout.distanceMeters, l10n),
              color: AppColors.gps,
            ),
            _MetricTile(
              width: tileWidth,
              icon: Icons.timer_outlined,
              label: l10n.elapsedTime,
              value: _formatDuration(workout.movingDuration),
              color: AppColors.primary,
            ),
            _MetricTile(
              width: tileWidth,
              icon: Icons.timeline_rounded,
              label: l10n.averagePace,
              value: formatPace(workout.effectivePaceSecondsPerKm, l10n),
              color: AppColors.accent,
            ),
            _MetricTile(
              width: tileWidth,
              icon: Icons.bolt_rounded,
              label: l10n.maxSpeed,
              value: _formatSpeed(workout.effectiveMaxSpeedKmh),
              color: AppColors.danger,
            ),
          ],
        );
      },
    );
  }
}

class _HighlightsPanel extends StatelessWidget {
  const _HighlightsPanel({required this.workout});

  final WorkoutDetail workout;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final fastest = workout.fastestPoint;
    final fastestTime = fastest?.recordedAt == null
        ? null
        : l10n.fastestMomentAt(_formatTime(context, fastest!.recordedAt));

    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.workoutHighlights,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final gap = 10.0;
              final tileWidth = (constraints.maxWidth - gap) / 2;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  _HighlightTile(
                    width: tileWidth,
                    icon: Icons.bolt_rounded,
                    color: AppColors.danger,
                    label: l10n.fastestMoment,
                    value: _formatSpeed(workout.effectiveMaxSpeedKmh),
                    detail: fastestTime,
                  ),
                  _HighlightTile(
                    width: tileWidth,
                    icon: Icons.speed_rounded,
                    color: AppColors.gps,
                    label: l10n.averageSpeed,
                    value: _formatSpeed(workout.effectiveAverageSpeedKmh),
                  ),
                  _HighlightTile(
                    width: tileWidth,
                    icon: Icons.local_fire_department_rounded,
                    color: AppColors.danger,
                    label: l10n.caloriesBurned,
                    value: workout.caloriesBurned > 0
                        ? '${workout.caloriesBurned} kcal'
                        : l10n.emptyValue,
                  ),
                  _HighlightTile(
                    width: tileWidth,
                    icon: Icons.landscape_outlined,
                    color: AppColors.accent,
                    label: l10n.elevation,
                    value:
                        '${workout.elevationGainMeters.toStringAsFixed(0)} m',
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TimelinePanel extends StatelessWidget {
  const _TimelinePanel({required this.workout});

  final WorkoutDetail workout;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (!workout.hasRoute) {
      return AppPanel(
        child: Text(
          l10n.gpsTraceMissing,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    final points = workout.gpsPoints;
    final middleIndex = points.length ~/ 2;

    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.routeTimeline,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          _TimelineRow(
            label: l10n.startedAtLabel,
            value: _formatDateTime(context, workout.startedAt),
            detail: l10n.routePointCount(1),
            color: AppColors.gps,
          ),
          _TimelineRow(
            label: l10n.midRouteLabel,
            value: _formatDateTime(context, points[middleIndex].recordedAt),
            detail: l10n.routePointCount(middleIndex + 1),
            color: AppColors.accent,
          ),
          _TimelineRow(
            label: l10n.endedAtLabel,
            value: _formatDateTime(context, workout.endedAt),
            detail: l10n.routePointCount(points.length),
            color: AppColors.danger,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _WorkoutDataPanel extends StatelessWidget {
  const _WorkoutDataPanel({required this.workout});

  final WorkoutDetail workout;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final note = workout.note?.trim();

    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.workoutDetails,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          _InfoLine(
            icon: Icons.sports_score_outlined,
            color: AppColors.primary,
            label: l10n.perceivedEffort,
            value: workout.perceivedEffort > 0
                ? l10n.effortValue(workout.perceivedEffort)
                : l10n.emptyValue,
          ),
          const Divider(height: 22),
          _InfoLine(
            icon: Icons.mood_outlined,
            color: AppColors.accent,
            label: l10n.feeling,
            value: _feelingLabel(workout.feeling, l10n),
          ),
          const Divider(height: 22),
          _InfoLine(
            icon: Icons.location_on_outlined,
            color: AppColors.gps,
            label: l10n.routePoints,
            value: l10n.routePointCount(workout.gpsPoints.length),
          ),
          const Divider(height: 22),
          Text(l10n.sessionNote, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 6),
          Text(
            note == null || note.isEmpty ? l10n.workoutNoteEmpty : note,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.width,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final double width;
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: width,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          border: Border.all(color: color.withValues(alpha: 0.18)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 15),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        height: 1,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(value, style: theme.textTheme.titleSmall),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShareHeader extends StatelessWidget {
  const _ShareHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        const PulseTrackLogo(size: 34, showWordmark: false),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleLarge),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(icon, size: 15, color: AppColors.primary),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Text(
              'GymFlow',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HighlightTile extends StatelessWidget {
  const _HighlightTile({
    required this.width,
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    this.detail,
  });

  final double width;
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: width,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 19),
              ),
              const SizedBox(height: 10),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
              if (detail != null) ...[
                const SizedBox(height: 4),
                Text(
                  detail!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 21),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text(label, style: theme.textTheme.titleSmall)],
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall,
          ),
        ),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.label,
    required this.value,
    required this.detail,
    required this.color,
    this.isLast = false,
  });

  final String label;
  final String value;
  final String detail;
  final Color color;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: color.withValues(alpha: 0.3),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 2),
                  Text(value, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 2),
                  Text(detail, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoRoutePanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.gps.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gps.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            const Icon(Icons.route_outlined, color: AppColors.gps),
            const SizedBox(width: 12),
            Expanded(child: Text(l10n.gpsTraceMissing)),
          ],
        ),
      ),
    );
  }
}

class _WorkoutLoadError extends StatelessWidget {
  const _WorkoutLoadError({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return AppRefreshScrollView(
      onRefresh: onRetry,
      padding: const EdgeInsets.all(20),
      child: AppPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 44,
              color: AppColors.danger,
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            AppButton.secondary(
              label: MaterialLocalizations.of(
                context,
              ).refreshIndicatorSemanticLabel,
              icon: Icons.refresh_rounded,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDateTime(BuildContext context, DateTime? value) {
  if (value == null) return AppLocalizations.of(context).emptyValue;
  final material = MaterialLocalizations.of(context);
  final date = material.formatMediumDate(value);
  final time = material.formatTimeOfDay(
    TimeOfDay.fromDateTime(value),
    alwaysUse24HourFormat: true,
  );
  return '$date · $time';
}

String _formatTime(BuildContext context, DateTime? value) {
  if (value == null) return AppLocalizations.of(context).emptyValue;
  return MaterialLocalizations.of(
    context,
  ).formatTimeOfDay(TimeOfDay.fromDateTime(value), alwaysUse24HourFormat: true);
}

String _formatDuration(Duration duration) {
  final hours = duration.inHours.toString().padLeft(2, '0');
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$hours:$minutes:$seconds';
}

String _formatSpeed(double speedKmh) {
  if (speedKmh <= 0) return '--';
  return '${speedKmh.toStringAsFixed(1)} km/h';
}

String _feelingLabel(String? feeling, AppLocalizations l10n) {
  return switch (feeling) {
    'GREAT' => l10n.feelingGreat,
    'GOOD' => l10n.feelingGood,
    'OK' => l10n.feelingOk,
    'TIRED' => l10n.feelingTired,
    'EXHAUSTED' => l10n.feelingExhausted,
    _ => l10n.emptyValue,
  };
}

String _errorMessage(Object? error, AppLocalizations l10n) {
  if (error is ApiProblem) return error.message;
  return l10n.apiUnexpectedError;
}

List<MapHighlightMarker> _workoutMapHighlights(
  AppLocalizations l10n,
  WorkoutDetail workout,
) {
  final routePoints = workout.routePoints;
  if (routePoints.length < 3) return const [];

  final highlights = <MapHighlightMarker>[
    MapHighlightMarker(
      point: routePoints[routePoints.length ~/ 2],
      label: l10n.midRouteMarker,
      icon: Icons.timeline_rounded,
      color: AppColors.accent,
    ),
  ];

  final fastestPoint = workout.fastestPoint;
  if (fastestPoint != null) {
    highlights.add(
      MapHighlightMarker(
        point: fastestPoint.latLng,
        label: l10n.speedPeakMarker,
        icon: Icons.bolt_rounded,
        color: AppColors.danger,
      ),
    );
  }

  return highlights;
}
