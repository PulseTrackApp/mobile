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
import '../../activity/models/workout_challenge.dart';
import '../../activity/screens/activity_screen.dart';
import '../../tracking/models/sport_mode.dart';

/// Les défis : parcourir telle distance en tel temps.
///
/// Armer un défi ouvre directement l'écran de course avec le tableau de marche.
/// Le serveur remet à ce moment-là un `plan` — jalons, seuils et messages — que
/// le téléphone joue **localement** : le réseau est mauvais quand on bouge, et
/// une alerte d'échéance qui attend une réponse HTTP arrive après l'échéance.
///
/// Le défi se règle tout seul à l'arrivée : son identifiant part avec la séance,
/// et le verdict revient dans la même réponse.
class ChallengesScreen extends ConsumerStatefulWidget {
  const ChallengesScreen({super.key});

  @override
  ConsumerState<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends ConsumerState<ChallengesScreen> {
  final _distanceController = TextEditingController(text: '5');
  final _minutesController = TextEditingController(text: '30');
  SportMode _sport = SportMode.run;
  Future<List<Map<String, dynamic>>>? _future;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _future = _loadChallenges();
  }

  @override
  void dispose() {
    _distanceController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.challengesTitle)),
      body: SafeArea(
        child: AppRefreshScrollView(
          onRefresh: _refresh,
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.challengesSubtitle,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 18),
              _buildCreationPanel(l10n),
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

                  final challenges = snapshot.data ?? const [];
                  if (challenges.isEmpty) {
                    return AppPanel(child: Text(l10n.challengesEmpty));
                  }

                  return Column(
                    children: challenges
                        .map(
                          (challenge) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _ChallengeCard(
                              challenge: challenge,
                              onStart: () => _start(challenge),
                              onAbandon: () => _abandon(challenge),
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

  Widget _buildCreationPanel(AppLocalizations l10n) {
    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<SportMode>(
            initialValue: _sport,
            decoration: InputDecoration(
              labelText: l10n.settingsSport,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            items: SportMode.values
                .map(
                  (mode) => DropdownMenuItem<SportMode>(
                    value: mode,
                    child: Text(mode.label(l10n)),
                  ),
                )
                .toList(),
            onChanged: (mode) {
              if (mode != null) setState(() => _sport = mode);
            },
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _distanceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.challengeDistanceLabel,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _minutesController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.challengeMinutesLabel,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          // L'allure exigée, calculée à la saisie : c'est le chiffre qui dit si
          // l'objectif est raisonnable, bien avant que le serveur ne le juge.
          if (_previewPaceSecondsPerKm() > 0) ...[
            const SizedBox(height: 10),
            Text(
              l10n.challengeRequiredPace(
                formatPace(_previewPaceSecondsPerKm(), l10n),
              ),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: 14),
          AppButton.primary(
            label: _isSaving ? l10n.saving : l10n.challengeCreate,
            icon: Icons.add_rounded,
            onPressed: _isSaving ? null : _create,
          ),
        ],
      ),
    );
  }

  int _previewPaceSecondsPerKm() {
    final km = parseLocalizedDouble(_distanceController.text);
    final minutes = parseLocalizedDouble(_minutesController.text);
    if (km <= 0 || minutes <= 0) return 0;
    return (minutes * 60 / km).round();
  }

  Future<List<Map<String, dynamic>>> _loadChallenges() {
    return ref.read(pulseTrackApiProvider).getChallenges();
  }

  Future<void> _refresh() async {
    final future = _loadChallenges();
    setState(() => _future = future);
    try {
      await future;
    } catch (_) {}
  }

  Future<void> _create() async {
    final l10n = AppLocalizations.of(context);
    final km = parseLocalizedDouble(_distanceController.text);
    final minutes = parseLocalizedDouble(_minutesController.text);
    if (km <= 0 || minutes <= 0) {
      _showMessage(l10n.challengeInvalidTarget);
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ref.read(pulseTrackApiProvider).createChallenge({
        'sportType': _sport.apiValue,
        'targetDistanceMeters': km * 1000,
        'targetDurationSeconds': (minutes * 60).round(),
      });
      await _refresh();
    } on ApiProblem catch (problem) {
      _showMessage(problem.message);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  /// Arme le défi puis ouvre l'écran de course avec sa cible.
  ///
  /// Le serveur refuse un second défi armé (`409`) : deux échéances simultanées
  /// ne veulent rien dire, et l'écran de course n'en affiche qu'une.
  Future<void> _start(Map<String, dynamic> challenge) async {
    final l10n = AppLocalizations.of(context);
    final id = jsonString(challenge, 'id');
    if (id == null || id.isEmpty) return;

    try {
      final armed = await ref.read(pulseTrackApiProvider).startChallenge(id);
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ActivityScreen(
            selectedSport: _sportOf(challenge),
            initialChallenge: WorkoutChallenge.fromServer(armed),
          ),
        ),
      );
    } on ApiProblem catch (problem) {
      _showMessage(
        problem.status == 409 ? l10n.challengeAlreadyRunning : problem.message,
      );
    }
  }

  Future<void> _abandon(Map<String, dynamic> challenge) async {
    final l10n = AppLocalizations.of(context);
    final id = jsonString(challenge, 'id');
    if (id == null || id.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.challengeAbandonConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.challengeAbandon),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(pulseTrackApiProvider).abandonChallenge(id);
      await _refresh();
    } on ApiProblem catch (problem) {
      _showMessage(problem.message);
    }
  }

  SportMode _sportOf(Map<String, dynamic> challenge) {
    return SportMode.fromApiValue(jsonString(challenge, 'sportType')) ?? _sport;
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({
    required this.challenge,
    required this.onStart,
    required this.onAbandon,
  });

  final Map<String, dynamic> challenge;
  final VoidCallback onStart;
  final VoidCallback onAbandon;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final status = jsonString(challenge, 'status') ?? '';
    final difficulty = jsonMap(challenge, 'difficulty');
    final result = jsonMap(challenge, 'result');
    final color = _statusColor(status);

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
                child: Icon(_statusIcon(status), color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      jsonString(challenge, 'title') ?? '',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _statusLabel(status, l10n),
                      style: theme.textTheme.bodySmall?.copyWith(color: color),
                    ),
                  ],
                ),
              ),
              Text(
                formatPace(
                  jsonInt(challenge, 'requiredPaceSecondsPerKm'),
                  l10n,
                ),
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
          // L'avis rendu AVANT l'effort : « est-ce que je vise juste ? ». Le
          // serveur compare l'allure exigée à l'historique réel du sport.
          if (difficulty != null) ...[
            const SizedBox(height: 12),
            Text(
              jsonString(difficulty, 'headline') ?? '',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 2),
            Text(
              jsonString(difficulty, 'message') ?? '',
              style: theme.textTheme.bodySmall,
            ),
          ],
          // Le verdict, une fois le défi joué. Les textes viennent du serveur :
          // ils sont écrits pour encourager, y compris en cas d'échec.
          if (result != null) ...[
            const SizedBox(height: 12),
            Text(
              jsonString(jsonMap(result, 'appreciation'), 'headline') ?? '',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 2),
            Text(
              jsonString(jsonMap(result, 'appreciation'), 'message') ?? '',
              style: theme.textTheme.bodySmall,
            ),
          ],
          if (status == 'DRAFT' || status == 'ACTIVE') ...[
            const SizedBox(height: 14),
            Row(
              children: [
                if (status == 'DRAFT')
                  Expanded(
                    child: AppButton.primary(
                      label: l10n.challengeStart,
                      icon: Icons.play_arrow_rounded,
                      onPressed: onStart,
                    ),
                  ),
                if (status == 'DRAFT') const SizedBox(width: 10),
                Expanded(
                  child: AppButton.secondary(
                    label: l10n.challengeAbandon,
                    onPressed: onAbandon,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _statusLabel(String status, AppLocalizations l10n) {
    return switch (status) {
      'DRAFT' => l10n.challengeStatusDraft,
      'ACTIVE' => l10n.challengeStatusActive,
      'SUCCEEDED' => l10n.challengeStatusSucceeded,
      'FAILED' => l10n.challengeStatusFailed,
      'ABANDONED' => l10n.challengeStatusAbandoned,
      'EXPIRED' => l10n.challengeStatusExpired,
      _ => status,
    };
  }

  IconData _statusIcon(String status) {
    return switch (status) {
      'ACTIVE' => Icons.timer_rounded,
      'SUCCEEDED' => Icons.emoji_events_rounded,
      'FAILED' => Icons.flag_outlined,
      'ABANDONED' || 'EXPIRED' => Icons.remove_circle_outline_rounded,
      _ => Icons.outlined_flag_rounded,
    };
  }

  Color _statusColor(String status) {
    return switch (status) {
      'ACTIVE' => AppColors.gps,
      'SUCCEEDED' => AppColors.primary,
      'FAILED' => AppColors.danger,
      _ => AppColors.accent,
    };
  }
}
