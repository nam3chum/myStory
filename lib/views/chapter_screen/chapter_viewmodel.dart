import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mystory/services/truyen_crawler/src/services/services.dart';

class ChapterScreenState {
  final bool isLoading;
  final String chapterContent;
  String? errorMessage;

  ChapterScreenState({
    required this.isLoading,
    this.errorMessage,
    required this.chapterContent,
  });

  ChapterScreenState copyWith({
    bool? isLoading,
    String? chapterContent,
    String? errorMessage,
  }) {
    return ChapterScreenState(
      isLoading: isLoading ?? this.isLoading,
      chapterContent: chapterContent ?? this.chapterContent,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  factory ChapterScreenState.initial() => ChapterScreenState(
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
}

final chapterViewModelProvider = NotifierProvider<ChapterViewModel, ChapterScreenState>(ChapterViewModel.new);