import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mystory/views/commons/app_init_error_view.dart';

import 'package:mystory/views/main_screen/main_screen.dart';
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
    Future.microtask(() {
      ref.read(appInitViewModelProvider.notifier).initializeApp();
      ref.read(settingsProvider.notifier).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final appInit = ref.watch(appInitViewModelProvider);

    return appInit.when(
      data: (_) => MaterialApp(
        themeMode: settings.themeMode,
        darkTheme: ThemeData.dark(),
        home: MainScreen(),
      ),
      error: (error, stackTrace) => MaterialApp(
        home: AppInitErrorView(error: error, onRetry: () {
          ref.invalidate(appInitViewModelProvider);
        }),
      ),
      loading: () => const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
