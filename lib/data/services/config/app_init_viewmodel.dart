import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mystory/services/truyen_crawler/src/services/services.dart';
import 'package:mystory/views/settings_screen/setting_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../database/database_controller.dart';

final appInitViewModelProvider =
    AsyncNotifierProvider<AppInitViewModel, void>(AppInitViewModel.new);

class AppInitViewModel extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    await _init();
  }

  Future<void> _init() async {
    await ref.read(settingsProvider.notifier).init();
  }

  Future<void> initializeApp() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = !(prefs.getBool('hasLaunched') ?? false);
    if (isFirstLaunch) {
      final genresFromApi = await TruyenFullService().getGenres();
      await DatabaseController().insertGenres(genresFromApi.data ?? []);
      prefs.setBool('hasLaunched', true);
    }
  }
}
