import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:mystory/data/services/pref/theme_preference.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../database/database_controller.dart';
import '../network/dio_client.dart';
import '../network/service_genre.dart';
import '../network/service_story.dart';

final getIt = GetIt.instance;

Future<void> setLocator() async {
  //config
  getIt.registerLazySingleton<Dio>(() => DioClient.createDio());
  //service
  getIt.registerLazySingleton<ApiStoryService>(() => ApiStoryService(getIt<Dio>()));
  getIt.registerLazySingleton<ApiGenreService>(() => ApiGenreService(getIt<Dio>()));
  //database controller
  getIt.registerSingleton<DatabaseController>(DatabaseController());
  //Shared preference
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<ThemePreference>(ThemePreference(prefs));
}
