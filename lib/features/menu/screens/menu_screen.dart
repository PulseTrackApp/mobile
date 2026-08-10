import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/ui/app_menu_tile.dart';
import '../../../core/ui/app_panel.dart';
import '../../../core/ui/app_top_bar.dart';
import '../../../l10n/app_localizations.dart';
import '../../body/screens/body_progress_screen.dart';
import '../../coach/screens/gemini_coach_screen.dart';
import '../../goals/screens/goals_screen.dart';
import '../../history/screens/workout_history_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../settings/screens/settings_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key, this.showCloseButton = false});

  final bool showCloseButton;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTopBar(
            trailing: showCloseButton
                ? IconButton(
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).closeButtonTooltip,
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  )
                : null,
          ),
          const SizedBox(height: 28),
          Text(l10n.menuTitle, style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 18),
          AppPanel(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                AppMenuTile(
                  icon: Icons.person_outline_rounded,
                  title: l10n.profileTitle,
                  subtitle: l10n.profileSubtitle,
                  color: AppColors.primary,
                  onTap: () => _push(context, const ProfileScreen()),
                ),
                const _MenuDivider(),
                AppMenuTile(
                  icon: Icons.monitor_weight_outlined,
                  title: l10n.bodyProgressTitle,
                  subtitle: l10n.bodyProgressSubtitle,
                  color: AppColors.accent,
                  onTap: () => _push(context, const BodyProgressScreen()),
                ),
                const _MenuDivider(),
                AppMenuTile(
                  icon: Icons.history_rounded,
                  title: l10n.workoutHistoryTitle,
                  subtitle: l10n.workoutHistorySubtitle,
                  color: AppColors.gps,
                  onTap: () => _push(context, const WorkoutHistoryScreen()),
                ),
                const _MenuDivider(),
                AppMenuTile(
                  icon: Icons.flag_outlined,
                  title: l10n.goalsTitle,
                  subtitle: l10n.goalsSubtitle,
                  color: AppColors.primary,
                  onTap: () => _push(context, const GoalsScreen()),
                ),
                const _MenuDivider(),
                AppMenuTile(
                  icon: Icons.auto_awesome_rounded,
                  title: l10n.coachTitle,
                  subtitle: l10n.coachSubtitle,
                  color: AppColors.danger,
                  onTap: () => _push(context, const GeminiCoachScreen()),
                ),
                const _MenuDivider(),
                AppMenuTile(
                  icon: Icons.tune_rounded,
                  title: l10n.settings,
                  subtitle: l10n.settingsSubtitle,
                  color: AppColors.dark,
                  onTap: () => _push(context, const SettingsScreen()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }
}

class _MenuDivider extends StatelessWidget {
  const _MenuDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 18,
      endIndent: 18,
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }
}
