import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/ui/app_button.dart';
import '../../../core/ui/app_panel.dart';
import '../../../l10n/app_localizations.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.profileHeadline,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 18),
              AppPanel(
                child: Column(
                  children: [
                    _ProfileField(
                      label: l10n.displayName,
                      hint: l10n.displayNameHint,
                      icon: Icons.badge_outlined,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _ProfileField(
                            label: l10n.sexOptional,
                            hint: l10n.sexOptionalHint,
                            icon: Icons.person_search_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ProfileField(
                            label: l10n.ageOptional,
                            hint: '32',
                            icon: Icons.cake_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _ProfileField(
                            label: l10n.weightKg,
                            hint: '82',
                            icon: Icons.monitor_weight_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ProfileField(
                            label: l10n.heightCm,
                            hint: '178',
                            icon: Icons.height_rounded,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _ProfileField(
                      label: l10n.mainGoal,
                      hint: l10n.mainGoalHint,
                      icon: Icons.flag_outlined,
                    ),
                    const SizedBox(height: 14),
                    _ProfileField(
                      label: l10n.fitnessLevel,
                      hint: l10n.fitnessLevelHint,
                      icon: Icons.trending_up_rounded,
                    ),
                    const SizedBox(height: 14),
                    _ProfileField(
                      label: l10n.preferredSports,
                      hint: l10n.preferredSportsHint,
                      icon: Icons.directions_run_rounded,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              AppPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.calculate_outlined,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          l10n.bodyIndicators,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      l10n.bmiPreview,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      l10n.profileDataNote,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              AppButton.primary(
                label: l10n.saveProfile,
                icon: Icons.save_outlined,
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

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
  });

  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
