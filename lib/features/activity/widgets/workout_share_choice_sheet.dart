import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../models/workout_share_mode.dart';

Future<WorkoutShareMode?> showWorkoutShareChoiceSheet(BuildContext context) {
  return showModalBottomSheet<WorkoutShareMode>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      final l10n = AppLocalizations.of(context);

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.shareWorkoutChoiceTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 14),
              _ShareChoiceTile(
                icon: Icons.map_outlined,
                color: AppColors.gps,
                title: l10n.shareRouteOnlyTitle,
                subtitle: l10n.shareRouteOnlySubtitle,
                onTap: () =>
                    Navigator.of(context).pop(WorkoutShareMode.routeOnly),
              ),
              const SizedBox(height: 10),
              _ShareChoiceTile(
                icon: Icons.query_stats_rounded,
                color: AppColors.primary,
                title: l10n.shareRouteWithDataTitle,
                subtitle: l10n.shareRouteWithDataSubtitle,
                onTap: () =>
                    Navigator.of(context).pop(WorkoutShareMode.routeWithData),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _ShareChoiceTile extends StatelessWidget {
  const _ShareChoiceTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: color.withValues(alpha: 0.07),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleSmall),
                    const SizedBox(height: 3),
                    Text(subtitle, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
