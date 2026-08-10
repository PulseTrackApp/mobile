import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  const AppButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  }) : _variant = _AppButtonVariant.primary;

  const AppButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  }) : _variant = _AppButtonVariant.secondary;

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final _AppButtonVariant _variant;

  @override
  Widget build(BuildContext context) {
    final child = Text(label);

    if (icon == null) {
      return switch (_variant) {
        _AppButtonVariant.primary => FilledButton(
          onPressed: onPressed,
          child: child,
        ),
        _AppButtonVariant.secondary => OutlinedButton(
          onPressed: onPressed,
          child: child,
        ),
      };
    }

    return switch (_variant) {
      _AppButtonVariant.primary => FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: child,
      ),
      _AppButtonVariant.secondary => OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: child,
      ),
    };
  }
}

enum _AppButtonVariant { primary, secondary }
