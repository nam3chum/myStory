/// Story model
class Story {
  final String name;
  final String link;
  final String description; // Author
  final String? cover;
  final String host;

  const Story({
    required this.name,
    required this.link,
    required this.description,
    this.cover,
    required this.host,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      name: json['name'] ?? '',
      link: json['link'] ?? '',
      description: json['description'] ?? '',
      cover: json['cover'],
      host: json['host'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'link': link,
    'description': description,
    'cover': cover,
    'host': host,
  };

  @override
  String toString() => 'Story(name: $name, author: $description)';
}
