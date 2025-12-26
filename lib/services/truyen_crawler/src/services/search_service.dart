import 'package:dio/dio.dart';

import '../config/config.dart';
import '../models/models.dart';
import '../parsers/html_parser.dart';
import '../utils/utils.dart';
import 'base_service.dart';

/// Service for searching stories
class SearchService extends BaseService {
  SearchService({Dio? dio}) : super(dio: dio);

  /// Search stories by keyword with pagination
  Future<ApiResponse<ListResponse<Story>>> search(
    String keyword, {
    int page = 1,
  }) async {
    try {
      final url = UrlUtils.buildUrl(
        TruyenFullConfig.SEARCH_ENDPOINT,
        {
          TruyenFullConfig.SEARCH_PARAM_KEY: keyword,
          TruyenFullConfig.PAGE_PARAM: page.toString(),
        },
      );

      final response = await dioClient.fetchWithRetry(url);

      if (response.statusCode == 200) {
        final storyList = StoryListParser.parse(response.data);
        final nextPage = PaginationParser.parse(response.data);

        return ApiResponse.success(
          ListResponse(
            items: storyList,
            nextPage: nextPage,
            hasMore: nextPage != null && nextPage.isNotEmpty,
          ),
        );
      } else {
        return ApiResponse.error(
          'Failed to search stories',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      return ApiResponse.error('Network error: ${e.message}');
    } catch (e) {
      return ApiResponse.error('Search failed: $e');
    }
  }
}
