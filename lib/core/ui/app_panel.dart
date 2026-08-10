import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppPanel extends StatelessWidget {
  const AppPanel({
    super.key,
    required this.child,
    this.color,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final panelColor = color ?? theme.colorScheme.surfaceContainerLowest;
    final borderColor = color == null
        ? theme.colorScheme.outlineVariant
        : panelColor.withValues(alpha: 0);

    return Material(
      color: panelColor,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: borderColor),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    super.key,
    required this.value,
    this.color = AppColors.primary,
  });

  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 8,
        backgroundColor: Theme.of(context).colorScheme.outlineVariant,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}
