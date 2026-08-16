import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_providers.dart';
import '../../../core/api/pulse_track_api.dart';
import '../../../core/config/app_contact.dart';
import '../../../core/ui/app_button.dart';
import '../../../core/ui/app_panel.dart';
import '../../../core/ui/pulse_track_logo.dart';
import '../../../l10n/app_localizations.dart';

/// À propos : ce qu'est l'application, quelle version tourne, et qui l'édite.
///
/// <p>La version affichée est celle que l'API reçoit dans ses en-têtes, prise à
/// la même source. Un écran qui annoncerait autre chose rendrait tout
/// signalement d'anomalie trompeur, et c'est précisément l'écran qu'on ouvre
/// pour signaler une anomalie.
class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final api = ref.watch(pulseTrackApiProvider);
    final email = ref.watch(authTokenStoreProvider).email;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const PulseTrackLogo(size: 54),
                    const SizedBox(height: 16),
                    Text(l10n.aboutIntro, style: theme.textTheme.bodyLarge),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              AppPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Line(
                      label: l10n.aboutVersionLabel,
                      value: PulseTrackApi.appVersion,
                    ),
                    _Line(
                      label: l10n.aboutBuildLabel,
                      value: PulseTrackApi.appBuild,
                    ),
                    if (email != null && email.isNotEmpty)
                      _Line(label: l10n.aboutAccountLabel, value: email),
                    _Line(label: l10n.aboutServerLabel, value: api.baseUrl),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              AppPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.aboutPublisherTitle,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppContact.publisher,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    SelectableText(
                      AppContact.supportEmail,
                      style: theme.textTheme.bodyMedium,
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
                      l10n.aboutOpenSourceTitle,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    // Obligation des licences des bibliotheques utilisees, et pas
                    // une politesse : la page est fournie par Flutter, qui la
                    // tient a jour tout seul.
                    AppButton.secondary(
                      label: l10n.aboutOpenSourceButton,
                      icon: Icons.article_outlined,
                      onPressed: () => showLicensePage(
                        context: context,
                        applicationName: 'GymFlow',
                        applicationVersion: PulseTrackApi.appVersion,
                        applicationLegalese: AppContact.publisher,
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

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(label, style: theme.textTheme.bodySmall),
          ),
          Expanded(
            child: SelectableText(value, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
