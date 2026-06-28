import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:euro_fest/data/local_prefs.dart';
import 'package:euro_fest/features/event/widgets/event_card.dart';
import 'package:euro_fest/main.dart';

/// Pumps the app with the given persisted prefs injected.
Future<void> pumpApp(WidgetTester tester, Map<String, Object> values) async {
  SharedPreferences.setMockInitialValues(values);
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const EuroFestApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('first run shows onboarding in Arabic RTL', (tester) async {
    await pumpApp(tester, {});

    // Default locale is Arabic → right-to-left.
    expect(Directionality.of(tester.element(find.byType(Scaffold))),
        TextDirection.rtl);
    // Onboarding (not the bottom-nav shell) is shown on first run.
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('متابعة'), findsOneWidget); // "Continue"
  });

  testWidgets('returning user lands on the four-tab shell', (tester) async {
    await pumpApp(tester, {'onboardingComplete': true});

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(4));
  });

  testWidgets('following an artist persists to prefs', (tester) async {
    await pumpApp(tester, {'onboardingComplete': true, 'locale': 'en'});

    // Go to My Artists tab → browse catalog.
    await tester.tap(find.text('My Artists'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.search).last);
    await tester.pumpAndSettle();

    // Follow the first artist via its compact heart toggle.
    expect(find.byIcon(Icons.favorite_outline), findsWidgets);
    await tester.tap(find.byIcon(Icons.favorite_outline).first);
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('follows'), isNotEmpty);
  });

  testWidgets('discovery lists city events and opens detail with Book',
      (tester) async {
    await pumpApp(tester, {
      'onboardingComplete': true,
      'locale': 'en',
      'homeCity': 'berlin',
    });

    // Berlin has seed events → at least one card is shown.
    expect(find.byType(EventCard), findsWidgets);

    // Opening an on-sale event reveals the affiliate Book button.
    await tester.tap(find.byType(EventCard).first);
    await tester.pumpAndSettle();
    expect(find.text('Book tickets'), findsOneWidget);
  });
}
