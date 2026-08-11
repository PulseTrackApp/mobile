import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_error.dart';
import '../../../core/api/api_formatters.dart';
import '../../../core/api/api_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/app_button.dart';
import '../../../core/ui/app_panel.dart';
import '../../../l10n/app_localizations.dart';

class GeminiCoachScreen extends ConsumerStatefulWidget {
  const GeminiCoachScreen({super.key});

  @override
  ConsumerState<GeminiCoachScreen> createState() => _GeminiCoachScreenState();
}

class _GeminiCoachScreenState extends ConsumerState<GeminiCoachScreen> {
  final _questionController = TextEditingController();
  Future<_CoachData>? _future;
  bool _isRequesting = false;

  @override
  void initState() {
    super.initState();
    _future = _loadCoach();
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

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
              FutureBuilder<_CoachData>(
                future: _future,
                builder: (context, snapshot) {
                  final data = snapshot.data;
                  return AppPanel(
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
                                color: AppColors.primary.withValues(
                                  alpha: 0.12,
                                ),
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
                                    data?.settingsUsable == true
                                        ? l10n.coachAvailable
                                        : l10n.geminiBackendStatusTitle,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    data?.latestMessage ??
                                        l10n.geminiBackendStatusBody,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
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
                                    snapshot.hasError
                                        ? l10n.apiUnexpectedError
                                        : l10n.geminiPrivacyNote,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        AppButton.primary(
                          label: _isRequesting
                              ? l10n.saving
                              : l10n.requestWeeklyReview,
                          icon: Icons.insights_rounded,
                          onPressed: _isRequesting
                              ? null
                              : () => _requestWeeklyReview(refresh: true),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),
              AppPanel(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _questionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: l10n.coachQuestion,
                        hintText: l10n.coachQuestionHint,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    AppButton.secondary(
                      label: _isRequesting ? l10n.saving : l10n.askCoach,
                      icon: Icons.send_rounded,
                      onPressed: _isRequesting ? null : _askCoach,
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

  Future<_CoachData> _loadCoach() async {
    final api = ref.read(pulseTrackApiProvider);
    final results = await Future.wait<Object?>([
      api.getCoachSettings(),
      api.getLatestCoachMessage(),
    ]);
    final settings = results[0] as Map<String, dynamic>;
    final latest = results[1] as Map<String, dynamic>?;
    return _CoachData(
      settingsUsable: settings['usable'] == true,
      latestMessage: jsonString(latest, 'content'),
    );
  }

  Future<void> _requestWeeklyReview({required bool refresh}) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _isRequesting = true);
    try {
      await ref
          .read(pulseTrackApiProvider)
          .requestWeeklyReview(zone: gymFlowDefaultZone, refresh: refresh);
      setState(() => _future = _loadCoach());
    } on ApiProblem catch (problem) {
      _showMessage('${l10n.apiErrorPrefix} ${problem.message}');
    } catch (_) {
      _showMessage(l10n.apiUnexpectedError);
    } finally {
      if (mounted) setState(() => _isRequesting = false);
    }
  }

  Future<void> _askCoach() async {
    final l10n = AppLocalizations.of(context);
    final question = _questionController.text.trim();
    if (question.isEmpty) return;

    setState(() => _isRequesting = true);
    try {
      await ref
          .read(pulseTrackApiProvider)
          .askCoach(question: question, zone: gymFlowDefaultZone);
      _questionController.clear();
      setState(() => _future = _loadCoach());
    } on ApiProblem catch (problem) {
      _showMessage('${l10n.apiErrorPrefix} ${problem.message}');
    } catch (_) {
      _showMessage(l10n.apiUnexpectedError);
    } finally {
      if (mounted) setState(() => _isRequesting = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _CoachData {
  const _CoachData({required this.settingsUsable, required this.latestMessage});

  final bool settingsUsable;
  final String? latestMessage;
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
