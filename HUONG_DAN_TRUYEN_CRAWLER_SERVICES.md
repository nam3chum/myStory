# 📚 Hướng Dẫn Chi Tiết Sử Dụng Truyen Crawler Services

## 📋 Mục lục
1. [Giới thiệu tổng quan](#giới-thiệu-tổng-quan)
2. [Cấu trúc Services](#cấu-trúc-services)
3. [Chi tiết từng Service](#chi-tiết-từng-service)
4. [Ví dụ sử dụng thực tế](#ví-dụ-sử-dụng-thực-tế)
5. [Xử lý Response](#xử-lý-response)
6. [Quản lý Life Cycle](#quản-lý-life-cycle)
7. [Best Practices](#best-practices)

---

## Giới thiệu tổng quan 

**Truyen Crawler Services** là một bộ các dịch vụ được thiết kế để **crawl (lấy dữ liệu)** từ các trang web truyện online. Nó giúp bạn:
- ✅ Tìm kiếm truyện theo từ khóa
- ✅ Lấy danh sách truyện mới, hot, full
- ✅ Lấy thông tin chi tiết của truyện (tác giả, mô tả, rating...)
- ✅ Lấy danh sách chương của truyện
- ✅ Lấy nội dung từng chương
- ✅ Phân loại truyện theo thể loại

### Kiến trúc dịch vụ

```
TruyenFullService (Dịch vụ chính)
    ├── SearchService (Tìm kiếm)
    ├── DetailService (Chi tiết & Menu)
    ├── ChapterService (Chương truyện)
    └── BaseService (Dịch vụ cơ bản - HTTP, retry)
```

---

## Cấu trúc Services

### BaseService (Lớp cơ sở)
Là nền tảng cho tất cả services khác. Nó cung cấp:
- Khả năng kết nối HTTP sử dụng Dio
- Tự động retry khi request thất bại
- Quản lý timeout và error

```dart
abstract class BaseService {
  final DioClientWrapper dioClient;
  
  BaseService({Dio? dio})
      : dioClient = DioClientWrapper(dio: dio);

  // Tải dữ liệu từ URL với retry
  Future<Response> fetch(String url) async { ... }

  // Đóng kết nối
  void dispose() { ... }
}
```

---

## Chi tiết từng Service

### 1️⃣ SearchService - Dịch vụ Tìm kiếm

#### Mục đích
Tìm kiếm truyện trên trang web dựa vào từ khóa bạn cung cấp.

#### Hàm chính

##### `search(String keyword, {int page = 1})`
Tìm kiếm truyện với tên gọi cụ thể

**Tham số:**
- `keyword` (String): Từ khóa tìm kiếm (vd: "Kiếm Hiệp", "Ngôn tình")
- `page` (int): Trang kết quả (mặc định = 1)

**Trả về:**
```dart
ApiResponse<ListResponse<Novel>>
// Chứa:
//  - items: Danh sách truyện tìm được
//  - nextPage: Trang tiếp theo
//  - hasMore: Có truyện ở trang sau hay không
```

#### Ví dụ chi tiết

```dart
// Khởi tạo service
final searchService = SearchService();

// Tìm kiếm truyện "Kiếm Hiệp"
final response = await searchService.search('Kiếm Hiệp', page: 1);

// Kiểm tra kết quả
if (response.success) {
  final novels = response.data?.items ?? [];
  print('Tìm thấy ${novels.length} truyện');
  
  // Duyệt qua từng truyện
  for (var novel in novels) {
    print('Tên: ${novel.title}');
    print('Link: ${novel.url}');
    print('Tác giả: ${novel.author}');
  }
  
  // Kiểm tra có trang tiếp theo không
  if (response.data?.hasMore ?? false) {
    print('Có trang tiếp theo: ${response.data?.nextPage}');
  }
} else {
  print('Lỗi: ${response.message}');
}

// Đóng kết nối sau khi dùng xong
searchService.dispose();
```

---

### 2️⃣ DetailService - Dịch vụ Chi tiết & Menu

#### Mục đích
Lấy danh sách menu, thể loại, thông tin chi tiết truyện.

#### Hàm chính

##### `getHomeMenu()`
Lấy danh sách menu chính trên trang chủ

**Trả về:**
```dart
ApiResponse<List<HomeMenuItem>>
```

**Ví dụ:**
```dart
final detailService = DetailService();

final response = await detailService.getHomeMenu();

if (response.success) {
  final menu = response.data ?? [];
  
  // Duyệt danh sách menu
  for (var item in menu) {
    print('${item.title}');
    print('URL: ${item.input}');
    // Output:
    // Truyện mới cập nhật
    // URL: https://example.com/danh-sach/truyen-moi/
    //
    // Truyện Hot
    // URL: https://example.com/danh-sach/truyen-hot/
    // ... v.v
  }
}
```

**Kết quả sẽ bao gồm:**
- Truyện mới cập nhật
- Truyện Hot (được yêu thích)
- Truyện Full (kết thúc)
- Tiên Hiệp Hay
- Kiếm Hiệp Hay
- Truyện Teen Hay
- Ngôn Tình Hay

---

##### `getGenres()`
Lấy danh sách tất cả thể loại truyện

**Trả về:**
```dart
ApiResponse<List<Genre>>
```

**Ví dụ:**
```dart
final detailService = DetailService();

final response = await detailService.getGenres();

if (response.success) {
  final genres = response.data ?? [];
  
  // Duyệt danh sách thể loại
  for (var genre in genres) {
    print('${genre.title}');
    // Output:
    // Tiên Hiệp
    // Kiếm Hiệp
    // Ngôn Tình
    // Đô Thị
    // ... v.v
  }
}
```

**Danh sách thể loại bao gồm:**
- Tiên Hiệp
- Kiếm Hiệp
- Ngôn Tình
- Đô Thị
- Quan Trường
- Võng Du
- Khoa Huyễn
- Hệ Thống
- Huyền Huyễn
- Dị Giới

---

##### `getNovelsByGenre(String genreUrl, {int page = 1})`
Lấy danh sách truyện theo thể loại cụ thể

**Tham số:**
- `genreUrl` (String): URL của thể loại
- `page` (int): Trang kết quả

**Trả về:**
```dart
ApiResponse<ListResponse<Novel>>
```

**Ví dụ:**
```dart
final detailService = DetailService();

// Lấy truyện thể loại Kiếm Hiệp
const genreUrl = 'https://example.com/the-loai/kiem-hiep/';
final response = await detailService.getNovelsByGenre(genreUrl, page: 1);

if (response.success) {
  final novels = response.data?.items ?? [];
  print('Tìm thấy ${novels.length} truyện Kiếm Hiệp');
  
  for (var novel in novels) {
    print('${novel.title} - Tác giả: ${novel.author}');
  }
}
```

---

##### `getDetail(String novelUrl)`
Lấy thông tin chi tiết của một truyện cụ thể

**Tham số:**
- `novelUrl` (String): URL của truyện

**Trả về:**
```dart
ApiResponse<NovelDetail>
// Bao gồm: title, author, description, rating, status, v.v...
```

**Ví dụ:**
```dart
final detailService = DetailService();

final response = await detailService.getDetail('https://example.com/truyen/...');

if (response.success) {
  final detail = response.data!;
  
  print('Tên truyện: ${detail.title}');
  print('Tác giả: ${detail.author}');
  print('Mô tả: ${detail.description}');
  print('Rating: ${detail.rating}');
  print('Trạng thái: ${detail.status}');
  print('Tổng chương: ${detail.totalChapters}');
}
```

---

### 3️⃣ ChapterService - Dịch vụ Chương Truyện

#### Mục đích
Lấy danh sách chương và nội dung của từng chương.

#### Hàm chính

##### `getChapterList(String novelUrl)`
Lấy danh sách tất cả chương của một truyện

**Tham số:**
- `novelUrl` (String): URL của truyện

**Trả về:**
```dart
ApiResponse<List<Chapter>>
// Mỗi Chapter chứa: title, url, publishDate, v.v...
```

**Ví dụ chi tiết:**
```dart
final chapterService = ChapterService();

// Lấy tất cả chương từ URL truyện
final response = await chapterService.getChapterList(
  'https://example.com/truyen/kiem-hiep-hay'
);

if (response.success) {
  final chapters = response.data ?? [];
  print('Tổng số chương: ${chapters.length}');
  
  // Duyệt từng chương
  for (int i = 0; i < chapters.length; i++) {
    final chapter = chapters[i];
    print('${i + 1}. ${chapter.title}');
    print('   URL: ${chapter.url}');
    print('   Ngày đăng: ${chapter.publishDate}');
  }
  
  // Ví dụ: In chương đầu tiên và chương cuối cùng
  if (chapters.isNotEmpty) {
    print('\n=== CHƯƠNG ĐẦU TIÊN ===');
    print(chapters[0].title);
    
    print('\n=== CHƯƠNG CUỐI CÙNG ===');
    print(chapters[chapters.length - 1].title);
  }
} else {
  print('Lỗi: ${response.message}');
}
```

---

##### `getContent(String chapterUrl, String chapterName)`
Lấy nội dung chi tiết của một chương

**Tham số:**
- `chapterUrl` (String): URL chương
- `chapterName` (String): Tên chương (để hiển thị)

**Trả về:**
```dart
ApiResponse<ChapterContent>
// Bao gồm: title, content, publishDate, v.v...
```

**Ví dụ chi tiết:**
```dart
final chapterService = ChapterService();

// Lấy nội dung chương
final response = await chapterService.getContent(
  'https://example.com/truyen/kiem-hiep-hay/chuong-1',
  'Chương 1: Khởi Đầu'
);

if (response.success) {
  final content = response.data!;
  
  print('📖 ${content.title}');
  print('━' * 50);
  print(content.content);
  print('━' * 50);
  print('Đăng lúc: ${content.publishDate}');
} else {
  print('Lỗi: ${response.message}');
}
```

---

### 4️⃣ TruyenFullService - Dịch vụ Tổng hợp ⭐

#### Mục đích
**Đây là service chính mà bạn nên dùng** vì nó kết hợp tất cả các service khác.

#### Tất cả hàm có sẵn

```dart
// === TÌM KIẾM ===
searchNovels(String keyword, {int page = 1})
  → Tìm kiếm truyện

// === MENU & THỂ LOẠI ===
getHomeMenu()
  → Lấy danh sách menu chính

getGenres()
  → Lấy tất cả thể loại

getNovelsByGenre(String genreUrl, {int page = 1})
  → Lấy truyện theo thể loại

getNovelDetail(String novelUrl)
  → Lấy chi tiết truyện

// === CHƯƠNG TRUYỆN ===
getChapterList(String novelUrl)
  → Lấy danh sách chương

getChapterContent(String chapterUrl, String chapterName)
  → Lấy nội dung chương
```

---

## Ví dụ sử dụng thực tế

### Ví dụ 1: Tìm kiếm và xem chi tiết truyện

```dart
void searchAndViewDetails() async {
  // 1. Khởi tạo service
  final service = TruyenFullService();
  
  try {
    // 2. Tìm kiếm truyện "Kiếm Hiệp"
    print('🔍 Đang tìm kiếm...');
    final searchResult = await service.searchNovels('Kiếm Hiệp', page: 1);
    
    if (!searchResult.success) {
      print('❌ Tìm kiếm thất bại: ${searchResult.message}');
      return;
    }
    
    final novels = searchResult.data?.items ?? [];
    if (novels.isEmpty) {
      print('❌ Không tìm thấy truyện nào');
      return;
    }
    
    // 3. Lấy truyện đầu tiên
    final firstNovel = novels[0];
    print('✅ Tìm thấy truyện: ${firstNovel.title}');
    
    // 4. Lấy chi tiết truyện
    print('📖 Đang lấy chi tiết...');
    final detailResult = await service.getNovelDetail(firstNovel.url);
    
    if (detailResult.success) {
      final detail = detailResult.data!;
      print('''
╔════════════════════════════════════════╗
║  ${detail.title}
║  Tác giả: ${detail.author}
║  Rating: ${detail.rating}
║  Trạng thái: ${detail.status}
║  Tổng chương: ${detail.totalChapters}
╚════════════════════════════════════════╝
      ''');
    }
  } finally {
    service.dispose();
  }
}
```

---

### Ví dụ 2: Lấy danh sách chương và đọc chương đầu

```dart
void readFirstChapter() async {
  final service = TruyenFullService();
  
  try {
    const novelUrl = 'https://example.com/truyen/kiem-hiep-hay';
    
    // 1. Lấy danh sách chương
    print('📚 Đang lấy danh sách chương...');
    final chaptersResult = await service.getChapterList(novelUrl);
    
    if (!chaptersResult.success || chaptersResult.data == null) {
      print('❌ Lỗi: ${chaptersResult.message}');
      return;
    }
    
    final chapters = chaptersResult.data!;
    print('✅ Tổng số chương: ${chapters.length}');
    
    // 2. Lấy chương đầu tiên
    final firstChapter = chapters[0];
    print('📖 Đang đọc: ${firstChapter.title}');
    
    final contentResult = await service.getChapterContent(
      firstChapter.url,
      firstChapter.title,
    );
    
    if (contentResult.success) {
      final content = contentResult.data!;
      print(content.content);
    }
  } finally {
    service.dispose();
  }
}
```

---

### Ví dụ 3: Duyệt thể loại

```dart
void browseGenre() async {
  final service = TruyenFullService();
  
  try {
    // 1. Lấy danh sách thể loại
    print('📚 Đang lấy danh sách thể loại...');
    final genresResult = await service.getGenres();
    
    if (!genresResult.success) {
      print('❌ Lỗi: ${genresResult.message}');
      return;
    }
    
    final genres = genresResult.data ?? [];
    print('✅ Tổng thể loại: ${genres.length}\n');
    
    // 2. Chọn thể loại "Kiếm Hiệp"
    final genre = genres.firstWhere(
      (g) => g.title == 'Kiếm Hiệp',
      orElse: () => genres[0],
    );
    
    print('📖 Đang xem thể loại: ${genre.title}');
    
    // 3. Lấy truyện của thể loại này
    final novelsResult = await service.getNovelsByGenre(genre.input, page: 1);
    
    if (novelsResult.success) {
      final novels = novelsResult.data?.items ?? [];
      print('Tìm thấy ${novels.length} truyện:\n');
      
      for (int i = 0; i < novels.length && i < 5; i++) {
        final novel = novels[i];
        print('${i + 1}. ${novel.title}');
        print('   Tác giả: ${novel.author}');
        print('   URL: ${novel.url}\n');
      }
    }
  } finally {
    service.dispose();
  }
}
```

---

### Ví dụ 4: Tích hợp vào ViewModel (MVVM)

```dart
class NovelListViewModel extends ChangeNotifier {
  final TruyenFullService _service = TruyenFullService();
  
  List<Novel> novels = [];
  bool isLoading = false;
  String? errorMessage;
  
  // Tìm kiếm truyện
  Future<void> searchNovels(String keyword) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    
    try {
      final response = await _service.searchNovels(keyword, page: 1);
      
      if (response.success) {
        novels = response.data?.items ?? [];
      } else {
        errorMessage = response.message;
      }
    } catch (e) {
      errorMessage = 'Lỗi: ${e.toString()}';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  
  // Lấy danh sách chương
  Future<List<Chapter>> getChapters(String novelUrl) async {
    try {
      final response = await _service.getChapterList(novelUrl);
      return response.success ? response.data ?? [] : [];
    } catch (e) {
      print('Lỗi: $e');
      return [];
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

### Ví dụ 5: Tích hợp vào Widget

```dart
class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();
  final _service = TruyenFullService();
  List<Novel> _searchResults = [];
  bool _isLoading = false;

  void _search(String keyword) async {
    setState(() => _isLoading = true);
    
    try {
      final response = await _service.searchNovels(keyword);
      
      setState(() {
        if (response.success) {
          _searchResults = response.data?.items ?? [];
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: ${response.message}')),
          );
        }
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tìm kiếm')),
      body: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Nhập tên truyện',
              suffixIcon: IconButton(
                icon: Icon(Icons.search),
                onPressed: () => _search(_controller.text),
              ),
            ),
          ),
          if (_isLoading)
            Center(child: CircularProgressIndicator())
          else
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final novel = _searchResults[index];
                  return ListTile(
                    title: Text(novel.title),
                    subtitle: Text(novel.author),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _service.dispose();
    _controller.dispose();
    super.dispose();
  }
}
```

---

## Xử lý Response

Tất cả service trả về `ApiResponse<T>`. Đây là cấu trúc:

```dart
class ApiResponse<T> {
  final bool success;      // Thành công hay không
  final T? data;          // Dữ liệu trả về
  final String message;   // Thông báo lỗi
  final int? statusCode;  // HTTP status code
}
```

### Cách xử lý đúng cách

```dart
final response = await service.searchNovels('keyword');

// ❌ SAI - không kiểm tra success
final novels = response.data?.items ?? []; // Có thể null/crash

// ✅ ĐÚNG - kiểm tra success trước
if (response.success) {
  final novels = response.data?.items ?? [];
  // Xử lý dữ liệu
} else {
  print('Lỗi: ${response.message}');
  print('Status code: ${response.statusCode}');
}

// ✅ ĐÚNG - sử dụng try-catch
try {
  final response = await service.searchNovels('keyword');
  
  if (response.success) {
    final novels = response.data?.items ?? [];
    // Xử lý
  } else {
    showError(response.message);
  }
} catch (e) {
  showError('Lỗi mạng: $e');
}
```

---

## Quản lý Life Cycle

### Khởi tạo Service

```dart
// Cách 1: Khởi tạo với Dio mặc định
final service = TruyenFullService();

// Cách 2: Khởi tạo với Dio tùy chỉnh
final dio = Dio();
dio.options.connectTimeout = Duration(seconds: 10);
dio.options.receiveTimeout = Duration(seconds: 10);
final service = TruyenFullService(dio: dio);
```

### Đóng Service

```dart
// Quan trọng: Luôn đóng service khi không dùng
service.dispose();

// Hoặc sử dụng try-finally
try {
  // Sử dụng service
} finally {
  service.dispose();
}
```

### Quản lý trong ViewModel

```dart
class MyViewModel extends ChangeNotifier {
  late TruyenFullService _service;
  
  MyViewModel() {
    _service = TruyenFullService();
  }
  
  @override
  void dispose() {
    _service.dispose(); // ⭐ Luôn gọi dispose
    super.dispose();
  }
}
```

---

## Best Practices

### 1. ✅ Luôn kiểm tra response.success

```dart
// ❌ SAI
final novels = response.data!.items;

// ✅ ĐÚNG
if (response.success && response.data != null) {
  final novels = response.data!.items;
}
```

### 2. ✅ Sử dụng try-catch-finally

```dart
final service = TruyenFullService();

try {
  final response = await service.searchNovels('keyword');
  // Xử lý kết quả
} catch (e) {
  print('Lỗi: $e');
} finally {
  service.dispose(); // Luôn gọi
}
```

### 3. ✅ Hiển thị Loading state

```dart
setState(() => isLoading = true);

try {
  final response = await service.searchNovels(keyword);
  // Xử lý
} finally {
  setState(() => isLoading = false);
}
```

### 4. ✅ Xử lý phân trang

```dart
List<Novel> allNovels = [];
int currentPage = 1;
bool hasMore = true;

Future<void> loadMore() async {
  if (!hasMore) return;
  
  final response = await service.searchNovels('keyword', page: currentPage);
  
  if (response.success) {
    allNovels.addAll(response.data?.items ?? []);
    hasMore = response.data?.hasMore ?? false;
    currentPage++;
  }
}
```

### 5. ✅ Sử dụng Singleton Pattern (tùy chọn)

```dart
// Tạo singleton service
class ServiceLocator {
  static final TruyenFullService _service = TruyenFullService();
  
  static TruyenFullService get service => _service;
  
  static void dispose() {
    _service.dispose();
  }
}

// Sử dụng
final service = ServiceLocator.service;
```

### 6. ✅ Caching dữ liệu

```dart
class CachedNovelService {
  final TruyenFullService _service = TruyenFullService();
  final Map<String, List<Novel>> _cache = {};
  
  Future<List<Novel>> searchNovels(String keyword) async {
    // Kiểm tra cache
    if (_cache.containsKey(keyword)) {
      return _cache[keyword]!;
    }
    
    // Nếu không có cache, fetch từ API
    final response = await _service.searchNovels(keyword);
    
    if (response.success) {
      final novels = response.data?.items ?? [];
      _cache[keyword] = novels;
      return novels;
    }
    
    return [];
  }
}
```

---

## Lưu ý quan trọng

### ⚠️ Network & Performance
- Service sử dụng **Dio** với **retry logic** tự động
- Có delay giữa các request để tránh bị block
- Timeout mặc định: ~10 giây

### ⚠️ HTML Parsing
- Dữ liệu được parse từ HTML bằng **html_parser**
- Nếu website thay đổi cấu trúc, parser có thể không hoạt động
- Cần update parser khi website cập nhật

### ⚠️ User-Agent
- Service tự động gửi User-Agent để tránh bị chặn
- Nếu vẫn bị chặn, có thể cần thêm headers tùy chỉnh

### ⚠️ Paging
- Phải sử dụng `page` parameter để phân trang
- Mỗi page chứa ~20-30 truyện
- Sử dụng `hasMore` để biết còn trang tiếp theo hay không

---

## Tóm tắt nhanh

| Service | Hàm | Mục đích |
|---------|-----|---------|
| **SearchService** | `search()` | Tìm kiếm truyện |
| **DetailService** | `getHomeMenu()` | Lấy menu chính |
| | `getGenres()` | Lấy thể loại |
| | `getNovelsByGenre()` | Lấy truyện theo thể loại |
| | `getDetail()` | Chi tiết truyện |
| **ChapterService** | `getChapterList()` | Danh sách chương |
| | `getContent()` | Nội dung chương |
| **TruyenFullService** | Tất cả trên | Kết hợp tất cả |

---

**Happy coding! 🚀**
