import 'package:flutter/material.dart';

import '../../../core/config/app_contact.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/app_button.dart';
import '../../../core/ui/app_panel.dart';
import '../../../core/ui/app_top_bar.dart';
import '../../../core/ui/pulse_track_logo.dart';
import '../../../l10n/app_localizations.dart';

/// Écran affiché quand l'API refuse un compte suspendu.
///
/// <p>Autonome, sans barre de navigation : la suspension coupe les sessions en
/// cours, si bien que l'application se retrouve le plus souvent déconnectée. Cet
/// écran doit donc s'afficher sans supposer un utilisateur connu.
///
/// <p><strong>Il dit la raison.</strong> Le message vient du serveur et porte
/// l'explication saisie par l'administrateur. Une porte fermée sans motif ne
/// laisse aucun recours — et sans elle, l'utilisateur croirait à une panne et
/// retaperait son mot de passe indéfiniment.
///
/// <p>Le bouton « réessayer » ne débloque rien tant que le serveur refuse
/// toujours ; il est là parce qu'un écran sans issue est une prison, et parce
/// qu'une réouverture doit pouvoir se constater sans réinstaller l'application.
class AccountDisabledScreen extends StatelessWidget {
  const AccountDisabledScreen({super.key, this.message, this.onRetry});

  /// Explication rédigée côté serveur, raison comprise.
  final String? message;

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppTopBar(),
              const SizedBox(height: 28),
              AppPanel(
                color: AppColors.dark,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const PulseTrackLogo(size: 54, showWordmark: false),
                    const SizedBox(height: 18),
                    Text(
                      l10n.accountDisabledTitle,
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      message == null || message!.isEmpty
                          ? l10n.accountDisabledBody
                          : message!,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              AppPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.accountDisabledContactTitle,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.accountDisabledContactBody,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 10),
                    SelectableText(
                      AppContact.supportEmail,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    if (onRetry != null) ...[
                      const SizedBox(height: 16),
                      AppButton.secondary(
                        label: l10n.accountDisabledRetry,
                        icon: Icons.refresh_rounded,
                        onPressed: onRetry,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
