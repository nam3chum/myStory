import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'chapter_viewmodel.dart';

class ChapterScreen extends ConsumerStatefulWidget {
  final String chapterUrl;
  final String chapterName;

  const ChapterScreen({
    super.key,
    required this.chapterUrl,
    required this.chapterName,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return ChapterState();
  }
}

class ChapterState extends ConsumerState<ChapterScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref
          .read(chapterViewModelProvider.notifier)
          .loadChapterContent(widget.chapterUrl, widget.chapterName);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(chapterViewModelProvider);
    final vmRead = ref.read(chapterViewModelProvider.notifier);

    if (vm.errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.chapterName)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(vm.errorMessage ?? 'Lỗi không xác định', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await vmRead.loadChapterContent(widget.chapterUrl, widget.chapterName);
                },
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (vm.isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.chapterName)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chapterName),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              widget.chapterName,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (vm.chapterContent.isNotEmpty)
              HtmlContent(htmlData: vm.chapterContent)
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

  const HtmlContent({super.key, required this.htmlData});

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
