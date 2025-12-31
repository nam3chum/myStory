/// Story model
class Story {
  final String name;
  final String link;
  final String author; // Author
  final String? cover;
  final String host;

  const Story({
    required this.name,
    required this.link,
    required this.author,
    this.cover,
    required this.host,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      name: json['name'] ?? '',
      link: json['link'] ?? '',
      author: json['author'] ?? '',
      cover: json['cover'],
      host: json['host'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'link': link,
    'author': author,
    'cover': cover,
    'host': host,
  };

  @override
  String toString() => 'Story(name: $name, author: $author)';
}
