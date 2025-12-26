import 'package:dio/dio.dart';

import '../utils/utils.dart';

/// Base service with common HTTP operations
abstract class BaseService {
  final DioClientWrapper dioClient;

  BaseService({Dio? dio})
      : dioClient = DioClientWrapper(dio: dio);

  /// Fetch URL with retry
  Future<Response> fetch(String url) async {
    final normalizedUrl = UrlUtils.normalizeUrl(url);
    return dioClient.fetchWithRetry(normalizedUrl);
  }

  void dispose() {
    dioClient.close();
  }
}
