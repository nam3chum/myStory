import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mystory/services/truyen_crawler/truyen_crawler.dart';

/// State
class SearchState {
  final bool loading;
  final String keyword;
  final List<Story> results;

  const SearchState({
    this.loading = false,
    this.keyword = '',
    this.results = const [],
  });

  SearchState copyWith({
    bool? loading,
    String? keyword,
    List<Story>? results,
  }) {
    return SearchState(
      loading: loading ?? this.loading,
      keyword: keyword ?? this.keyword,
      results: results ?? this.results,
    );
  }

  factory SearchState.initial() => const SearchState();
}

/// ViewModel
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
        loading: false,
        results: results.data?.items,
      );
    } catch (e) {
      state = state.copyWith(
        loading: false,
        results: [],
      );
    }
  }


}

/// Provider
final searchViewModelProvider = NotifierProvider<SearchViewModel, SearchState>(SearchViewModel.new);
