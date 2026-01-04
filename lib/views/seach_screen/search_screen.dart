import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'search_viewmodel.dart';
import 'widgets/widgets.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(searchViewModelProvider);
    final viewModel = ref.read(searchViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SearchInput(
              onSubmit: viewModel.search,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SearchResultList(
                loading: state.loading,
                results: state.results,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
