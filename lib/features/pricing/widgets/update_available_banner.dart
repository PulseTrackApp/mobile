import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_providers.dart';
import '../../../core/api/billing_models.dart';
import '../../../core/api/pulse_track_api.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';

/// Exigences de version, demandees une seule fois par lancement.
///
/// La route repond sans session et n'est jamais verrouillee : l'appel tient
/// donc aussi bien avant la connexion qu'apres. Un echec ne se signale pas —
/// c'est une invitation, pas un diagnostic.
final clientRequirementsProvider = FutureProvider<ClientRequirements?>((
  ref,
) async {
  try {
    return await ref.read(pulseTrackApiProvider).getClientRequirements();
  } catch (_) {
    return null;
  }
});

/// Invite a mettre a jour l'application, **sans bloquer**.
///
/// <p>C'est la moitie manquante du verrou de version. Jusqu'ici l'application ne
/// decouvrait qu'elle etait perimee qu'au moment ou le serveur la refusait
/// (`426`), c'est-a-dire trop tard : d'un lancement a l'autre, tout s'arretait.
/// Ce bandeau apparait pendant la periode ou le serveur annonce un minimum sans
/// encore le faire respecter, et laisse le temps de mettre a jour tranquillement.
///
/// <p>Il disparait de lui-meme des que le verrou devient effectif : a ce
/// moment-la l'ecran de mise a jour prend le relais, et deux messages diraient
/// la meme chose.
class UpdateAvailableBanner extends ConsumerWidget {
  const UpdateAvailableBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requirements = ref.watch(clientRequirementsProvider).valueOrNull;
    if (requirements == null) return const SizedBox.shrink();

    // Verrou deja actif : l'ecran de mise a jour se charge du message.
    if (requirements.enforced) return const SizedBox.shrink();
    if (!isOutdated(PulseTrackApi.appVersion, requirements.minimumVersion)) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final storeUrl = requirements.androidStoreUrl;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.32)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.system_update_alt_rounded, color: AppColors.dark),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.updateAvailableBanner(requirements.minimumVersion),
              style: theme.textTheme.bodyMedium,
            ),
          ),
          // Sans adresse de magasin, un bouton n'irait nulle part : le texte
          // suffit alors a prevenir.
          if (storeUrl != null && storeUrl.isNotEmpty) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: storeUrl));
              },
              child: Text(l10n.updateAvailableAction),
            ),
          ],
        ],
      ),
    );
  }

  /// Compare deux versions `majeur.mineur.correctif`, nombre par nombre.
  ///
  /// Nombre par nombre et non caractere par caractere : `1.10.0` est posterieure
  /// a `1.9.0`, alors qu'un ordre alphabetique conclurait l'inverse et
  /// afficherait le bandeau a tort — exactement au moment ou l'application est
  /// pourtant a jour.
  ///
  /// Une valeur illisible ne declenche rien : mieux vaut ne rien dire que
  /// reclamer une mise a jour inutile.
  static bool isOutdated(String current, String minimum) {
    final left = _parse(current);
    final right = _parse(minimum);
    if (left == null || right == null) return false;

    for (var i = 0; i < 3; i++) {
      if (left[i] != right[i]) return left[i] < right[i];
    }
    return false;
  }

  static List<int>? _parse(String value) {
    final parts = value.trim().split('.');
    if (parts.isEmpty || parts.length > 3) return null;

    final numbers = <int>[0, 0, 0];
    for (var i = 0; i < parts.length; i++) {
      final parsed = int.tryParse(parts[i]);
      if (parsed == null || parsed < 0) return null;
      numbers[i] = parsed;
    }
    return numbers;
  }
}
