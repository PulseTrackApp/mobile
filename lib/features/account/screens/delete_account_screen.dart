import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_error.dart';
import '../../../core/api/api_providers.dart';
import '../../../core/push/push_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/app_button.dart';
import '../../../core/ui/app_panel.dart';
import '../../../core/ui/app_password_field.dart';
import '../../../l10n/app_localizations.dart';

/// Suppression définitive du compte.
///
/// <p>Un écran plutôt qu'une boîte de dialogue, et ce n'est pas cosmétique :
/// c'est le geste le plus irréversible de l'application, et une boîte qu'on
/// referme d'un geste ne laisse pas la place d'expliquer ce qui disparaît ni de
/// rappeler que l'export existe encore.
///
/// <p>Trois barrières, dans cet ordre : dire ce qui est effacé, proposer
/// l'export, puis exiger le mot de passe **et** une confirmation explicite. Le
/// mot de passe seul ne suffirait pas — il est enregistré dans bien des
/// téléphones.
class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() =>
      _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  final _password = TextEditingController();
  bool _confirmed = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.deleteAccountTitle)),
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
                          Icons.warning_amber_rounded,
                          color: AppColors.danger,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            l10n.deleteAccountTitle,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l10n.deleteAccountScreenIntro,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l10n.deleteAccountExportFirst,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
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
                      l10n.deleteAccountBody,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 14),
                    AppPasswordField(
                      controller: _password,
                      label: l10n.password,
                      hint: l10n.passwordHint,
                    ),
                    const SizedBox(height: 6),
                    CheckboxListTile(
                      value: _confirmed,
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(l10n.deleteAccountConfirmLabel),
                      onChanged: _isSubmitting
                          ? null
                          : (value) =>
                                setState(() => _confirmed = value == true),
                    ),
                    const SizedBox(height: 10),
                    AppButton.danger(
                      label: l10n.deleteAccountFinalButton,
                      icon: Icons.delete_forever_outlined,
                      // Bouton inactif tant que les deux conditions ne sont pas
                      // reunies : un refus apres coup se lit comme une panne, la
                      // ou un bouton grise se lit comme une etape manquante.
                      onPressed: _isSubmitting || !_confirmed
                          ? null
                          : _submit,
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

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final password = _password.text;
    if (password.isEmpty) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.deleteAccountRequiredFields)),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      // Retirer l'appareil avant, pas apres : la suppression invalide la
      // session, et sans cela ce telephone garderait des rappels d'un compte qui
      // n'existe plus.
      await ref.read(pushRegistrarProvider).unregister();
      await ref.read(pulseTrackApiProvider).deleteAccount(password: password);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.deleteAccountSuccess)),
      );
      navigator.popUntil((route) => route.isFirst);
    } on ApiProblem catch (problem) {
      messenger.showSnackBar(
        SnackBar(content: Text('${l10n.apiErrorPrefix} ${problem.message}')),
      );
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.apiUnexpectedError)));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
