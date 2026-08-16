import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_error.dart';
import '../../../core/api/api_formatters.dart';
import '../../../core/api/api_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/app_panel.dart';
import '../../../core/ui/app_refresh_scroll_view.dart';
import '../../../l10n/app_localizations.dart';

/// La note de l'utilisateur sur quatre semaines, et l'encouragement qui va avec.
///
/// Tout vient du serveur, y compris les phrases : le calcul est déterministe et
/// ne passe par aucun assistant, donc deux ouvertures le même jour donnent la
/// même note.
///
/// **Un compte sans séance ne reçoit pas zéro** mais un accueil : `score` et
/// `grade` sont nuls, et le palier vaut `NEW`. Ce cas est traité à part — noter
/// zéro quelqu'un qui vient d'arriver est le plus sûr moyen de le perdre.
class RatingScreen extends ConsumerStatefulWidget {
  const RatingScreen({super.key});

  @override
  ConsumerState<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends ConsumerState<RatingScreen> {
  Future<Map<String, dynamic>>? _future;

  @override
  void initState() {
    super.initState();
    _future = _loadRating();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.ratingTitle)),
      body: SafeArea(
        child: AppRefreshScrollView(
          onRefresh: _refresh,
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: FutureBuilder<Map<String, dynamic>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return AppPanel(
                  child: Text(
                    snapshot.error is ApiProblem
                        ? (snapshot.error as ApiProblem).message
                        : l10n.apiUnexpectedError,
                  ),
                );
              }

              final rating = snapshot.data ?? const <String, dynamic>{};
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ScorePanel(rating: rating),
                  const SizedBox(height: 18),
                  _ComponentsPanel(rating: rating),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _loadRating() {
    return ref.read(pulseTrackApiProvider).getRating(zone: gymFlowDefaultZone);
  }

  Future<void> _refresh() async {
    final future = _loadRating();
    setState(() => _future = future);
    try {
      await future;
    } catch (_) {}
  }
}

class _ScorePanel extends StatelessWidget {
  const _ScorePanel({required this.rating});

  final Map<String, dynamic> rating;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final rawScore = rating['score'];
    // `null` n'est pas zéro : c'est un compte qui n'a pas encore couru.
    final hasScore = rawScore is num;
    final score = hasScore ? rawScore.toInt() : 0;
    final color = _scoreColor(hasScore ? score : null);

    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: hasScore
                    ? Text(
                        '$score',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w900,
                        ),
                      )
                    : Icon(Icons.emoji_flags_outlined, color: color, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      jsonString(rating, 'title') ?? l10n.ratingTitle,
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.ratingWindow(jsonInt(rating, 'windowDays')),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (jsonString(rating, 'grade') != null)
                Text(
                  jsonString(rating, 'grade')!,
                  style: theme.textTheme.headlineSmall?.copyWith(color: color),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            jsonString(rating, 'message') ?? '',
            style: theme.textTheme.bodyMedium,
          ),
          if (jsonString(rating, 'advice') != null) ...[
            const SizedBox(height: 8),
            Text(
              jsonString(rating, 'advice')!,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Chip(
                icon: Icons.local_fire_department_outlined,
                label: l10n.ratingStreak(jsonInt(rating, 'streakDays')),
              ),
              _TrendChip(trend: jsonMap(rating, 'trend')),
              if (rating['pointsToNextTier'] is num &&
                  jsonString(rating, 'nextTier') != null)
                _Chip(
                  icon: Icons.trending_up_rounded,
                  label: l10n.ratingNextTier(
                    jsonInt(rating, 'pointsToNextTier'),
                    jsonString(rating, 'nextTier')!,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _scoreColor(int? score) {
    if (score == null) return AppColors.accent;
    if (score >= 70) return AppColors.primary;
    if (score >= 40) return AppColors.gps;
    return AppColors.accent;
  }
}

class _ComponentsPanel extends StatelessWidget {
  const _ComponentsPanel({required this.rating});

  final Map<String, dynamic> rating;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final components = jsonList(rating, 'components');
    // Un compte sans séance n'a aucune composante : la note n'existe pas encore,
    // et un tableau vide vaut mieux qu'un détail inventé.
    if (components.isEmpty) return const SizedBox.shrink();

    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.ratingComponents, style: theme.textTheme.titleMedium),
          const SizedBox(height: 14),
          ...components.map((component) {
            final score = jsonInt(component, 'score');
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          jsonString(component, 'label') ?? '',
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                      Text('$score', style: theme.textTheme.titleSmall),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (score / 100).clamp(0, 1).toDouble(),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Le motif de la note. Une note sans motif se conteste.
                  Text(
                    jsonString(component, 'comment') ?? '',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _TrendChip extends StatelessWidget {
  const _TrendChip({required this.trend});

  final Map<String, dynamic>? trend;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final direction = jsonString(trend, 'direction') ?? 'FLAT';

    return _Chip(
      icon: switch (direction) {
        'UP' => Icons.arrow_upward_rounded,
        'DOWN' => Icons.arrow_downward_rounded,
        _ => Icons.remove_rounded,
      },
      label: switch (direction) {
        'UP' => l10n.ratingTrendUp,
        'DOWN' => l10n.ratingTrendDown,
        _ => l10n.ratingTrendFlat,
      },
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 6),
            Text(label, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
