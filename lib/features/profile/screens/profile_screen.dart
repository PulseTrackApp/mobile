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
import '../../../core/user/current_user_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../tracking/models/sport_mode.dart';
import '../widgets/profile_choice_fields.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _displayNameController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _customGoalController = TextEditingController();
  SexOption _sex = SexOption.male;
  FitnessLevelOption _fitnessLevel = FitnessLevelOption.beginner;
  final Set<GoalOption> _selectedGoals = {GoalOption.loseWeight};
  final Set<SportMode> _preferredSports = {SportMode.run};
  Future<Map<String, dynamic>?>? _profileFuture;
  Map<String, dynamic>? _profile;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (ref.read(authTokenStoreProvider).isAuthenticated) {
      _profileFuture = _loadProfile();
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _customGoalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: SafeArea(
        child: AppRefreshScrollView(
          onRefresh: _refresh,
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
                      controller: _displayNameController,
                      label: l10n.displayName,
                      hint: l10n.displayNameHint,
                      icon: Icons.badge_outlined,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: SexSelect(
                            value: _sex,
                            onChanged: (sex) {
                              setState(() => _sex = sex);
                            },
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
                            controller: _weightController,
                            label: l10n.weightKg,
                            hint: '82',
                            icon: Icons.monitor_weight_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ProfileField(
                            controller: _heightController,
                            label: l10n.heightCm,
                            hint: '178',
                            icon: Icons.height_rounded,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    GoalsSelector(
                      selectedGoals: _selectedGoals,
                      onGoalToggled: _toggleGoal,
                      customGoalController: _customGoalController,
                    ),
                    const SizedBox(height: 14),
                    FitnessLevelSelect(
                      value: _fitnessLevel,
                      onChanged: (level) {
                        setState(() => _fitnessLevel = level);
                      },
                    ),
                    const SizedBox(height: 14),
                    _PreferredSportsSelector(
                      selectedSports: _preferredSports,
                      onSportToggled: _toggleSport,
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
                    FutureBuilder<Map<String, dynamic>?>(
                      future: _profileFuture,
                      builder: (context, snapshot) {
                        final profile = _profile ?? snapshot.data;
                        return _ProfileBodyIndicators(
                          profile: profile,
                          isLoading:
                              snapshot.connectionState ==
                                  ConnectionState.waiting &&
                              profile == null,
                          hasError: snapshot.hasError,
                        );
                      },
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
                label: _isSaving ? l10n.saving : l10n.saveProfile,
                icon: Icons.save_outlined,
                onPressed: _isSaving ? null : _saveProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    final l10n = AppLocalizations.of(context);
    final profile = _buildProfilePayload(l10n);
    if (profile == null) return;

    setState(() => _isSaving = true);

    try {
      final savedProfile = await ref
          .read(pulseTrackApiProvider)
          .saveProfile(profile);
      if (mounted) {
        setState(() => _applyProfile(savedProfile, updateFields: false));
      }
      await ref
          .read(authTokenStoreProvider)
          .markProfileCompleted(displayName: _displayNameController.text);
      ref.invalidate(currentUserProvider);
      _showMessage(l10n.profileSavedApi);
    } on ApiProblem catch (problem) {
      _showMessage('${l10n.apiErrorPrefix} ${problem.message}');
    } catch (_) {
      _showMessage(l10n.apiUnexpectedError);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<Map<String, dynamic>?> _loadProfile() async {
    try {
      final profile = await ref.read(pulseTrackApiProvider).getProfile();
      if (mounted) {
        setState(() => _applyProfile(profile));
      }
      return profile;
    } on ApiProblem catch (problem) {
      if (problem.status == 404) return null;
      rethrow;
    }
  }

  Future<void> _refresh() async {
    if (!ref.read(authTokenStoreProvider).isAuthenticated) return;

    final future = _loadProfile();
    setState(() => _profileFuture = future);

    try {
      await future;
    } catch (_) {}
  }

  void _applyProfile(Map<String, dynamic> profile, {bool updateFields = true}) {
    _profile = profile;

    if (!updateFields) return;

    _displayNameController.text = jsonString(profile, 'displayName') ?? '';
    _weightController.text = jsonDouble(
      profile,
      'currentWeightKg',
    ).toStringAsFixed(1);
    _heightController.text = jsonInt(profile, 'heightCm').toString();
    _fitnessLevel = FitnessLevelOption.fromApiValue(
      jsonString(profile, 'fitnessLevel'),
    );
    _sex = SexOption.fromApiValue(jsonString(profile, 'sex'));

    final primaryGoal = GoalOption.fromApiPrimaryGoalValue(
      jsonString(profile, 'primaryGoal'),
    );
    _selectedGoals
      ..clear()
      ..add(primaryGoal);

    final sports = _sportsFromProfile(profile);
    _preferredSports
      ..clear()
      ..addAll(sports.isEmpty ? {SportMode.run} : sports);
  }

  Set<SportMode> _sportsFromProfile(Map<String, dynamic> profile) {
    final rawSports = profile['preferredSports'];
    if (rawSports is! List) return const {};

    return rawSports
        .map((value) => SportMode.fromApiValue(value?.toString()))
        .whereType<SportMode>()
        .toSet();
  }

  void _toggleGoal(GoalOption goal) {
    setState(() {
      if (_selectedGoals.contains(goal)) {
        if (_selectedGoals.length == 1) return;
        _selectedGoals.remove(goal);
      } else {
        _selectedGoals.add(goal);
      }
    });
  }

  void _toggleSport(SportMode sport) {
    setState(() {
      if (_preferredSports.contains(sport)) {
        if (_preferredSports.length == 1) return;
        _preferredSports.remove(sport);
      } else {
        _preferredSports.add(sport);
      }
    });
  }

  Map<String, dynamic>? _buildProfilePayload(AppLocalizations l10n) {
    final displayName = _displayNameController.text.trim();
    final weight = double.tryParse(
      _weightController.text.trim().replaceAll(',', '.'),
    );
    final height = int.tryParse(_heightController.text.trim());

    if (displayName.isEmpty || weight == null || height == null) {
      _showMessage(l10n.requiredProfileFields);
      return null;
    }

    final primaryGoal = _selectedGoals.firstWhere(
      (goal) => goal != GoalOption.other,
      orElse: () => _selectedGoals.first,
    );

    return {
      'displayName': displayName,
      'heightCm': height,
      'currentWeightKg': weight,
      'sex': _sex.apiValue,
      'primaryGoal': primaryGoal.apiPrimaryGoalValue,
      'fitnessLevel': _fitnessLevel.apiValue,
      'preferredSports': _preferredSports
          .map((sport) => sport.apiValue)
          .toList(),
    };
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ProfileBodyIndicators extends StatelessWidget {
  const _ProfileBodyIndicators({
    required this.profile,
    required this.isLoading,
    required this.hasError,
  });

  final Map<String, dynamic>? profile;
  final bool isLoading;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (isLoading) {
      return const LinearProgressIndicator(minHeight: 3);
    }

    if (hasError) {
      return Text(
        l10n.apiUnexpectedError,
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }

    final bmi = jsonDouble(profile, 'bmi');
    final category = bmiCategoryLabel(jsonString(profile, 'bmiCategory'), l10n);
    if (bmi <= 0) {
      return Text(
        l10n.bmiPreview,
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }

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
                label: l10n.bmiTitle,
                value: formatBmi(bmi),
                unit: '',
                color: AppColors.primary,
              ),
            ),
            if (category != null)
              SizedBox(
                width: itemWidth,
                child: AppMetricTile(
                  label: l10n.bmiCategory,
                  value: category,
                  unit: '',
                  color: AppColors.gps,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.label,
    required this.hint,
    required this.icon,
    this.controller,
    this.keyboardType,
  });

  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController? controller;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
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

class _PreferredSportsSelector extends StatelessWidget {
  const _PreferredSportsSelector({
    required this.selectedSports,
    required this.onSportToggled,
  });

  final Set<SportMode> selectedSports;
  final ValueChanged<SportMode> onSportToggled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.preferredSports,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: SportMode.values.map((sport) {
            return FilterChip(
              avatar: Icon(sport.icon, size: 18),
              label: Text(sport.label(l10n)),
              selected: selectedSports.contains(sport),
              onSelected: (_) => onSportToggled(sport),
            );
          }).toList(),
        ),
      ],
    );
  }
}
