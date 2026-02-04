import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mystory/data/database/database_provider.dart';
import 'package:mystory/services/truyen_crawler/src/models/story.dart';
import 'package:sqflite/sqflite.dart';

import '../../services/truyen_crawler/src/models/detail_models.dart';

final dbProvider = Provider<DatabaseController>((ref) {
  return DatabaseController();
});

class DatabaseController {
  final dbClient = DataBaseProvider.dataBaseProvider;

  Future<void> insertGenres(List<Genre> genres) async {
    final db = await dbClient.db;

    final batch = db.batch();
    for (var genre in genres) {
      batch.insert('genresTable', genre.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<Genre>> getAllGenres() async {
    final db = await dbClient.db;
    var result = await db.query("genresTable", orderBy: "title ASC");
    return result.isNotEmpty ? result.map((e) => Genre.fromJson(e)).toList() : [];
  }

  Future<int> updateGenre(Genre genre) async {
    final db = await dbClient.db;
    return db.update('genresTable', genre.toJson(), where: 'id = ?', whereArgs: [genre.id]);
  }

  Future<int> deleteGenre(String id) async {
    final db = await dbClient.db;
    return db.delete('genresTable', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> createStory(Story story) async {
    final db = await dbClient.db;
    return db.insert("storiesTable", story.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Story>> getAllStories({List<String>? columns}) async {
    final db = await dbClient.db;
    var result = await db.query("storiesTable", columns: columns, orderBy: "updatedAt DESC");
    return result.isNotEmpty ? result.map((e) => Story.fromJson(e)).toList() : [];
  }

  Future<List<Story>> searchStories({List<String>? columns, required String query}) async {
    final db = await dbClient.db;
    var result = await db.query(
      "storiesTable",
      columns: columns,
      where: "(name LIKE ? OR author LIKE ? OR link LIKE ?) AND id IS NOT NULL",
      whereArgs: ["%$query%", '%$query%', '%$query%'],
    );
    return result.isNotEmpty ? result.map((e) => Story.fromJson(e)).toList() : [];
  }

  Future<int> countStory(String status) async {
    final db = await dbClient.db;
    final count = Sqflite.firstIntValue(
      await db.rawQuery("SELECT COUNT(*) FROM storiesTable WHERE status = '$status'"),
    );

    return count ?? 0;
  }

  Future<int> updateStory(Story story) async {
    final db = await dbClient.db;

    return await db.update("storiesTable", story.toJson(), where: "id = ?", whereArgs: [story.id]);
  }

  Future<int> deleteStory(String? id) async {
    final db = await dbClient.db;

    return await db.delete("storiesTable", where: "id = ?", whereArgs: [id]);
  }

  Future<Story?> getStoryById(String id) async {
    final db = await dbClient.db;
    var result = await db.query("storiesTable", limit: 1, where: "id = ?", whereArgs: [id]);
    return result.isNotEmpty ? result.map((e) => Story.fromJson(e)).toList()[0] : null;
  }

  Future<int> removedAllStories() async {
    final db = await dbClient.db;
    return db.delete("storiesTable");
  }

  Future<List<Story>> getAllStoriesSameAuthor(String author) async {
    final db = await dbClient.db;
    var result = await db.query(
      "storiesTable",
      where: "author = ? AND id IS NOT NULL",
      whereArgs: [author],
      orderBy: "updatedAt DESC",
    );

    return result.isNotEmpty ? result.map((e) => Story.fromJson(e)).toList() : [];
  }

  // Lưu vị trí đang đọc của chapter
  Future<int> saveReadingProgress(String chapterUrl, double scrollOffset) async {
    final db = await dbClient.db;
    return db.insert(
      'reading_progress',
      {
        'chapterUrl': chapterUrl,
        'scrollOffset': scrollOffset,
        'lastReadAt': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Lấy vị trí đang đọc của chapter
  Future<double> getReadingProgress(String chapterUrl) async {
    final db = await dbClient.db;
    final result = await db.query(
      'reading_progress',
      where: 'chapterUrl = ?',
      whereArgs: [chapterUrl],
    );

    if (result.isNotEmpty) {
      return result.first['scrollOffset'] as double;
    }
    return 0.0;
  }

  //xoá vị trí đang đọc của chapter
  Future<int> deleteReadingProgress(String chapterUrl) async {
    final db = await dbClient.db;
    return db.delete(
      'reading_progress',
      where: 'chapterUrl = ?',
      whereArgs: [chapterUrl],
    );
  }

  //xoá toàn bộ ví trí đang đọc (xoá bảng)
  Future<int> clearAllReadingProgress() async {
    final db = await dbClient.db;
    return db.delete('reading_progress');
  }
}
