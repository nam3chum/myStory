import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/truyen_crawler/src/models/chapter_models.dart';
import '../../chapter_screen/chapter_screen.dart';
import '../story_detail_viewmodel.dart';

class ChapterList extends ConsumerWidget {
  final List<Chapter> chapters;
  final String storyUrl;

  const ChapterList(
      {required this.storyUrl, super.key, required this.chapters});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(storyDetailProvider(storyUrl));
    if (state.isChapterLoading) {
      return const Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Đang tải chương truyện!"),
          CircularProgressIndicator(),
        ],
      ));
    }
    return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(10),
        child: ListView.separated(
          separatorBuilder: (context, index) =>
              const Divider(color: Colors.black26),
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                chapters[index].name,
                style: const TextStyle(color: Colors.black),
              ),
              onTap: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChapterScreen(
                              chapterName: chapters[index].name,
                              chapterUrl: chapters[index].url,
                              chapterList: chapters,
                              storyName: state.storyDetail.name,
                            )));
              },
            );
          },
          itemCount: chapters.length,
        ));
  }
}
