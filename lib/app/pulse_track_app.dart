import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_settings_controller.dart';
import '../core/api/api_providers.dart';
import '../core/api/auth_token_store.dart';
import '../core/modules/module_providers.dart';
import '../core/push/push_providers.dart';
import '../core/theme/app_theme.dart';
import '../features/account/screens/account_disabled_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/onboarding/screens/onboarding_screen.dart';
import '../features/pricing/screens/pricing_screen.dart';
import '../features/pricing/screens/upgrade_required_screen.dart';
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
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  late bool _showOnboarding;
  int _lastSessionExpiredNoticeId = 0;
  int _lastPaymentRequiredNoticeId = 0;

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
              !tokenStore.isAuthenticated ||
              !tokenStore.profileCompleted;

          return MaterialApp(
            title: 'GymFlow',
            debugShowCheckedModeBanner: false,
            scaffoldMessengerKey: _scaffoldMessengerKey,
            builder: (context, child) {
              _showGlobalNotices(AppLocalizations.of(context), tokenStore);
              return child ?? const SizedBox.shrink();
            },
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
            // L'ordre compte, et il est celui du serveur. La suspension passe
            // devant tout : elle ne se debloque ni en mettant a jour ni en
            // payant. Puis la mise a jour avant le paiement, parce qu'une
            // application trop ancienne doit apprendre qu'elle est perimee et
            // non qu'il faut payer. Les trois passent avant l'authentification :
            // le serveur refuse aussi la connexion et l'inscription — sans quoi
            // un vieil APK contournerait le verrou en creant un compte.
            home: tokenStore.accountDisabled
                ? AccountDisabledScreen(
                    message: tokenStore.accountDisabledMessage,
                    onRetry: () {
                      ref.read(authTokenStoreProvider).clearAccountDisabled();
                    },
                  )
                : tokenStore.upgradeRequired
                ? UpgradeRequiredScreen(
                    minimumVersion: tokenStore.minimumVersion,
                    storeUrl: tokenStore.storeUrl,
                    onRetry: () {
                      ref.read(authTokenStoreProvider).clearUpgradeRequired();
                    },
                  )
                : tokenStore.paymentRequired && tokenStore.isAuthenticated
                ? PricingScreen(
                    paymentRequired: true,
                    onRetryAccess: () {
                      ref.read(authTokenStoreProvider).clearPaymentRequired();
                      unawaited(
                        ref.read(moduleAccessControllerProvider).refresh(),
                      );
                    },
                  )
                : showOnboarding
                ? OnboardingScreen(
                    onComplete: () {
                      setState(() {
                        _showOnboarding = false;
                      });
                    },
                  )
                : const HomeScreen(),
          );
        },
      ),
    );
  }

  void _showGlobalNotices(AppLocalizations l10n, AuthTokenStore tokenStore) {
    if (tokenStore.sessionExpiredNoticeId != _lastSessionExpiredNoticeId) {
      _lastSessionExpiredNoticeId = tokenStore.sessionExpiredNoticeId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text(l10n.sessionExpiredToast)),
        );
      });
    }

    if (tokenStore.paymentRequiredNoticeId != _lastPaymentRequiredNoticeId) {
      _lastPaymentRequiredNoticeId = tokenStore.paymentRequiredNoticeId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text(l10n.paymentRequiredToast)),
        );
      });
    }
  }
}
