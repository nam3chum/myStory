# 📖 Hướng Dẫn Chi Tiết `truyen_crawler`

Tài liệu này giải thích chi tiết về cách hoạt động và cách sử dụng của các thành phần trong thư mục `lib/services/truyen_crawler`.

## 📂 Cấu Trúc Thư Mục

```
lib/services/truyen_crawler/
├── src/
│   ├── config/       # Cấu hình (URL, endpoint,...)
│   ├── models/       # Các lớp mô hình dữ liệu (Story, Chapter,...)
│   ├── parsers/      # Các lớp phân tích cú pháp HTML
│   └── services/     # Các lớp dịch vụ (gọi API, xử lý logic)
└── truyen_crawler.dart # Tệp export chính
```

## 🚀 Thành Phần Chính

### 1. `TruyenFullService` - Giao Diện Chính

Đây là lớp bạn sẽ tương tác nhiều nhất. Nó đóng vai trò là một "cửa ngõ" (facade) để truy cập tất cả các chức năng của crawler một cách đơn giản.

**Tệp:** `lib/services/truyen_crawler/src/services/truyen_full_service.dart`

**Cách sử dụng:**

```dart
// Khởi tạo service
final truyenService = TruyenFullService();

// 1. Tìm kiếm truyện
final searchResult = await truyenService.searchStories('tiên hiệp', page: 1);
if (searchResult.success) {
  List<Story> stories = searchResult.data?.items ?? [];
  print('Tìm thấy ${stories.length} truyện.');
}

// 2. Lấy chi tiết truyện
final detailResult = await truyenService.getStoryDetail('/truyen-tien-hiep-hay-nhat/');
if (detailResult.success) {
  StoryDetail? detail = detailResult.data;
  print('Tên truyện: ${detail?.name}');
  print('Tác giả: ${detail?.author}');
}

// 3. Lấy danh sách chương
final chaptersResult = await truyenService.getChapterList('/truyen-tien-hiep-hay-nhat/');
if (chaptersResult.success) {
  List<Chapter> chapters = chaptersResult.data ?? [];
  print('Tổng số chương: ${chapters.length}');
}

// 4. Lấy nội dung chương
final contentResult = await truyenService.getChapterContent('/truyen-tien-hiep-hay-nhat/chuong-1/', 'Chương 1');
if (contentResult.success) {
  String? content = contentResult.data?.content;
  print('Nội dung chương 1 đã được tải.');
}
```

---

### 2. Các Lớp `Service` Con

`TruyenFullService` được xây dựng từ các service con, mỗi service đảm nhận một nhiệm vụ cụ thể.

#### a. `SearchService`

*   **Chức năng:** Tìm kiếm truyện theo từ khóa.
*   **Tệp:** `.../services/search_service.dart`
*   **Phương thức chính:** `search(String keyword, {int page})`
*   **Luồng hoạt động:**
    1.  Xây dựng URL tìm kiếm với từ khóa và số trang.
    2.  Gửi yêu cầu HTTP GET đến URL đó.
    3.  Nếu thành công, gọi `StoryListParser.parse()` để trích xuất danh sách truyện từ HTML trả về.
    4.  Gọi `PaginationParser.parse()` để lấy thông tin trang tiếp theo.
    5.  Trả về đối tượng `ApiResponse<ListResponse<Story>>`.

#### b. `DetailService`

*   **Chức năng:** Lấy thông tin chi tiết về truyện, danh sách truyện theo thể loại.
*   **Tệp:** `.../services/detail_service.dart`
*   **Phương thức chính:**
    *   `getDetail(String storyUrl)`: Lấy chi tiết một truyện.
    *   `getStoriesByGenre(String genreUrl, {int page})`: Lấy danh sách truyện của một thể loại.
    *   `getHomeMenu()`: Trả về danh sách các mục menu trang chủ (cứng).
    *   `getGenres()`: Trả về danh sách các thể loại (cứng).
*   **Luồng hoạt động (`getDetail`):**
    1.  Gửi yêu cầu HTTP GET đến `storyUrl`.
    2.  Nếu thành công, gọi `StoryDetailParser.parse()` để trích xuất toàn bộ thông tin chi tiết từ HTML.
    3.  Trả về `ApiResponse<StoryDetail>`.

#### c. `ChapterService`

*   **Chức năng:** Lấy danh sách chương và nội dung từng chương.
*   **Tệp:** `.../services/chapter_service.dart`
*   **Phương thức chính:**
    *   `getChapterList(String storyUrl)`
    *   `getContent(String chapterUrl, String chapterName)`
