import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

enum FitnessLevelOption {
  beginner,
  intermediate,
  advanced;

  static FitnessLevelOption fromApiValue(String? value) {
    return switch (value) {
      'INTERMEDIATE' => FitnessLevelOption.intermediate,
      'ADVANCED' => FitnessLevelOption.advanced,
      _ => FitnessLevelOption.beginner,
    };
  }

  String label(AppLocalizations l10n) {
    return switch (this) {
      FitnessLevelOption.beginner => l10n.fitnessLevelBeginner,
      FitnessLevelOption.intermediate => l10n.fitnessLevelIntermediate,
      FitnessLevelOption.advanced => l10n.fitnessLevelAdvanced,
    };
  }

  String get apiValue {
    return switch (this) {
      FitnessLevelOption.beginner => 'BEGINNER',
      FitnessLevelOption.intermediate => 'INTERMEDIATE',
      FitnessLevelOption.advanced => 'ADVANCED',
    };
  }
}

enum GoalOption {
  loseWeight,
  endurance,
  restart,
  runFaster,
  goFurther,
  maintain,
  cyclingWalking,
  other;

  static GoalOption fromApiPrimaryGoalValue(String? value) {
    return switch (value) {
      'LOSE_WEIGHT' => GoalOption.loseWeight,
      'IMPROVE_ENDURANCE' => GoalOption.endurance,
      'RETURN_TO_SPORT' => GoalOption.restart,
      'RUN_FASTER' => GoalOption.runFaster,
      'GO_FURTHER' => GoalOption.goFurther,
      'MAINTAIN_FITNESS' => GoalOption.maintain,
      'PROGRESS_CYCLING_WALKING' => GoalOption.cyclingWalking,
      _ => GoalOption.loseWeight,
    };
  }

  String label(AppLocalizations l10n) {
    return switch (this) {
      GoalOption.loseWeight => l10n.onboardingGoalLoseWeight,
      GoalOption.endurance => l10n.onboardingGoalEndurance,
      GoalOption.restart => l10n.onboardingGoalRestart,
      GoalOption.runFaster => l10n.onboardingGoalRunFaster,
      GoalOption.goFurther => l10n.onboardingGoalGoFurther,
      GoalOption.maintain => l10n.onboardingGoalMaintain,
      GoalOption.cyclingWalking => l10n.onboardingGoalCyclingWalking,
      GoalOption.other => l10n.onboardingGoalOther,
    };
  }

  String get apiPrimaryGoalValue {
    return switch (this) {
      GoalOption.loseWeight => 'LOSE_WEIGHT',
      GoalOption.endurance => 'IMPROVE_ENDURANCE',
      GoalOption.restart => 'RETURN_TO_SPORT',
      GoalOption.runFaster => 'RUN_FASTER',
      GoalOption.goFurther => 'GO_FURTHER',
      GoalOption.maintain => 'MAINTAIN_FITNESS',
      GoalOption.cyclingWalking => 'PROGRESS_CYCLING_WALKING',
      GoalOption.other => 'MAINTAIN_FITNESS',
    };
  }
}

class FitnessLevelSelect extends StatelessWidget {
  const FitnessLevelSelect({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final FitnessLevelOption value;
  final ValueChanged<FitnessLevelOption> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DropdownButtonFormField<FitnessLevelOption>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: l10n.fitnessLevel,
        prefixIcon: const Icon(Icons.trending_up_rounded),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      items: FitnessLevelOption.values.map((level) {
        return DropdownMenuItem<FitnessLevelOption>(
          value: level,
          child: Text(level.label(l10n)),
        );
      }).toList(),
      onChanged: (level) {
        if (level != null) onChanged(level);
      },
    );
  }
}

class GoalsSelector extends StatelessWidget {
  const GoalsSelector({
    super.key,
    required this.selectedGoals,
    required this.onGoalToggled,
    required this.customGoalController,
  });

  final Set<GoalOption> selectedGoals;
  final ValueChanged<GoalOption> onGoalToggled;
  final TextEditingController customGoalController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasOtherGoal = selectedGoals.contains(GoalOption.other);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.mainGoal, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: GoalOption.values.map((goal) {
            final selected = selectedGoals.contains(goal);
            return FilterChip(
              label: Text(goal.label(l10n)),
              selected: selected,
              onSelected: (_) => onGoalToggled(goal),
            );
          }).toList(),
        ),
        if (hasOtherGoal) ...[
          const SizedBox(height: 14),
          TextFormField(
            controller: customGoalController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: l10n.customGoal,
              hintText: l10n.customGoalHint,
              prefixIcon: const Icon(Icons.edit_note_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
