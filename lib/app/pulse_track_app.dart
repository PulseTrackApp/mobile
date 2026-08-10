import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_settings_controller.dart';
import '../core/theme/app_theme.dart';
import '../features/home/screens/home_screen.dart';
import '../features/onboarding/screens/onboarding_screen.dart';
import '../l10n/app_localizations.dart';

class PulseTrackApp extends StatefulWidget {
  const PulseTrackApp({super.key, this.locale, this.showOnboarding = true});

  final Locale? locale;
  final bool showOnboarding;

  @override
  State<PulseTrackApp> createState() => _PulseTrackAppState();
}

class _PulseTrackAppState extends State<PulseTrackApp> {
  late final AppSettingsController _settingsController;
  late bool _showOnboarding;

  @override
  void initState() {
    super.initState();
    _settingsController = AppSettingsController(initialLocale: widget.locale);
    _showOnboarding = widget.showOnboarding;
  }

  @override
  void dispose() {
    _settingsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppSettingsScope(
      controller: _settingsController,
      child: AnimatedBuilder(
        animation: _settingsController,
        builder: (context, _) {
          return MaterialApp(
            title: 'PulseTrack',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: _settingsController.themeMode,
            locale: _settingsController.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: _showOnboarding
                ? OnboardingScreen(
                    onComplete: () {
                      setState(() => _showOnboarding = false);
                    },
                  )
                : const HomeScreen(),
          );
        },
      ),
    );
  }
}
