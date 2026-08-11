import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/ui/app_metric_tile.dart';
import '../../../l10n/app_localizations.dart';

class TodayMetrics extends StatelessWidget {
  const TodayMetrics({
    super.key,
    this.distanceKm = '0.00',
    this.movingTime = '0:00',
    this.pace = '--',
  });

  final String distanceKm;
  final String movingTime;
  final String pace;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const gap = 10.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final halfWidth = (constraints.maxWidth - gap) / 2;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            SizedBox(
              width: halfWidth,
              child: AppMetricTile(
                label: l10n.distance,
                value: distanceKm,
                unit: l10n.kilometersUnit,
                color: AppColors.primary,
              ),
            ),
            SizedBox(
              width: halfWidth,
              child: AppMetricTile(
                label: l10n.time,
                value: movingTime,
                unit: '',
                color: AppColors.gps,
              ),
            ),
            SizedBox(
              width: constraints.maxWidth,
              child: AppMetricTile(
                label: l10n.pace,
                value: pace,
                unit: l10n.paceUnit,
                color: AppColors.accent,
              ),
            ),
          ],
        );
      },
    );
  }
}
