import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_settings_controller.dart';
import '../../../core/api/api_error.dart';
import '../../../core/api/api_providers.dart';
import '../../../core/push/push_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/user/current_user_provider.dart';
import '../../../core/ui/app_button.dart';
import '../../../core/ui/email_verification_dialog.dart';
import '../../../core/ui/app_panel.dart';
import '../../../core/ui/app_password_field.dart';
import '../../../l10n/app_localizations.dart';
import '../../account/screens/delete_account_screen.dart';
import '../../tracking/models/sport_mode.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = AppSettingsScope.of(context);
    final tokenStore = ref.watch(authTokenStoreProvider);
    final currentUser = ref.watch(currentUserProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SettingsSection(
                title: l10n.settingsAppearance,
                children: [
                  _SettingsSegmentedTile<ThemeMode>(
                    icon: Icons.contrast_rounded,
                    title: l10n.settingsTheme,
                    segments: [
                      _SegmentOption(ThemeMode.system, l10n.themeSystem),
                      _SegmentOption(ThemeMode.light, l10n.themeLight),
                      _SegmentOption(ThemeMode.dark, l10n.themeDark),
                    ],
                    selected: settings.themeMode,
                    onChanged: settings.setThemeMode,
                  ),
                  _SettingsSegmentedTile<LocalePreference>(
                    icon: Icons.language_rounded,
                    title: l10n.settingsLanguage,
                    segments: [
                      _SegmentOption(
                        LocalePreference.system,
                        l10n.languageSystem,
                      ),
                      _SegmentOption(
                        LocalePreference.french,
                        l10n.languageFrench,
                      ),
                      _SegmentOption(
                        LocalePreference.english,
                        l10n.languageEnglish,
                      ),
                    ],
                    selected: settings.localePreference,
                    onChanged: settings.setLocalePreference,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _SettingsSection(
                title: l10n.settingsSport,
                children: [
                  _SettingsSegmentedTile<MeasurementUnit>(
                    icon: Icons.straighten_rounded,
                    title: l10n.settingsUnits,
                    segments: [
                      _SegmentOption(MeasurementUnit.metric, l10n.unitsMetric),
                      _SegmentOption(
                        MeasurementUnit.imperial,
                        l10n.unitsImperial,
                      ),
                    ],
                    selected: settings.measurementUnit,
                    onChanged: settings.setMeasurementUnit,
                  ),
                  _SettingsSegmentedTile<SportMode>(
                    icon: Icons.sports_rounded,
                    title: l10n.defaultSport,
                    segments: SportMode.values
                        .map(
                          (sport) => _SegmentOption(sport, sport.label(l10n)),
                        )
                        .toList(),
                    selected: settings.defaultSport,
                    onChanged: settings.setDefaultSport,
                  ),
                  _WeeklyTargetStepper(settings: settings),
                ],
              ),
              const SizedBox(height: 18),
              _SettingsSection(
                title: l10n.settingsTracking,
                children: [
                  _SettingsSegmentedTile<GpsAccuracyPreference>(
                    icon: Icons.gps_fixed_rounded,
                    title: l10n.gpsAccuracy,
                    segments: [
                      _SegmentOption(
                        GpsAccuracyPreference.balanced,
                        l10n.gpsBalanced,
                      ),
                      _SegmentOption(GpsAccuracyPreference.high, l10n.gpsHigh),
                      _SegmentOption(GpsAccuracyPreference.best, l10n.gpsBest),
                    ],
                    selected: settings.gpsAccuracy,
                    onChanged: settings.setGpsAccuracy,
                  ),
                  _SettingsSwitchTile(
                    icon: Icons.pause_circle_outline_rounded,
                    title: l10n.autoPause,
                    subtitle: l10n.autoPauseDescription,
                    value: settings.autoPause,
                    onChanged: settings.setAutoPause,
                  ),
                  _SettingsSwitchTile(
                    icon: Icons.timer_rounded,
                    title: l10n.countdown,
                    subtitle: l10n.countdownDescription,
                    value: settings.countdown,
                    onChanged: settings.setCountdown,
                  ),
                  _SettingsSwitchTile(
                    icon: Icons.volume_up_rounded,
                    title: l10n.voiceCues,
                    subtitle: l10n.voiceCuesDescription,
                    value: settings.voiceCues,
                    onChanged: settings.setVoiceCues,
                  ),
                  _SettingsSwitchTile(
                    icon: Icons.phone_android_rounded,
                    title: l10n.keepScreenAwake,
                    subtitle: l10n.keepScreenAwakeDescription,
                    value: settings.keepScreenAwake,
                    onChanged: settings.setKeepScreenAwake,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _SettingsSection(
                title: l10n.settingsPrivacy,
                children: [
                  _SettingsSwitchTile(
                    icon: Icons.route_rounded,
                    title: l10n.saveRoutes,
                    subtitle: l10n.saveRoutesDescription,
                    value: settings.saveRoutes,
                    onChanged: settings.setSaveRoutes,
                  ),
                  _SettingsSwitchTile(
                    icon: Icons.lock_outline_rounded,
                    title: l10n.privateActivities,
                    subtitle: l10n.privateActivitiesDescription,
                    value: settings.privateActivities,
                    onChanged: settings.setPrivateActivities,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _SettingsSection(
                title: l10n.settingsAccount,
                children: [
                  _AccountTile(
                    displayName: currentUser?.displayName,
                    email: tokenStore.email,
                    isAuthenticated: tokenStore.isAuthenticated,
                    emailVerified: tokenStore.emailVerified,
                    onChangePassword: () =>
                        _openChangePasswordDialog(context, ref),
                    onVerifyEmail: () =>
                        _openEmailVerificationDialog(context, ref),
                    onResendVerification: () =>
                        _resendVerificationCode(context, ref),
                    onDeleteAccount: () =>
                        _openDeleteAccount(context),
                    onLogout: () => _logout(context, ref),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openChangePasswordDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final api = ref.read(pulseTrackApiProvider);
    final completed = await showDialog<bool>(
      context: context,
      builder: (_) => _ChangePasswordDialog(
        onSubmit: ({required currentPassword, required newPassword}) async {
          await api.changePassword(
            currentPassword: currentPassword,
            newPassword: newPassword,
          );
        },
      ),
    );

    if (!context.mounted || completed != true) return;
    ref.invalidate(currentUserProvider);
    _showMessage(context, AppLocalizations.of(context).changePasswordSuccess);
  }

  Future<void> _openEmailVerificationDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final api = ref.read(pulseTrackApiProvider);
    final completed = await showEmailVerificationDialog(
      context,
      onSubmit: (code) => api.verifyEmail(code: code),
    );

    if (!context.mounted || completed != true) return;
    final successMessage = AppLocalizations.of(
      context,
    ).emailVerificationSuccess;
    await ref.read(authTokenStoreProvider).markEmailVerified();
    if (!context.mounted) return;
    _showMessage(context, successMessage);
  }

  Future<void> _resendVerificationCode(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final l10n = AppLocalizations.of(context);
    final email = ref.read(authTokenStoreProvider).email?.trim();
    if (email == null || email.isEmpty) return;

    try {
      await ref
          .read(pulseTrackApiProvider)
          .resendVerificationEmail(email: email);
      if (!context.mounted) return;
      _showMessage(context, l10n.emailVerificationCodeSent);
    } on ApiProblem catch (problem) {
      if (!context.mounted) return;
      _showMessage(context, '${l10n.apiErrorPrefix} ${problem.message}');
    } catch (_) {
      if (!context.mounted) return;
      _showMessage(context, l10n.apiUnexpectedError);
    }
  }

  /// La suppression a son propre ecran depuis qu'elle doit dire ce qu'elle
  /// efface et rappeler que l'export existe encore. Une boite de dialogue
  /// n'avait la place ni de l'un ni de l'autre.
  void _openDeleteAccount(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const DeleteAccountScreen()),
    );
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    // Avant la deconnexion, pas apres : retirer l'appareil exige un jeton
    // d'acces valide, que `logout()` efface. Sans cela, le prochain compte
    // ouvert sur ce telephone recevrait les rappels du precedent.
    await ref.read(pushRegistrarProvider).unregister();
    await ref.read(pulseTrackApiProvider).logout();

    messenger.showSnackBar(SnackBar(content: Text(l10n.signedOut)));
    navigator.popUntil((route) => route.isFirst);
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        AppPanel(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var index = 0; index < children.length; index++) ...[
                children[index],
                if (index < children.length - 1)
                  Divider(
                    height: 1,
                    indent: 18,
                    endIndent: 18,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsSegmentedTile<T> extends StatelessWidget {
  const _SettingsSegmentedTile({
    required this.icon,
    required this.title,
    required this.segments,
    required this.selected,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final List<_SegmentOption<T>> segments;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SettingsTileHeader(icon: icon, title: title),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<T>(
              segments: segments
                  .map(
                    (segment) => ButtonSegment<T>(
                      value: segment.value,
                      label: Text(segment.label),
                    ),
                  )
                  .toList(),
              selected: {selected},
              showSelectedIcon: false,
              onSelectionChanged: (selection) => onChanged(selection.first),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  const _SettingsSwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      contentPadding: const EdgeInsets.fromLTRB(14, 8, 10, 8),
      secondary: _SettingsIcon(icon: icon),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}

class _WeeklyTargetStepper extends StatelessWidget {
  const _WeeklyTargetStepper({required this.settings});

  final AppSettingsController settings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SettingsTileHeader(
                  icon: Icons.flag_rounded,
                  title: l10n.weeklyGoal,
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.weeklyTargetValue(settings.weeklyTargetKm),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          _RoundStepButton(
            tooltip: l10n.decrease,
            icon: Icons.remove_rounded,
            onPressed: () {
              settings.setWeeklyTargetKm(settings.weeklyTargetKm - 5);
            },
          ),
          const SizedBox(width: 8),
          _RoundStepButton(
            tooltip: l10n.increase,
            icon: Icons.add_rounded,
            onPressed: () {
              settings.setWeeklyTargetKm(settings.weeklyTargetKm + 5);
            },
          ),
        ],
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({
    required this.displayName,
    required this.email,
    required this.isAuthenticated,
    required this.emailVerified,
    required this.onChangePassword,
    required this.onVerifyEmail,
    required this.onResendVerification,
    required this.onDeleteAccount,
    required this.onLogout,
  });

  final String? displayName;
  final String? email;
  final bool isAuthenticated;
  final bool emailVerified;
  final VoidCallback onChangePassword;
  final VoidCallback onVerifyEmail;
  final VoidCallback onResendVerification;
  final VoidCallback onDeleteAccount;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final name = displayName?.trim();
    final displayEmail = email?.trim();
    final hasName = name != null && name.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SettingsTileHeader(
            icon: Icons.account_circle_outlined,
            title: l10n.account,
          ),
          const SizedBox(height: 10),
          Text(
            hasName ? name : l10n.connectedAccount,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (displayEmail != null && displayEmail.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              l10n.connectedAs(displayEmail),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          if (isAuthenticated) ...[
            const SizedBox(height: 12),
            _EmailVerificationStatus(
              verified: emailVerified,
              onVerifyEmail: onVerifyEmail,
              onResendVerification: onResendVerification,
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                AppButton.secondary(
                  label: l10n.changePassword,
                  icon: Icons.password_rounded,
                  onPressed: onChangePassword,
                ),
                AppButton.danger(
                  label: l10n.deleteAccount,
                  icon: Icons.delete_forever_outlined,
                  onPressed: onDeleteAccount,
                ),
              ],
            ),
          ],
          const SizedBox(height: 14),
          AppButton.danger(
            label: l10n.signOut,
            icon: Icons.logout_rounded,
            onPressed: onLogout,
          ),
        ],
      ),
    );
  }
}

class _EmailVerificationStatus extends StatelessWidget {
  const _EmailVerificationStatus({
    required this.verified,
    required this.onVerifyEmail,
    required this.onResendVerification,
  });

  final bool verified;
  final VoidCallback onVerifyEmail;
  final VoidCallback onResendVerification;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = verified ? AppColors.primary : AppColors.accent;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        border: Border.all(color: color.withValues(alpha: 0.24)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  verified
                      ? Icons.verified_outlined
                      : Icons.mark_email_unread_outlined,
                  color: color,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    verified ? l10n.emailVerified : l10n.emailNotVerified,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            if (!verified) ...[
              const SizedBox(height: 10),
              Text(
                l10n.emailVerificationBody,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  AppButton.primary(
                    label: l10n.verifyEmail,
                    icon: Icons.check_circle_outline_rounded,
                    onPressed: onVerifyEmail,
                  ),
                  AppButton.secondary(
                    label: l10n.resendVerificationCode,
                    icon: Icons.mark_email_read_outlined,
                    onPressed: onResendVerification,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog({required this.onSubmit});

  final Future<void> Function({
    required String currentPassword,
    required String newPassword,
  })
  onSubmit;

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n.changePasswordTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppPasswordField(
              controller: _currentPasswordController,
              label: l10n.currentPassword,
              hint: l10n.passwordHint,
            ),
            const SizedBox(height: 12),
            AppPasswordField(
              controller: _newPasswordController,
              label: l10n.newPassword,
              hint: l10n.passwordHint,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.close),
        ),
        FilledButton.icon(
          onPressed: _isSubmitting ? null : _submit,
          icon: _isSubmitting
              ? const SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.check_rounded),
          label: Text(l10n.changePassword),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;
    if (currentPassword.isEmpty || newPassword.isEmpty) {
      _showDialogMessage(l10n.changePasswordRequiredFields);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await widget.onSubmit(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiProblem catch (problem) {
      _showDialogMessage('${l10n.apiErrorPrefix} ${problem.message}');
    } catch (_) {
      _showDialogMessage(l10n.apiUnexpectedError);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showDialogMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _SettingsTileHeader extends StatelessWidget {
  const _SettingsTileHeader({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SettingsIcon(icon: icon),
        const SizedBox(width: 12),
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
      ],
    );
  }
}

class _SettingsIcon extends StatelessWidget {
  const _SettingsIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: AppColors.primary, size: 22),
    );
  }
}

class _RoundStepButton extends StatelessWidget {
  const _RoundStepButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(tooltip: tooltip, onPressed: onPressed, icon: Icon(icon));
  }
}

class _SegmentOption<T> {
  const _SegmentOption(this.value, this.label);

  final T value;
  final String label;
}
