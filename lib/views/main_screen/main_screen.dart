// app/main_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mystory/views/bookshelf_screen/bookshelf_screen.dart';
import 'package:mystory/views/home/home_screen.dart';
import 'package:mystory/views/main_screen/main_viewmodel.dart';
import 'package:mystory/views/settings_screen/setting_screen.dart';


class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mainProvider);
    final vm = ref.read(mainProvider.notifier);

    final pages = [
      const HomeScreen(),
      const BookshelfScreen(),
      const SettingScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: state.selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        indicatorColor: Colors.blue,
        elevation: 120,
        height: 60,
        selectedIndex: state.selectedIndex,
        onDestinationSelected: vm.changeTab,
        labelPadding: EdgeInsets.only(top: 0),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: "Trang chủ"),
          NavigationDestination(icon: Icon(Icons.menu_book_sharp), label: "Kệ sách"),
          NavigationDestination(icon: Icon(Icons.settings), label: "Cài đặt"),
        ],
      ),
    );
  }
}
