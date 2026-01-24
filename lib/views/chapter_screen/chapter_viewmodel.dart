import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mystory/services/truyen_crawler/src/services/services.dart';

class ChapterScreenState {
  final bool isLoading;
  final String chapterContent;
  String? errorMessage;
  final bool isShowBar;

  ChapterScreenState({
    required this.isLoading,
    this.errorMessage,
    required this.chapterContent,
    required this.isShowBar,
  });

  ChapterScreenState copyWith({
    bool? isLoading,
    String? chapterContent,
    String? errorMessage,
    bool? isShowBar,
  }) {
    return ChapterScreenState(
      isShowBar: isShowBar ?? this.isShowBar,
      isLoading: isLoading ?? this.isLoading,
      chapterContent: chapterContent ?? this.chapterContent,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  factory ChapterScreenState.initial() => ChapterScreenState(
        isShowBar: true,
        isLoading: false,
        chapterContent: '',
        errorMessage: null,
      );
}

class ChapterViewModel extends Notifier<ChapterScreenState> {
  late final TruyenFullService crawler;

  @override
  ChapterScreenState build() {
    crawler = TruyenFullService();
    return ChapterScreenState.initial();
  }

  Future<void> loadChapterContent(String chapterUrl, String chapterName) async {
    state = state.copyWith(isLoading: true);

    try {
      final result = await crawler.getChapterContent(chapterUrl, chapterName);

      if (result.success && result.data != null) {
       state = state.copyWith(chapterContent: result.data?.content, isLoading: false, errorMessage: null);
      } else {
        state = state.copyWith(isLoading: false, errorMessage: result.error);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
  void toggleBar() {
    state = state.copyWith(isShowBar: !state.isShowBar);
  }

  void hideBar() {
    state = state.copyWith(isShowBar: false);
  }
}

final chapterViewModelProvider = NotifierProvider<ChapterViewModel, ChapterScreenState>(ChapterViewModel.new);