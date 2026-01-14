import 'package:flutter/material.dart';
import 'package:mystory/views/commons/story_item.dart';
import 'package:mystory/views/story_detail_screen/story_detail_screen.dart';

import '../../../services/truyen_crawler/src/models/story.dart';

class SearchResultList extends StatelessWidget {
  final bool loading;
  final List<Story> results;
  final List<Color> gradientColors = [
    Colors.deepPurple,
    Colors.purple,
    Colors.pink,
    Colors.indigo,
    Colors.blue,
    Colors.teal,
  ];

  SearchResultList({
    super.key,
    required this.loading,
    required this.results,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (results.isEmpty) {
      return const Center(child: Text('Không có kết quả'));
    }

    return ListView.separated(
      itemCount: results.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (_, i) {
        final story = results[i];
        return GestureDetector(
          onTapDown: (_) {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => StoryDetailScreen(storyUrl: story.link)));
          },
          child: StoryListItem(
              story: story,
              context: context,
              index: i,
              gradientColors: gradientColors),
        );
      },
    );
  }
}
