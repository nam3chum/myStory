class ReadingProgress {
  final String storyUrl;
  final String chapterUrl;
  final double scrollOffset;

  ReadingProgress({
    required this.storyUrl,
    required this.chapterUrl,
    required this.scrollOffset,
  });

  factory ReadingProgress.fromJson(Map<String, dynamic> json) {
    return ReadingProgress(
      storyUrl: json['storyUrl'],
      chapterUrl: json['chapterUrl'],
      scrollOffset: json['scrollOffset'],
    );
  }

  factory ReadingProgress.empty() {
    return ReadingProgress(
      storyUrl: '',
      chapterUrl: '',
      scrollOffset: 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'storyUrl': storyUrl,
        'chapterUrl': chapterUrl,
        'scrollOffset': scrollOffset,
      };
}
