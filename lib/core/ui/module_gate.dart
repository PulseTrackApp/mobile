import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../modules/app_module.dart';
import '../modules/module_providers.dart';
import '../theme/app_colors.dart';
import 'app_panel.dart';
import 'app_top_bar.dart';

class ModuleGate extends ConsumerWidget {
  const ModuleGate({
    super.key,
    required this.module,
    required this.child,
    this.showTopBar = true,
  });

  final AppModule module;
  final Widget child;
  final bool showTopBar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final access = ref.watch(moduleAccessControllerProvider).state;
    if (access.isEnabled(module)) return child;

    return ModuleLockedView(module: module, showTopBar: showTopBar);
  }
}

class ModuleLockedView extends StatelessWidget {
  const ModuleLockedView({
    super.key,
    required this.module,
    this.showTopBar = true,
  });

  final AppModule module;
  final bool showTopBar;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final moduleLabel = module.label(l10n);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showTopBar) ...[const AppTopBar(), const SizedBox(height: 28)],
          AppPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    color: AppColors.danger,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  l10n.moduleLockedTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.moduleLockedBody(moduleLabel),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
