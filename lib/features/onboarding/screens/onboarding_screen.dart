import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/ui/app_button.dart';
import '../../../core/ui/app_panel.dart';
import '../../../core/ui/pulse_track_logo.dart';
import '../../../l10n/app_localizations.dart';
import '../../tracking/models/sport_mode.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _totalPages = 3;

  final _pageController = PageController();
  int _currentPage = 0;
  String _selectedGoal = '';
  SportMode _favoriteSport = SportMode.run;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final goals = [
      l10n.onboardingGoalLoseWeight,
      l10n.onboardingGoalEndurance,
      l10n.onboardingGoalRestart,
      l10n.onboardingGoalMaintain,
    ];
    _selectedGoal = _selectedGoal.isEmpty ? goals.first : _selectedGoal;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(child: PulseTrackLogo()),
                  TextButton(
                    onPressed: widget.onComplete,
                    child: Text(l10n.onboardingSkip),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _StepIndicator(
                currentPage: _currentPage,
                totalPages: _totalPages,
              ),
              const SizedBox(height: 18),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  children: [
                    _IntroPage(
                      title: l10n.onboardingWelcomeTitle,
                      body: l10n.onboardingWelcomeBody,
                    ),
                    _ProfilePage(l10n: l10n),
                    _TargetsPage(
                      l10n: l10n,
                      goals: goals,
                      selectedGoal: _selectedGoal,
                      favoriteSport: _favoriteSport,
                      onGoalChanged: (goal) {
                        setState(() => _selectedGoal = goal);
                      },
                      onSportChanged: (sport) {
                        setState(() => _favoriteSport = sport);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: AppButton.secondary(
                      label: l10n.onboardingBack,
                      icon: Icons.arrow_back_rounded,
                      onPressed: _currentPage == 0 ? null : _goBack,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton.primary(
                      label: _currentPage == _totalPages - 1
                          ? l10n.onboardingFinish
                          : l10n.onboardingNext,
                      icon: _currentPage == _totalPages - 1
                          ? Icons.check_rounded
                          : Icons.arrow_forward_rounded,
                      onPressed: _currentPage == _totalPages - 1
                          ? widget.onComplete
                          : _goNext,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goNext() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  void _goBack() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.currentPage, required this.totalPages});

  final int currentPage;
  final int totalPages;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        Text(
          l10n.onboardingStep(currentPage + 1, totalPages),
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Row(
            children: List.generate(totalPages, (index) {
              final isActive = index <= currentPage;
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 6,
                  margin: EdgeInsets.only(
                    right: index == totalPages - 1 ? 0 : 6,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primary
                        : Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _IntroPage extends StatelessWidget {
  const _IntroPage({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      color: AppColors.dark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PulseTrackLogo(size: 72, showWordmark: false),
          const Spacer(),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.displaySmall?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 14),
          Text(
            body,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 18),
          const Row(
            children: [
              _IntroPill(icon: Icons.route_rounded, label: 'GPS'),
              SizedBox(width: 10),
              _IntroPill(icon: Icons.flag_rounded, label: 'Targets'),
              SizedBox(width: 10),
              _IntroPill(icon: Icons.insights_rounded, label: 'Stats'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.onboardingProfileTitle,
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 10),
          Text(
            l10n.onboardingProfileBody,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 18),
          AppPanel(
            child: Column(
              children: [
                _OnboardingField(
                  label: l10n.displayName,
                  hint: l10n.displayNameHint,
                  icon: Icons.badge_outlined,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _OnboardingField(
                        label: l10n.weightKg,
                        hint: '82',
                        icon: Icons.monitor_weight_outlined,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _OnboardingField(
                        label: l10n.heightCm,
                        hint: '178',
                        icon: Icons.height_rounded,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _OnboardingField(
                  label: l10n.fitnessLevel,
                  hint: l10n.fitnessLevelHint,
                  icon: Icons.trending_up_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TargetsPage extends StatelessWidget {
  const _TargetsPage({
    required this.l10n,
    required this.goals,
    required this.selectedGoal,
    required this.favoriteSport,
    required this.onGoalChanged,
    required this.onSportChanged,
  });

  final AppLocalizations l10n;
  final List<String> goals;
  final String selectedGoal;
  final SportMode favoriteSport;
  final ValueChanged<String> onGoalChanged;
  final ValueChanged<SportMode> onSportChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.onboardingTargetsTitle,
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 10),
          Text(
            l10n.onboardingTargetsBody,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 18),
          AppPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.mainGoal,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: goals.map((goal) {
                    return ChoiceChip(
                      label: Text(goal),
                      selected: goal == selectedGoal,
                      onSelected: (_) => onGoalChanged(goal),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),
                Text(
                  l10n.onboardingFavoriteSport,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                SegmentedButton<SportMode>(
                  segments: SportMode.values
                      .map(
                        (sport) => ButtonSegment<SportMode>(
                          value: sport,
                          label: Text(sport.label(l10n)),
                          icon: Icon(sport.icon),
                        ),
                      )
                      .toList(),
                  selected: {favoriteSport},
                  onSelectionChanged: (selection) {
                    onSportChanged(selection.first);
                  },
                ),
                const SizedBox(height: 18),
                _TargetPreview(label: l10n.onboardingWeeklyTarget),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TargetPreview extends StatelessWidget {
  const _TargetPreview({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const Icon(Icons.flag_outlined, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Text('20 km', style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

class _OnboardingField extends StatelessWidget {
  const _OnboardingField({
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

class _IntroPill extends StatelessWidget {
  const _IntroPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
