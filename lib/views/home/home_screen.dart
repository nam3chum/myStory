import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mystory/views/settings_screen/setting_viewmodel.dart';

import '../../core/constants/enums/view_type.dart';
import '../../core/constants/text_styles/app_text_styles.dart';
import '../bookshelf_screen/bookshelf_screen.dart';
import '../commons/skeleton_list.dart';
import '../commons/story_grid_item.dart';
import '../commons/story_item.dart';
import '../settings_screen/setting_screen.dart';
import '../story_detail_screen/story_detail_screen.dart';
import '../story_genre/genre_story_screen.dart';
import 'home_viewmodel.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends ConsumerState<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late List<String> moreButtonOptions;
  late final HomeViewModel vmRead;
  final List<Color> gradientColors = [
    Colors.deepPurple,
    Colors.purple,
    Colors.pink,
    Colors.indigo,
    Colors.blue,
    Colors.teal,
  ];

  @override
  void initState() {
    super.initState();
    vmRead = ref.read(homeProvider.notifier);
    _animationController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
    Future.microtask(() async {
      await vmRead.loadStories();
      await vmRead.getViewMode();
    });
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(homeProvider);

    ref.listen<HomeState>(homeProvider, (prev, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(next.errorMessage.toString())));
      }
    });

    moreButtonOptions = HomeViewModel.menuOptions;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            // expandedHeight: 200,
            floating: true,
            //pinned: true,
            snap: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.deepPurple.shade400, Colors.purple.shade300, Colors.pink.shade300],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 50,
                      right: 20,
                      child: Icon(Icons.auto_stories, size: 100, color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 20,
                      child: Icon(Icons.book, size: 80, color: Colors.white.withValues(alpha: 0.1)),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(onPressed: () => _showMenuBottomSheet(), icon: Icon(Icons.sort)),
              PopupMenuButton<String>(
                onSelected: (choice) {
                  if (choice == HomeViewModel.menuOptions[1]) {
                    // "Kệ sách cá nhân"
                    Navigator.push(context, MaterialPageRoute(builder: (context) => BookshelfScreen()));
                  } else if (choice == HomeViewModel.menuOptions[2]) {
                    // "Thiết lập"
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingScreen()));
                  }
                },
                itemBuilder: (_) {
                  return moreButtonOptions.map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                  }).toList();
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                  children: []
              ),
            ),
          ),
          vm.isLoading
              ? const SliverToBoxAdapter(child: Center(child: SkeletonItem()))
              : SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: Builder(
              builder: (context) {
                switch (vm.viewType) {
                  case ViewType.list:
                    return SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final story = vm.stories[index];
                        return FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero).animate(
                              CurvedAnimation(
                                parent: _animationController,
                                curve: Interval(index * 0.1, 1.0, curve: Curves.easeOutCubic),
                              ),
                            ),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => StoryDetailPage(id: story.id)),
                                );
                              },
                              child: StoryListItem(
                                index: index,
                                context: context,
                                gradientColors: gradientColors,
                                listGenre: vm.genres,
                                story: story,
                              ),
                            ),
                          ),
                        );
                      }, childCount: vm.stories.length),
                    );
                  case ViewType.grid1:
                    return SliverGrid(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final story = vm.stories[index];
                        return FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero).animate(
                              CurvedAnimation(
                                parent: _animationController,
                                curve: Interval(index * 0.1, 1.0, curve: Curves.easeOutCubic),
                              ),
                            ),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => StoryDetailPage(id: story.id)),
                                );
                              },
                              child: StoryGridItem(
                                fontSize: ref.watch(settingsProvider).fontSize,
                                listGenre: vm.genres,
                                story: story,
                                accentColor: gradientColors.first,
                              ),
                            ),
                          ),
                        );
                      }, childCount: vm.stories.length),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.7,
                      ),
                    );
                  case ViewType.grid2:
                  // TODO: Handle this case.
                    throw UnimplementedError();
                  case ViewType.grid3:
                  // TODO: Handle this case.
                    throw UnimplementedError();
                }
              },
            ),
          ),
        ],
      ),
      drawer: _buildEnhancedDrawer(),

    );
  }

  void _showMenuBottomSheet() {
    final vm = ref.read(homeProvider.notifier);
    final value = ref.watch(homeProvider);
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      sheetAnimationStyle: AnimationStyle(curve: Curves.easeInOut),
      context: context,
      isDismissible: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Theme
                  .of(context)
                  .cardColor,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Text('Cài đặt'),
                SizedBox(height: 25),
                ListTile(
                  title: Text(
                    "Sắp xếp kệ",
                    style: AppTextStyles.body(context: context, fontSize: 12, ref: ref),
                  ),
                  trailing: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.view_list_rounded, size: 15),
                        color: value.viewType == ViewType.list ? Colors.blue : Colors.grey,
                        tooltip: "Hiển thị dạng danh sách",
                        onPressed: () async{
                          await vm.setViewMode(ViewType.list);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.grid_view, size: 15),
                        color: value.viewType == ViewType.grid1 ? Colors.blue : Colors.grey,
                        tooltip: "Hiển thị dạng lưới 1",
                        onPressed: () async {
                         await vm.setViewMode(ViewType.grid1);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.grid_3x3, size: 15),
                        color: value.viewType == ViewType.grid2 ? Colors.blue : Colors.grey,
                        tooltip: "Hiển thị dạng lưới 2",
                        onPressed: () async{
                         await vm.setViewMode(ViewType.grid2);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.grid_on_outlined, size: 15),
                        color: value.viewType == ViewType.grid3 ? Colors.blue : Colors.grey,
                        tooltip: "Hiển thị dạng lưới 3",
                        onPressed: () async {
                         await vm.setViewMode(ViewType.grid3);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedDrawer() {
    final vm = ref.watch(homeProvider);
    final fontFamily = ref.watch(settingsProvider).fontFamily;
    return Drawer(
      child: Column(
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.deepPurple.shade400, Colors.purple.shade300],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.category, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Text('Thể loại', style: AppTextStyles.title(context: context, ref: ref)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Khám phá ${vm.stories.length} thể loại',
                      style: AppTextStyles.body(context: context, opacity: 0.8, ref: ref),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: vm.stories.length,
              itemBuilder: (context, index) {
                final genre = vm.genres[index];
                final isSelected = vm.selectedSlug == genre.id;
                final color = gradientColors[index % gradientColors.length];

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
                    border: isSelected ? Border.all(color: color, width: 2) : null,
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.bookmark, color: color, size: 20),
                    ),
                    title: Text(
                      genre.name,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? color : Colors.grey[800],
                        fontSize: 16,
                        fontFamily: fontFamily,
                      ),
                    ),
                    trailing:
                    isSelected
                        ? Icon(Icons.check_circle, color: color)
                        : Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    onTap: () {
                      vmRead.selectGenre(genre.id);
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GenreStoryListScreen(genreName: genre.name, genreId: genre.id),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

