import 'package:flutter/material.dart';

class StoryDetailMenu extends StatelessWidget {
  final List<PopupMenuEntry<String>> menuItems;
  final void Function(String) onSelected;

  const StoryDetailMenu({required this.menuItems, required this.onSelected, super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: onSelected,
      itemBuilder: (BuildContext context) => menuItems,
    );
  }
}
