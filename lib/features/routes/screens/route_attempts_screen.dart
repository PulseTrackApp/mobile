import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_error.dart';
import '../../../core/api/api_formatters.dart';
import '../../../core/api/api_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/app_button.dart';
import '../../../core/ui/app_panel.dart';
import '../../../core/ui/app_refresh_scroll_view.dart';
import '../../../l10n/app_localizations.dart';
import '../../history/screens/workout_detail_screen.dart';

/// Le classement des passages sur un circuit.
///
/// Le classement porte sur le temps **en mouvement**, pas sur la durée totale :
/// s'arrêter lacer sa chaussure au milieu d'un circuit ne veut pas dire l'avoir
/// couru plus lentement. C'est le serveur qui classe, on affiche son ordre.
class RouteAttemptsScreen extends ConsumerStatefulWidget {
  const RouteAttemptsScreen({
    super.key,
    required this.routeId,
    required this.routeName,
  });

  final String routeId;
  final String routeName;

  @override
  ConsumerState<RouteAttemptsScreen> createState() =>
      _RouteAttemptsScreenState();
}

class _RouteAttemptsScreenState extends ConsumerState<RouteAttemptsScreen> {
  Future<List<Map<String, dynamic>>>? _future;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _future = _loadAttempts();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.routeName)),
      body: SafeArea(
        child: AppRefreshScrollView(
          onRefresh: _refresh,
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.routeAttemptsTitle,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 18),
              FutureBuilder<List<Map<String, dynamic>>>(
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

                  final attempts = snapshot.data ?? const [];
                  if (attempts.isEmpty) {
                    return AppPanel(child: Text(l10n.routeAttemptsEmpty));
                  }

                  return Column(
                    children: attempts
                        .map(
                          (attempt) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _AttemptCard(
                              attempt: attempt,
                              onOpen: () => _openWorkout(attempt),
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 18),
              AppButton.danger(
                label: l10n.routeDelete,
                icon: Icons.delete_outline_rounded,
                onPressed: _isDeleting ? null : _confirmDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _loadAttempts() {
    return ref.read(pulseTrackApiProvider).getRouteAttempts(widget.routeId);
  }

  Future<void> _refresh() async {
    final future = _loadAttempts();
    setState(() => _future = future);
    try {
      await future;
    } catch (_) {}
  }

  void _openWorkout(Map<String, dynamic> attempt) {
    final id = jsonString(attempt, 'workoutId');
    if (id == null || id.isEmpty) return;

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WorkoutDetailScreen(workoutId: id),
      ),
    );
  }

  /// Supprimer un circuit ne supprime aucune séance : celles qui le rejouaient
  /// ont bien eu lieu, elles perdent seulement leur rattachement. Le dire dans
  /// la confirmation évite l'hésitation.
  Future<void> _confirmDelete() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.routeDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.routeDelete),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);
    try {
      await ref.read(pulseTrackApiProvider).deleteRoute(widget.routeId);
      if (mounted) Navigator.of(context).pop();
    } on ApiProblem catch (problem) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(problem.message)));
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }
}

class _AttemptCard extends StatelessWidget {
  const _AttemptCard({required this.attempt, required this.onOpen});

  final Map<String, dynamic> attempt;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isBest = attempt['isBest'] == true;
    final rank = jsonInt(attempt, 'rank');
    final delta = jsonInt(attempt, 'deltaSecondsVsBest');
    final color = isBest ? AppColors.gps : theme.colorScheme.outline;

    return AppPanel(
      child: InkWell(
        onTap: onOpen,
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: isBest
                  ? Icon(Icons.emoji_events_rounded, color: color)
                  : Text(
                      l10n.routeRank(rank),
                      style: theme.textTheme.titleMedium?.copyWith(color: color),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatChrono(jsonInt(attempt, 'movingDurationSeconds')),
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${formatKm(jsonDouble(attempt, 'distanceMeters'))} km '
                    '· ${formatPace(jsonInt(attempt, 'averagePaceSecondsPerKm'), l10n)}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            // Écart négatif = plus rapide, comme sur un chronomètre. La meilleure
            // tentative n'affiche rien : son écart avec elle-même est nul.
            if (!isBest && delta != 0)
              Text(
                formatChronoDelta(delta),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: delta < 0 ? AppColors.gps : AppColors.danger,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
