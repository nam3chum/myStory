# Tổng quan dự án mystory

Đây là một bản tóm tắt chi tiết về dự án Flutter "mystory" của bạn, dựa trên các tệp cấu hình và mã hiện có:

## 1. Tổng quan cấp cao về dự án

"mystory" là một ứng dụng di động Flutter được phát triển cho cả nền tảng Android và Windows. Nó được thiết kế để cung cấp trải nghiệm đọc truyện, có thể tích hợp cả dữ liệu từ API bên ngoài và dữ liệu được cào. Các thư viện và công nghệ chính được sử dụng bao gồm:

*   **Quản lý trạng thái:** `flutter_riverpod` được sử dụng để quản lý trạng thái hiệu quả và có thể dự đoán được.
*   **Tiêm phụ thuộc (DI):** `get_it` được sử dụng để quản lý các phụ thuộc và dịch vụ trong toàn bộ ứng dụng.
*   **Lưu trữ cục bộ:** `sqflite` được sử dụng để lưu trữ dữ liệu cục bộ, có thể là để lưu trữ truyện, thể loại hoặc tùy chọn người dùng.
*   **Truy cập dữ liệu từ xa:** Một gói tùy chỉnh, `truyen_crawler`, chịu trách nhiệm cào dữ liệu từ các nguồn từ xa hoặc tương tác với các API bên ngoài.

Điểm vào ứng dụng là `lib/main.dart`. Tại đây, quá trình tiêm phụ thuộc được khởi tạo thông qua `setLocator()`, sau đó là `ProviderScope` và luồng không đồng bộ `AppInitViewModel` để quản lý khởi tạo ứng dụng.

## 2. Khởi động và Tiêm phụ thuộc

Quá trình bootstrap tiêm phụ thuộc được định cấu hình trong `lib/data/services/config/service_get_it.dart`. Các singleton quan trọng được đăng ký tại đây bao gồm:

*   `Dio` (thông qua `DioClient.createDio()`): Để xử lý các yêu cầu HTTP.
*   `ApiStoryService` và `ApiGenreService`: Các dịch vụ để tương tác với các API liên quan đến truyện và thể loại.
*   `DatabaseController`: Điểm đồng bộ hóa duy nhất cho các hoạt động cơ sở dữ liệu SQL.
*   `ThemePreference`: Một trình bao bọc xung quanh `SharedPreferences` để quản lý các tùy chọn liên quan đến chủ đề và các cài đặt người dùng khác.

Mẫu khởi tạo xoay quanh `AppInitViewModel` (một AsyncNotifier), chịu trách nhiệm gọi `settingsProvider` và thực hiện các di chuyển lần đầu khi ứng dụng khởi chạy lần đầu (tham khảo `lib/data/services/config/app_init_viewmodel.dart`).

## 3. Quy ước quản lý trạng thái

Ứng dụng tuân theo các quy ước của `flutter_riverpod` để quản lý trạng thái. Các Notifier và AsyncNotifier providers được sử dụng cho trạng thái của view-model. Một ví dụ điển hình là `settingsProvider` trong `lib/views/settings_screen/setting_viewmodel.dart`.

Để đọc trạng thái, `ref.watch(...)` được sử dụng, trong khi việc thay đổi trạng thái được thực hiện thông qua `ref.read(...).notifier` hoặc các phương thức nhà cung cấp có liên quan (ví dụ, `AppStarter.initState` trong `lib/main.dart`).

## 4. Tích hợp mạng và Crawler

Ứng dụng kết hợp hai phong cách mạng khác nhau:

*   **API nội bộ:** Sử dụng các API giống Retrofit được tạo ra cùng với thư viện `Dio` cho các điểm cuối nội bộ của ứng dụng. Các dịch vụ API này được đặt trong `lib/data/services/network` (ví dụ: `service_story.dart`).
*   **Gói Crawler cục bộ:** Gói `services/truyen_crawler` (`lib/services/truyen_crawler`) cung cấp `TruyenFullService`. Dịch vụ này tổng hợp `SearchService`, `DetailService` và `ChapterService` để xử lý việc cào và truy xuất dữ liệu truyện. `TruyenFullService()` được sử dụng trực tiếp ở những nơi cần thiết, chẳng hạn như trong các view-model liên quan đến thể loại, tìm kiếm và xem chương.

