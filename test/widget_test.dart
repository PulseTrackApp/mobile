import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_flutter/app/pulse_track_app.dart';

void main() {
  testWidgets('GymFlow onboarding can be skipped', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: PulseTrackApp(locale: Locale('fr'))),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ton sport, tes stats, tes objectifs'), findsOneWidget);

    await tester.tap(find.text('Passer'));
    await tester.pumpAndSettle();

    expect(find.text('Démarrer une session'), findsOneWidget);
  });

  testWidgets('GymFlow home renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: PulseTrackApp(locale: Locale('fr'))),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Passer'));
    await tester.pumpAndSettle();

    expect(find.text('GymFlow'), findsOneWidget);
    expect(find.text('Démarrer une session'), findsOneWidget);
    expect(find.text('Objectif semaine'), findsOneWidget);

    await tester.tap(find.byTooltip('Ouvrir le menu'));
    await tester.pumpAndSettle();

    expect(find.text('Profil initial'), findsOneWidget);
    expect(find.text('Évolution physique'), findsOneWidget);
    expect(find.text('Coach Gemini'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Paramètres'), 200);
    await tester.tap(find.text('Paramètres'));
    await tester.pumpAndSettle();

    expect(find.text('Apparence'), findsOneWidget);
    expect(find.text('Sport'), findsOneWidget);
    expect(find.text('Tracking'), findsOneWidget);
    expect(find.text('Confidentialité'), findsOneWidget);
  });
}
