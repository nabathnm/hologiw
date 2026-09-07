import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/router.dart';
import 'app/theme.dart';
import 'core/services/demo_data_service.dart';
import 'providers/user_preferences_provider.dart';
import 'providers/storage_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
  );

  // Load demo data
  await DemoDataService.loadDemoData(container);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const RuangBelajarApp(),
    ),
  );
}

class RuangBelajarApp extends ConsumerWidget {
  const RuangBelajarApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final prefs = ref.watch(userPreferencesProvider);

    return MaterialApp.router(
      title: 'KeepUp!',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(
        fontFamily: prefs.fontFamily,
        fontSize: prefs.fontSize,
        letterSpacing: prefs.letterSpacing,
        lineHeight: prefs.lineHeight,
        backgroundTheme: prefs.backgroundTheme,
      ),
      routerConfig: router,
    );
  }
}