## 5. Lưu trữ cục bộ và Cơ sở dữ liệu

`DatabaseController` (`lib/data/database/database_controller.dart`) đóng vai trò là điểm đồng bộ hóa tập trung cho tất cả các hoạt động SQL. Nó sử dụng `DataBaseProvider` để khởi tạo cơ sở dữ liệu và lưu trữ các thực thể như thể loại và truyện trong các bảng như `genresTable` và `storiesTable`.

`ThemePreference` (`lib/data/services/pref/preference.dart`) là một trình bao bọc thuận tiện xung quanh `SharedPreferences` để quản lý các tùy chọn người dùng, đặc biệt là liên quan đến cài đặt chủ đề.

## 6. Tạo mã và ghi chú xây dựng

Dự án dựa vào các công cụ tạo mã để tự động hóa các khía cạnh khác nhau của quá trình phát triển. Các gói chính được sử dụng là `retrofit_generator`, `json_serializable` và `build_runner`. Để tạo lại DTO (Đối tượng truyền dữ liệu) hoặc các заглушки API, bạn có thể chạy các lệnh sau:

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

Các tệp được tạo thường được tìm thấy trong thư mục `build/` và các tệp có định dạng `lib/.g.dart`.

## 7. Kiểm tra, chạy và ghi chú nền tảng

*   **Chạy ứng dụng cục bộ:** Bạn có thể khởi chạy ứng dụng bằng lệnh `flutter run`. Bạn có thể cần chỉ định thiết bị hoặc nền tảng (ví dụ: `flutter run -d windows` cho Windows).
*   **Kiểm tra:** Các bài kiểm tra đơn vị và widget được đặt trong thư mục `test/`. Bạn có thể chạy chúng bằng cách sử dụng `flutter test`.

## 8. Quy ước và cạm bẫy cụ thể của dự án

*   **Ưu tiên DI:** Nhiều view-model gọi `getIt<T>()` trong phương thức `build()` của chúng. Điều quan trọng là đảm bảo rằng `setLocator()` được chạy trước khi sử dụng bất kỳ nhà cung cấp nào, điều này đã được xử lý trong `main.dart`.
*   **Di chuyển dữ liệu lần đầu:** Khi khởi chạy lần đầu, `AppInitViewModel.initializeApp()` tìm nạp các thể loại thông qua `TruyenFullService().getGenres()` và duy trì chúng. Cần thận trọng khi chạy logic này trong quá trình kiểm tra, có thể yêu cầu mô phỏng mạng hoặc đặt `hasLaunched` trong `SharedPreferences`.
*   **Luồng lỗi:** `AppStarter` hiển thị `AppInitErrorView` khi có lỗi và làm mất hiệu lực `appInitViewModelProvider` khi thử lại. Sử dụng `ref.invalidate(...)` để khởi động lại các async notifiers.

## 9. Tham chiếu tệp hữu ích (truy cập nhanh)

*   `lib/main.dart` — Điểm vào ứng dụng và kết nối nhà cung cấp.
*   `lib/data/services/config/service_get_it.dart` — Đăng ký DI.
*   `lib/data/services/config/app_init_viewmodel.dart` — Logic khởi động/lần đầu khởi chạy.
*   `lib/views/settings_screen/setting_viewmodel.dart` — Tùy chọn và chủ đề.
*   `lib/data/database/database_controller.dart` — Các trợ giúp CRUD cơ sở dữ liệu.
*   `lib/services/truyen_crawler/src/services/truyen_full_service.dart` — Bề mặt API của crawler.

## 10. Cách thực hiện các thay đổi mã nhỏ một cách an toàn

*   Sau khi chỉnh sửa, luôn chạy `flutter analyze` và `flutter test` để đảm bảo không có lỗi hoặc hồi quy.
*   Nếu bạn sửa đổi các mô hình hoặc chú thích Retrofit, hãy chạy `build_runner` để tạo lại mã.
*   Khi chỉnh sửa một view-model được hỗ trợ bởi nhà cung cấp, hãy ưu tiên thêm các phương thức vào Notifier và cập nhật trạng thái thông qua `state = state.copyWith(...)` để duy trì tính bất biến của trạng thái.
