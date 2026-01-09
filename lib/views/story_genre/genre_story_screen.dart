import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../commons/skeleton_list.dart';
import '../commons/story_item.dart';
import '../story_detail_screen/story_detail_screen.dart';
import 'genre_story_viewmodel.dart';

class GenreStoryListScreen extends ConsumerStatefulWidget {
  final String genreUrl;
  final String genreName;

  const GenreStoryListScreen({super.key, required this.genreUrl, required this.genreName});

  @override
  ConsumerState<GenreStoryListScreen> createState() {
    return GenreStoryListScreenState();
  }
}

class GenreStoryListScreenState extends ConsumerState<GenreStoryListScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late ScrollController _scrollController;
  late Animation<double> _fadeAnimation;
  late final GenreStoryViewModelNotifier vmRead;
  final List<Color> gradientColors = [
    Colors.deepPurple,
    Colors.purple,
    Colors.pink,
    Colors.indigo,
    Colors.blue,
    Colors.teal,
    Colors.cyan,
    Colors.lightBlue,
  ];

  Color get genreColor {
    final hash = widget.genreName.hashCode;
    return gradientColors[hash.abs() % gradientColors.length];
  }

  @override
  void initState() {
    super.initState();
    vmRead = ref.read(genreStoryProvider.notifier);
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent - _scrollController.position.pixels <= 200) {
        vmRead.loadStories(widget.genreUrl);
      }
    });
    _animationController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    Future.microtask(() {
      vmRead.loadStories(widget.genreUrl);
    });
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(genreStoryProvider);
    final stories = ref.watch(genreStoryProvider.select((value) => value.listStory));
    // final List<Story> filteredStories =
    //     stories.where((story) => story.genreId.any((g) => g == widget.genreId)).toList();

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Consumer(
                    builder: (BuildContext context, WidgetRef ref, Widget? child) {
                      return Text(
                        widget.genreName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                  Text(
                    '${stories.length} truyện',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      genreColor,
                      genreColor.withValues(alpha: 0.8),
                      genreColor.withValues(alpha: 0.6),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Background pattern
                    Positioned(
                      top: 50,
                      right: 20,
                      child: Icon(Icons.category, size: 120, color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    Positioned(
                      bottom: 30,
                      left: 20,
                      child: Icon(Icons.auto_stories, size: 80, color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    // Floating particles effect
                    ...List.generate(8, (index) {
                      return Positioned(
                        top: 60 + (index * 20.0),
                        left: 30 + (index * 30.0) % 300,
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: () => ref.read(genreStoryProvider.notifier).loadStories(widget.genreUrl),
                ),
              ),
            ],
          ),

          // Loading or Content
          vm.isLoading
              ? const SliverToBoxAdapter(child: SkeletonList())
              : stories.isEmpty
                  ? SliverToBoxAdapter(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                'Không có truyện nào',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Thể loại "${widget.genreName}" chưa có truyện',
                                style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final story = stories[index];
                          return FadeTransition(
                            opacity: _fadeAnimation,
                            child: SlideTransition(
                              position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
                                CurvedAnimation(
                                  parent: _animationController,
                                  curve: Interval(index * 0.1, 1.0, curve: Curves.easeOutCubic),
                                ),
                              ),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => StoryDetailScreen(storyUrl: story.link)),
                                  );
                                },
                                child: StoryListItem(
                                  index: index,
                                  context: context,
                                  gradientColors: gradientColors,
                                  listGenre: vm.listGenre,
                                  story: story,
                                ),
                              ),
                            ),
                          );
                        }, childCount: stories.length),
                      ),
                    ),
        ],
      ),
    );
  }
}
