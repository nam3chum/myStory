/// Story detail model with full information
class StoryDetail {
  final String name;
  final String? cover;
  final String author;
  final String description; // HTML
  final bool ongoing;
  final List<Genre> genres;
  final List<Genre> suggests; // Same author stories
  final String host;

  const StoryDetail({
    required this.name,
    this.cover,
    required this.author,
    required this.description,
    this.ongoing = false,
    this.genres = const [],
    this.suggests = const [],
    required this.host,
  });

  factory StoryDetail.fromJson(Map<String, dynamic> json) {
    return StoryDetail(
      name: json['name'] ?? '',
      cover: json['cover'],
      author: json['author'] ?? '',
      description: json['description'] ?? '',
      ongoing: json['ongoing'] ?? false,
      genres: (json['genres'] as List?)?.map((e) => Genre.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      suggests:
          (json['suggests'] as List?)?.map((e) => Genre.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      host: json['host'] ?? '',
    );
  }

  factory StoryDetail.empty() {
    return const StoryDetail(
      name: '',
      author: '',
      description: '',
      host: '',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'cover': cover,
        'author': author,
        'description': description,
        'ongoing': ongoing,
        'genres': genres.map((e) => e.toJson()).toList(),
        'suggests': suggests.map((e) => e.toJson()).toList(),
        'host': host,
      };

  @override
  String toString() => 'StoryDetail(name: $name, author: $author, ongoing: $ongoing)';
}

/// Genre/Category model
class Genre {
  final String id;
  final String title;
  final String input; // URL

  const Genre({
    this.id = '',
    required this.title,
    required this.input,
  });

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      input: json['input'] ?? '',
    );
  }

  factory Genre.empty() {
    return const Genre(
      id: '',
      title: '',
      input: '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'input': input,
      };

  @override
  String toString() => 'Genre(title: $title)';
}
