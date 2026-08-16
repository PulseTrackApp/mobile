import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_providers.dart';
import '../../../core/api/billing_models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/app_button.dart';
import '../../../core/ui/app_panel.dart';
import '../../../core/ui/app_top_bar.dart';
import '../../../core/ui/pulse_track_logo.dart';
import '../../../l10n/app_localizations.dart';

/// Écran de tarifs, servi par le catalogue du serveur.
///
/// Les offres, leurs prix et leurs libellés viennent tous de
/// `GET /api/v1/billing/plans` : rien n'est codé en dur ici. C'est ce qui permet
/// à Nicolas de corriger un montant sans nouvelle version de l'application, et
/// c'est indispensable puisque les prix actuels sont des valeurs d'attente.
///
/// `priceLabel` est affiché tel quel — la mise en forme est faite côté serveur
/// pour qu'Android et iOS montrent exactement le même texte.
class PricingScreen extends ConsumerStatefulWidget {
  const PricingScreen({
    super.key,
    this.paymentRequired = false,
    this.onRetryAccess,
  });

  /// Mode « mur de paiement » : l'écran devient la seule chose visible, sans
  /// barre de navigation, parce que l'accès est refusé par le serveur.
  final bool paymentRequired;

  final VoidCallback? onRetryAccess;

  @override
  ConsumerState<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends ConsumerState<PricingScreen> {
  late Future<List<BillingPlan>> _plans;
  late Future<SubscriptionState?> _subscription;

  @override
  void initState() {
    super.initState();
    final api = ref.read(pulseTrackApiProvider);
    _plans = api.getBillingPlans();
    // L'etat d'acces ne doit jamais empecher l'ecran de s'afficher : sans lui on
    // montre les tarifs, ce qui reste utile. C'est l'inverse qui serait absurde.
    _subscription = api.getSubscription().then<SubscriptionState?>(
      (state) => state,
      onError: (_) => null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: widget.paymentRequired
          ? null
          : AppBar(title: Text(l10n.pricingTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.paymentRequired) ...[
                const AppTopBar(),
                const SizedBox(height: 28),
              ],
              AppPanel(
                color: widget.paymentRequired ? AppColors.dark : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const PulseTrackLogo(size: 54, showWordmark: false),
                    const SizedBox(height: 18),
                    Text(
                      widget.paymentRequired
                          ? l10n.pricingRequiredTitle
                          : l10n.pricingTitle,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: widget.paymentRequired ? Colors.white : null,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.paymentRequired
                          ? l10n.pricingRequiredBody
                          : l10n.pricingSubtitle,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: widget.paymentRequired ? Colors.white70 : null,
                      ),
                    ),
                    if (widget.paymentRequired &&
                        widget.onRetryAccess != null) ...[
                      const SizedBox(height: 18),
                      AppButton.primary(
                        label: l10n.pricingRetryAccess,
                        icon: Icons.refresh_rounded,
                        onPressed: widget.onRetryAccess,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _SubscriptionPanel(subscription: _subscription),
              const SizedBox(height: 18),
              _PlanList(
                plans: _plans,
                suggestedPlanCode: ref
                    .watch(authTokenStoreProvider)
                    .suggestedPlanCode,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanList extends StatelessWidget {
  const _PlanList({required this.plans, this.suggestedPlanCode});

  final Future<List<BillingPlan>> plans;

  /// Offre mise en avant par le refus de paiement, quand l'ecran vient de la.
  final String? suggestedPlanCode;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BillingPlan>>(
      future: plans,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final catalogue = snapshot.data ?? const <BillingPlan>[];
        // Catalogue injoignable ou vide : on ne montre rien plutot qu'une liste
        // inventee. Le texte d'introduction dit deja que les offres arrivent, ce
        // qui reste vrai et n'engage aucun prix.
        if (catalogue.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            for (final plan in catalogue) ...[
              _PlanCard(
                plan: plan,
                suggested: plan.code == suggestedPlanCode,
              ),
              const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan, this.suggested = false});

  final BillingPlan plan;

  /// Offre que le serveur a jointe a son refus : on la souligne, c'est celle
  /// vers laquelle il oriente.
  final bool suggested;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    // Une offre qui n'est pas en vente est peinte en gris et **sans son prix**.
    // Annoncer un montant qu'on ne peut pas encaisser fait deux dégâts : la
    // question « pourquoi 2 000 et je ne peux pas payer ? », et un chiffre qui
    // s'installe dans les têtes alors qu'il n'est pas arrêté. « À venir » dit
    // tout ce qu'il y a à dire aujourd'hui. Le prix réapparaîtra tout seul
    // quand le serveur passera l'offre en `AVAILABLE`.
    final color = plan.isComingSoon
        ? theme.colorScheme.onSurfaceVariant
        : suggested || plan.highlighted
        ? AppColors.gps
        : AppColors.primary;
    final textColor = plan.isComingSoon
        ? theme.colorScheme.onSurfaceVariant
        : null;

    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  plan.highlighted
                      ? Icons.emoji_events_outlined
                      : Icons.directions_run_rounded,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: textColor,
                      ),
                    ),
                    if (!plan.isComingSoon && plan.priceLabel.isNotEmpty)
                      Text(
                        plan.priceLabel,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                  ],
                ),
              ),
              if (plan.isComingSoon)
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.28),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    child: Text(
                      l10n.pricingComingSoon,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.dark,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (plan.description.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              plan.description,
              style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
            ),
          ],
          const SizedBox(height: 14),
          ...plan.features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded, size: 18, color: color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      feature,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bouton volontairement inactif : rien n'est en vente. Le rendre
          // cliquable pour ouvrir un ecran vide serait pire que pas de bouton.
          if (plan.isComingSoon)
            const SizedBox.shrink()
          else
            AppButton.primary(label: plan.name, onPressed: null),
        ],
      ),
    );
  }
}


/// L'etat d'acces du compte, tel que le serveur le decrit.
///
/// On affiche ses phrases telles quelles : elles sont redigees cote serveur pour
/// qu'Android et iOS disent la meme chose, et pour rester encourageantes meme
/// quand l'acces est perdu.
class _SubscriptionPanel extends StatelessWidget {
  const _SubscriptionPanel({required this.subscription});

  final Future<SubscriptionState?> subscription;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SubscriptionState?>(
      future: subscription,
      builder: (context, snapshot) {
        final state = snapshot.data;
        // Injoignable : on ne dit rien plutot que d'inventer un etat d'acces.
        if (state == null) return const SizedBox.shrink();

        final theme = Theme.of(context);
        final color = state.accessGranted
            ? AppColors.primary
            : AppColors.danger;

        return AppPanel(
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  state.accessGranted
                      ? Icons.verified_outlined
                      : Icons.lock_clock_outlined,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(state.headline, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(state.message, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
