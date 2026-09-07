import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/onboarding/personalization_screen.dart';
import '../features/home/home_screen.dart';
import '../features/material_import/import_screen.dart';
import '../features/reader/reader_screen.dart';
import '../features/focus_session/focus_setup_screen.dart';
import '../features/calm_break/calm_break_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/storage_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  final isOnboardingCompleted = storageService.isOnboardingCompleted();
  
  return GoRouter(
    initialLocation: isOnboardingCompleted ? '/' : '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/personalization',
        builder: (context, state) => const PersonalizationScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/import',
        builder: (context, state) => const ImportScreen(),
      ),
      GoRoute(
        path: '/focus-setup',
        builder: (context, state) => const FocusSetupScreen(),
      ),
      GoRoute(
        path: '/reader',
        builder: (context, state) => const ReaderScreen(),
      ),
      GoRoute(
        path: '/calm-break',
        builder: (context, state) => const CalmBreakScreen(),
      ),
    ],
  );
});
