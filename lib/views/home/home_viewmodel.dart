import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/enums/view_type.dart';
import '../../data/services/config/service_get_it.dart';
import '../../data/services/network/dio_client.dart';
import '../../data/services/pref/preference.dart';
import '../../services/truyen_crawler/truyen_crawler.dart';

final homeProvider = NotifierProvider.autoDispose<HomeViewModel, HomeState>(HomeViewModel.new);

class HomeState {
  final List<Story> stories;
  final List<Genre> genres;
  final List<HomeMenuItem>? homeMenuItems;
  final bool isLoading;
  final String? errorMessage;
  String selectedSlug;
  final ViewType viewType;

  HomeState({
    this.stories = const [],
    this.genres = const [],
    this.homeMenuItems,
    this.isLoading = false,
    this.errorMessage,
    this.selectedSlug = '',
    this.viewType = ViewType.grid1,
  });

  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  bool get hasData => stories.isNotEmpty;

  bool get hasGenres => genres.isNotEmpty;

  HomeState copyWith({
    List<Story>? stories,
    List<Genre>? genres,
    List<HomeMenuItem>? homeMenuItems,
    bool? isLoading,
    String? errorMessage,
    String? selectedSlug,
    ViewType? viewType,
  }) {
    return HomeState(
      stories: stories ?? this.stories,
      genres: genres ?? this.genres,
      homeMenuItems: homeMenuItems ?? this.homeMenuItems,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedSlug: selectedSlug ?? this.selectedSlug,
      viewType: viewType ?? this.viewType,
    );
  }

  factory HomeState.initial() => HomeState(
        stories: [],
        genres: [],
        homeMenuItems: null,
        isLoading: false,
        selectedSlug: '',
        viewType: ViewType.grid1,
        errorMessage: '',
      );
}

class HomeViewModel extends AutoDisposeNotifier<HomeState> {
  late final ThemePreference _pref;
  late final TruyenFullService _truyenService;

  @override
  HomeState build() {
    _pref = getIt<ThemePreference>();
    _truyenService = TruyenFullService();
    return HomeState.initial();
  }

  Future<void> loadStories(String genreUrl) async {
    state = state.copyWith(isLoading: true);

    try {
      final stories = await _truyenService.getStoriesByGenre(genreUrl);
      final genres = await _truyenService.getGenres();
      state = state.copyWith(stories: stories.data?.items, genres: genres.data, errorMessage: 'thành công');
    } on DioException catch (e) {
      final error = DioClient.handleError(e);
      state = state.copyWith(errorMessage: (error.toString()));
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Load menu items from crawler service
  Future<void> loadHomeMenu() async {
    try {
      final result = await _truyenService.getHomeMenu();
      if (result.success && result.data != null) {
        state = state.copyWith(homeMenuItems: result.data);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> getViewMode() async {
    final mode = await _pref.getViewType();
    state = state.copyWith(viewType: mode);
  }

  Future<void> setViewMode(ViewType mode) async {
    if (state.viewType != mode) {
      state = state.copyWith(viewType: mode);
      await _pref.saveViewType(mode);
    }
  }

  void selectGenre(String genreId) {
    state = state.copyWith(selectedSlug: genreId);
  }

  // Constants for menu options
  static const List<String> menuOptions = ["Quản lý truyện và thể loại", "Kệ sách cá nhân", "Thiết lập"];
}
