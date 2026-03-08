import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_skeleton/core/services/analytics/analytics_client.dart';
import 'package:flutter_skeleton/core/services/analytics/analytics_navigation_observer.dart';
import 'package:flutter_skeleton/di/di_container.dart';
import 'package:flutter_skeleton/features/auth/presentation/cubit/auth_cubit.dart';

// ──────────────────────────────────────────────────────────────
// ROUTING MODE – swap the import below to change routing style.
//
//  Shell  : bottom navigation bar with persistent tab state.
//  Flat   : simple stack-based navigation without a shell.
// ──────────────────────────────────────────────────────────────
import 'package:flutter_skeleton/navigation/routes_shell.dart';
// import 'package:flutter_skeleton/navigation/routes_flat.dart';

class AppRouter {
  static final rootNavigatorKey = GlobalKey<NavigatorState>();

  final GoRouter router = GoRouter(
    initialLocation: const SplashRoute().location,
    debugLogDiagnostics: true,
    navigatorKey: rootNavigatorKey,
    routes: $appRoutes,
    observers: [
      AnalyticsNavigationObserver(
        analyticsClient: diContainer<AnalyticsClient>(),
      ),
    ],
    redirect: (context, state) {
      final authCubit = diContainer<AuthCubit>();
      final authState = authCubit.state;
      return switch (authState) {
        AuthInitial() => const SplashRoute().location,
        AuthLoading() => const SplashRoute().location,
        UserAuthenticated() => _handleAuthenticated(state),
        UserUnAuthenticated() => _handleUnauthenticated(state),
        AuthError() => const WelcomeRoute().location,
      };
    },
    errorPageBuilder: (context, state) => const MaterialPage(
      child: Scaffold(
        body: Center(child: Text('Route not found!')),
      ),
    ),
  );

  static String? _handleAuthenticated(GoRouterState state) {
    final authRoutes = [
      const WelcomeRoute().location,
      const SplashRoute().location,
    ];
    final isOnAuthRoute =
        authRoutes.any((r) => state.matchedLocation.startsWith(r));
    if (isOnAuthRoute) {
      return const HomeRoute().location;
    }
    return null;
  }

  static String? _handleUnauthenticated(GoRouterState state) {
    if (state.matchedLocation.startsWith(const WelcomeRoute().location)) {
      return null;
    }
    return const WelcomeRoute().location;
  }
}
