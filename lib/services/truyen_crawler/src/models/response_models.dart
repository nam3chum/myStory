/// Response wrapper for list results with pagination
class ListResponse<T> {
  final List<T> items;
  final String? nextPage;
  final bool hasMore;

  const ListResponse({
    required this.items,
    this.nextPage,
    this.hasMore = false,
  });

  @override
  String toString() => 'ListResponse(items: ${items.length}, hasMore: $hasMore)';
}

/// API Response wrapper
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final int? statusCode;

  const ApiResponse({
    required this.success,
    this.data,
    this.error,
    this.statusCode,
  });

  factory ApiResponse.success(T data) {
    return ApiResponse(
      success: true,
      data: data,
    );
  }

  factory ApiResponse.error(String error, {int? statusCode}) {
    return ApiResponse(
      success: false,
      error: error,
      statusCode: statusCode,
    );
  }

  @override
  String toString() => 'ApiResponse(success: $success, error: $error)';
}
