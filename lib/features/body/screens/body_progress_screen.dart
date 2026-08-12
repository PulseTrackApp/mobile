import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_error.dart';
import '../../../core/api/api_formatters.dart';
import '../../../core/api/api_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/app_button.dart';
import '../../../core/ui/app_metric_tile.dart';
import '../../../core/ui/app_panel.dart';
import '../../../core/ui/app_refresh_scroll_view.dart';
import '../../../l10n/app_localizations.dart';

class BodyProgressScreen extends ConsumerStatefulWidget {
  const BodyProgressScreen({super.key});

  @override
  ConsumerState<BodyProgressScreen> createState() => _BodyProgressScreenState();
}

class _BodyProgressScreenState extends ConsumerState<BodyProgressScreen> {
  final _weightController = TextEditingController();
  final _waistController = TextEditingController();
  final _chestController = TextEditingController();
  final _hipsController = TextEditingController();
  final _energyController = TextEditingController();
  final _sleepController = TextEditingController();
  final _noteController = TextEditingController();
  Future<Map<String, dynamic>>? _future;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _future = _loadProgress();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _waistController.dispose();
    _chestController.dispose();
    _hipsController.dispose();
    _energyController.dispose();
    _sleepController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.bodyProgressTitle)),
      body: SafeArea(
        child: AppRefreshScrollView(
          onRefresh: _refresh,
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.weeklyCheckIn,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 18),
              FutureBuilder<Map<String, dynamic>>(
                future: _future,
                builder: (context, snapshot) {
                  final progress = snapshot.data;
                  final hasCheckIns = jsonInt(progress, 'checkInCount') > 0;
                  final hasChange = progress?['changeSincePreviousKg'] != null;
                  final bmi = jsonDouble(progress, 'currentBmi');
                  final category = bmiCategoryLabel(
                    jsonString(progress, 'bmiCategory'),
                    l10n,
                  );

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      const gap = 10.0;
                      final itemWidth = (constraints.maxWidth - gap) / 2;

                      return Wrap(
                        spacing: gap,
                        runSpacing: gap,
                        children: [
                          SizedBox(
                            width: itemWidth,
                            child: AppMetricTile(
                              label: l10n.currentWeight,
                              value: hasCheckIns
                                  ? jsonDouble(
                                      progress,
                                      'currentWeightKg',
                                    ).toStringAsFixed(1)
                                  : '--',
                              unit: 'kg',
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: AppMetricTile(
                              label: l10n.weeklyChange,
                              value: hasChange
                                  ? jsonDouble(
                                      progress,
                                      'changeSincePreviousKg',
                                    ).toStringAsFixed(1)
                                  : '--',
                              unit: hasChange ? 'kg' : '',
                              color: AppColors.accent,
                            ),
                          ),
                          SizedBox(
                            width: constraints.maxWidth,
                            child: AppMetricTile(
                              label: l10n.bmiTitle,
                              value: formatBmi(bmi),
                              unit: category ?? '',
                              color: AppColors.gps,
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 18),
              AppPanel(
                child: Column(
                  children: [
                    _CheckInField(
                      controller: _weightController,
                      label: l10n.weightKg,
                      hint: '82.0',
                    ),
                    const SizedBox(height: 14),
                    _CheckInField(
                      controller: _waistController,
                      label: l10n.waistCm,
                      hint: '92',
                    ),
                    const SizedBox(height: 14),
                    _CheckInField(
                      controller: _chestController,
                      label: l10n.chestCm,
                      hint: '101',
                    ),
                    const SizedBox(height: 14),
                    _CheckInField(
                      controller: _hipsController,
                      label: l10n.hipsCm,
                      hint: '98',
                    ),
                    const SizedBox(height: 14),
                    _CheckInField(
                      controller: _energyController,
                      label: l10n.energyLevel,
                      hint: '4 / 5',
                    ),
                    const SizedBox(height: 14),
                    _CheckInField(
                      controller: _sleepController,
                      label: l10n.sleepHours,
                      hint: '7.5',
                    ),
                    const SizedBox(height: 14),
                    _CheckInField(
                      controller: _noteController,
                      label: l10n.weeklyNote,
                      hint: l10n.weeklyNoteHint,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              AppPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.bodyTrendTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    FutureBuilder<Map<String, dynamic>>(
                      future: _future,
                      builder: (context, snapshot) {
                        final progress = snapshot.data;
                        final count = jsonInt(progress, 'checkInCount');
                        final trend = jsonString(progress, 'trend');
                        return Text(
                          count == 0
                              ? l10n.bodyTrendEmpty
                              : '$count check-ins - ${trend ?? ''}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              AppButton.primary(
                label: _isSaving ? l10n.saving : l10n.saveCheckIn,
                icon: Icons.check_rounded,
                onPressed: _isSaving ? null : _saveCheckIn,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _loadProgress() {
    return ref.read(pulseTrackApiProvider).getBodyProgress();
  }

  Future<void> _refresh() async {
    final future = _loadProgress();
    setState(() => _future = future);

    try {
      await future;
    } catch (_) {}
  }

  Future<void> _saveCheckIn() async {
    final l10n = AppLocalizations.of(context);
    final weight = parseLocalizedDouble(_weightController.text);
    if (weight <= 0) {
      _showMessage(l10n.requiredBodyCheckInFields);
      return;
    }

    setState(() => _isSaving = true);

    try {
      await ref.read(pulseTrackApiProvider).saveBodyCheckIn({
        'checkinDate': todayIsoDate(),
        'weightKg': weight,
        if (_waistController.text.trim().isNotEmpty)
          'waistCm': parseLocalizedDouble(_waistController.text),
        if (_chestController.text.trim().isNotEmpty)
          'chestCm': parseLocalizedDouble(_chestController.text),
        if (_hipsController.text.trim().isNotEmpty)
          'hipsCm': parseLocalizedDouble(_hipsController.text),
        if (_energyController.text.trim().isNotEmpty)
          'energyLevel': int.tryParse(_energyController.text.trim()),
        if (_sleepController.text.trim().isNotEmpty)
          'averageSleepHours': parseLocalizedDouble(_sleepController.text),
        if (_noteController.text.trim().isNotEmpty)
          'note': _noteController.text.trim(),
      });
      setState(() => _future = _loadProgress());
      _showMessage(l10n.checkInSavedApi);
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

class _CheckInField extends StatelessWidget {
  const _CheckInField({
    required this.controller,
    required this.label,
    required this.hint,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: maxLines == 1 ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
