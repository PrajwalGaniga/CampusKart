import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/app_theme.dart';
import 'routes/app_router.dart';
import 'services/shared_prefs_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWithValue(
          SharedPreferencesService(sharedPreferences),
        ),
      ],
      child: const CampusPulseApp(),
    ),
  );
}

class CampusPulseApp extends ConsumerWidget {
  const CampusPulseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'CampusPulse',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      routerConfig: appRouter,
    );
  }
}
