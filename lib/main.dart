import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:neo_game_suit/core/routing/app_router.dart';
import 'package:neo_game_suit/core/theme/app_theme.dart';
import 'package:neo_game_suit/core/storage/storage_service.dart';
import 'package:neo_game_suit/core/storage/game_storage.dart';

late final StorageService storageService;
late final GameStorage gameStorage;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  storageService = StorageService(prefs);
  gameStorage = GameStorage(storageService);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Gemini Game Suite',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
