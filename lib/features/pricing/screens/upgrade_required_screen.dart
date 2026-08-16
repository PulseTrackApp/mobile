import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/ui/app_button.dart';
import '../../../core/ui/app_panel.dart';
import '../../../core/ui/app_top_bar.dart';
import '../../../core/ui/pulse_track_logo.dart';
import '../../../l10n/app_localizations.dart';

/// Écran affiché quand l'API refuse cette version de l'application.
///
/// Il doit pouvoir s'afficher **sans session** : le refus s'applique aussi à la
/// connexion et à l'inscription, sinon un vieil APK contournerait le verrou en
/// créant simplement un compte neuf. C'est donc un écran autonome, sans barre de
/// navigation et sans rien qui suppose un utilisateur connu.
///
/// L'adresse du magasin est copiée dans le presse-papiers plutôt qu'ouverte
/// directement : ouvrir une application tierce demanderait `url_launcher`, une
/// dépendance de plus pour un écran que l'on espère ne jamais montrer. Si le
/// verrou est un jour réellement activé, ce sera le moment de l'ajouter.
class UpgradeRequiredScreen extends StatelessWidget {
  const UpgradeRequiredScreen({
    super.key,
    this.minimumVersion,
    this.storeUrl,
    this.onRetry,
  });

  /// Version minimale annoncée par le serveur.
  final String? minimumVersion;

  /// Adresse du magasin. `null` quand le serveur n'en a pas configuré : on
  /// n'affiche alors rien plutôt qu'un bouton qui ne mène nulle part.
  final String? storeUrl;

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final hasStore = storeUrl != null && storeUrl!.isNotEmpty;

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
                      l10n.upgradeRequiredTitle,
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l10n.upgradeRequiredBody,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    if (minimumVersion != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        l10n.upgradeRequiredMinimum(minimumVersion!),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white60,
                        ),
                      ),
                    ],
                    if (hasStore) ...[
                      const SizedBox(height: 16),
                      SelectableText(
                        storeUrl!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white60,
                        ),
                      ),
                      const SizedBox(height: 12),
                      AppButton.primary(
                        label: l10n.upgradeRequiredCopyLink,
                        onPressed: () => _copyStoreLink(context),
                      ),
                    ],
                    if (onRetry != null) ...[
                      const SizedBox(height: 12),
                      AppButton.secondary(
                        label: l10n.upgradeRequiredRetry,
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

  Future<void> _copyStoreLink(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.maybeOf(context);
    await Clipboard.setData(ClipboardData(text: storeUrl!));
    messenger?.showSnackBar(
      SnackBar(content: Text(l10n.upgradeRequiredLinkCopied)),
    );
  }
}
