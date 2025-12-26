import 'package:html/parser.dart' as html_parser;

import '../models/models.dart';
import '../config/config.dart';

/// Selectors for chapter parsing
class ChapterSelectors {
  static const String chapterList = ".list-chapter li a";
  static const String chapterContent = "div.chapter-c";
  static const String truyenId = "input#truyen-id";
  static const String truyenAscii = "input#truyen-ascii";
  static const String totalPage = "input#total-page";
}

/// Parser for chapter list from AJAX response
class ChapterListParser {
  static List<Chapter> parseFromJson(String jsonHtml) {
    final document = html_parser.parse(jsonHtml);
    final chapters = <Chapter>[];

    try {
      final elements = document.querySelectorAll(ChapterSelectors.chapterList);
6
      for (final element in elements) {
        try {
          final link = element.attributes['href'];
          if (link != null && link.isNotEmpty) {
            chapters.add(Chapter(
              name: element.text.trim(),
              url: link,
              host: TruyenFullConfig.BASE_URL,
            ));
          }
        } catch (e) {
          continue;
        }
      }
    } catch (e) {
      throw ChapterParseException('Failed to parse chapter list: $e');
    }

    return chapters;
  }
}

/// Parser for chapter content
class ChapterContentParser {
  static String parse(String htmlContent) {
    final document = html_parser.parse(htmlContent);

    try {
      // Remove unwanted elements
      _removeUnwantedElements(document);

      final contentElement = document.querySelector(ChapterSelectors.chapterContent);
      if (contentElement != null) {
        var content = contentElement.innerHtml;
        // Remove image content warnings
        content = content.replaceAll(
          RegExp(r'<em>.*?Chương này có nội dung ảnh.*?</em>',
              caseSensitive: false),
          '',
        );
        return content.trim();
      }

      return '';
    } catch (e) {
      throw ChapterParseException('Failed to parse chapter content: $e');
    }
  }

  static void _removeUnwantedElements(dynamic document) {
    document.querySelectorAll('noscript').forEach((e) => e.remove());
    document.querySelectorAll('script').forEach((e) => e.remove());
    document.querySelectorAll('iframe').forEach((e) => e.remove());
    document.querySelectorAll('div.ads-responsive').forEach((e) => e.remove());
    document.querySelectorAll('[style*="font-size:0px"]').forEach((e) => e.remove());
    document.querySelectorAll('a').forEach((e) => e.remove());
  }
}

/// Parser for truyen info (ID, ASCII, total pages)
class TruyenInfoParser {
  static Map<String, String> parse(String htmlContent) {
    final document = html_parser.parse(htmlContent);

    try {
      final idElement = document.querySelector(ChapterSelectors.truyenId);
      final asciiElement = document.querySelector(ChapterSelectors.truyenAscii);
      final pageElement = document.querySelector(ChapterSelectors.totalPage);

      return {
        'truyenId': idElement?.attributes['value'] ?? '',
        'truyenAscii': asciiElement?.attributes['value'] ?? '',
        'totalPage': pageElement?.attributes['value'] ?? '1',
      };
    } catch (e) {
      throw ChapterParseException('Failed to parse truyen info: $e');
    }
  }
}

/// Exception for chapter parsing errors
class ChapterParseException implements Exception {
  final String message;
  ChapterParseException(this.message);

  @override
  String toString() => 'ChapterParseException: $message';
}
