import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DataBaseProvider {
  static final DataBaseProvider dataBaseProvider = DataBaseProvider();
  late final Future<Database> db = createDatabase();

  Future<Database> createDatabase() async {
    Directory? dir = await getApplicationDocumentsDirectory();
    String path = join(dir.path, "Stories.db");
    debugPrint("đương dẫn : $path");
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Table lưu các thể loại/genre
        await db.execute('''
        CREATE TABLE genresTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          input TEXT NOT NULL
        )
        ''');

        // Table lưu các truyện đã lưu/đang đọc
        await db.execute('''
        CREATE TABLE storiesTable (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          link TEXT NOT NULL,
          author TEXT,
          cover TEXT,
          host TEXT NOT NULL,
          status TEXT,
          chapter TEXT,
          createdAt TEXT DEFAULT CURRENT_TIMESTAMP,
          updatedAt TEXT DEFAULT CURRENT_TIMESTAMP
        )
        ''');

        // Table lưu quan hệ N-N giữa truyện và thể loại
        await db.execute('''
        CREATE TABLE story_genres_table (
          storyId TEXT,
          genreId TEXT,
          PRIMARY KEY (storyId, genreId),
          FOREIGN KEY (storyId) REFERENCES storiesTable(id) ON DELETE CASCADE,
          FOREIGN KEY (genreId) REFERENCES genresTable(id) ON DELETE CASCADE
        )
        ''');

        // Table lưu vị trí đang đọc (reading progress)
        await db.execute('''
        CREATE TABLE reading_progress (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          chapterUrl TEXT UNIQUE NOT NULL,
          scrollOffset REAL NOT NULL,
          lastReadAt TEXT DEFAULT CURRENT_TIMESTAMP
        )
        ''');
      },
    );
  }
}
