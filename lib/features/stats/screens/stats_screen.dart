import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/ui/app_metric_tile.dart';
import '../../../core/ui/app_panel.dart';
import '../../../core/ui/app_stat_row.dart';
import '../../../core/ui/app_top_bar.dart';
import '../../../l10n/app_localizations.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  _StatsPeriod _period = _StatsPeriod.week;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
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
              setState(() => _period = selection.first);
            },
          ),
          const SizedBox(height: 18),
          _StatsOverviewGrid(period: _period),
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
                _PeriodBars(period: _period),
                const SizedBox(height: 12),
                Text(
                  l10n.statsEmptyPeriod,
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
            value: l10n.emptyPace,
          ),
          const SizedBox(height: 10),
          AppStatRow(
            icon: Icons.route_rounded,
            color: AppColors.primary,
            label: l10n.longestDistance,
            value: l10n.emptyDistanceKm,
          ),
          const SizedBox(height: 10),
          AppStatRow(
            icon: Icons.flag_rounded,
            color: AppColors.accent,
            label: l10n.completedGoals,
            value: l10n.zero,
          ),
        ],
      ),
    );
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
  const _StatsOverviewGrid({required this.period});

  final _StatsPeriod period;

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
                value: '0.00',
                unit: l10n.kilometersUnit,
                color: AppColors.primary,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: AppMetricTile(
                label: l10n.sessions,
                value: '0',
                unit: '',
                color: AppColors.gps,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: AppMetricTile(
                label: l10n.movingTime,
                value: '0',
                unit: l10n.hoursUnit,
                color: AppColors.accent,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: AppMetricTile(
                label: period == _StatsPeriod.week
                    ? l10n.activeDays
                    : l10n.caloriesBurned,
                value: '0',
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
  const _PeriodBars({required this.period});

  final _StatsPeriod period;

  @override
  Widget build(BuildContext context) {
    final count = switch (period) {
      _StatsPeriod.week => 7,
      _StatsPeriod.month => 4,
      _StatsPeriod.year => 12,
    };

    return SizedBox(
      height: 96,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(count, (index) {
          final isCurrent = index == count - 1;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: index == count - 1 ? 0 : 6),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: isCurrent
                      ? AppColors.primary.withValues(alpha: 0.32)
                      : Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const SizedBox(height: 10),
              ),
            ),
          );
        }),
      ),
    );
  }
}

enum _StatsPeriod { week, month, year }
