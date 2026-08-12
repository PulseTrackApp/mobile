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
                label: Text(l10n.statsPeriodWeek),
                icon: const Icon(Icons.view_week_outlined),
              ),
              ButtonSegment<_StatsPeriod>(
                value: _StatsPeriod.month,
                label: Text(l10n.statsPeriodMonth),
                icon: const Icon(Icons.calendar_view_month_outlined),
              ),
              ButtonSegment<_StatsPeriod>(
                value: _StatsPeriod.year,
                label: Text(l10n.statsPeriodYear),
                icon: const Icon(Icons.calendar_today_outlined),
              ),
            ],
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
              final totals = jsonMap(stats, 'totals');
              final series = jsonList(stats, 'series');
              final records = jsonMap(stats, 'records');

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
                      jsonInt(records, 'bestPaceSecondsPerKm'),
                      l10n,
                    ),
                  ),
                  const SizedBox(height: 10),
                  AppStatRow(
                    icon: Icons.route_rounded,
                    color: AppColors.primary,
                    label: l10n.longestDistance,
                    value: formatMetersAsKm(
                      jsonDouble(records, 'longestDistanceMeters'),
                      l10n,
                    ),
                  ),
                  const SizedBox(height: 10),
                  AppStatRow(
                    icon: Icons.flag_rounded,
                    color: AppColors.accent,
                    label: l10n.completedGoals,
                    value: l10n.zero,
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
                value: formatKm(jsonDouble(totals, 'distanceMeters')),
                unit: l10n.kilometersUnit,
                color: AppColors.primary,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: AppMetricTile(
                label: l10n.sessions,
                value: jsonInt(totals, 'sessionCount').toString(),
                unit: '',
                color: AppColors.gps,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: AppMetricTile(
                label: l10n.movingTime,
                value: formatDurationShort(
                  jsonInt(totals, 'movingDurationSeconds'),
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
                    ? jsonInt(totals, 'activeDays').toString()
                    : jsonInt(totals, 'caloriesBurned').toString(),
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
        .map(
          (bucket) => jsonDouble(jsonMap(bucket, 'totals'), 'distanceMeters'),
        )
        .fold<double>(0, (max, value) => value > max ? value : max);

    return SizedBox(
      height: 96,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(count, (index) {
          final isCurrent = index == count - 1;
          final bucket = index < series.length ? series[index] : null;
          final distance = jsonDouble(
            jsonMap(bucket, 'totals'),
            'distanceMeters',
          );
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

enum _StatsPeriod {
  week(ApiStatsPeriod.week),
  month(ApiStatsPeriod.month),
  year(ApiStatsPeriod.year);

  const _StatsPeriod(this.apiPeriod);

  final ApiStatsPeriod apiPeriod;
}
