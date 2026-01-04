import 'package:dio/dio.dart';

import '../config/config.dart';
import '../models/models.dart';
import '../parsers/html_parser.dart';
import '../utils/utils.dart';
import 'base_service.dart';

/// Service for story details and metadata
class DetailService extends BaseService {
  DetailService({super.dio});

  /// Get home menu items
  Future<ApiResponse<List<HomeMenuItem>>> getHomeMenu() async {
    try {
      final menuItems = [
        const HomeMenuItem(
          title: "Truyện mới cập nhật",
          input: "${TruyenFullConfig.BASE_URL}/danh-sach/truyen-moi/",
        ),
        const HomeMenuItem(
          title: "Truyện Hot",
          input: "${TruyenFullConfig.BASE_URL}/danh-sach/truyen-hot/",
        ),
        const HomeMenuItem(
          title: "Truyện Full",
          input: "${TruyenFullConfig.BASE_URL}/danh-sach/truyen-full/",
        ),
        const HomeMenuItem(
          title: "Tiên Hiệp Hay",
          input: "${TruyenFullConfig.BASE_URL}/danh-sach/tien-hiep-hay/",
        ),
        const HomeMenuItem(
          title: "Kiếm Hiệp Hay",
          input: "${TruyenFullConfig.BASE_URL}/danh-sach/kiem-hiep-hay/",
        ),
        const HomeMenuItem(
          title: "Truyện Teen Hay",
          input: "${TruyenFullConfig.BASE_URL}/danh-sach/truyen-teen-hay/",
        ),
        const HomeMenuItem(
          title: "Ngôn Tình Hay",
          input: "${TruyenFullConfig.BASE_URL}/danh-sach/ngon-tinh-hay/",
        ),
      ];

      return ApiResponse.success(menuItems);
    } catch (e) {
      return ApiResponse.error('Failed to get home menu: $e');
    }
  }

  /// Get all genres
  Future<ApiResponse<List<Genre>>> getGenres() async {
    try {
      final genres = [
        const Genre(title: "Tiên Hiệp", input: "${TruyenFullConfig.BASE_URL}/the-loai/tien-hiep/"),
        const Genre(title: "Kiếm Hiệp", input: "${TruyenFullConfig.BASE_URL}/the-loai/kiem-hiep/"),
        const Genre(title: "Ngôn Tình", input: "${TruyenFullConfig.BASE_URL}/the-loai/ngon-tinh/"),
        const Genre(title: "Đô Thị", input: "${TruyenFullConfig.BASE_URL}/the-loai/do-thi/"),
        const Genre(title: "Quan Trường", input: "${TruyenFullConfig.BASE_URL}/the-loai/quan-truong/"),
        const Genre(title: "Võng Du", input: "${TruyenFullConfig.BASE_URL}/the-loai/vong-du/"),
        const Genre(title: "Khoa Huyễn", input: "${TruyenFullConfig.BASE_URL}/the-loai/khoa-huyen/"),
        const Genre(title: "Hệ Thống", input: "${TruyenFullConfig.BASE_URL}/the-loai/he-thong/"),
        const Genre(title: "Huyền Huyễn", input: "${TruyenFullConfig.BASE_URL}/the-loai/huyen-huyen/"),
        const Genre(title: "Dị Giới", input: "${TruyenFullConfig.BASE_URL}/the-loai/di-gioi/"),
      ];

      return ApiResponse.success(genres);
    } catch (e) {
      return ApiResponse.error('Failed to get genres: $e');
    }
  }

  /// Get stories by genre with pagination
  Future<ApiResponse<ListResponse<Story>>> getStoriesByGenre(
    String genreUrl, {
    int page = 1,
  }) async {
    try {
      final url = '$genreUrl/trang-$page';

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
          'Failed to get stories by genre',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      return ApiResponse.error('Network error: ${e.message}');
    } catch (e) {
      return ApiResponse.error('Failed to get stories by genre: $e');
    }
  }

  /// Get detailed information about a story
  Future<ApiResponse<StoryDetail>> getDetail(String storyUrl) async {
    try {
      final url = UrlUtils.normalizeUrl(storyUrl);
      final response = await dioClient.fetchWithRetry(url);

      if (response.statusCode == 200) {
        final detail = StoryDetailParser.parse(response.data);
        return ApiResponse.success(detail);
      } else {
        return ApiResponse.error(
          'Failed to get story detail',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      return ApiResponse.error('Network error: ${e.message}');
    } catch (e) {
      return ApiResponse.error('Failed to get story detail: $e');
    }
  }
}
