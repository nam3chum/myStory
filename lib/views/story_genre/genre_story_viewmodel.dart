import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mystory/services/truyen_crawler/src/models/story.dart';
import 'package:mystory/services/truyen_crawler/src/services/services.dart';

import '../../services/truyen_crawler/src/models/detail_models.dart';

class GenreStoryState {
  final List<Genre> listGenre;
  final List<Story> listStory;
  final bool isLoading;
  final bool hasMore;

  const GenreStoryState({
    this.listGenre = const [],
    this.listStory = const [],
    this.isLoading = false,
    this.hasMore = false,
  });

  GenreStoryState copyWith({
    List<Genre>? listGenre,
    List<Story>? listStory,
    bool? isLoading,
    bool? hasMore,
  }) {
    return GenreStoryState(
      listGenre: listGenre ?? this.listGenre,
      listStory: listStory ?? this.listStory,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  factory GenreStoryState.initial() => const GenreStoryState();
}

class GenreStoryViewModelNotifier extends Notifier<GenreStoryState> {
  late final TruyenFullService crawler;

  @override
  GenreStoryState build() {
    crawler = TruyenFullService();
    return GenreStoryState.initial();
  }

  //
  // Future<void> loadGenres() async {
  //   try {
  //     final genres = await _genreService.getGenres();
  //     state = state.copyWith(listGenre: genres.cast<Genre>());
  //   } catch (e) {
  //     // Keep current state if error occurs
  //   }
  // }

  Future<void> loadStories(String genreUrl) async {
    state = state.copyWith(isLoading: true);
    try {
      final loadedStories = await crawler.getStoriesByGenre(genreUrl);
      final storiesByGenrre = loadedStories.data?.items;
      state = state.copyWith(listStory: storiesByGenrre, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }
}

final genreStoryProvider = NotifierProvider<GenreStoryViewModelNotifier, GenreStoryState>(
  () => GenreStoryViewModelNotifier(),
);
