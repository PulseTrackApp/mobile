import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../api/api_error.dart';

Future<bool?> showEmailVerificationDialog(
  BuildContext context, {
  required Future<void> Function(String code) onSubmit,
}) {
  return showDialog<bool>(
    context: context,
    builder: (_) => _EmailVerificationDialog(onSubmit: onSubmit),
  );
}

class _EmailVerificationDialog extends StatefulWidget {
  const _EmailVerificationDialog({required this.onSubmit});

  final Future<void> Function(String code) onSubmit;

  @override
  State<_EmailVerificationDialog> createState() =>
      _EmailVerificationDialogState();
}

class _EmailVerificationDialogState extends State<_EmailVerificationDialog> {
  final _codeController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n.emailVerificationTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.emailVerificationBody),
          const SizedBox(height: 12),
          TextField(
            controller: _codeController,
            textCapitalization: TextCapitalization.characters,
            keyboardType: TextInputType.visiblePassword,
            decoration: InputDecoration(
              labelText: l10n.verificationCode,
              hintText: l10n.passwordResetCodeHint,
              prefixIcon: const Icon(Icons.pin_outlined),
            ),
          ),
        ],
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
          label: Text(l10n.verifyEmail),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      _showDialogMessage(l10n.emailVerificationRequiredFields);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await widget.onSubmit(code);
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
