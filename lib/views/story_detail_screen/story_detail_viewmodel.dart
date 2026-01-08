import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mystory/data/services/config/service_get_it.dart';
import 'package:mystory/services/truyen_crawler/src/models/detail_models.dart';
import 'package:mystory/services/truyen_crawler/src/services/services.dart';

import '../../data/database/database_controller.dart';
import '../../data/services/network/service_genre.dart';
import '../../data/services/network/service_story.dart';
import '../../services/truyen_crawler/src/models/story.dart';

final storyDetailProvider = NotifierProvider.family<StoryDetailViewmodelNotifier, StoryDetailState, String>(
  StoryDetailViewmodelNotifier.new,
);

class StoryDetailState {
  final StoryDetail storyDetail;
  final List<Genre> genreList;
  final bool isLoading;
  final bool isBookmarked;
  final bool hasError;
  final String errorMessage;

  StoryDetailState({
    required this.storyDetail,
    required this.genreList,
    required this.isLoading,
    required this.isBookmarked,
    required this.hasError,
    required this.errorMessage,
  });

  factory StoryDetailState.initial() => StoryDetailState(
        storyDetail: StoryDetail.empty(),
        genreList: [],
        isLoading: false,
        isBookmarked: false,
        hasError: false,
        errorMessage: '',
      );

  StoryDetailState copyWith({
    StoryDetail? storyDetail,
    List<Genre>? genreList,
    bool? isLoading,
    bool? isBookmarked,
    bool? hasError,
    String? errorMessage,
  }) {
    return StoryDetailState(
      storyDetail: storyDetail ?? this.storyDetail,
      genreList: genreList ?? this.genreList,
      isLoading: isLoading ?? this.isLoading,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class StoryDetailViewmodelNotifier extends FamilyNotifier<StoryDetailState, String> {
  late final String storyId;
  final genreService = getIt<ApiGenreService>();
  final storyService = getIt<ApiStoryService>();
  final DatabaseController dbController = getIt<DatabaseController>();
  late final TruyenFullService crawler;

  @override
  StoryDetailState build(String arg) {
    crawler = TruyenFullService();
    storyId = arg;
    fetchStory(storyId);
    checkBookMarked(storyId);
    loadGenres();
    return StoryDetailState.initial();
  }

  Future<void> loadGenres() async {
    try {
      final genres = await crawler.getGenres();
      state = state.copyWith(genreList: genres.data);
    } catch (e) {
      final localGenres = await dbController.getAllGenres();
      state = state.copyWith(genreList: localGenres);
    }
  }

  Future<void> checkBookMarked(String storyId) async {
    final bookMarked = await dbController.getStoryById(storyId);
    state = state.copyWith(isBookmarked: bookMarked != null);
    print("check bookmark = ${state.isBookmarked}");
  }

  Future<void> fetchStory(String storyUrl) async {
    state = state.copyWith(isLoading: true);
    try {
      final result = await crawler.getStoryDetail(storyUrl);
      state = state.copyWith(storyDetail: result.data, isLoading: false);
    } catch (e) {
      debugPrint('Lỗi tải từ API: $e');
    }
  }

  Future<void> toggleBookmark(String storyUrl) async {
    final isCheckBookmark = !state.isBookmarked;
    state = state.copyWith(isBookmarked: isCheckBookmark);

    try {
      if (isCheckBookmark) {
        await dbController.createStory(storyUrl);
        state = state.copyWith(errorMessage: 'Đã thêm vào kệ sách');
      } else {
        await dbController.deleteStory(story.id);
        state = state.copyWith(errorMessage: 'Đã xóa khỏi kệ sách');
      }
    } catch (e) {
      state =
          state.copyWith(isBookmarked: !isCheckBookmark, errorMessage: 'Thao tác thất bại: ${e.toString()}');
    }
  }
}
