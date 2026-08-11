import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../api/api_providers.dart';
import '../theme/app_colors.dart';
import '../user/current_user_provider.dart';
import 'app_panel.dart';

class CurrentUserSummary extends ConsumerWidget {
  const CurrentUserSummary({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokenStore = ref.watch(authTokenStoreProvider);
    final user = ref.watch(currentUserProvider).valueOrNull;
    final displayName = user?.displayName?.trim();
    final email = user?.email?.trim() ?? tokenStore.email?.trim();
    final hasDisplayName = displayName != null && displayName.isNotEmpty;
    final title = hasDisplayName
        ? l10n.userGreeting(displayName)
        : l10n.connectedAccount;
    final subtitle = email == null || email.isEmpty
        ? null
        : l10n.connectedAs(email);

    return AppPanel(
      padding: EdgeInsets.all(compact ? 14 : 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: compact ? 20 : 23,
            backgroundColor: AppColors.primary.withValues(alpha: 0.13),
            foregroundColor: AppColors.primary,
            child: Text(
              _initial(displayName ?? email),
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _initial(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return '?';
  return trimmed.characters.first.toUpperCase();
}
