import 'package:flutter/material.dart';
import 'package:mystory/views/story_detail_screen/story_detail_screen.dart';

import '../../../services/truyen_crawler/src/models/story.dart';

class SearchResultList extends StatelessWidget {
  final bool loading;
  final List<Story> results;

  const SearchResultList({
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
          child: ListTile(
            leading: story.cover != null
                ? Image.network(
                    story.cover!,
                    width: 50,
                    height: 80,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 50,
                    height: 80,
                    color: Colors.grey,
                    child: const Icon(Icons.book),
                  ),
            title: Text(story.name),
            subtitle: Text(story.author),
          ),
        );
      },
    );
  }
}
