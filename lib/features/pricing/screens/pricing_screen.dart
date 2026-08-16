import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/ui/app_button.dart';
import '../../../core/ui/app_panel.dart';
import '../../../core/ui/app_top_bar.dart';
import '../../../core/ui/pulse_track_logo.dart';
import '../../../l10n/app_localizations.dart';

class PricingScreen extends StatelessWidget {
  const PricingScreen({
    super.key,
    this.paymentRequired = false,
    this.onRetryAccess,
  });

  final bool paymentRequired;
  final VoidCallback? onRetryAccess;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: paymentRequired ? null : AppBar(title: Text(l10n.pricingTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (paymentRequired) ...[
                const AppTopBar(),
                const SizedBox(height: 28),
              ],
              AppPanel(
                color: paymentRequired ? AppColors.dark : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const PulseTrackLogo(size: 54, showWordmark: false),
                    const SizedBox(height: 18),
                    Text(
                      paymentRequired
                          ? l10n.pricingRequiredTitle
                          : l10n.pricingTitle,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: paymentRequired ? Colors.white : null,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      paymentRequired
                          ? l10n.pricingRequiredBody
                          : l10n.pricingSubtitle,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: paymentRequired ? Colors.white70 : null,
                      ),
                    ),
                    if (paymentRequired && onRetryAccess != null) ...[
                      const SizedBox(height: 18),
                      AppButton.primary(
                        label: l10n.pricingRetryAccess,
                        icon: Icons.refresh_rounded,
                        onPressed: onRetryAccess,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _PlanCard(
                icon: Icons.directions_run_rounded,
                title: l10n.pricingPlanEssential,
                items: [
                  l10n.pricingFeatureTracking,
                  l10n.pricingFeatureStats,
                  l10n.pricingFeatureHistory,
                ],
                color: AppColors.primary,
              ),
              const SizedBox(height: 12),
              _PlanCard(
                icon: Icons.emoji_events_outlined,
                title: l10n.pricingPlanPerformance,
                items: [
                  l10n.pricingFeatureChallenges,
                  l10n.pricingFeatureRouteReplay,
                  l10n.pricingFeatureExports,
                ],
                color: AppColors.gps,
              ),
              const SizedBox(height: 12),
              _PlanCard(
                icon: Icons.auto_awesome_rounded,
                title: l10n.pricingPlanCoach,
                items: [
                  l10n.pricingFeatureCoach,
                  l10n.pricingFeatureWeeklyReview,
                  l10n.pricingFeatureMotivation,
                ],
                color: AppColors.danger,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.icon,
    required this.title,
    required this.items,
    required this.color,
  });

  final IconData icon;
  final String title;
  final List<String> items;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
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
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.dark,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded, size: 18, color: color),
                  const SizedBox(width: 8),
                  Expanded(child: Text(item)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
