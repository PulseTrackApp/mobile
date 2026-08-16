import 'package:flutter/material.dart';

import '../../../core/config/app_contact.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/app_panel.dart';
import '../../../l10n/app_localizations.dart';

/// Mentions légales : confidentialité et conditions d'utilisation.
///
/// <p><strong>Ce texte décrit ce que l'application fait réellement</strong> —
/// les données listées sont exactement celles que le serveur enregistre, et les
/// droits annoncés sont exactement ceux que l'application sait honorer
/// (l'export et la suppression existent tous les deux et sont immédiats).
///
/// <p>Il n'a pas été relu par un juriste, et l'écran le dit lui-même en tête.
/// Mieux vaut un texte honnête et marqué comme provisoire qu'un texte
/// d'apparence définitive dont personne ne répond.
class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.legalTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.32),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.legalDraftNotice,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _Section(
                icon: Icons.inventory_2_outlined,
                title: l10n.legalDataTitle,
                body: l10n.legalDataBody,
              ),
              _Section(
                icon: Icons.visibility_outlined,
                title: l10n.legalUsageTitle,
                body: l10n.legalUsageBody,
              ),
              _Section(
                icon: Icons.dns_outlined,
                title: l10n.legalHostingTitle,
                body: l10n.legalHostingBody,
              ),
              _Section(
                icon: Icons.gavel_rounded,
                title: l10n.legalRightsTitle,
                body: l10n.legalRightsBody,
              ),
              _Section(
                icon: Icons.rule_rounded,
                title: l10n.legalTermsTitle,
                body: l10n.legalTermsBody,
              ),
              AppPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.legalContactTitle,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppContact.publisher,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 2),
                    SelectableText(
                      AppContact.supportEmail,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
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

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: AppPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(title, style: theme.textTheme.titleMedium),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(body, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
