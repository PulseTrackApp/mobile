import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/ui/app_panel.dart';
import '../../../l10n/app_localizations.dart';

class GeminiCoachScreen extends StatelessWidget {
  const GeminiCoachScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.coachTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.coachHeadline,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 18),
              AppPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.dns_outlined,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.geminiBackendStatusTitle,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                l10n.geminiBackendStatusBody,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.gps.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.key_off_outlined,
                              color: AppColors.gps,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                l10n.geminiPrivacyNote,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _CoachInsightCard(
                icon: Icons.warning_amber_rounded,
                color: AppColors.danger,
                title: l10n.effortWarningTitle,
                body: l10n.effortWarningBody,
              ),
              const SizedBox(height: 10),
              _CoachInsightCard(
                icon: Icons.fitness_center_rounded,
                color: AppColors.primary,
                title: l10n.exerciseSuggestionsTitle,
                body: l10n.exerciseSuggestionsBody,
              ),
              const SizedBox(height: 10),
              _CoachInsightCard(
                icon: Icons.insights_rounded,
                color: AppColors.gps,
                title: l10n.weeklyReviewTitle,
                body: l10n.weeklyReviewBody,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoachInsightCard extends StatelessWidget {
  const _CoachInsightCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(body, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
