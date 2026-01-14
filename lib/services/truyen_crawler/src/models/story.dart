/// Story model
class Story {
  final String id;
  final String name;
  final String link;
  final String author; // Author
  final String? cover;
  final String host;
  final String? status;
  final String chapter;
  const Story({
    this.id = '',
    required this.name,
    required this.link,
    required this.author,
    this.cover,
    required this.host,
    this.status = '',
    required this.chapter,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      link: json['link'] ?? '',
      author: json['author'] ?? '',
      cover: json['cover'],
      host: json['host'] ?? '',
      status: json['status'] ?? '',
      chapter: json['chapter'] ?? '',
    );
  }
  factory Story.empty(){
    return const Story(
      id: '',
      name: '',
      link: '',
      author: '',
      cover: '',
      host: '',
      status: '',
      chapter: '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id' : id,
    'name': name,
    'link': link,
    'author': author,
    'cover': cover,
    'host': host,
    'chapter': chapter,
    'status': status
  };
  @override
  String toString() => 'Story(name: $name, author: $author)';
}
