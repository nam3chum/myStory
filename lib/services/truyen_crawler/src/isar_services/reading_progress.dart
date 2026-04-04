import 'package:isar/isar.dart';

part 'reading_progress.g.dart';

@collection
class ReadingProgress {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late final String storyUrl;

  late final String chapterUrl;
  late final double scrollOffset;
  int updatedAt = DateTime.now().millisecondsSinceEpoch;
}
