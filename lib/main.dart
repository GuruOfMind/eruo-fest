import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/router/app_router.dart';
import 'core/services/firebase/firebase_service.dart';
import 'core/services/firebase/messaging_service.dart';
import 'core/state/app_settings.dart';
import 'core/theme/app_theme.dart';
import 'data/local_prefs.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Fails softly until `flutterfire configure` is run — see FirebaseService.
  await FirebaseService.ensureInitialized();
  // Load locale date symbols so DateFormat works for `ar` (and others).
  await initializeDateFormatting();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const EuroFestApp(),
    ),
  );
}

class EuroFestApp extends ConsumerStatefulWidget {
  const EuroFestApp({super.key});

  @override
  ConsumerState<EuroFestApp> createState() => _EuroFestAppState();
}

class _EuroFestAppState extends ConsumerState<EuroFestApp> {
  @override
  void initState() {
    super.initState();
    // Register for push and route notification taps to the event. Runs after
    // first frame so the router is ready; no-ops when Firebase is unavailable.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await MessagingService.instance.start();
      await MessagingService.instance.wireOpenHandlers(
        (eventId) => ref.read(goRouterProvider).push('/event/$eventId'),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(appSettingsProvider).locale;
    return MaterialApp.router(
      title: 'EuroFest',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      // Arabic-first: default locale is `ar`; RTL is applied automatically by
      // MaterialApp based on the active locale's text direction.
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: ref.watch(goRouterProvider),
    );
  }
}
