import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/genre_model.dart';
import '../../data/models/story_model.dart';
import '../../data/services/config/service_get_it.dart';
import '../../data/services/network/service_genre.dart';
import '../../data/services/network/service_story.dart';

class GenreStoryState {
  final List<Genre> listGenre;
  final List<Story> listStory;
  final bool isLoading;

  const GenreStoryState({
    this.listGenre = const [],
    this.listStory = const [],
    this.isLoading = false,
  });

  GenreStoryState copyWith({
    List<Genre>? listGenre,
    List<Story>? listStory,
    bool? isLoading,
  }) {
    return GenreStoryState(
      listGenre: listGenre ?? this.listGenre,
      listStory: listStory ?? this.listStory,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  factory GenreStoryState.initial() => const GenreStoryState();
}

class GenreStoryViewModelNotifier extends Notifier<GenreStoryState> {
  late final ApiGenreService _genreService;
  late final ApiStoryService _storyService;

  @override
  GenreStoryState build() {
    _genreService = getIt<ApiGenreService>();
    _storyService = getIt<ApiStoryService>();
    return GenreStoryState.initial();
  }

  Future<void> loadGenres() async {
    try {
      final genres = await _genreService.getGenres();
      state = state.copyWith(listGenre: genres.cast<Genre>());
    } catch (e) {
      // Keep current state if error occurs
    }
  }

  Future<void> loadStories(String genreId) async {
    state = state.copyWith(isLoading: true);
    try {
      List<Story> loadedStories = (await _storyService.getStories()).cast<Story>();
      state = state.copyWith(listStory: loadedStories, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }
}

final genreStoryProvider = NotifierProvider<GenreStoryViewModelNotifier, GenreStoryState>(
  () => GenreStoryViewModelNotifier(),
);
