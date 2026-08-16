import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_contract.dart';
import '../../../core/api/api_formatters.dart';
import '../../../core/api/api_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/app_metric_tile.dart';
import '../../../core/ui/app_panel.dart';
import '../../../core/ui/app_refresh_scroll_view.dart';
import '../../../core/ui/app_stat_row.dart';
import '../../../core/ui/app_top_bar.dart';
import '../../../l10n/app_localizations.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  _StatsPeriod _period = _StatsPeriod.week;
  Future<Map<String, dynamic>>? _future;

  @override
  void initState() {
    super.initState();
    _future = _loadStats();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppRefreshScrollView(
      onRefresh: _refresh,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppTopBar(),
          const SizedBox(height: 28),
          Text(
            l10n.performance,
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 8),
          Text(
            _periodTitle(l10n),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 18),
          SegmentedButton<_StatsPeriod>(
            segments: [
              ButtonSegment<_StatsPeriod>(
                value: _StatsPeriod.week,
                label: _PeriodSegmentLabel(l10n.statsPeriodWeek),
                icon: const Icon(Icons.view_week_outlined),
              ),
              ButtonSegment<_StatsPeriod>(
                value: _StatsPeriod.month,
                label: _PeriodSegmentLabel(l10n.statsPeriodMonth),
                icon: const Icon(Icons.calendar_view_month_outlined),
              ),
              ButtonSegment<_StatsPeriod>(
                value: _StatsPeriod.year,
                label: _PeriodSegmentLabel(l10n.statsPeriodYear),
                icon: const Icon(Icons.calendar_today_outlined),
              ),
            ],
            style: const ButtonStyle(
              visualDensity: VisualDensity.compact,
              textStyle: WidgetStatePropertyAll(
                TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
            selected: {_period},
            onSelectionChanged: (selection) {
              setState(() {
                _period = selection.first;
                _future = _loadStats();
              });
            },
          ),
          const SizedBox(height: 18),
          FutureBuilder<Map<String, dynamic>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return AppPanel(
                  child: Text(
                    l10n.apiUnexpectedError,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                );
              }

              final stats = snapshot.data;
              final totals = _statsTotals(stats);
              final series = _statsSeries(stats);
              final records = _statsRecords(stats);

              return Column(
                children: [
                  _StatsOverviewGrid(period: _period, totals: totals),
                  const SizedBox(height: 18),
                  AppPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.statsTrend,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 14),
                        _PeriodBars(period: _period, series: series),
                        const SizedBox(height: 12),
                        Text(
                          series.isEmpty
                              ? l10n.statsEmptyPeriod
                              : '${jsonString(stats, 'start') ?? ''} - ${jsonString(stats, 'end') ?? ''}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  AppStatRow(
                    icon: Icons.speed_rounded,
                    color: AppColors.gps,
                    label: l10n.bestPace,
                    value: formatPace(
                      _firstPositiveInt([
                        jsonInt(records, 'bestPaceSecondsPerKm'),
                        jsonInt(stats, 'bestPaceSecondsPerKm'),
                      ]),
                      l10n,
                    ),
                  ),
                  const SizedBox(height: 10),
                  AppStatRow(
                    icon: Icons.route_rounded,
                    color: AppColors.primary,
                    label: l10n.longestDistance,
                    value: formatMetersAsKm(
                      _firstPositiveDouble([
                        jsonDouble(records, 'longestDistanceMeters'),
                        jsonDouble(stats, 'longestDistanceMeters'),
                      ]),
                      l10n,
                    ),
                  ),
                  const SizedBox(height: 10),
                  AppStatRow(
                    icon: Icons.flag_rounded,
                    color: AppColors.accent,
                    label: l10n.completedGoals,
                    value: _firstPositiveInt([
                      jsonInt(records, 'completedGoals'),
                      jsonInt(stats, 'completedGoals'),
                      jsonInt(totals, 'completedGoals'),
                    ]).toString(),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> _loadStats() {
    return ref
        .read(pulseTrackApiProvider)
        .getStats(period: _period.apiPeriod, zone: gymFlowDefaultZone);
  }

  Future<void> _refresh() async {
    final future = _loadStats();
    setState(() => _future = future);

    try {
      await future;
    } catch (_) {}
  }

  String _periodTitle(AppLocalizations l10n) {
    return switch (_period) {
      _StatsPeriod.week => l10n.statsThisWeek,
      _StatsPeriod.month => l10n.statsThisMonth,
      _StatsPeriod.year => l10n.statsThisYear,
    };
  }
}

class _PeriodSegmentLabel extends StatelessWidget {
  const _PeriodSegmentLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        label,
        maxLines: 1,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _StatsOverviewGrid extends StatelessWidget {
  const _StatsOverviewGrid({required this.period, required this.totals});

  final _StatsPeriod period;
  final Map<String, dynamic>? totals;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const gap = 10.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - gap) / 2;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            SizedBox(
              width: itemWidth,
              child: AppMetricTile(
                label: l10n.distance,
                value: formatKm(
                  _firstPositiveDouble([
                    jsonDouble(totals, 'distanceMeters'),
                    jsonDouble(totals, 'distance'),
                  ]),
                ),
                unit: l10n.kilometersUnit,
                color: AppColors.primary,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: AppMetricTile(
                label: l10n.sessions,
                value: _firstPositiveInt([
                  jsonInt(totals, 'sessionCount'),
                  jsonInt(totals, 'sessionsCount'),
                  jsonInt(totals, 'workoutsCount'),
                ]).toString(),
                unit: '',
                color: AppColors.gps,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: AppMetricTile(
                label: l10n.movingTime,
                value: formatDurationShort(
                  _firstPositiveInt([
                    jsonInt(totals, 'movingDurationSeconds'),
                    jsonInt(totals, 'durationSeconds'),
                    jsonInt(totals, 'activeDurationSeconds'),
                  ]),
                  l10n,
                ),
                unit: '',
                color: AppColors.accent,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: AppMetricTile(
                label: period == _StatsPeriod.week
                    ? l10n.activeDays
                    : l10n.caloriesBurned,
                value: period == _StatsPeriod.week
                    ? _firstPositiveInt([
                        jsonInt(totals, 'activeDays'),
                        jsonInt(totals, 'daysActive'),
                      ]).toString()
                    : _firstPositiveInt([
                        jsonInt(totals, 'caloriesBurned'),
                        jsonInt(totals, 'calories'),
                      ]).toString(),
                unit: period == _StatsPeriod.week ? '' : 'kcal',
                color: AppColors.danger,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PeriodBars extends StatelessWidget {
  const _PeriodBars({required this.period, required this.series});

  final _StatsPeriod period;
  final List<Map<String, dynamic>> series;

  @override
  Widget build(BuildContext context) {
    final count = switch (period) {
      _StatsPeriod.week => 7,
      _StatsPeriod.month => 4,
      _StatsPeriod.year => 12,
    };

    final maxDistance = series
        .map((bucket) {
          final bucketTotals = jsonMap(bucket, 'totals') ?? bucket;
          return _firstPositiveDouble([
            jsonDouble(bucketTotals, 'distanceMeters'),
            jsonDouble(bucketTotals, 'distance'),
          ]);
        })
        .fold<double>(0, (max, value) => value > max ? value : max);

    return SizedBox(
      height: 96,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(count, (index) {
          final isCurrent = index == count - 1;
          final bucket = index < series.length ? series[index] : null;
          final bucketTotals = jsonMap(bucket, 'totals') ?? bucket;
          final distance = _firstPositiveDouble([
            jsonDouble(bucketTotals, 'distanceMeters'),
            jsonDouble(bucketTotals, 'distance'),
          ]);
          final ratio = maxDistance <= 0
              ? 0.08
              : (distance / maxDistance).clamp(0.08, 1.0);

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: index == count - 1 ? 0 : 6),
              child: FractionallySizedBox(
                heightFactor: ratio,
                alignment: Alignment.bottomCenter,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? AppColors.primary.withValues(alpha: 0.32)
                        : Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const SizedBox(height: 96),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

Map<String, dynamic>? _statsTotals(Map<String, dynamic>? stats) {
  return jsonMap(stats, 'totals') ?? jsonMap(stats, 'summary') ?? stats;
}

Map<String, dynamic>? _statsRecords(Map<String, dynamic>? stats) {
  return jsonMap(stats, 'records') ?? jsonMap(stats, 'best') ?? stats;
}

List<Map<String, dynamic>> _statsSeries(Map<String, dynamic>? stats) {
  final series = jsonList(stats, 'series');
  if (series.isNotEmpty) return series;
  final buckets = jsonList(stats, 'buckets');
  if (buckets.isNotEmpty) return buckets;
  return jsonList(stats, 'items');
}

double _firstPositiveDouble(List<double> values) {
  for (final value in values) {
    if (value > 0) return value;
  }
  return 0;
}

int _firstPositiveInt(List<int> values) {
  for (final value in values) {
    if (value > 0) return value;
  }
  return 0;
}

enum _StatsPeriod {
  week(ApiStatsPeriod.week),
  month(ApiStatsPeriod.month),
  year(ApiStatsPeriod.year);

  const _StatsPeriod(this.apiPeriod);

  final ApiStatsPeriod apiPeriod;
}
