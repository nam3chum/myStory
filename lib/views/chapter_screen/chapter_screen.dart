import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mystory/views/chapter_screen/widgets/bottom_sheet.dart';
import 'package:mystory/views/chapter_screen/widgets/chapter_content.dart';

import '../../services/truyen_crawler/src/models/chapter_models.dart';
import 'chapter_viewmodel.dart';

class ChapterReaderScreen extends ConsumerStatefulWidget {
  final String chapterUrl;
  final String chapterName;
  final List<Chapter> chapterList;
  final String storyName;

  const ChapterReaderScreen({
    super.key,
    required this.chapterUrl,
    required this.chapterName,
    required this.chapterList,
    required this.storyName,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return ChapterReaderState();
  }
}

class ChapterReaderState extends ConsumerState<ChapterReaderScreen> {
  late ScrollController _chapterListScrollController;
  late ScrollController _contentScrollController;

  void enterReadingMode() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.immersiveSticky,
      );
    });
  }

  void exitReadingMode() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );
  }

  @override
  void initState() {
    super.initState();
    _chapterListScrollController = ScrollController();
    _contentScrollController = ScrollController();

    enterReadingMode();

    Future.microtask(() async {
      await ref
          .read(chapterViewModelProvider.notifier)
          .loadChapterList(widget.chapterList);
      await ref
          .read(chapterViewModelProvider.notifier)
          .loadChapterContent(widget.chapterUrl, widget.chapterName);

      // Restore scroll position từ lần trước
      final savedScrollPosition = await ref
          .read(chapterViewModelProvider.notifier)
          .loadScrollPosition(widget.chapterUrl);

      Future.delayed(const Duration(milliseconds: 100), () {
        if (_contentScrollController.hasClients) {
          _contentScrollController.jumpTo(savedScrollPosition);
          ref
              .read(chapterViewModelProvider.notifier)
              .updateScrollPosition(savedScrollPosition);
        }
      });

      // Auto-scroll tới chapter hiện tại lần đầu tiên
      if (!ref.read(chapterViewModelProvider).hasInitialScrolled) {
        ref.read(chapterViewModelProvider.notifier).markInitialScrolled();
      }
    });

    // Lưu scroll position khi cuộn
    _contentScrollController.addListener(() {
      ref
          .read(chapterViewModelProvider.notifier)
          .updateScrollPosition(_contentScrollController.offset);
    });
  }

  @override
  void dispose() {
    exitReadingMode();
    _chapterListScrollController.dispose();
    _contentScrollController.dispose();
    super.dispose();
  }

  void _scrollToCurrentChapter(String currentChapterUrl) {
    // Tìm index của chapter hiện tại
    final index =
        widget.chapterList.indexWhere((ch) => ch.url == currentChapterUrl);
    if (index != -1) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_chapterListScrollController.hasClients) {
          _chapterListScrollController.animateTo(
            index * 56.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    }
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
              Text(vm.errorMessage ?? 'Lỗi không xác định',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await vmRead.loadChapterContent(
                      widget.chapterUrl, widget.chapterName);
                },
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      // appBar: AppBar(
      //   title: Text(widget.chapterName),
      //   elevation: 0,
      // ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                /// CONTENT
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: vmRead.toggleBar,
                  child: SafeArea(
                      child: SingleChildScrollView(
                          controller: _contentScrollController,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text(
                                widget.chapterName,
                                style: Theme.of(context).textTheme.titleLarge,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              if (vm.chapterContent.isNotEmpty)
                                HtmlContent(htmlData: vm.chapterContent)
                              else
                                const Center(child: Text("không có nội dung"))
                            ],
                          ))),
                ),

                Align(
                  alignment: Alignment.bottomCenter,
                  child: AnimatedSlide(
                    offset: vm.isShowBar ? Offset.zero : const Offset(0, 1),
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    child: PlaySheetBottom(
                      chapterTitle: widget.chapterName,
                      scrollController: _contentScrollController,
                    ),
                  ),
                ),
              ],
            ),
      drawer: _buildChapterListDrawer(),
    );
  }

  Widget _buildChapterListDrawer() {
    final vm = ref.read(chapterViewModelProvider);
    final listChapter = vm.chapterList;

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            child: Text(
              widget.storyName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ),
          Expanded(
              child: Scrollbar(
                  interactive: true,
                  thumbVisibility: true,
                  thickness: 8,
                  controller: _chapterListScrollController,
                  child: ListView.builder(
                      key: const PageStorageKey('chapter_drawer_list'),
                      itemExtent: 56,
                      cacheExtent: 300,
                      controller: _chapterListScrollController,
                      itemCount: widget.chapterList.length,
                      itemBuilder: (context, index) {
                        final chapter = listChapter[index];
                        final isCurrentChapter =
                            vm.currentChapterUrl == chapter.url;
                        return ListTile(
                            title: Text(
                              chapter.name,
                              style: TextStyle(
                                fontWeight: isCurrentChapter
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color:
                                    isCurrentChapter ? Colors.brown[800] : null,
                              ),
                            ),
                            tileColor:
                                isCurrentChapter ? Colors.brown[50] : null,
                            onTap: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ChapterReaderScreen(
                                          storyName: widget.storyName,
                                          chapterUrl: chapter.url,
                                          chapterName: chapter.name,
                                          chapterList: listChapter)));
                            });
                      })))
        ],
      ),
    );
  }
}
