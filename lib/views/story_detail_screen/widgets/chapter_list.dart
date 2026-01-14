import 'package:flutter/material.dart';

import '../../../services/truyen_crawler/src/models/chapter_models.dart';
import '../../chapter_screen/chapter_screen.dart';

class ChapterList extends StatelessWidget {
  final List<Chapter> chapters;

  const ChapterList({super.key, required this.chapters});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(10),
        child: ListView.separated(
         // padding: const EdgeInsets.all(0),
          separatorBuilder: (context, index) => const Divider(color: Colors.black26),
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                chapters[index].name,
                style: const TextStyle(color: Colors.black),
              ),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ChapterScreen(chapterName:chapters[index].name,chapterUrl:chapters[index].url ,)));
              },
            );
          },
          itemCount: chapters.length,
        ));
  }
}
