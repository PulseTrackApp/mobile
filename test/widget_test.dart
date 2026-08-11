import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_flutter/app/pulse_track_app.dart';
import 'package:mobile_flutter/core/api/api_providers.dart';
import 'package:mobile_flutter/core/api/auth_token_store.dart';

void main() {
  testWidgets('GymFlow bloque la Home sans onboarding termine', (
    WidgetTester tester,
  ) async {
    FlutterSecureStorage.setMockInitialValues({});
    final tokenStore = AuthTokenStore();
    await tokenStore.restore();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authTokenStoreProvider.overrideWith((ref) => tokenStore)],
        child: const PulseTrackApp(locale: Locale('fr'), showOnboarding: false),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ton sport, tes stats, tes objectifs'), findsOneWidget);
    expect(find.text('Passer'), findsNothing);
    expect(find.text('Demarrer une session'), findsNothing);
  });
}
