import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Champ de mot de passe masqué, avec bascule d'affichage.
///
/// Extrait des réglages le jour où la suppression de compte a eu son propre
/// écran : deux copies du même champ auraient divergé à la première correction,
/// et c'est précisément le champ sur lequel une divergence se remarque le moins.
class AppPasswordField extends StatefulWidget {
  const AppPasswordField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final ValueChanged<String>? onSubmitted;

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return TextField(
      controller: widget.controller,
      obscureText: _obscure,
      keyboardType: TextInputType.visiblePassword,
      onSubmitted: widget.onSubmitted,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          tooltip: _obscure ? l10n.showPassword : l10n.hidePassword,
          onPressed: () => setState(() => _obscure = !_obscure),
          icon: Icon(
            _obscure
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
        ),
      ),
    );
  }
}
