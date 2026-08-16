import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_error.dart';
import '../../../core/api/api_formatters.dart';
import '../../../core/api/api_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/app_panel.dart';
import '../../../core/ui/app_refresh_scroll_view.dart';
import '../../../l10n/app_localizations.dart';
import 'route_attempts_screen.dart';

/// Les circuits enregistrés, et ce qu'ils valent.
///
/// La liste ne porte pas le tracé — le serveur renvoie `points` à `null` sur la
/// liste paginée, parce que trois cents points par ligne coûteraient un
/// demi-mégaoctet pour dessiner des vignettes que personne ne regarde de près.
/// Le détail des passages se lit dans [RouteAttemptsScreen].
///
/// On ne crée pas un parcours depuis ici : un circuit qu'on veut reprendre est
/// forcément un circuit qu'on a couru, il naît donc du détail d'une séance.
class RoutesScreen extends ConsumerStatefulWidget {
  const RoutesScreen({super.key});

  @override
  ConsumerState<RoutesScreen> createState() => _RoutesScreenState();
}

class _RoutesScreenState extends ConsumerState<RoutesScreen> {
  Future<List<Map<String, dynamic>>>? _future;

  @override
  void initState() {
    super.initState();
    _future = _loadRoutes();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.routesTitle)),
      body: SafeArea(
        child: AppRefreshScrollView(
          onRefresh: _refresh,
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.routesSubtitle,
                style: Theme.of(context).textTheme.bodyLarge,
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
                        _errorMessage(snapshot.error, l10n),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  }

                  final routes = snapshot.data ?? const [];
                  if (routes.isEmpty) {
                    return AppPanel(
                      child: Text(
                        l10n.routesEmpty,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  }

                  return Column(
                    children: routes
                        .map(
                          (route) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _RouteCard(
                              route: route,
                              onOpen: () => _openAttempts(route),
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _loadRoutes() {
    return ref.read(pulseTrackApiProvider).getRoutes();
  }

  Future<void> _refresh() async {
    final future = _loadRoutes();
    setState(() => _future = future);
    try {
      await future;
    } catch (_) {
      // L'erreur est rendue par le FutureBuilder, pas par une exception nue.
    }
  }

  void _openAttempts(Map<String, dynamic> route) {
    final id = jsonString(route, 'id');
    if (id == null || id.isEmpty) return;

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RouteAttemptsScreen(
          routeId: id,
          routeName: jsonString(route, 'name') ?? '',
        ),
      ),
    );
  }

  String _errorMessage(Object? error, AppLocalizations l10n) {
    if (error is ApiProblem) return error.message;
    return l10n.apiUnexpectedError;
  }
}

class _RouteCard extends StatelessWidget {
  const _RouteCard({required this.route, required this.onOpen});

  final Map<String, dynamic> route;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isLoop = route['loop'] == true;
    final attempts = jsonInt(route, 'attemptCount');
    final bestSeconds = jsonInt(route, 'bestDurationSeconds');

    return AppPanel(
      child: InkWell(
        onTap: onOpen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.gps.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isLoop ? Icons.loop_rounded : Icons.trending_flat_rounded,
                    color: AppColors.gps,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        jsonString(route, 'name') ?? '',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${formatKm(jsonDouble(route, 'distanceMeters'))} km '
                        '· ${isLoop ? l10n.routeLoop : l10n.routeOneWay}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.replay_rounded,
                  size: 18,
                  color: theme.colorScheme.outline,
                ),
                const SizedBox(width: 6),
                Text(
                  attempts == 0
                      ? l10n.routeNeverRun
                      : l10n.routeAttempts(attempts),
                  style: theme.textTheme.bodySmall,
                ),
                if (bestSeconds > 0) ...[
                  const SizedBox(width: 14),
                  Icon(
                    Icons.timer_outlined,
                    size: 18,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.routeBestTime(formatChrono(bestSeconds)),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
