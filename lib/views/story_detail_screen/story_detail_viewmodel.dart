import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mystory/data/services/config/service_get_it.dart';

import '../../data/database/database_controller.dart';
import '../../data/models/genre_model.dart';
import '../../data/models/story_model.dart';
import '../../data/services/network/service_genre.dart';
import '../../data/services/network/service_story.dart';

final storyDetailProvider = NotifierProvider.family<StoryDetailViewmodelNotifier, StoryDetailState, String>(
  StoryDetailViewmodelNotifier.new,
);

class StoryDetailState {
  final Story story;
  final List<Genre> genreList;
  final bool isLoading;
  final bool isBookmarked;
  final bool hasError;

  StoryDetailState({
    required this.story,
    required this.genreList,
    required this.isLoading,
    required this.isBookmarked,
    required this.hasError,
  });

  factory StoryDetailState.initial() => StoryDetailState(
    story: Story.empty(),
    genreList: [],
    isLoading: false,
    isBookmarked: false,
    hasError: false,
  );

  StoryDetailState copyWith({
    Story? story,
    List<Genre>? genreList,
    bool? isLoading,
    bool? isBookmarked,
    bool? hasError,
  }) {
    return StoryDetailState(
      story: story ?? this.story,
      genreList: genreList ?? this.genreList,
      isLoading: isLoading ?? this.isLoading,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      hasError: hasError ?? this.hasError,
    );
  }
}

class StoryDetailViewmodelNotifier extends FamilyNotifier<StoryDetailState, String> {
  late final String storyId;
  final genreService = getIt<ApiGenreService>();
  final storyService = getIt<ApiStoryService>();
  final DatabaseController dbController = getIt<DatabaseController>();

  @override
  StoryDetailState build(String arg) {
    storyId = arg;
    fetchStory(storyId);
    checkBookMarked(storyId);
    loadGenres();
    return StoryDetailState.initial();
  }

  Future<void> loadGenres() async {
    try {
      final genres = await genreService.getGenres();
      state = state.copyWith(genreList: genres.cast<Genre>());
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

  Future<void> fetchStory(String id) async {
    state = state.copyWith(isLoading: true);
    try {
      final result = await storyService.getStoryById(id);
      state = state.copyWith(story: result, isLoading: false);
    } catch (e) {
      debugPrint('Lỗi tải từ API: $e');
      try {
        final localStory = await dbController.getStoryById(id);
        if (localStory != null) {
          state = state.copyWith(story: localStory, isLoading: false);
        } else {
          state = state.copyWith(isLoading: false, hasError: true);
        }
      } catch (e2) {
        debugPrint('Lỗi tải từ DB local: $e2');

        // Cả 2 cùng lỗi
        state = state.copyWith(isLoading: false, hasError: true);
      }
    }
  }

  Future<void> toggleBookmark(Story story, BuildContext context) async {
    final isCheckBookmark = !state.isBookmarked;
    state = state.copyWith(isBookmarked: isCheckBookmark);
    if (isCheckBookmark) {
      await dbController.createStory(story);
    } else {
      await dbController.deleteStory(story.id);
    }

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isCheckBookmark ? 'Đã thêm vào kệ sách' : 'Đã xóa khỏi kệ sách'),
        backgroundColor: isCheckBookmark ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void readStory() {}

  void loadTableOfContents(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(height: 20),
                const Text('Mục lục', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                const Text('Tính năng đang được phát triển...'),
                const SizedBox(height: 40),
              ],
            ),
          ),
    );
  }
}
