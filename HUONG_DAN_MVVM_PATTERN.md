# 🏗️ Hướng dẫn MVVM + Truyen Crawler Services

## 📋 Mục lục
1. [MVVM là gì?](#mvvm-là-gì)
2. [Cấu trúc thư mục](#cấu-trúc-thư-mục)
3. [Các thành phần MVVM](#các-thành-phần-mvvm)
4. [Ví dụ chi tiết từng layer](#ví-dụ-chi-tiết-từng-layer)
5. [Workflow hoàn chỉnh](#workflow-hoàn-chỉnh)
6. [Luồng dữ liệu](#luồng-dữ-liệu)

---

## MVVM là gì?

**MVVM** = **Model - View - ViewModel** là một kiến trúc phổ biến trong Flutter.

```
┌─────────────────────────────────────────┐
│              UI LAYER (View)            │
│   - Widgets, UI elements, animations   │
└─────────────────────┬───────────────────┘
                      │
                      ▼ (Communicate via notifyListeners)
┌─────────────────────────────────────────┐
│          BUSINESS LAYER (ViewModel)     │
│  - State management, logic, processing │
└─────────────────────┬───────────────────┘
                      │
                      ▼ (Call services)
┌─────────────────────────────────────────┐
│           DATA LAYER (Model + Service)  │
│   - API calls, database, business logic│
└─────────────────────────────────────────┘
```

### Quy trách vụ của mỗi layer:

| Layer | Trách vụ | Ví dụ |
|-------|----------|-------|
| **View** | Hiển thị UI, nhận user input | Button, TextField, ListView |
| **ViewModel** | Xử lý logic, quản lý state | Search novels, filter |
| **Model** | Định nghĩa dữ liệu | Novel class, Chapter class |
| **Service** | Gọi API, fetch dữ liệu | TruyenFullService |

---

## Cấu trúc thư mục

```
lib/
├── main.dart
├── models/                          ← Data models
│   ├── novel_model.dart
│   ├── chapter_model.dart
│   └── response_model.dart
│
├── services/                        ← Services (gọi API)
│   └── truyen_crawler/
│       └── ... (đã có)
│
├── view_models/                     ← ViewModels (MVVM)
│   ├── novel_list_view_model.dart
│   ├── novel_detail_view_model.dart
│   ├── chapter_list_view_model.dart
│   └── search_view_model.dart
│
├── views/                           ← UI Pages/Widgets
│   ├── home_screen.dart
│   ├── search_screen.dart
│   ├── novel_detail_screen.dart
│   └── chapter_reader_screen.dart
│
└── utils/                           ← Utilities
    ├── constants.dart
    └── extensions.dart
```

---

## Các thành phần MVVM

### 1. Model (Mô hình dữ liệu)

#### novel_model.dart
```dart
class Novel {
  final String id;
  final String title;
  final String author;
  final String imageUrl;
  final String description;
  final String url;
  final double rating;
  
  const Novel({
    required this.id,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.description,
    required this.url,
    required this.rating,
  });
  
  // Chuyển đổi từ dữ liệu API thành object
  factory Novel.fromApi(dynamic data) {
    return Novel(
      id: data['id'] ?? '',
      title: data['title'] ?? 'Unknown',
      author: data['author'] ?? 'Unknown',
      imageUrl: data['imageUrl'] ?? '',
      description: data['description'] ?? '',
      url: data['url'] ?? '',
      rating: double.tryParse(data['rating'].toString()) ?? 0.0,
    );
  }
}

class Chapter {
  final String id;
  final String title;
  final String url;
  final DateTime? publishDate;
  
  const Chapter({
    required this.id,
    required this.title,
    required this.url,
    this.publishDate,
  });
}
```

---

### 2. ViewModel (Xử lý logic)

#### search_view_model.dart
```dart
import 'package:flutter/material.dart';
import 'package:mystory/services/truyen_crawler/src/services/services.dart';
import 'package:mystory/models/novel_model.dart';

/// ViewModel cho Search Screen
/// Quản lý logic tìm kiếm truyện
class SearchViewModel extends ChangeNotifier {
  // ===== SERVICES =====
  final TruyenFullService _service = TruyenFullService();
  
  // ===== STATE VARIABLES =====
  List<Novel> searchResults = [];
  bool isLoading = false;
  String? errorMessage;
  String currentKeyword = '';
  int currentPage = 1;
  bool hasMoreResults = true;
  
  // ===== METHODS =====
  
  /// Tìm kiếm truyện theo từ khóa
  /// 
  /// Ví dụ:
  /// ```
  /// await viewModel.searchNovels('Kiếm Hiệp');
  /// ```
  Future<void> searchNovels(String keyword, {int page = 1}) async {
    // 1. Kiểm tra input
    if (keyword.trim().isEmpty) {
      errorMessage = 'Vui lòng nhập từ khóa tìm kiếm';
      notifyListeners();
      return;
    }
    
    // 2. Reset state khi tìm kiếm mới
    if (page == 1) {
      searchResults.clear();
      currentPage = 1;
    }
    
    // 3. Bắt đầu loading
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    
    try {
      // 4. Gọi service để tìm kiếm
      final response = await _service.searchNovels(
        keyword,
        page: page,
      );
      
      // 5. Xử lý kết quả
      if (response.success && response.data != null) {
        // Cập nhật danh sách
        final novels = response.data!.items ?? [];
        
        if (page == 1) {
          searchResults = novels;
        } else {
          searchResults.addAll(novels);
        }
        
        // Cập nhật pagination
        currentKeyword = keyword;
        currentPage = page;
        hasMoreResults = response.data!.hasMore ?? false;
        errorMessage = null;
      } else {
        // Xử lý lỗi
        errorMessage = response.message ?? 'Tìm kiếm thất bại';
      }
    } catch (e) {
      errorMessage = 'Lỗi: ${e.toString()}';
    } finally {
      // 6. Kết thúc loading
      isLoading = false;
      notifyListeners();
    }
  }
  
  /// Tải thêm kết quả (phân trang)
  Future<void> loadMore() async {
    if (!hasMoreResults || isLoading) return;
    
    await searchNovels(currentKeyword, page: currentPage + 1);
  }
  
  /// Xóa kết quả tìm kiếm
  void clearSearch() {
    searchResults.clear();
    currentKeyword = '';
    currentPage = 1;
    errorMessage = null;
    notifyListeners();
  }
  
  /// Cleanup
  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}
```

---

#### novel_detail_view_model.dart
```dart
import 'package:flutter/material.dart';
import 'package:mystory/services/truyen_crawler/src/services/services.dart';
import 'package:mystory/models/novel_model.dart';

/// ViewModel cho Novel Detail Screen
class NovelDetailViewModel extends ChangeNotifier {
  final TruyenFullService _service = TruyenFullService();
  
  // ===== STATE =====
  bool isLoading = false;
  String? errorMessage;
  Map<String, dynamic>? novelDetail;
  List<Chapter> chapters = [];
  
  // ===== GETTERS =====
  bool get hasDetail => novelDetail != null;
  bool get hasChapters => chapters.isNotEmpty;
  
  // ===== METHODS =====
  
  /// Lấy chi tiết truyện
  /// 
  /// Gọi khi người dùng vào xem chi tiết truyện
  Future<void> loadNovelDetail(String novelUrl) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    
    try {
      // Lấy chi tiết
      final detailResponse = await _service.getNovelDetail(novelUrl);
      
      if (detailResponse.success) {
        novelDetail = detailResponse.data;
      } else {
        errorMessage = detailResponse.message ?? 'Không thể tải chi tiết';
      }
      
      // Lấy danh sách chương
      await loadChapters(novelUrl);
    } catch (e) {
      errorMessage = 'Lỗi: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  
  /// Lấy danh sách chương
  Future<void> loadChapters(String novelUrl) async {
    try {
      final response = await _service.getChapterList(novelUrl);
      
      if (response.success) {
        chapters = response.data ?? [];
      }
    } catch (e) {
      print('Lỗi tải chương: $e');
    }
  }
  
  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}
```

---

#### chapter_reader_view_model.dart
```dart
import 'package:flutter/material.dart';
import 'package:mystory/services/truyen_crawler/src/services/services.dart';

/// ViewModel cho Chapter Reader Screen
class ChapterReaderViewModel extends ChangeNotifier {
  final TruyenFullService _service = TruyenFullService();
  
  // ===== STATE =====
  String chapterTitle = '';
  String chapterContent = '';
  bool isLoading = false;
  String? errorMessage;
  
  // ===== METHODS =====
  
  /// Tải nội dung chương
  Future<void> loadChapterContent(String chapterUrl, String chapterName) async {
    isLoading = true;
    errorMessage = null;
    chapterTitle = chapterName;
    notifyListeners();
    
    try {
      final response = await _service.getChapterContent(
        chapterUrl,
        chapterName,
      );
      
      if (response.success) {
        chapterContent = response.data?.content ?? '';
      } else {
        errorMessage = response.message ?? 'Không thể tải chương';
      }
    } catch (e) {
      errorMessage = 'Lỗi: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  
  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}
```

---

### 3. View (UI Layer)

#### search_screen.dart
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mystory/view_models/search_view_model.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    // Khởi tạo ViewModel
    // (Hoặc sử dụng Provider.of())
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tìm kiếm')),
      body: Consumer<SearchViewModel>(
        builder: (context, viewModel, _) {
          return Column(
            children: [
              // ===== SEARCH BAR =====
              Padding(
                padding: EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Nhập tên truyện...',
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        // Gọi tìm kiếm từ ViewModel
                        viewModel.searchNovels(_searchController.text);
                      },
                    ),
                  ),
                ),
              ),
              
              // ===== ERROR MESSAGE =====
              if (viewModel.errorMessage != null)
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    viewModel.errorMessage!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              
              // ===== LOADING INDICATOR =====
              if (viewModel.isLoading)
                Center(
                  child: CircularProgressIndicator(),
                ),
              
              // ===== RESULTS LIST =====
              if (!viewModel.isLoading && viewModel.searchResults.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: viewModel.searchResults.length,
                    itemBuilder: (context, index) {
                      final novel = viewModel.searchResults[index];
                      return NovelTile(novel: novel);
                    },
                  ),
                ),
              
              // ===== EMPTY STATE =====
              if (!viewModel.isLoading && viewModel.searchResults.isEmpty)
                Center(
                  child: Text('Hãy tìm kiếm truyện yêu thích của bạn'),
                ),
            ],
          );
        },
      ),
    );
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class NovelTile extends StatelessWidget {
  final dynamic novel;
  
  const NovelTile({required this.novel});
  
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(novel.title),
      subtitle: Text(novel.author),
      onTap: () {
        // Điều hướng sang chi tiết
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NovelDetailScreen(novelUrl: novel.url),
          ),
        );
      },
    );
  }
}
```

---

#### novel_detail_screen.dart
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mystory/view_models/novel_detail_view_model.dart';

class NovelDetailScreen extends StatefulWidget {
  final String novelUrl;
  
  const NovelDetailScreen({required this.novelUrl});
  
  @override
  _NovelDetailScreenState createState() => _NovelDetailScreenState();
}

class _NovelDetailScreenState extends State<NovelDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Gọi loadNovelDetail khi screen khởi tạo
    Future.microtask(() {
      final viewModel = context.read<NovelDetailViewModel>();
      viewModel.loadNovelDetail(widget.novelUrl);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chi tiết truyện')),
      body: Consumer<NovelDetailViewModel>(
        builder: (context, viewModel, _) {
          // ===== LOADING =====
          if (viewModel.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          
          // ===== ERROR =====
          if (viewModel.errorMessage != null) {
            return Center(
              child: Text('Lỗi: ${viewModel.errorMessage}'),
            );
          }
          
          // ===== CONTENT =====
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Chi tiết truyện
                if (viewModel.hasDetail)
                  _buildDetailSection(viewModel.novelDetail!),
                
                SizedBox(height: 20),
                
                // Danh sách chương
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Danh sách chương (${viewModel.chapters.length})',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                if (viewModel.hasChapters)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: viewModel.chapters.length,
                    itemBuilder: (context, index) {
                      final chapter = viewModel.chapters[index];
                      return ListTile(
                        title: Text(chapter.title),
                        onTap: () {
                          // Đi đến đọc chương
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChapterReaderScreen(
                                chapterUrl: chapter.url,
                                chapterTitle: chapter.title,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildDetailSection(Map<String, dynamic> detail) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            detail['title'] ?? 'Unknown',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Tác giả: ${detail['author'] ?? 'Unknown'}'),
          Text('Rating: ${detail['rating'] ?? 'N/A'}/5'),
          SizedBox(height: 16),
          Text(
            detail['description'] ?? '',
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
```

---

#### chapter_reader_screen.dart
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mystory/view_models/chapter_reader_view_model.dart';

class ChapterReaderScreen extends StatefulWidget {
  final String chapterUrl;
  final String chapterTitle;
  
  const ChapterReaderScreen({
    required this.chapterUrl,
    required this.chapterTitle,
  });
  
  @override
  _ChapterReaderScreenState createState() => _ChapterReaderScreenState();
}

class _ChapterReaderScreenState extends State<ChapterReaderScreen> {
  @override
  void initState() {
    super.initState();
    // Tải nội dung chương
    Future.microtask(() {
      final viewModel = context.read<ChapterReaderViewModel>();
      viewModel.loadChapterContent(widget.chapterUrl, widget.chapterTitle);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đang đọc'),
      ),
      body: Consumer<ChapterReaderViewModel>(
        builder: (context, viewModel, _) {
          // ===== LOADING =====
          if (viewModel.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          
          // ===== ERROR =====
          if (viewModel.errorMessage != null) {
            return Center(
              child: Text('Lỗi: ${viewModel.errorMessage}'),
            );
          }
          
          // ===== CONTENT =====
          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tiêu đề chương
                Text(
                  viewModel.chapterTitle,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                SizedBox(height: 20),
                
                // Nội dung chương
                Text(
                  viewModel.chapterContent,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.8,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
```

---

## Workflow hoàn chỉnh

### Quy trình thực thi:

```
1. USER INTERACTION
   ↓ Người dùng nhập "Kiếm Hiệp" và nhấn tìm kiếm
   
2. VIEW (SearchScreen)
   ↓ Gọi: viewModel.searchNovels('Kiếm Hiệp')
   
3. VIEWMODEL (SearchViewModel)
   ↓ Xử lý logic:
   - Validate input
   - Set isLoading = true
   - notifyListeners() → UI cập nhật (hiện loading)
   
4. SERVICE (TruyenFullService)
   ↓ Thực hiện HTTP request
   - Gọi API tìm kiếm
   - Parse HTML
   - Trả về ApiResponse
   
5. VIEWMODEL (tiếp tục)
   ↓ Xử lý kết quả:
   - Kiểm tra response.success
   - Cập nhật searchResults
   - Set isLoading = false
   - notifyListeners() → UI cập nhật (hiện kết quả)
   
6. VIEW (cập nhật lại)
   ↓ Consumer rebuild
   - Hiện danh sách truyện
   - Người dùng có thể bấm vào chi tiết
```

---

## Luồng dữ liệu

### Ví dụ: Tìm kiếm → Chi tiết → Đọc chương

```
┌──────────────────────────────────────────────┐
│        SearchScreen (View Layer)             │
│  - TextField để nhập từ khóa                 │
│  - Button "Tìm kiếm"                         │
│  - Hiển thị danh sách kết quả                │
└────────────────┬─────────────────────────────┘
                 │
     (Bấm tìm kiếm)
                 │
                 ▼
┌──────────────────────────────────────────────┐
│     SearchViewModel (ViewModel Layer)        │
│  - searchNovels(keyword)                     │
│  - Kiểm tra input, set loading               │
│  - Gọi service                               │
│  - Xử lý kết quả, notify UI                  │
└────────────────┬─────────────────────────────┘
                 │
          (Gọi service)
                 │
                 ▼
┌──────────────────────────────────────────────┐
│    TruyenFullService (Service Layer)         │
│  - searchNovels(keyword)                     │
│  - Gọi API                                   │
│  - Parse dữ liệu                             │
│  - Trả về ApiResponse<ListResponse<Novel>>   │
└────────────────┬─────────────────────────────┘
                 │
        (Kết quả trả về)
                 │
                 ▼
     ┌─────────────────────┐
     │  Novel List Result  │ ← Hiển thị trên UI
     └─────────────────────┘
            │
    (Người dùng bấm 1 truyện)
            │
            ▼
┌──────────────────────────────────────────────┐
│   NovelDetailScreen (View Layer)             │
│  - Hiển thị chi tiết truyện                  │
│  - Danh sách chương                          │
└────────────────┬─────────────────────────────┘
                 │
    (LoadChapterList on init)
                 │
                 ▼
┌──────────────────────────────────────────────┐
│   NovelDetailViewModel (ViewModel Layer)     │
│  - loadNovelDetail(novelUrl)                 │
│  - loadChapters(novelUrl)                    │
└────────────────┬─────────────────────────────┘
                 │
          (Gọi service)
                 │
                 ▼
┌──────────────────────────────────────────────┐
│    TruyenFullService (Service Layer)         │
│  - getNovelDetail(novelUrl)                  │
│  - getChapterList(novelUrl)                  │
└────────────────┬─────────────────────────────┘
                 │
        (Kết quả trả về)
                 │
                 ▼
     ┌───────────────────────┐
     │  Novel Detail + List  │ ← Hiển thị trên UI
     └───────────────────────┘
            │
    (Người dùng bấm 1 chương)
            │
            ▼
┌──────────────────────────────────────────────┐
│   ChapterReaderScreen (View Layer)           │
│  - Hiển thị nội dung chương                  │
└────────────────┬─────────────────────────────┘
                 │
    (LoadChapterContent on init)
                 │
                 ▼
┌──────────────────────────────────────────────┐
│ ChapterReaderViewModel (ViewModel Layer)     │
│  - loadChapterContent(chapterUrl, name)      │
└────────────────┬─────────────────────────────┘
                 │
          (Gọi service)
                 │
                 ▼
┌──────────────────────────────────────────────┐
│    TruyenFullService (Service Layer)         │
│  - getChapterContent(chapterUrl, name)       │
└────────────────┬─────────────────────────────┘
                 │
        (Kết quả trả về)
                 │
                 ▼
     ┌───────────────────────┐
     │    Chapter Content    │ ← Hiển thị trên UI
     └───────────────────────┘
```

---

## Cách thiết lập Provider

### main.dart
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mystory/view_models/search_view_model.dart';
import 'package:mystory/view_models/novel_detail_view_model.dart';
import 'package:mystory/view_models/chapter_reader_view_model.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Story',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MultiProvider(
        // Khởi tạo tất cả ViewModel
        providers: [
          // Tìm kiếm
          ChangeNotifierProvider(
            create: (_) => SearchViewModel(),
          ),
          
          // Chi tiết truyện
          ChangeNotifierProvider(
            create: (_) => NovelDetailViewModel(),
          ),
          
          // Đọc chương
          ChangeNotifierProvider(
            create: (_) => ChapterReaderViewModel(),
          ),
        ],
        child: HomeScreen(),
      ),
    );
  }
}
```

---

## Tóm tắt MVVM Pattern

### ✅ Lợi ích

1. **Tách biệt trách vụ** - Mỗi layer có trách vụ riêng
2. **Dễ test** - Có thể test ViewModel độc lập
3. **Dễ bảo trì** - Thay đổi UI không ảnh hưởng logic
4. **Tái sử dụng** - Một ViewModel có thể dùng cho nhiều View
5. **Quản lý state** - ViewModel đảm nhiệm tất cả state

### ⚠️ Quy tắc quan trọng

| ❌ KHÔNG LÀM | ✅ NÊN LÀM |
|----------|----------|
| Gọi API trực tiếp từ View | Gọi API từ ViewModel |
| Lưu state ở View | Lưu state ở ViewModel |
| Mix logic ở View | Logic ở ViewModel, UI ở View |
| Gọi service nhiều lần | Gọi 1 lần ở ViewModel |

### 📊 Quan hệ giữa các thành phần

```
┌─────────────────────────────────────┐
│          View (UI)                  │  ← Hiển thị & nhận input
│   SearchScreen, DetailScreen        │
│   (Consumer<ViewModel>)             │
└──────────────┬──────────────────────┘
               │ notifyListeners()
               │ (Rebuilt UI)
               │
┌──────────────▼──────────────────────┐
│       ViewModel (Logic)             │  ← Xử lý logic & state
│   SearchViewModel, DetailViewModel  │
│   (extends ChangeNotifier)          │
└──────────────┬──────────────────────┘
               │ await service.method()
               │
┌──────────────▼──────────────────────┐
│    Service (Data & API)             │  ← Lấy dữ liệu từ API
│   TruyenFullService                 │
│   (HTTP requests & parsing)         │
└─────────────────────────────────────┘
```

---

## Checklist Implementasi

- [ ] Tạo Model classes (Novel, Chapter, etc.)
- [ ] Tạo ViewModels (SearchViewModel, DetailViewModel, etc.)
- [ ] Tạo UI Screens (SearchScreen, DetailScreen, etc.)
- [ ] Setup Provider đúng cách
- [ ] Gọi loadData() ở initState hoặc sử dụng Future.microtask()
- [ ] Kiểm tra state (isLoading, errorMessage) trước khi hiển thị
- [ ] Cleanup resources ở dispose()
- [ ] Test lại toàn bộ flow

---

**Happy coding! 🚀 MVVM sẽ giúp code của bạn clean và dễ bảo trì hơn rất nhiều!**
