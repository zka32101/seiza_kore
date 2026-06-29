import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers/settings_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/constellation_detail_screen.dart';
import 'screens/timecapsule_screen.dart';
import 'screens/ar_observation_screen.dart';
import 'screens/add_observation_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/achievements_screen.dart';

class SeizaKoreApp extends ConsumerWidget {
  const SeizaKoreApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nightMode = ref.watch(nightModeProvider);

    final app = MaterialApp.router(
      title: '星座コレ！',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );

    if (!nightMode) return app;

    // 夜間赤色フィルター（AR画面は自前のフィルターを持つので重複するが許容）
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix(<double>[
        0.2126, 0, 0, 0, 0,
        0, 0, 0, 0, 0,
        0, 0, 0, 0, 0,
        0, 0, 0, 1, 0,
      ]),
      child: app,
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/stats',
      builder: (context, state) => const StatsScreen(),
    ),
    GoRoute(
      path: '/achievements',
      builder: (context, state) => const AchievementsScreen(),
    ),
    GoRoute(
      path: '/constellation/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ConstellationDetailScreen(constellationId: id);
      },
    ),
    GoRoute(
      path: '/timecapsule',
      builder: (context, state) => const TimecapsuleScreen(),
    ),
    GoRoute(
      path: '/ar',
      builder: (context, state) => const ARObservationScreen(),
    ),
    GoRoute(
      path: '/add-observation/:id/:bortle',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        final bortle = int.tryParse(state.pathParameters['bortle'] ?? '5') ?? 5;
        return AddObservationScreen(
          constellationId: id,
          initialBortle: bortle,
        );
      },
    ),
    GoRoute(
      path: '/add-observation/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return AddObservationScreen(constellationId: id);
      },
    ),
  ],
);
