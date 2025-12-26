import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainState {
  final int selectedIndex;

  const MainState({this.selectedIndex = 0});

  MainState copyWith({int? selectedIndex}) {
    return MainState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }
}

class MainVM extends StateNotifier<MainState> {
  MainVM() : super(const MainState());

  void changeTab(int index) {
    state = state.copyWith(selectedIndex: index);
  }
}

final mainProvider = StateNotifierProvider<MainVM, MainState>(
      (ref) => MainVM(),
);
