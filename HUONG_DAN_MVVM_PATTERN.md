# 🏗️ Hướng dẫn sử dụng Truyen Crawler với kiến trúc MVVM

Tài liệu này hướng dẫn cách tích hợp `TruyenFullService` vào một ứng dụng Flutter theo kiến trúc MVVM (Model-View-ViewModel) một cách chi tiết và chính xác.

## 📋 Mục lục
1. [Tổng quan về MVVM](#tổng-quan-về-mvvm)
2. [Cấu trúc thư mục đề xuất](#cấu-trúc-thư-mục-đề-xuất)
3. [Các thành phần chi tiết](#các-thành-phần-chi-tiết)
    - [Model](#1-model-sử-dụng-trực-tiếp-từ-service)
    - [ViewModel](#2-viewmodel-bộ-não-xử-lý)
    - [View](#3-view-lớp-giao-diện)
4. [Luồng hoạt động hoàn chỉnh](#luồng-hoạt-động-hoàn-chỉnh)

---

## Tổng quan về MVVM

**MVVM** = **Model - View - ViewModel**.

```
┌─────────────────────────────────────────┐
│              UI LAYER (View)            │
│   - Chỉ hiển thị UI và nhận input.     │
│   - Lắng nghe thay đổi từ ViewModel.    │
└─────────────────────┬───────────────────┘
                      │ (Data Binding / ChangeNotifier)
                      ▼
┌─────────────────────────────────────────┐
│        BUSINESS LAYER (ViewModel)       │
│  - Giữ trạng thái (state) của View.     │
│  - Xử lý logic nghiệp vụ.               │
└─────────────────────┬───────────────────┘
                      │ (Gọi hàm)
                      ▼
┌─────────────────────────────────────────┐
│         DATA LAYER (Model + Service)    │
│   - `TruyenFullService` gọi API.        │
│   - `Model` định nghĩa cấu trúc dữ liệu. │
└─────────────────────────────────────────┘
```

---

## Cấu trúc thư mục đề xuất

```
lib/
├── main.dart
│
├── services/
│   └── truyen_crawler/     ← Service đã có sẵn
│       ├── src/
│       │   ├── models/     ← Các Model đã có sẵn (Story, Chapter, v.v.)
│       │   └── services/   ← TruyenFullService đã có sẵn
│       └── truyen_crawler.dart
│
├── view_models/            ← Các ViewModel (cần tạo)
│   ├── search_view_model.dart
│   ├── story_detail_view_model.dart
│   └── chapter_reader_view_model.dart
│
└── views/                  ← Các View (UI) (cần tạo)
    ├── search/
    │   ├── search_screen.dart
    │   └── widgets/
    │       └── story_list_tile.dart
    ├── detail/
    │   └── story_detail_screen.dart
    └── reader/
        └── chapter_reader_screen.dart
```

---

## Các thành phần chi tiết

### 1. Model (Sử dụng trực tiếp từ Service)

**Không cần tạo file Model mới!** `truyen_crawler` đã cung cấp sẵn các lớp dữ liệu bạn cần. Hãy sử dụng chúng trực tiếp để đảm bảo tính nhất quán.

- **Các file model:** `lib/services/truyen_crawler/src/models/`
- **Các lớp chính:** `Story`, `StoryDetail`, `Chapter`, `ChapterContent`, `Genre`.

Chỉ cần import `truyen_crawler.dart` để sử dụng:
```dart
import '''package:my_story/services/truyen_crawler/truyen_crawler.dart''';
```

---

### 2. ViewModel (Bộ não xử lý)

ViewModel sẽ gọi `TruyenFullService`, quản lý trạng thái (loading, error, success) và cung cấp dữ liệu cho View. Chúng ta sẽ dùng `ChangeNotifier` để thông báo cho View khi có thay đổi.

#### `search_view_model.dart`
```dart
import '''package:flutter/material.dart''';
import '''package:my_story/services/truyen_crawler/truyen_crawler.dart''';

enum ViewState { idle, loading, success, error }

class SearchViewModel extends ChangeNotifier {
  // ===== DEPENDENCIES =====
  final TruyenFullService _truyenService = TruyenFullService();

  // ===== STATE =====
  ViewState _state = ViewState.idle;
  ViewState get state => _state;

  List<Story> _stories = [];
  List<Story> get stories => _stories;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _currentKeyword = '';
  int _currentPage = 1;
  bool _hasMore = true;

  // ===== METHODS =====

  /// Tìm kiếm truyện theo từ khóa.
  /// Gọi lần đầu hoặc khi người dùng refresh.
  Future<void> search(String keyword) async {
    if (keyword.trim().isEmpty) return;

    _currentKeyword = keyword;
    _currentPage = 1;
    _stories = [];
    _state = ViewState.loading;
    notifyListeners();

    final response = await _truyenService.searchStories(keyword, page: _currentPage);

    if (response.success && response.data != null) {
      _stories = response.data!.items;
      _hasMore = response.data!.hasMore;
      _state = ViewState.success;
    } else {
      _errorMessage = response.message ?? 'Lỗi không xác định';
      _state = ViewState.error;
    }
    notifyListeners();
  }

  /// Tải thêm kết quả cho phân trang.
  Future<void> loadMore() async {
    if (_state == ViewState.loading || !_hasMore) return;

    _currentPage++;
    final response = await _truyenService.searchStories(_currentKeyword, page: _currentPage);

    if (response.success && response.data != null) {
      _stories.addAll(response.data!.items);
      _hasMore = response.data!.hasMore;
    }
    // Không thay đổi state để tránh UI nhảy về loading
    notifyListeners();
  }
}
```

#### `story_detail_view_model.dart`
```dart
import '''package:flutter/material.dart''';
import '''package:my_story/services/truyen_crawler/truyen_crawler.dart''';

enum DetailViewState { loading, success, error }

class StoryDetailViewModel extends ChangeNotifier {
  final TruyenFullService _truyenService = TruyenFullService();

  DetailViewState _state = DetailViewState.loading;
  DetailViewState get state => _state;

  StoryDetail? _storyDetail;
  StoryDetail? get storyDetail => _storyDetail;

  List<Chapter> _chapters = [];
  List<Chapter> get chapters => _chapters;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Tải chi tiết truyện và danh sách chương.
  Future<void> loadStoryDetail(String storyUrl) async {
    _state = DetailViewState.loading;
    notifyListeners();

    try {
      // Chạy song song 2 request để tăng tốc
      final responses = await Future.wait([
        _truyenService.getStoryDetail(storyUrl),
        _truyenService.getChapterList(storyUrl),
      ]);

      final detailResponse = responses[0] as ApiResponse<StoryDetail>;
      final chapterResponse = responses[1] as ApiResponse<List<Chapter>>;

      // Xử lý detail
      if (detailResponse.success && detailResponse.data != null) {
        _storyDetail = detailResponse.data;
      } else {
        throw Exception(detailResponse.message ?? 'Không thể tải chi tiết truyện');
      }

      // Xử lý chapters
      if (chapterResponse.success && chapterResponse.data != null) {
        _chapters = chapterResponse.data!;
      }
      // (Nếu lỗi tải chapter có thể không cần báo lỗi cả màn hình)

      _state = DetailViewState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _state = DetailViewState.error;
    }
    notifyListeners();
  }
}
```

#### `chapter_reader_view_model.dart`
```dart
import '''package:flutter/material.dart''';
import '''package:my_story/services/truyen_crawler/truyen_crawler.dart''';

enum ReaderViewState { loading, success, error }

class ChapterReaderViewModel extends ChangeNotifier {
  final TruyenFullService _truyenService = TruyenFullService();

  ReaderViewState _state = ReaderViewState.loading;
  ReaderViewState get state => _state;

  ChapterContent? _chapterContent;
  ChapterContent? get chapterContent => _chapterContent;
  
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadContent(String chapterUrl, String chapterName) async {
    _state = ReaderViewState.loading;
    notifyListeners();

    final response = await _truyenService.getChapterContent(chapterUrl, chapterName);

    if (response.success && response.data != null) {
      _chapterContent = response.data;
      _state = ReaderViewState.success;
    } else {
      _errorMessage = response.message ?? 'Không thể tải nội dung chương';
      _state = ReaderViewState.error;
    }
    notifyListeners();
  }
}
```

---

### 3. View (Lớp giao diện)

View chỉ có nhiệm vụ hiển thị dữ liệu từ ViewModel và gọi các hàm của ViewModel khi người dùng tương tác. Sử dụng `Consumer` hoặc `context.watch` để lắng nghe thay đổi.

#### `search_screen.dart`
```dart
import '''package:flutter/material.dart''';
import '''package:my_story/view_models/search_view_model.dart''';
import '''package:provider/provider.dart''';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dùng ChangeNotifierProvider để cung cấp ViewModel cho cây widget
    return ChangeNotifierProvider(
      create: (_) => SearchViewModel(),
      child: const _SearchScreenContent(),
    );
  }
}

class _SearchScreenContent extends StatelessWidget {
  const _SearchScreenContent();

  @override
  Widget build(BuildContext context) {
    // context.watch sẽ khiến widget này build lại khi viewModel.notifyListeners() được gọi
    final viewModel = context.watch<SearchViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Tìm kiếm')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Nhập tên truyện...',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (keyword) {
                // Chỉ gọi hàm, không xử lý logic ở View
                context.read<SearchViewModel>().search(keyword);
              },
            ),
          ),
          Expanded(child: _buildBody(context, viewModel)),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, SearchViewModel viewModel) {
    switch (viewModel.state) {
      case ViewState.loading:
        return const Center(child: CircularProgressIndicator());
      case ViewState.error:
        return Center(child: Text(viewModel.errorMessage!));
      case ViewState.success:
        if (viewModel.stories.isEmpty) {
          return const Center(child: Text('Không tìm thấy kết quả nào.'));
        }
        return ListView.builder(
          itemCount: viewModel.stories.length,
          itemBuilder: (context, index) {
            final story = viewModel.stories[index];
            return ListTile(
              leading: story.cover != null
                  ? Image.network(story.cover!, width: 50, fit: BoxFit.cover)
                  : const Icon(Icons.book_online),
              title: Text(story.name),
              subtitle: Text(story.description, maxLines: 2),
              onTap: () {
                // TODO: Điều hướng sang màn hình chi tiết
                // Navigator.push(context, MaterialPageRoute(builder: (_) => StoryDetailScreen(storyUrl: story.link)));
              },
            );
          },
        );
      case ViewState.idle:
      default:
        return const Center(child: Text('Nhập từ khóa để tìm truyện.'));
    }
  }
}
```

---

## Luồng hoạt động hoàn chỉnh (Ví dụ Tìm kiếm)

1.  **Người dùng** mở `SearchScreen`.
2.  `ChangeNotifierProvider` tạo một instance của `SearchViewModel`. `SearchScreen` hiển thị trạng thái `idle`.
3.  **Người dùng** nhập "thôn phệ" và nhấn Enter.
4.  `TextField`'s `onSubmitted` được kích hoạt. Nó gọi `context.read<SearchViewModel>().search('thôn phệ')`.
5.  **ViewModel** nhận lệnh, đổi `state` thành `loading` và gọi `notifyListeners()`.
6.  **View** (`_SearchScreenContent`) build lại vì `context.watch` nhận được thay đổi. Nó thấy `state` là `loading` và hiển thị `CircularProgressIndicator`.
7.  **ViewModel** thực thi `_truyenService.searchStories(...)`.
8.  Sau khi `_truyenService` trả về kết quả, **ViewModel** cập nhật `_stories` và `_state` thành `success` (hoặc `error`). Nó gọi `notifyListeners()` một lần nữa.
9.  **View** lại build lại. Lần này nó thấy `state` là `success` và hiển thị `ListView` với danh sách truyện đã lấy được.
