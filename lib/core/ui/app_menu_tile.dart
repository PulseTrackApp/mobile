import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppMenuTile extends StatelessWidget {
  const AppMenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.color = AppColors.primary,
    this.locked = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Color color;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = locked ? Theme.of(context).disabledColor : color;

    return ListTile(
      onTap: onTap,
      enabled: onTap != null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: effectiveColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: effectiveColor),
      ),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
      trailing: Icon(
        locked ? Icons.lock_outline_rounded : Icons.chevron_right_rounded,
      ),
    );
  }
}
