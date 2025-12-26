/// Chapter/content models
class Chapter {
  final String name;
  final String url;
  final String host;

  const Chapter({
    required this.name,
    required this.url,
    required this.host,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      name: json['name'] ?? '',
      url: json['url'] ?? '',
      host: json['host'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'url': url,
    'host': host,
  };

  @override
  String toString() => 'Chapter(name: $name)';
}

/// Chapter content with HTML
class ChapterContent {
  final String chapterName;
  final String content; // HTML
  final DateTime? fetchedAt;

  const ChapterContent({
    required this.chapterName,
    required this.content,
    this.fetchedAt,
  });

  factory ChapterContent.fromJson(Map<String, dynamic> json) {
    return ChapterContent(
      chapterName: json['chapterName'] ?? '',
      content: json['content'] ?? '',
      fetchedAt: json['fetchedAt'] != null
          ? DateTime.parse(json['fetchedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'chapterName': chapterName,
    'content': content,
    'fetchedAt': fetchedAt?.toIso8601String(),
  };

  @override
  String toString() => 'ChapterContent(chapter: $chapterName)';
}

/// Home menu item
class HomeMenuItem {
  final String title;
  final String input; // URL
  final String script;

  const HomeMenuItem({
    required this.title,
    required this.input,
    this.script = "gen.js",
  });

  factory HomeMenuItem.fromJson(Map<String, dynamic> json) {
    return HomeMenuItem(
      title: json['title'] ?? '',
      input: json['input'] ?? '',
      script: json['script'] ?? 'gen.js',
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'input': input,
    'script': script,
  };

  @override
  String toString() => 'HomeMenuItem(title: $title)';
}
