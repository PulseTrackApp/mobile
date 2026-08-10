import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/ui/app_button.dart';
import '../../../core/ui/app_metric_tile.dart';
import '../../../core/ui/app_panel.dart';
import '../../../l10n/app_localizations.dart';

class BodyProgressScreen extends StatelessWidget {
  const BodyProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.bodyProgressTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.weeklyCheckIn,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: AppMetricTile(
                      label: l10n.currentWeight,
                      value: '--',
                      unit: 'kg',
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppMetricTile(
                      label: l10n.weeklyChange,
                      value: '--',
                      unit: 'kg',
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              AppPanel(
                child: Column(
                  children: [
                    _CheckInField(label: l10n.weightKg, hint: '82.0'),
                    const SizedBox(height: 14),
                    _CheckInField(label: l10n.waistCm, hint: '92'),
                    const SizedBox(height: 14),
                    _CheckInField(label: l10n.chestCm, hint: '101'),
                    const SizedBox(height: 14),
                    _CheckInField(label: l10n.hipsCm, hint: '98'),
                    const SizedBox(height: 14),
                    _CheckInField(label: l10n.energyLevel, hint: '7 / 10'),
                    const SizedBox(height: 14),
                    _CheckInField(label: l10n.sleepHours, hint: '7.5'),
                    const SizedBox(height: 14),
                    _CheckInField(
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
                    Text(
                      l10n.bodyTrendEmpty,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              AppButton.primary(
                label: l10n.saveCheckIn,
                icon: Icons.check_rounded,
                onPressed: () => _showDraftSaved(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDraftSaved(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).draftSaved)),
    );
  }
}

class _CheckInField extends StatelessWidget {
  const _CheckInField({
    required this.label,
    required this.hint,
    this.maxLines = 1,
  });

  final String label;
  final String hint;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
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
