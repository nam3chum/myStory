import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mystory/services/truyen_crawler/src/services/services.dart';
import 'package:mystory/views/story_detail_screen/story_detail_viewmodel.dart';

import '../../services/truyen_crawler/src/models/chapter_models.dart';

class ChapterScreenState {
  final bool isLoading;
  final String chapterContent;
  final List<Chapter> chapterList;
  String? errorMessage;
  final bool isShowBar;
  final String? currentChapterUrl; // Track chapter hiện tại
  final bool
      hasInitialScrolled; // Để biết đã scroll tới chapter hiện tại lần đầu chưa

  ChapterScreenState({
    required this.isLoading,
    this.errorMessage,
    required this.chapterContent,
    required this.isShowBar,
    required this.chapterList,
    this.currentChapterUrl,
    this.hasInitialScrolled = false,
  });

  ChapterScreenState copyWith({
    bool? isLoading,
    String? chapterContent,
    String? errorMessage,
    bool? isShowBar,
    List<Chapter>? chapterList,
    String? currentChapterUrl,
    bool? hasInitialScrolled,
  }) {
    return ChapterScreenState(
      isShowBar: isShowBar ?? this.isShowBar,
      isLoading: isLoading ?? this.isLoading,
      chapterList: chapterList ?? this.chapterList,
      chapterContent: chapterContent ?? this.chapterContent,
      errorMessage: errorMessage ?? this.errorMessage,
      currentChapterUrl: currentChapterUrl ?? this.currentChapterUrl,
      hasInitialScrolled: hasInitialScrolled ?? this.hasInitialScrolled,
    );
  }

  factory ChapterScreenState.initial() => ChapterScreenState(
        isShowBar: true,
        isLoading: false,
        chapterList: [],
        chapterContent: '',
        errorMessage: null,
        currentChapterUrl: null,
        hasInitialScrolled: false,
      );
}

class ChapterViewModel extends Notifier<ChapterScreenState> {
  late final TruyenFullService crawler;
  late final StoryDetailViewmodelNotifier chapterScreenState;

  @override
  ChapterScreenState build() {
    crawler = TruyenFullService();
    return ChapterScreenState.initial();
  }

  Future<void> loadChapterContent(String chapterUrl, String chapterName) async {
    state = state.copyWith(isLoading: true, currentChapterUrl: chapterUrl);

    try {
      final result = await crawler.getChapterContent(chapterUrl, chapterName);

      if (result.success && result.data != null) {
        state = state.copyWith(
            chapterContent: result.data?.content,
            isLoading: false,
            errorMessage: null,
            currentChapterUrl: chapterUrl);
      } else {
        state = state.copyWith(isLoading: false, errorMessage: result.error);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> loadChapterList(List<Chapter> chapterList) async {
    state = state.copyWith(chapterList: chapterList);
  }

  void toggleBar() {
    state = state.copyWith(isShowBar: !state.isShowBar);
  }

  void markInitialScrolled() {
    state = state.copyWith(hasInitialScrolled: true);
  }
}

final chapterViewModelProvider =
    NotifierProvider<ChapterViewModel, ChapterScreenState>(
        ChapterViewModel.new);
