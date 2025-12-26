import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mystory/data/services/truyen_crawler_provider.dart';

class ChapterScreen extends ConsumerStatefulWidget {
  final String? chapterUrl;
  final String? chapterName;

  const ChapterScreen({
    Key? key,
    this.chapterUrl,
    this.chapterName,
  }) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return ChapterState();
  }
}

class ChapterState extends ConsumerState<ChapterScreen> {
  bool _isLoading = false;
  String _chapterContent = '';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.chapterUrl != null && widget.chapterUrl!.isNotEmpty) {
      _loadChapterContent();
    }
  }

  Future<void> _loadChapterContent() async {
    setState(() => _isLoading = true);
    
    try {
      final service = ref.read(truyenFullServiceProvider);
      final result = await service.getChapterContent(
        widget.chapterUrl!,
        widget.chapterName ?? 'Chương không xác định',
      );

      if (result.success && result.data != null) {
        setState(() {
          _chapterContent = result.data!.content;
          _errorMessage = null;
        });
      } else {
        setState(() {
          _errorMessage = result.error ?? 'Không thể tải nội dung chương';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi: ${e.toString()}';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.chapterName ?? 'Chương')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadChapterContent,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.chapterName ?? 'Chương')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chapterName ?? 'Chương'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (widget.chapterName != null)
              Text(
                widget.chapterName!,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 24),
            if (_chapterContent.isNotEmpty)
              HtmlContent(htmlData: _chapterContent)
            else
              const Center(child: Text('Không có nội dung chương')),
          ],
        ),
      ),
    );
  }
}

/// Widget hiển thị nội dung HTML đơn giản
class HtmlContent extends StatelessWidget {
  final String htmlData;

  const HtmlContent({Key? key, required this.htmlData}) : super(key: key);

  /// Loại bỏ HTML tags
  String _stripHtmlIfNeeded(String htmlString) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: false);
    String plainString = htmlString.replaceAll(exp, '');
    return plainString.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  @override
  Widget build(BuildContext context) {
    final plainText = _stripHtmlIfNeeded(htmlData);

    return Text(
      plainText,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        height: 1.8,
      ),
      textAlign: TextAlign.justify,
    );
  }
}
