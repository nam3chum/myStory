import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/enums/view_type.dart';
import '../../data/models/genre_model.dart';
import '../../data/models/story_model.dart';
import '../../data/services/config/service_get_it.dart';
import '../../data/services/network/dio_client.dart';
import '../../data/services/network/service_genre.dart';
import '../../data/services/network/service_story.dart';

final homeProvider = NotifierProvider.autoDispose<HomeViewModel, HomeState>(HomeViewModel.new);

class HomeState {
  final List<Story> stories;
  final List<Genre> genres;
  final bool isLoading;
  final String? errorMessage;
  String selectedSlug;
  final ViewMode viewMode;

  HomeState({
    this.stories = const [],
    this.genres = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedSlug = '',
    this.viewMode = ViewMode.list,
  });

  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  bool get hasData => stories.isNotEmpty;

  bool get hasGenres => genres.isNotEmpty;

  HomeState copyWith({
    List<Story>? stories,
    List<Genre>? genres,
    bool? isLoading,
    String? errorMessage,
    String? selectedSlug,
    ViewMode? viewMode,
  }) {
    return HomeState(
      stories: stories ?? this.stories,
      genres: genres ?? this.genres,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedSlug: selectedSlug ?? this.selectedSlug,
      viewMode: viewMode ?? this.viewMode,
    );
  }

  factory HomeState.initial() => HomeState(
    stories: [],
    genres: [],
    isLoading: false,
    selectedSlug: '',
    viewMode: ViewMode.list,
    errorMessage: '',
  );
}

class HomeViewModel extends AutoDisposeNotifier<HomeState> {
  late final ApiGenreService _genreService;
  late final ApiStoryService _storyService;

  @override
  HomeState build() {
    _genreService = getIt<ApiGenreService>();
    _storyService = getIt<ApiStoryService>();
    return HomeState.initial();
  }

  Future<void> loadStories() async {
    state = state.copyWith(isLoading: true);

    try {
     // throw("lỗi");
      final stories = await _storyService.getStories();
      final genres = await _genreService.getGenres();
      state = state.copyWith(stories: stories, genres: genres, errorMessage: null);
    } on DioException catch (e) {
      final error = DioClient.handleError(e);
      state = state.copyWith(errorMessage: (error.toString()));
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> retryLoadStories() async {
    await loadStories();
  }

  void setViewMode(ViewMode mode) {
    if (state.viewMode != mode) {
      state = state.copyWith(viewMode: mode);
    }
  }
}
