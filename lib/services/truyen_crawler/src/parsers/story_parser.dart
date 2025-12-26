import 'package:html/parser.dart' as html_parser;

import '../models/models.dart';
import '../config/config.dart';

/// Selectors for parsing HTML
class HtmlSelectors {
  // Story list selectors
  static const String storyList = ".list-truyen div[itemscope]";
  static const String storyTitle = ".truyen-title > a";
  static const String storyAuthor = ".author";
  static const String storyCover = "[data-image]";

  // Detail page selectors
  static const String detailTitle = "h3.title";
  static const String detailCover = "div.book img";
  static const String detailAuthor = "div.info div a";
  static const String detailDescription = "div.desc-text";
  static const String detailGenres = ".info a[itemprop=genre]";
  static const String detailOngoing = "div.info";

  // Chapter selectors
  static const String chapterList = ".list-chapter li a";
  static const String chapterContent = "div.chapter-c";

  // Info extraction
  static const String truyenId = "input#truyen-id";
  static const String truyenAscii = "input#truyen-ascii";
  static const String totalPage = "input#total-page";

  // Pagination
  static const String pagination = ".pagination > li.active + li";
}

/// Parser for story list
class StoryListParser {
  static List<Story> parse(String htmlContent) {
    final document = html_parser.parse(htmlContent);
    final storyList = <Story>[];

    try {
      final elements = document.querySelectorAll(HtmlSelectors.storyList);

      for (final element in elements) {
        try {
          final titleElement = element.querySelector(HtmlSelectors.storyTitle);
          final authorElement = element.querySelector(HtmlSelectors.storyAuthor);
          final coverElement = element.querySelector(HtmlSelectors.storyCover);

          if (titleElement != null) {
            storyList.add(Story(
              name: titleElement.text.trim(),
              link: titleElement.attributes['href'] ?? '',
              description: authorElement?.text.trim() ?? '',
              cover: coverElement?.attributes['data-image'],
              host: TruyenFullConfig.BASE_URL,
            ));
          }
        } catch (e) {
          continue;
        }
      }
    } catch (e) {
      throw HtmlParseException('Failed to parse story list: $e');
    }

    return storyList;
  }
}

/// Parser for story detail page
class StoryDetailParser {
  static StoryDetail parse(String htmlContent) {
    final document = html_parser.parse(htmlContent);

    try {
      final titleElement = document.querySelector(HtmlSelectors.detailTitle);
      final coverElement = document.querySelector(HtmlSelectors.detailCover);
      final authorElement =
          document.querySelector(HtmlSelectors.detailAuthor);
      final descElement =
          document.querySelector(HtmlSelectors.detailDescription);
      final genreElements =
          document.querySelectorAll(HtmlSelectors.detailGenres);
      final infoHtml =
          document.querySelector(HtmlSelectors.detailOngoing)?.innerHtml ?? '';

      final genres = genreElements
          .map((e) => Genre(
            title: e.text.trim(),
            input: e.attributes['href'] ?? '',
          ))
          .toList();

      final ongoing = infoHtml.contains('>Đang ra<');

      return StoryDetail(
        name: titleElement?.text.trim() ?? 'Unknown',
        cover: coverElement?.attributes['src'],
        author: authorElement?.text.trim() ?? 'Unknown',
        description: descElement?.innerHtml ?? '',
        ongoing: ongoing,
        genres: genres,
        suggests: [
          Genre(
            title: 'Cùng tác giả',
            input: authorElement?.attributes['href'] ?? '',
          ),
        ],
        host: TruyenFullConfig.BASE_URL,
      );
    } catch (e) {
      throw HtmlParseException('Failed to parse story detail: $e');
    }
  }
}

/// Parser for pagination
class PaginationParser {
  static String? parse(String htmlContent) {
    try {
      final document = html_parser.parse(htmlContent);
      final nextElement =
          document.querySelectorAll(HtmlSelectors.pagination).lastOrNull;
      return nextElement?.text.trim();
    } catch (e) {
      return null;
    }
  }
}

/// Exception for HTML parsing errors
class HtmlParseException implements Exception {
  final String message;
  HtmlParseException(this.message);

  @override
  String toString() => 'HtmlParseException: $message';
}
