import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_settings_controller.dart';
import '../core/api/api_providers.dart';
import '../core/modules/module_providers.dart';
import '../core/push/push_providers.dart';
import '../core/theme/app_theme.dart';
import '../features/home/screens/home_screen.dart';
import '../features/onboarding/screens/onboarding_screen.dart';
import '../l10n/app_localizations.dart';

class PulseTrackApp extends ConsumerStatefulWidget {
  const PulseTrackApp({super.key, this.locale, this.showOnboarding = true});

  final Locale? locale;
  final bool showOnboarding;

  @override
  ConsumerState<PulseTrackApp> createState() => _PulseTrackAppState();
}

class _PulseTrackAppState extends ConsumerState<PulseTrackApp>
    with WidgetsBindingObserver {
  late final AppSettingsController _settingsController;
  late bool _showOnboarding;
  bool _allowGuestHome = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _settingsController = AppSettingsController(initialLocale: widget.locale);
    _showOnboarding = widget.showOnboarding;

    // Apres le premier rendu : demander la permission de notifier pendant que
    // l'ecran se construit ferait apparaitre la boite de dialogue systeme
    // avant que l'utilisateur ait vu quoi que ce soit de l'application.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(ref.read(pushRegistrarProvider).start());
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _settingsController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(ref.read(moduleAccessControllerProvider).refresh());
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokenStore = ref.watch(authTokenStoreProvider);

    return AppSettingsScope(
      controller: _settingsController,
      child: AnimatedBuilder(
        animation: _settingsController,
        builder: (context, _) {
          final showOnboarding =
              _showOnboarding ||
              (!tokenStore.isAuthenticated && !_allowGuestHome);

          return MaterialApp(
            title: 'GymFlow',
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
            home: showOnboarding
                ? OnboardingScreen(
                    onComplete: () {
                      setState(() {
                        _showOnboarding = false;
                        _allowGuestHome = false;
                      });
                    },
                    onSkip: () {
                      setState(() {
                        _showOnboarding = false;
                        _allowGuestHome = true;
                      });
                    },
                  )
                : const HomeScreen(),
          );
        },
      ),
    );
  }
}
