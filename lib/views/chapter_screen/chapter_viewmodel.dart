import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mystory/data/database/database_controller.dart';
import 'package:mystory/services/truyen_crawler/src/services/services.dart';

import '../../services/truyen_crawler/src/models/chapter_models.dart';

class ChapterScreenState {
  final bool isLoading;
  final String chapterContent;
  final List<Chapter> chapterList;
  String? errorMessage;
  final bool isShowBar;
  final String? currentChapterUrl; // Track chapter hiện tại
  final bool hasInitialScrolled; // Để biết đã scroll tới chapter hiện tại lần đầu chưa
  final double scrollPosition; // Vị trí cuộn hiện tại

  ChapterScreenState({
    required this.isLoading,
    this.errorMessage,
    required this.chapterContent,
    required this.isShowBar,
    required this.chapterList,
    this.currentChapterUrl,
    this.hasInitialScrolled = false,
    this.scrollPosition = 0.0,
  });

  ChapterScreenState copyWith({
    bool? isLoading,
    String? chapterContent,
    String? errorMessage,
    bool? isShowBar,
    List<Chapter>? chapterList,
    String? currentChapterUrl,
    bool? hasInitialScrolled,
    double? scrollPosition,
  }) {
    return ChapterScreenState(
      isShowBar: isShowBar ?? this.isShowBar,
      isLoading: isLoading ?? this.isLoading,
      chapterList: chapterList ?? this.chapterList,
      chapterContent: chapterContent ?? this.chapterContent,
      errorMessage: errorMessage ?? this.errorMessage,
      currentChapterUrl: currentChapterUrl ?? this.currentChapterUrl,
      hasInitialScrolled: hasInitialScrolled ?? this.hasInitialScrolled,
      scrollPosition: scrollPosition ?? this.scrollPosition,
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
        scrollPosition: 0.0,
      );
}

class ChapterViewModel extends Notifier<ChapterScreenState> {
  late final TruyenFullService crawler;
  late final DatabaseController dbController;

  @override
  ChapterScreenState build() {
    crawler = TruyenFullService();
    dbController = DatabaseController();
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

  Future<void> nextChapter() async {
    if (state.chapterList.isNotEmpty) {
      final currentIndex = state.chapterList.indexWhere((ch) => ch.url == state.currentChapterUrl);
      if (currentIndex != -1 && currentIndex < state.chapterList.length - 1) {
        final nextChapter = state.chapterList[currentIndex + 1];
        await loadChapterContent(nextChapter.url, nextChapter.name);
      }
    }
  }

  Future<void> previousChapter() async {
    if (state.chapterList.isNotEmpty) {
      final currentIndex = state.chapterList.indexWhere((ch) => ch.url == state.currentChapterUrl);
      if (currentIndex != -1 && currentIndex > 0) {
        final previousChapter = state.chapterList[currentIndex - 1];
        await loadChapterContent(previousChapter.url, previousChapter.name);
      }
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

  // Cập nhật vị trí cuộn nội dung chương
  void updateScrollPosition(double offset) {
    state = state.copyWith(scrollPosition: offset);
  }

  // Lưu scroll position vào SQLite Database
  Future<void> saveScrollPosition(String chapterUrl) async {
    await dbController.saveReadingProgress(chapterUrl, state.scrollPosition);
  }

  // Lấy scroll position từ SQLite Database
  Future<double> loadScrollPosition(String chapterUrl) async {
    return await dbController.getReadingProgress(chapterUrl);
  }
}

final chapterViewModelProvider = NotifierProvider<ChapterViewModel, ChapterScreenState>(ChapterViewModel.new);
