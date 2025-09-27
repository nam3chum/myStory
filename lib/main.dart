import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mystory/data/services/pref/theme_preference.dart';
import 'package:mystory/views/home/home_screen.dart';
import 'package:mystory/views/settings_screen/setting_viewmodel.dart';

import 'data/services/config/app_init_viewmodel.dart';
import 'data/services/config/service_get_it.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setLocator();
  runApp(ProviderScope(child: AppStarter()));
}

class AppStarter extends ConsumerStatefulWidget {
  const AppStarter({super.key});

  @override
  ConsumerState<AppStarter> createState() => _AppStarterState();
}

class _AppStarterState extends ConsumerState<AppStarter> {
  @override
  void initState() {
    super.initState();
    // gọi init ngay khi app start
    Future.microtask(() {
      ref.read(appInitViewModelProvider.notifier).initializeApp();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(settingsProvider).themeMode;
    final isInitialized = ref.watch(appInitViewModelProvider);
    ref.listen<SettingsState>(settingsProvider, (prev, next) {
      final prefs = getIt<ThemePreference>();
      prefs.saveFontSize(next.fontSize);
    });
    if (!isInitialized) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      themeMode: themeMode,
      darkTheme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}