*   **Luồng hoạt động (`getChapterList`):** Đây là phương thức phức tạp nhất.
    1.  Gửi yêu cầu đến `storyUrl` để lấy trang chi tiết truyện.
    2.  Dùng `TruyenInfoParser.parse()` để lấy các thông tin ẩn cần thiết cho việc gọi AJAX (như `truyenId`, `truyenAscii`, `totalPage`).
    3.  Lặp qua tất cả các trang chương (`totalPage`).
    4.  Trong mỗi vòng lặp, gửi một yêu cầu **AJAX** đến endpoint của `truyenfull.vn` để lấy danh sách chương của trang đó.
    5.  Phản hồi AJAX trả về một JSON, trong đó có một trường chứa HTML của danh sách chương.
    6.  Dùng `ChapterListParser.parseFromJson()` để phân tích chuỗi HTML này và lấy ra danh sách `Chapter`.
    7.  Thêm các chương vừa lấy được vào danh sách tổng.
    8.  Có một khoảng dừng nhỏ (`Future.delayed`) giữa các lần gọi để tránh bị server chặn.
    9.  Trả về `ApiResponse<List<Chapter>>` chứa toàn bộ chương của truyện.

---

### 3. Các Lớp `Parser`

Các parser chịu trách nhiệm phân tích cú pháp (parsing) nội dung HTML thô và chuyển đổi nó thành các đối tượng `Model` có cấu trúc. Chúng sử dụng thư viện `package:html` và các **CSS Selector**.

**Tệp:** `lib/services/truyen_crawler/src/parsers/*.dart`

| Lớp Parser | Tệp | Chức năng |
| :--- | :--- | :--- |
| **`StoryListParser`** | `story_parser.dart` | Phân tích trang danh sách, trích xuất các truyện thành `List<Story>`. |
| **`StoryDetailParser`** | `story_parser.dart` | Phân tích trang chi tiết, trích xuất thông tin thành đối tượng `StoryDetail`. |
| **`PaginationParser`**| `story_parser.dart` | Tìm và trích xuất số của trang tiếp theo. |
| **`ChapterListParser`** | `chapter_parser.dart`| Phân tích HTML danh sách chương (từ AJAX), trích xuất thành `List<Chapter>`. |
| **`ChapterContentParser`**| `chapter_parser.dart`| Phân tích trang đọc truyện, trích xuất và **làm sạch** nội dung chương. |
| **`TruyenInfoParser`** | `chapter_parser.dart`| Trích xuất các `input` ẩn chứa thông tin về ID truyện để gọi AJAX. |

**Ví dụ (`ChapterContentParser`):**

Nó không chỉ lấy `div.chapter-c` mà còn thực hiện các công việc quan trọng:
*   Xóa các thẻ `<script>`, `<iframe>`, `<noscript>`.
*   Xóa các `div` quảng cáo.
*   Xóa các cảnh báo "chương này có nội dung ảnh".

Điều này đảm bảo nội dung bạn nhận được là sạch sẽ và sẵn sàng để hiển thị.

---

### 4. Các Lớp `Model`

Đây là các lớp dữ liệu thuần túy (Plain Old Dart Objects - PODOs) định nghĩa cấu trúc cho dữ liệu mà crawler lấy về.

**Tệp:** `lib/services/truyen_crawler/src/models/*.dart`

| Lớp Model | Mô tả |
| :--- | :--- |
| **`Story`** | Thông tin cơ bản của truyện khi hiển thị trong danh sách. |
| **`StoryDetail`** | Thông tin đầy đủ của truyện (có thêm mô tả, thể loại,...). |
| **`Chapter`** | Thông tin về một chương (tên, URL). |
| **`ChapterContent`**| Nội dung chi tiết của một chương. |
| **`Genre`** | Thông tin về thể loại truyện. |
| **`ApiResponse`** | Lớp vỏ bọc (wrapper) cho các phản hồi từ service, chứa trạng thái (`success`), dữ liệu (`data`), và thông báo lỗi (`message`). |
| **`ListResponse`** | Lớp vỏ bọc cho các danh sách có phân trang, chứa danh sách các mục (`items`) và thông tin trang tiếp theo (`nextPage`, `hasMore`). |

## 🏁 Kết Luận

1.  **Để sử dụng:** Luôn bắt đầu với `TruyenFullService`.
2.  **Luồng dữ liệu:** `Service` gọi API -> Nhận HTML -> `Parser` phân tích HTML -> Tạo ra `Model` -> `Service` trả về `ApiResponse` chứa `Model`.
3.  **Tùy chỉnh:** Nếu trang web nguồn (truyenfull.vn) thay đổi cấu trúc HTML, bạn chỉ cần cập nhật các **CSS Selector** trong các tệp `parser`. Logic trong các `service` hầu như không cần thay đổi.
