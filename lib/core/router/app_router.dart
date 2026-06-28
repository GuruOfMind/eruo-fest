import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/artist/artist_detail_screen.dart';
import '../../features/catalog/catalog_screen.dart';
import '../../features/discovery/discovery_screen.dart';
import '../../features/event/event_detail_screen.dart';
import '../../features/follows/my_artists_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/settings/notif_prefs_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../state/app_settings.dart';
import 'app_shell.dart';

final _rootKey = GlobalKey<NavigatorState>();

/// Top-level router. A StatefulShellRoute drives the four bottom-nav branches.
/// First-run users are redirected to `/onboarding` until they complete it.
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/discover',
    redirect: (context, state) {
      final done = ref.read(appSettingsProvider).onboardingComplete;
      final onboarding = state.matchedLocation == '/onboarding';
      if (!done && !onboarding) return '/onboarding';
      if (done && onboarding) return '/discover';
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/event/:id',
        parentNavigatorKey: _rootKey,
        builder: (context, state) =>
            EventDetailScreen(eventId: state.pathParameters['id']!),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/discover',
                builder: (context, state) => const DiscoveryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/artists',
                builder: (context, state) => const MyArtistsScreen(),
                routes: [
                  // Static segment declared before the `:id` param route.
                  GoRoute(
                    path: 'browse',
                    builder: (context, state) => const CatalogScreen(),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => ArtistDetailScreen(
                      artistId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/notifications',
                builder: (context, state) => const NotificationsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
                routes: [
                  GoRoute(
                    path: 'notifications',
                    builder: (context, state) => const NotifPrefsScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
