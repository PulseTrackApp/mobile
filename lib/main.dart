import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/pulse_track_app.dart';
import 'core/api/api_providers.dart';
import 'core/api/auth_token_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final tokenStore = AuthTokenStore();
  await tokenStore.restore();

  runApp(
    ProviderScope(
      overrides: [authTokenStoreProvider.overrideWith((ref) => tokenStore)],
      child: PulseTrackApp(
        showOnboarding:
            !tokenStore.isAuthenticated || !tokenStore.profileCompleted,
      ),
    ),
  );
}
