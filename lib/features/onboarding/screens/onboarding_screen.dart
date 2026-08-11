import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_error.dart';
import '../../../core/api/api_formatters.dart';
import '../../../core/api/api_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/app_button.dart';
import '../../../core/ui/app_panel.dart';
import '../../../core/ui/pulse_track_logo.dart';
import '../../../l10n/app_localizations.dart';
import '../../profile/widgets/profile_choice_fields.dart';
import '../../tracking/models/sport_mode.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key, required this.onComplete, this.onSkip});

  final VoidCallback onComplete;
  final VoidCallback? onSkip;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _totalPages = 3;

  final _pageController = PageController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _customGoalController = TextEditingController();
  int _currentPage = 0;
  FitnessLevelOption _fitnessLevel = FitnessLevelOption.beginner;
  final Set<GoalOption> _selectedGoals = {GoalOption.loseWeight};
  SportMode _favoriteSport = SportMode.run;
  bool _useExistingAccount = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(child: PulseTrackLogo()),
                  TextButton(
                    onPressed: widget.onSkip ?? widget.onComplete,
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
                    _ProfilePage(
                      l10n: l10n,
                      emailController: _emailController,
                      passwordController: _passwordController,
                      displayNameController: _displayNameController,
                      weightController: _weightController,
                      heightController: _heightController,
                      fitnessLevel: _fitnessLevel,
                      useExistingAccount: _useExistingAccount,
                      onUseExistingAccountChanged: (value) {
                        setState(() => _useExistingAccount = value);
                      },
                      onForgotPasswordPressed: _openPasswordResetSheet,
                      onFitnessLevelChanged: (level) {
                        setState(() => _fitnessLevel = level);
                      },
                    ),
                    _TargetsPage(
                      l10n: l10n,
                      selectedGoals: _selectedGoals,
                      favoriteSport: _favoriteSport,
                      customGoalController: _customGoalController,
                      onGoalToggled: _toggleGoal,
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
                      label: _isSubmitting
                          ? l10n.saving
                          : _currentPage == _totalPages - 1
                          ? l10n.onboardingFinish
                          : l10n.onboardingNext,
                      icon: _currentPage == _totalPages - 1
                          ? Icons.check_rounded
                          : Icons.arrow_forward_rounded,
                      onPressed: _isSubmitting
                          ? null
                          : _currentPage == _totalPages - 1
                          ? _completeOnboarding
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

  Future<void> _completeOnboarding() async {
    final l10n = AppLocalizations.of(context);
    final profile = _buildProfilePayload(l10n);
    if (profile == null) return;

    setState(() => _isSubmitting = true);

    try {
      final api = ref.read(pulseTrackApiProvider);
      if (_useExistingAccount) {
        await api.login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        await api.register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }
      await api.saveProfile(profile);
      if (!mounted) return;
      widget.onComplete();
    } on ApiProblem catch (problem) {
      _showMessage('${l10n.apiErrorPrefix} ${problem.message}');
    } catch (_) {
      _showMessage(l10n.apiUnexpectedError);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _openPasswordResetSheet() async {
    final api = ref.read(pulseTrackApiProvider);
    final completed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _PasswordResetSheet(
        initialEmail: _emailController.text.trim(),
        onRequestCode: (email) => api.requestPasswordResetCode(email: email),
        onResetPassword: ({required code, required newPassword}) =>
            api.resetPassword(code: code, newPassword: newPassword),
      ),
    );

    if (!mounted || completed != true) return;
    _showMessage(AppLocalizations.of(context).passwordResetSuccess);
  }

  Map<String, dynamic>? _buildProfilePayload(AppLocalizations l10n) {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final displayName = _displayNameController.text.trim();
    final weight = double.tryParse(
      _weightController.text.trim().replaceAll(',', '.'),
    );
    final height = int.tryParse(_heightController.text.trim());

    if (email.isEmpty ||
        password.isEmpty ||
        displayName.isEmpty ||
        weight == null ||
        height == null) {
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
      'primaryGoal': primaryGoal.apiPrimaryGoalValue,
      'fitnessLevel': _fitnessLevel.apiValue,
      'preferredSports': [_favoriteSport.apiValue],
    };
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
  const _ProfilePage({
    required this.l10n,
    required this.emailController,
    required this.passwordController,
    required this.displayNameController,
    required this.weightController,
    required this.heightController,
    required this.fitnessLevel,
    required this.useExistingAccount,
    required this.onUseExistingAccountChanged,
    required this.onForgotPasswordPressed,
    required this.onFitnessLevelChanged,
  });

  final AppLocalizations l10n;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController displayNameController;
  final TextEditingController weightController;
  final TextEditingController heightController;
  final FitnessLevelOption fitnessLevel;
  final bool useExistingAccount;
  final ValueChanged<bool> onUseExistingAccountChanged;
  final VoidCallback onForgotPasswordPressed;
  final ValueChanged<FitnessLevelOption> onFitnessLevelChanged;

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
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.existingAccount),
                  value: useExistingAccount,
                  onChanged: onUseExistingAccountChanged,
                ),
                const SizedBox(height: 8),
                _OnboardingField(
                  controller: emailController,
                  label: l10n.email,
                  hint: l10n.emailHint,
                  icon: Icons.alternate_email_rounded,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 14),
                _OnboardingPasswordField(
                  controller: passwordController,
                  label: l10n.password,
                  hint: l10n.passwordHint,
                  icon: Icons.lock_outline_rounded,
                ),
                if (useExistingAccount) ...[
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: onForgotPasswordPressed,
                      icon: const Icon(Icons.lock_reset_rounded),
                      label: Text(l10n.forgotPassword),
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                _OnboardingField(
                  controller: displayNameController,
                  label: l10n.displayName,
                  hint: l10n.displayNameHint,
                  icon: Icons.badge_outlined,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _OnboardingField(
                        controller: weightController,
                        label: l10n.weightKg,
                        hint: '82',
                        icon: Icons.monitor_weight_outlined,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _OnboardingField(
                        controller: heightController,
                        label: l10n.heightCm,
                        hint: '178',
                        icon: Icons.height_rounded,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _BmiPreview(
                  weightController: weightController,
                  heightController: heightController,
                ),
                const SizedBox(height: 14),
                FitnessLevelSelect(
                  value: fitnessLevel,
                  onChanged: onFitnessLevelChanged,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BmiPreview extends StatelessWidget {
  const _BmiPreview({
    required this.weightController,
    required this.heightController,
  });

  final TextEditingController weightController;
  final TextEditingController heightController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([weightController, heightController]),
      builder: (context, _) {
        final l10n = AppLocalizations.of(context);
        final bmi = _calculateBmi(weightController.text, heightController.text);
        final color = bmi == null ? AppColors.gps : AppColors.primary;

        return DecoratedBox(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            border: Border.all(color: color.withValues(alpha: 0.24)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.calculate_outlined, color: color),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bmi == null
                            ? l10n.bmiTitle
                            : l10n.bmiValue(bmi.toStringAsFixed(1)),
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        bmi == null ? l10n.bmiWaiting : l10n.bmiHelper,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PasswordResetSheet extends StatefulWidget {
  const _PasswordResetSheet({
    required this.initialEmail,
    required this.onRequestCode,
    required this.onResetPassword,
  });

  final String initialEmail;
  final Future<void> Function(String email) onRequestCode;
  final Future<void> Function({
    required String code,
    required String newPassword,
  })
  onResetPassword;

  @override
  State<_PasswordResetSheet> createState() => _PasswordResetSheetState();
}

class _PasswordResetSheetState extends State<_PasswordResetSheet> {
  late final TextEditingController _emailController;
  late final TextEditingController _codeController;
  late final TextEditingController _newPasswordController;
  bool _codeRequested = false;
  bool _isRequesting = false;
  bool _isResetting = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
    _codeController = TextEditingController();
    _newPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 18, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.passwordResetTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  tooltip: l10n.close,
                  onPressed: () => Navigator.of(context).pop(false),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _OnboardingField(
              controller: _emailController,
              label: l10n.email,
              hint: l10n.emailHint,
              icon: Icons.alternate_email_rounded,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            AppButton.secondary(
              label: _isRequesting
                  ? l10n.passwordResetSending
                  : l10n.requestResetCode,
              icon: Icons.mark_email_read_outlined,
              onPressed: _isRequesting ? null : _requestCode,
            ),
            if (_codeRequested) ...[
              const SizedBox(height: 18),
              _OnboardingField(
                controller: _codeController,
                label: l10n.passwordResetCode,
                hint: l10n.passwordResetCodeHint,
                icon: Icons.pin_outlined,
                keyboardType: TextInputType.visiblePassword,
              ),
              const SizedBox(height: 12),
              _OnboardingPasswordField(
                controller: _newPasswordController,
                label: l10n.newPassword,
                hint: l10n.passwordHint,
                icon: Icons.lock_outline_rounded,
              ),
              const SizedBox(height: 18),
              AppButton.primary(
                label: _isResetting
                    ? l10n.passwordResetSubmitting
                    : l10n.resetPassword,
                icon: Icons.check_rounded,
                onPressed: _isResetting ? null : _resetPassword,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _requestCode() async {
    final l10n = AppLocalizations.of(context);
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showMessage(l10n.passwordResetEmailRequired);
      return;
    }

    setState(() => _isRequesting = true);
    try {
      await widget.onRequestCode(email);
      if (!mounted) return;
      setState(() => _codeRequested = true);
      _showMessage(l10n.passwordResetCodeSent);
    } on ApiProblem catch (problem) {
      _showMessage('${l10n.apiErrorPrefix} ${problem.message}');
    } catch (_) {
      _showMessage(l10n.apiUnexpectedError);
    } finally {
      if (mounted) setState(() => _isRequesting = false);
    }
  }

  Future<void> _resetPassword() async {
    final l10n = AppLocalizations.of(context);
    final code = _codeController.text.trim();
    final newPassword = _newPasswordController.text;
    if (_emailController.text.trim().isEmpty ||
        code.isEmpty ||
        newPassword.isEmpty) {
      _showMessage(l10n.passwordResetRequiredFields);
      return;
    }

    setState(() => _isResetting = true);
    try {
      await widget.onResetPassword(code: code, newPassword: newPassword);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiProblem catch (problem) {
      _showMessage('${l10n.apiErrorPrefix} ${problem.message}');
    } catch (_) {
      _showMessage(l10n.apiUnexpectedError);
    } finally {
      if (mounted) setState(() => _isResetting = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _TargetsPage extends StatelessWidget {
  const _TargetsPage({
    required this.l10n,
    required this.selectedGoals,
    required this.favoriteSport,
    required this.customGoalController,
    required this.onGoalToggled,
    required this.onSportChanged,
  });

  final AppLocalizations l10n;
  final Set<GoalOption> selectedGoals;
  final SportMode favoriteSport;
  final TextEditingController customGoalController;
  final ValueChanged<GoalOption> onGoalToggled;
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
                GoalsSelector(
                  selectedGoals: selectedGoals,
                  onGoalToggled: onGoalToggled,
                  customGoalController: customGoalController,
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

double? _calculateBmi(String weightValue, String heightValue) {
  final weight = parseLocalizedDouble(weightValue);
  final heightCm = parseLocalizedDouble(heightValue);
  if (weight <= 0 || heightCm <= 0) return null;

  final heightMeters = heightCm / 100;
  return weight / (heightMeters * heightMeters);
}

class _OnboardingField extends StatelessWidget {
  const _OnboardingField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
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

class _OnboardingPasswordField extends StatefulWidget {
  const _OnboardingPasswordField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;

  @override
  State<_OnboardingPasswordField> createState() =>
      _OnboardingPasswordFieldState();
}

class _OnboardingPasswordFieldState extends State<_OnboardingPasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      enableSuggestions: false,
      autocorrect: false,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: Icon(widget.icon),
        suffixIcon: IconButton(
          tooltip: _obscureText ? l10n.showPassword : l10n.hidePassword,
          icon: Icon(
            _obscureText
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
          onPressed: () {
            setState(() => _obscureText = !_obscureText);
          },
        ),
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
