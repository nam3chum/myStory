/// Application configuration for TruyenFull crawler
class TruyenFullConfig {
  // Base configuration
  static const String BASE_URL = "https://truyenfull.vision";

  // Endpoints
  static const String SEARCH_ENDPOINT = "/tim-kiem/";
  static const String GENRE_ENDPOINT = "/the-loai/";
  static const String AJAX_ENDPOINT = "/ajax.php";

  // Query parameters
  static const String SEARCH_PARAM_KEY = "tukhoa";
  static const String PAGE_PARAM = "page";
  static const String AJAX_TYPE = "list_chapter";

  // Request settings
  static const int TIMEOUT_SECONDS = 10;
  static const int RETRY_ATTEMPTS = 2;
  static const Duration RETRY_DELAY = Duration(milliseconds: 500);

  // User-Agent
  static const String USER_AGENT =
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36";
}
