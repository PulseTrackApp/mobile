import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/modules/app_module.dart';
import '../../../core/modules/module_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/app_menu_tile.dart';
import '../../../core/ui/app_panel.dart';
import '../../../core/ui/app_top_bar.dart';
import '../../../core/ui/current_user_summary.dart';
import '../../../l10n/app_localizations.dart';
import '../../account/screens/about_screen.dart';
import '../../account/screens/delete_account_screen.dart';
import '../../account/screens/legal_screen.dart';
import '../../account/screens/support_screen.dart';
import '../../body/screens/body_progress_screen.dart';
import '../../coach/screens/super_coach_screen.dart';
import '../../goals/screens/goals_screen.dart';
import '../../history/screens/workout_history_screen.dart';
import '../../challenges/screens/challenges_screen.dart';
import '../../pricing/screens/pricing_screen.dart';
import '../../rating/screens/rating_screen.dart';
import '../../routes/screens/routes_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../settings/screens/settings_screen.dart';

class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key, this.showCloseButton = false});

  final bool showCloseButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final moduleAccess = ref.watch(moduleAccessControllerProvider).state;

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
          const SizedBox(height: 18),
          const CurrentUserSummary(compact: true),
          const SizedBox(height: 24),
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
                  locked: !moduleAccess.isEnabled(AppModule.bodyCheckins),
                  onTap: moduleAccess.isEnabled(AppModule.bodyCheckins)
                      ? () => _push(context, const BodyProgressScreen())
                      : null,
                ),
                const _MenuDivider(),
                AppMenuTile(
                  icon: Icons.history_rounded,
                  title: l10n.workoutHistoryTitle,
                  subtitle: l10n.workoutHistorySubtitle,
                  color: AppColors.gps,
                  locked: !moduleAccess.isEnabled(AppModule.workouts),
                  onTap: moduleAccess.isEnabled(AppModule.workouts)
                      ? () => _push(context, const WorkoutHistoryScreen())
                      : null,
                ),
                const _MenuDivider(),
                AppMenuTile(
                  icon: Icons.route_outlined,
                  title: l10n.routesTitle,
                  subtitle: l10n.routesSubtitle,
                  color: AppColors.gps,
                  locked: !moduleAccess.isEnabled(AppModule.routes),
                  onTap: moduleAccess.isEnabled(AppModule.routes)
                      ? () => _push(context, const RoutesScreen())
                      : null,
                ),
                const _MenuDivider(),
                AppMenuTile(
                  icon: Icons.outlined_flag_rounded,
                  title: l10n.challengesTitle,
                  subtitle: l10n.challengesSubtitle,
                  color: AppColors.accent,
                  locked: !moduleAccess.isEnabled(AppModule.challenges),
                  onTap: moduleAccess.isEnabled(AppModule.challenges)
                      ? () => _push(context, const ChallengesScreen())
                      : null,
                ),
                const _MenuDivider(),
                AppMenuTile(
                  icon: Icons.stars_rounded,
                  title: l10n.ratingTitle,
                  subtitle: l10n.ratingSubtitle,
                  color: AppColors.primary,
                  locked: !moduleAccess.isEnabled(AppModule.rating),
                  onTap: moduleAccess.isEnabled(AppModule.rating)
                      ? () => _push(context, const RatingScreen())
                      : null,
                ),
                const _MenuDivider(),
                AppMenuTile(
                  icon: Icons.flag_outlined,
                  title: l10n.goalsTitle,
                  subtitle: l10n.goalsSubtitle,
                  color: AppColors.primary,
                  locked: !moduleAccess.isEnabled(AppModule.goals),
                  onTap: moduleAccess.isEnabled(AppModule.goals)
                      ? () => _push(context, const GoalsScreen())
                      : null,
                ),
                const _MenuDivider(),
                AppMenuTile(
                  icon: Icons.auto_awesome_rounded,
                  title: l10n.coachTitle,
                  subtitle: l10n.coachSubtitle,
                  color: AppColors.danger,
                  locked: !moduleAccess.isEnabled(AppModule.coach),
                  onTap: moduleAccess.isEnabled(AppModule.coach)
                      ? () => _push(context, const SuperCoachScreen())
                      : null,
                ),
                const _MenuDivider(),
                AppMenuTile(
                  icon: Icons.workspace_premium_outlined,
                  title: l10n.pricingTitle,
                  subtitle: l10n.pricingSubtitle,
                  color: AppColors.accent,
                  onTap: () => _push(context, const PricingScreen()),
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
          const SizedBox(height: 24),
          // Section a part, et volontairement en dernier : ce sont les pages
          // qu'on cherche quand quelque chose ne va pas, pas celles qu'on ouvre
          // pour s'entrainer. Les melanger aux fonctions sportives allongerait la
          // liste principale sans rendre celles-ci plus faciles a trouver.
          Text(
            l10n.menuHelpSection,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          AppPanel(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                AppMenuTile(
                  icon: Icons.support_agent_rounded,
                  title: l10n.supportTitle,
                  subtitle: l10n.supportSubtitle,
                  color: AppColors.gps,
                  onTap: () => _push(context, const SupportScreen()),
                ),
                const _MenuDivider(),
                AppMenuTile(
                  icon: Icons.info_outline_rounded,
                  title: l10n.aboutTitle,
                  subtitle: l10n.aboutSubtitle,
                  color: AppColors.primary,
                  onTap: () => _push(context, const AboutScreen()),
                ),
                const _MenuDivider(),
                AppMenuTile(
                  icon: Icons.gavel_rounded,
                  title: l10n.legalTitle,
                  subtitle: l10n.legalSubtitle,
                  color: AppColors.dark,
                  onTap: () => _push(context, const LegalScreen()),
                ),
                const _MenuDivider(),
                AppMenuTile(
                  icon: Icons.delete_forever_outlined,
                  title: l10n.deleteAccount,
                  subtitle: l10n.deleteAccountMenuSubtitle,
                  color: AppColors.danger,
                  onTap: () => _push(context, const DeleteAccountScreen()),
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
