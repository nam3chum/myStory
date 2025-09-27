import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../database/database_controller.dart';
import '../network/service_genre.dart';

final appInitViewModelProvider = StateNotifierProvider<AppInitViewModel, bool>((ref) => AppInitViewModel());

class AppInitViewModel extends StateNotifier<bool> {
  AppInitViewModel() : super(false);

  Future<void> initializeApp() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = !(prefs.getBool('hasLaunched') ?? false);
    if (isFirstLaunch) {
      final genresFromApi = await ApiGenreService(Dio()).getGenres();
      await DatabaseController().insertGenres(genresFromApi);
      prefs.setBool('hasLaunched', true);
    }
    state = true;
  }
}

final appInitProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final isFirstLaunch = (prefs.getBool('isFirstLaunch') ?? true);

  if (isFirstLaunch) {
    final genresFromApi = await ApiGenreService(Dio()).getGenres();
    await DatabaseController().insertGenres(genresFromApi);
    prefs.setBool('isFirstLaunch', false);
  }

  return true;
});
