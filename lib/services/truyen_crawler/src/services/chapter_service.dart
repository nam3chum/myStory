import 'package:dio/dio.dart';
import 'dart:convert';

import '../config/config.dart';
import '../models/models.dart';
import '../parsers/html_parser.dart';
import '../utils/utils.dart';
import 'base_service.dart';

/// Service for chapter operations
class ChapterService extends BaseService {
  ChapterService({Dio? dio}) : super(dio: dio);

  /// Get chapter list for a story
  Future<ApiResponse<List<Chapter>>> getChapterList(String storyUrl) async {
    try {
      final url = UrlUtils.normalizeUrl(storyUrl);
      final response = await dioClient.fetchWithRetry(url);

      if (response.statusCode == 200) {
        final truyenInfo = TruyenInfoParser.parse(response.data);
        final truyenId = truyenInfo['truyenId'] ?? '';
        final truyenAscii = truyenInfo['truyenAscii'] ?? '';
        final totalPage = int.tryParse(truyenInfo['totalPage'] ?? '1') ?? 1;

        if (truyenId.isEmpty || truyenAscii.isEmpty) {
          return ApiResponse.error('Could not extract chapter info');
        }

        final allChapters = <Chapter>[];

        // Fetch all pages of chapters
        for (int page = 1; page <= totalPage; page++) {
          final ajaxUrl = '${TruyenFullConfig.BASE_URL}${TruyenFullConfig.AJAX_ENDPOINT}';

          try {
            final ajaxResponse = await dioClient.dio.get(
              ajaxUrl,
              queryParameters: {
                'type': TruyenFullConfig.AJAX_TYPE,
                'tid': truyenId,
                'tascii': truyenAscii,
                'page': page.toString(),
                'totalp': totalPage.toString(),
              },
            );

            if (ajaxResponse.statusCode == 200) {
              try {
                final jsonData = ajaxResponse.data is String
                    ? jsonDecode(ajaxResponse.data)
                    : ajaxResponse.data;
                final chaptersHtml = jsonData['chap_list'] ?? '';

                if (chaptersHtml.isNotEmpty) {
                  final chapters = ChapterListParser.parseFromJson(chaptersHtml);
                  allChapters.addAll(chapters);
                }
              } catch (e) {
                continue;
              }
            }

            // Add delay to avoid being blocked
            await Future.delayed(TruyenFullConfig.RETRY_DELAY);
          } catch (e) {
            continue;
          }
        }

        if (allChapters.isEmpty) {
          return ApiResponse.error('No chapters found');
        }

        return ApiResponse.success(allChapters);
      } else {
        return ApiResponse.error(
          'Failed to get chapter list',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      return ApiResponse.error('Network error: ${e.message}');
    } catch (e) {
      return ApiResponse.error('Failed to get chapter list: $e');
    }
  }

  /// Get content of a specific chapter
  Future<ApiResponse<ChapterContent>> getContent(
    String chapterUrl,
    String chapterName,
  ) async {
    try {
      final url = UrlUtils.normalizeUrl(chapterUrl);
      final response = await dioClient.fetchWithRetry(url);

      if (response.statusCode == 200) {
        final content = ChapterContentParser.parse(response.data);

        if (content.isEmpty) {
          return ApiResponse.error('Chapter content is empty');
        }

        return ApiResponse.success(
          ChapterContent(
            chapterName: chapterName,
            content: content,
            fetchedAt: DateTime.now(),
          ),
        );
      } else {
        return ApiResponse.error(
          'Failed to get chapter content',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      return ApiResponse.error('Network error: ${e.message}');
    } catch (e) {
      return ApiResponse.error('Failed to get chapter content: $e');
    }
  }
}
