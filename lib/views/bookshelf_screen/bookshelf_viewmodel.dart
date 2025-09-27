import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mystory/data/database/database_controller.dart';

import '../../data/models/story_model.dart';

final bookshelfProvider = NotifierProvider<BookshelfNotifier, Bookshelf>(() {
  return BookshelfNotifier();
});

class Bookshelf {
  final bool isLoading;
  final List<Story> listStory;

  Bookshelf({required this.isLoading, required this.listStory});

  Bookshelf copyWith({bool? isLoading, List<Story>? listStory}) {
    return Bookshelf(isLoading: isLoading ?? this.isLoading, listStory: listStory ?? this.listStory);
  }

  factory Bookshelf.initial() => Bookshelf(isLoading: false, listStory: []);
}

class BookshelfNotifier extends Notifier<Bookshelf> {
  late final DatabaseController dbController;

  @override
  Bookshelf build() {
    dbController = ref.watch(dbProvider);
    return Bookshelf.initial();
  }

  Future<void> loadStories() async {
    state = state.copyWith(isLoading: true);
    try {
      final storiesData = await dbController.getAllStories();
      final stories = storiesData.map((data) => data).toList();
      state = state.copyWith(listStory: stories);
    } on DioException catch (e) {
      print("Error loading stories: $e");
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> deleteStory(String id) async {
    await dbController.deleteStory(id);
    await loadStories();
  }

  Future<void> deleteAllStory() async {
    await dbController.removedAllStories();
    await loadStories();
  }
}
