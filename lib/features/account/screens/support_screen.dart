import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_providers.dart';
import '../../../core/api/pulse_track_api.dart';
import '../../../core/config/app_contact.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/app_button.dart';
import '../../../core/ui/app_panel.dart';
import '../../../l10n/app_localizations.dart';

/// Aide et support.
///
/// <p>Deux choses, et pas une de plus : comment nous joindre, et de quoi
/// resoudre seul les quelques ennuis qui reviennent. Les informations techniques
/// sont affichees et copiables parce qu'un signalement sans version ni compte
/// oblige a un aller-retour avant meme de commencer a chercher.
class SupportScreen extends ConsumerWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final tokenStore = ref.watch(authTokenStoreProvider);
    final email = tokenStore.email;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.supportTitle)),
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
                    Row(
                      children: [
                        const Icon(
                          Icons.support_agent_rounded,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            l10n.supportContactTitle,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(l10n.supportIntro, style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 14),
                    SelectableText(
                      AppContact.supportEmail,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Copier plutot qu'ouvrir la messagerie : ouvrir une
                    // application tierce demande une dependance de plus, et
                    // echoue en silence sur un telephone sans client de courriel.
                    AppButton.secondary(
                      label: l10n.supportCopyEmail,
                      icon: Icons.copy_rounded,
                      onPressed: () => _copy(
                        context,
                        AppContact.supportEmail,
                        l10n.supportEmailCopied,
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
                      l10n.supportDiagnosticsTitle,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    _Detail(
                      label: l10n.aboutVersionLabel,
                      value: PulseTrackApi.appVersion,
                    ),
                    _Detail(
                      label: l10n.aboutBuildLabel,
                      value: PulseTrackApi.appBuild,
                    ),
                    if (email != null && email.isNotEmpty)
                      _Detail(label: l10n.aboutAccountLabel, value: email),
                    const SizedBox(height: 6),
                    AppButton.secondary(
                      label: l10n.supportCopyDiagnostics,
                      icon: Icons.copy_rounded,
                      onPressed: () => _copy(
                        context,
                        _diagnostics(email),
                        l10n.supportDiagnosticsCopied,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text(l10n.supportFaqTitle, style: theme.textTheme.titleMedium),
              const SizedBox(height: 10),
              AppPanel(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _Faq(
                      question: l10n.supportFaqGpsQuestion,
                      answer: l10n.supportFaqGpsAnswer,
                    ),
                    _Faq(
                      question: l10n.supportFaqStatsQuestion,
                      answer: l10n.supportFaqStatsAnswer,
                    ),
                    _Faq(
                      question: l10n.supportFaqLockedQuestion,
                      answer: l10n.supportFaqLockedAnswer,
                    ),
                    _Faq(
                      question: l10n.supportFaqDataQuestion,
                      answer: l10n.supportFaqDataAnswer,
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

  String _diagnostics(String? email) {
    final lines = [
      'GymFlow ${PulseTrackApi.appVersion} (${PulseTrackApi.appBuild})',
      if (email != null && email.isNotEmpty) email,
    ];
    return lines.join('\n');
  }

  Future<void> _copy(
    BuildContext context,
    String value,
    String confirmation,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(ClipboardData(text: value));
    messenger.showSnackBar(SnackBar(content: Text(confirmation)));
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
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

class _Faq extends StatelessWidget {
  const _Faq({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ExpansionTile(
      shape: const Border(),
      collapsedShape: const Border(),
      title: Text(question, style: theme.textTheme.titleSmall),
      childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      children: [Text(answer, style: theme.textTheme.bodyMedium)],
    );
  }
}
