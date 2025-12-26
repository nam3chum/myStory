import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mystory/services/truyen_crawler/truyen_crawler.dart';

/// Provider cho TruyenFullService (crawler)
final truyenFullServiceProvider = Provider<TruyenFullService>((ref) {
  return TruyenFullService();
});
