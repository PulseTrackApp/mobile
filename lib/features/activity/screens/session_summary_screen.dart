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
import '../../../core/ui/pulse_track_logo.dart';
import '../../../l10n/app_localizations.dart';
import '../../history/screens/workout_detail_screen.dart';
import '../../tracking/models/calorie_estimator.dart';
import '../../tracking/models/sport_mode.dart';
import '../../tracking/models/tracking_session_draft.dart';
import '../models/workout_share_mode.dart';
import '../widgets/map_preview.dart';
import '../widgets/workout_share_choice_sheet.dart';

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
  final _shareCardKey = GlobalKey();
  final _noteController = TextEditingController();
  int _effort = 5;
  _Feeling _feeling = _Feeling.good;
  bool _isSaving = false;
  bool _isSharing = false;
  WorkoutShareMode _shareMode = WorkoutShareMode.routeWithData;
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
              FutureBuilder<double?>(
                future: _weightFuture,
                builder: (context, snapshot) {
                  return RepaintBoundary(
                    key: _shareCardKey,
                    child: _WorkoutShareCard(
                      sport: widget.selectedSport,
                      track: widget.track,
                      calories: _formatCalories(snapshot.data),
                      elapsed: _formatDuration(widget.track.elapsed),
                      distance: '${formatKm(widget.track.distanceMeters)} km',
                      pace: formatPace(widget.track.paceSecondsPerKm, l10n),
                      averageSpeed:
                          '${widget.track.averageSpeedKmh.toStringAsFixed(1)} km/h',
                      maxSpeed:
                          '${widget.track.maxSpeedKmh.toStringAsFixed(1)} km/h',
                      elevation:
                          '${widget.track.elevationGainMeters.toStringAsFixed(0)} m',
                      shareMode: _shareMode,
                    ),
                  );
                },
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
              AppButton.secondary(
                label: _isSharing
                    ? l10n.sharingWorkoutImage
                    : l10n.shareWorkoutImage,
                icon: Icons.ios_share_rounded,
                onPressed: _isSharing ? null : _shareWorkoutImage,
              ),
              const SizedBox(height: 10),
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

  Future<void> _shareWorkoutImage() async {
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

      final fileName =
          'gymflow-${selectedMode.fileSuffix}-${_fileStamp(widget.track.startedAt)}.png';
      await SharePlus.instance.share(
        ShareParams(
          title: l10n.shareWorkoutTitle,
          subject: l10n.shareWorkoutTitle,
          text: selectedMode.includesData
              ? _shareText(l10n)
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

  String _shareText(AppLocalizations l10n) {
    return [
      l10n.shareWorkoutTitle,
      '${l10n.distance}: ${formatKm(widget.track.distanceMeters)} km',
      '${l10n.elapsedTime}: ${_formatDuration(widget.track.elapsed)}',
      '${l10n.pace}: ${formatPace(widget.track.paceSecondsPerKm, l10n)}',
      '${l10n.averageSpeed}: ${widget.track.averageSpeedKmh.toStringAsFixed(1)} km/h',
      '${l10n.maxSpeed}: ${widget.track.maxSpeedKmh.toStringAsFixed(1)} km/h',
    ].join('\n');
  }

  String _fileStamp(DateTime value) {
    return value.toLocal().toIso8601String().replaceAll(RegExp(r'[:.]'), '-');
  }

  Future<void> _saveWorkout() async {
    final l10n = AppLocalizations.of(context);

    setState(() => _isSaving = true);
    try {
      final savedWorkout = await ref.read(pulseTrackApiProvider).createWorkout({
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
      final summary = jsonMap(savedWorkout, 'summary') ?? savedWorkout;
      final workoutId = jsonString(summary, 'id');
      if (workoutId == null || workoutId.isEmpty) {
        Navigator.of(context).pop();
        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => WorkoutDetailScreen(
            workoutId: workoutId,
            initialWorkout: savedWorkout,
          ),
        ),
      );
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

class _WorkoutShareCard extends StatelessWidget {
  const _WorkoutShareCard({
    required this.sport,
    required this.track,
    required this.calories,
    required this.elapsed,
    required this.distance,
    required this.pace,
    required this.averageSpeed,
    required this.maxSpeed,
    required this.elevation,
    required this.shareMode,
  });

  final SportMode sport;
  final TrackingSessionDraft track;
  final String calories;
  final String elapsed;
  final String distance;
  final String pace;
  final String averageSpeed;
  final String maxSpeed;
  final String elevation;
  final WorkoutShareMode shareMode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final includeData = shareMode.includesData;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: EdgeInsets.all(includeData ? 16 : 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (includeData) ...[
              _ShareHeader(
                title: l10n.shareWorkoutTitle,
                subtitle: sport.label(l10n),
                icon: sport.icon,
              ),
              const SizedBox(height: 14),
            ],
            MapPreview(
              label: l10n.routePreview,
              routePoints: track.routePoints,
              framed: false,
              interactive: false,
              showLocateButton: false,
              showCurrentMarker: false,
              fitRoute: true,
              aspectRatio: includeData ? 0.86 : 0.66,
              highlightMarkers: _trackHighlights(l10n, track),
            ),
            if (includeData) ...[
              const SizedBox(height: 14),
              LayoutBuilder(
                builder: (context, constraints) {
                  final useThreeColumns = constraints.maxWidth >= 300;
                  final columns = useThreeColumns ? 3 : 2;
                  final gap = 6.0;
                  final tileWidth =
                      (constraints.maxWidth - (gap * (columns - 1))) / columns;
                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: [
                      _ShareStatTile(
                        width: tileWidth,
                        icon: Icons.route_rounded,
                        label: l10n.distance,
                        value: distance,
                        color: AppColors.gps,
                      ),
                      _ShareStatTile(
                        width: tileWidth,
                        icon: Icons.timer_outlined,
                        label: l10n.elapsedTime,
                        value: elapsed,
                        color: AppColors.primary,
                      ),
                      _ShareStatTile(
                        width: tileWidth,
                        icon: Icons.speed_rounded,
                        label: l10n.averageSpeed,
                        value: averageSpeed,
                        color: AppColors.accent,
                      ),
                      _ShareStatTile(
                        width: tileWidth,
                        icon: Icons.bolt_rounded,
                        label: l10n.maxSpeed,
                        value: maxSpeed,
                        color: AppColors.danger,
                      ),
                      _ShareStatTile(
                        width: tileWidth,
                        icon: Icons.timeline_rounded,
                        label: l10n.pace,
                        value: pace,
                        color: AppColors.primary,
                      ),
                      _ShareStatTile(
                        width: tileWidth,
                        icon: Icons.local_fire_department_rounded,
                        label: l10n.estimatedCalories,
                        value: calories,
                        color: AppColors.danger,
                      ),
                      _ShareStatTile(
                        width: tileWidth,
                        icon: Icons.landscape_outlined,
                        label: l10n.elevation,
                        value: elevation,
                        color: AppColors.accent,
                      ),
                    ],
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ShareStatTile extends StatelessWidget {
  const _ShareStatTile({
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

List<MapHighlightMarker> _trackHighlights(
  AppLocalizations l10n,
  TrackingSessionDraft track,
) {
  final routePoints = track.routePoints;
  if (routePoints.length < 3) return const [];

  final highlights = <MapHighlightMarker>[
    MapHighlightMarker(
      point: routePoints[routePoints.length ~/ 2],
      label: l10n.midRouteMarker,
      icon: Icons.timeline_rounded,
      color: AppColors.accent,
    ),
  ];

  final fastestPoint = track.fastestPoint;
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
