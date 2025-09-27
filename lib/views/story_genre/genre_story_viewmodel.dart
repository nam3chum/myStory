import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/genre_model.dart';
import '../../data/models/story_model.dart';
import '../../data/services/config/service_get_it.dart';
import '../../data/services/network/service_genre.dart';
import '../../data/services/network/service_story.dart';

class GenreStoryState {
  List<Genre> listGenre = [];
  List<Story> listStory = [];
  bool isLoading = false;

  GenreStoryState copyWith({List<Genre>? listGenre, List<Story>? listStory, bool? isLoading}) {
    final newState = GenreStoryState();
    newState.listGenre = listGenre ?? this.listGenre;
    newState.listStory = listStory ?? this.listStory;
    newState.isLoading = isLoading ?? this.isLoading;
    return newState;
  }
}

class GenreStoryViewModelNotifier extends Notifier<GenreStoryState> {
  @override
  GenreStoryState build() {
    return GenreStoryState();
  }

  final ApiGenreService genreService;

  final ApiStoryService storyService;

  GenreStoryViewModelNotifier({required this.genreService, required this.storyService});

  Future<void> loadGenres() async {
    final genres = await genreService.getGenres();
    state = state.copyWith(listGenre: genres.cast<Genre>());
  }

  Future<void> loadStories() async {
    state = state.copyWith(isLoading: true);
    try {
      List<Story> loadedStories = (await storyService.getStories()).cast<Story>();
      state = state.copyWith(listStory: loadedStories, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }
}

final genreStoryProvider = NotifierProvider<GenreStoryViewModelNotifier, GenreStoryState>(
  () => GenreStoryViewModelNotifier(
    genreService: getIt<ApiGenreService>(),
    storyService: getIt<ApiStoryService>(),
  ),
);
