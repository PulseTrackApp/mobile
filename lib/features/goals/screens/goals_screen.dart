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

class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key});

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen> {
  final _targetController = TextEditingController(text: '20');
  _GoalType _goalType = _GoalType.weeklyDistance;
  Future<List<Map<String, dynamic>>>? _future;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _future = _loadGoals();
  }

  @override
  void dispose() {
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.goalsTitle)),
      body: SafeArea(
        child: AppRefreshScrollView(
          onRefresh: _refresh,
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.targetsHeadline,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 18),
              AppPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<_GoalType>(
                      initialValue: _goalType,
                      decoration: InputDecoration(
                        labelText: l10n.goalsTitle,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: _GoalType.values.map((type) {
                        return DropdownMenuItem<_GoalType>(
                          value: type,
                          child: Text(type.label(l10n)),
                        );
                      }).toList(),
                      onChanged: (type) {
                        if (type != null) setState(() => _goalType = type);
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _targetController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.goalTargetValue,
                        suffixText: _goalType.unit,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    AppButton.primary(
                      label: _isSaving ? l10n.saving : l10n.createGoal,
                      icon: Icons.add_rounded,
                      onPressed: _isSaving ? null : _createGoal,
                    ),
                  ],
                ),
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
                        l10n.apiUnexpectedError,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  }

                  final goals = snapshot.data ?? const [];
                  if (goals.isEmpty) {
                    return AppPanel(
                      child: Text(
                        l10n.noGoalsYet,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  }

                  return Column(
                    children: goals.map((goal) {
                      final type = jsonString(goal, 'type') ?? '';
                      final value = jsonDouble(goal, 'targetValue');
                      final currentValue = jsonDouble(goal, 'currentValue');
                      final completionPercent = jsonDouble(
                        goal,
                        'completionPercent',
                      );
                      final progress = completionPercent > 0
                          ? completionPercent / 100
                          : value <= 0
                          ? 0.0
                          : currentValue / value;
                      final unit = jsonString(goal, 'unit') ?? '';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _GoalCard(
                          icon: _goalIcon(type),
                          color: _goalColor(type),
                          title: goalTitle(type, l10n),
                          value: currentValue > 0
                              ? '${currentValue.toStringAsFixed(1)} / ${value.toStringAsFixed(1)} $unit'
                              : '${value.toStringAsFixed(1)} $unit',
                          progress: progress,
                          appreciation: _goalAppreciation(progress, l10n),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _loadGoals() {
    return ref.read(pulseTrackApiProvider).getGoals();
  }

  Future<void> _refresh() async {
    final future = _loadGoals();
    setState(() => _future = future);

    try {
      await future;
    } catch (_) {}
  }

  Future<void> _createGoal() async {
    final l10n = AppLocalizations.of(context);
    final targetValue = parseLocalizedDouble(_targetController.text);
    if (targetValue <= 0) {
      _showMessage(l10n.requiredGoalFields);
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ref.read(pulseTrackApiProvider).createGoal({
        'type': _goalType.apiValue,
        'targetValue': targetValue,
        'startDate': todayIsoDate(),
      });
      setState(() => _future = _loadGoals());
      _showMessage(l10n.goalSavedApi);
    } on ApiProblem catch (problem) {
      _showMessage('${l10n.apiErrorPrefix} ${problem.message}');
    } catch (_) {
      _showMessage(l10n.apiUnexpectedError);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

enum _GoalType {
  weeklyDistance('WEEKLY_DISTANCE', 'km'),
  weeklySessions('WEEKLY_SESSIONS', 'seances'),
  weeklyDuration('WEEKLY_DURATION', 'min'),
  weeklyCalories('WEEKLY_CALORIES', 'kcal'),
  targetWeight('TARGET_WEIGHT', 'kg');

  const _GoalType(this.apiValue, this.unit);

  final String apiValue;
  final String unit;

  String label(AppLocalizations l10n) => goalTitle(apiValue, l10n);
}

IconData _goalIcon(String type) {
  return switch (type) {
    'WEEKLY_DISTANCE' => Icons.route_rounded,
    'WEEKLY_SESSIONS' => Icons.calendar_month_rounded,
    'WEEKLY_CALORIES' => Icons.local_fire_department_rounded,
    'WEEKLY_DURATION' => Icons.timer_outlined,
    'TARGET_WEIGHT' => Icons.monitor_weight_outlined,
    _ => Icons.flag_rounded,
  };
}

Color _goalColor(String type) {
  return switch (type) {
    'WEEKLY_DISTANCE' => AppColors.primary,
    'WEEKLY_SESSIONS' => AppColors.gps,
    'WEEKLY_CALORIES' => AppColors.danger,
    'WEEKLY_DURATION' => AppColors.gps,
    'TARGET_WEIGHT' => AppColors.accent,
    _ => AppColors.primary,
  };
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
    required this.progress,
    required this.appreciation,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String value;
  final double progress;
  final String appreciation;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(value, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress.clamp(0, 1),
              minHeight: 8,
              backgroundColor: Theme.of(context).colorScheme.outlineVariant,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            appreciation,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

String _goalAppreciation(double progress, AppLocalizations l10n) {
  if (progress >= 1) return l10n.weeklyGoalReached;
  if (progress >= 0.75) return l10n.weeklyGoalAlmost;
  if (progress >= 0.45) return l10n.weeklyGoalStrong;
  return l10n.goalNeedsWork;
}
