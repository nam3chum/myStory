import 'package:dio/dio.dart';

import '../config/config.dart';
import 'exceptions.dart';

/// Dio HTTP client wrapper with retry logic
class DioClientWrapper {
  final Dio _dio;

  DioClientWrapper({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: TruyenFullConfig.BASE_URL,
              connectTimeout: Duration(
                seconds: TruyenFullConfig.TIMEOUT_SECONDS,
              ),
              receiveTimeout: Duration(
                seconds: TruyenFullConfig.TIMEOUT_SECONDS,
              ),
              headers: {'User-Agent': TruyenFullConfig.USER_AGENT},
            ),
          );

  /// Fetch with retry logic
  Future<Response> fetchWithRetry(String url) async {
    int retryCount = 0;

    while (retryCount < TruyenFullConfig.RETRY_ATTEMPTS) {
      try {
        final response = await _dio.get(url);
        return response;
      } catch (e) {
        retryCount++;

        if (retryCount >= TruyenFullConfig.RETRY_ATTEMPTS) {
          if (e is DioException) {
            throw NetworkException('Network error: ${e.message}');
          }
          rethrow;
        }

        // Wait before retrying
        await Future.delayed(TruyenFullConfig.RETRY_DELAY);
      }
    }

    throw Exception('Max retries exceeded');
  }

  Dio get dio => _dio;

  void close() {
    _dio.close();
  }
}

/// URL utility functions
class UrlUtils {
  /// Normalize URL to ensure it uses BASE_URL
  static String normalizeUrl(String url) {
    if (url.isEmpty) return TruyenFullConfig.BASE_URL;

    if (url.startsWith('http')) {
      return url;
    }

    if (url.startsWith('/')) {
      return TruyenFullConfig.BASE_URL + url;
    }

    return TruyenFullConfig.BASE_URL + '/' + url;
  }

  /// Build URL with query parameters
  static String buildUrl(String path, [Map<String, String>? queryParams]) {
    final url = normalizeUrl(path);
    if (queryParams == null || queryParams.isEmpty) {
      return url;
    }

    final query = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    return '$url?$query';
  }
}

/// String extension utilities
extension StringExtensions on String {
  /// Normalize URL
  String normalizeUrl() => UrlUtils.normalizeUrl(this);

  /// Check if URL starts with http
  bool get isAbsoluteUrl => startsWith('http');

  /// Check if URL is relative
  bool get isRelativeUrl => !isAbsoluteUrl;
}
