import 'package:dio/dio.dart';

import '../models/models.dart';
import 'base_service.dart';
import 'search_service.dart';
import 'detail_service.dart';
import 'chapter_service.dart';

/// Main service combining all sub-services
class TruyenFullService extends BaseService {
  late SearchService _searchService;
  late DetailService _detailService;
  late ChapterService _chapterService;

  TruyenFullService({Dio? dio}) : super(dio: dio) {
    _searchService = SearchService(dio: dioClient.dio);
    _detailService = DetailService(dio: dioClient.dio);
    _chapterService = ChapterService(dio: dioClient.dio);
  }

  // --- Search Operations ---
  Future<ApiResponse<ListResponse<Story>>> searchStories(
    String keyword, {
    int page = 1,
  }) =>
      _searchService.search(keyword, page: page);

  // --- Detail Operations ---
  Future<ApiResponse<List<HomeMenuItem>>> getHomeMenu() =>
      _detailService.getHomeMenu();

  Future<ApiResponse<List<Genre>>> getGenres() => _detailService.getGenres();

  Future<ApiResponse<ListResponse<Story>>> getStoriesByGenre(
    String genreUrl, {
    int page = 1,
  }) =>
      _detailService.getStoriesByGenre(genreUrl, page: page);

  Future<ApiResponse<StoryDetail>> getStoryDetail(String storyUrl) =>
      _detailService.getDetail(storyUrl);

  // --- Chapter Operations ---
  Future<ApiResponse<List<Chapter>>> getChapterList(String storyUrl) =>
      _chapterService.getChapterList(storyUrl);

  Future<ApiResponse<ChapterContent>> getChapterContent(
    String chapterUrl,
    String chapterName,
  ) =>
      _chapterService.getContent(chapterUrl, chapterName);
}
