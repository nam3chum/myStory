import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'reading_progress.dart';

class IsarService {

  static late Isar isar;

  static Future init() async {

    final dir = await getApplicationDocumentsDirectory();

    isar = await Isar.open(
      [ReadingProgressSchema],
      directory: dir.path,
    );
  }
}