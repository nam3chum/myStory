import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mystory/services/truyen_crawler/truyen_crawler.dart';

class SearchState {
  final bool loading;
  final String keyword;
  final List<Story> results;
  final String errorMessage;

  const SearchState({
    this.loading = false,
    this.keyword = '',
    this.results = const [],
    this.errorMessage = '',
  });

  SearchState copyWith({
    bool? loading,
    String? keyword,
    List<Story>? results,
    String? errorMessage,
  }) {
    return SearchState(
      loading: loading ?? this.loading,
      keyword: keyword ?? this.keyword,
      results: results ?? this.results,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  factory SearchState.initial() => const SearchState();
}

class SearchViewModel extends Notifier<SearchState> {
  late final TruyenFullService _crawler;

  @override
  SearchState build() {
    _crawler = TruyenFullService();
    return SearchState.initial();
  }

  Future<void> search(String keyword) async {
    if (keyword.isEmpty) return;

    state = state.copyWith(
      loading: true,
      keyword: keyword,
    );

    try {
      final results = await _crawler.searchStories(keyword);
      state = state.copyWith(
        results: results.data?.items,
      );
    } catch (e) {
      state = state.copyWith(
        results: [],
        errorMessage: e.toString(),
      );
    } finally {
      state = state.copyWith(
        loading: false,
      );
    }
  }
}

final searchViewModelProvider = NotifierProvider<SearchViewModel, SearchState>(SearchViewModel.new);
