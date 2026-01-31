import 'package:flutter/material.dart';

class SearchInput extends StatefulWidget {
  final ValueChanged<String> onSubmit;

  const SearchInput({
    super.key,
    required this.onSubmit,
  });

  @override
  State<SearchInput> createState() => _SearchInputState();
}

class _SearchInputState extends State<SearchInput> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: 'Nhập truyện cần tìm',
        prefixIcon: const Icon(Icons.search),
        border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(25))),
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            // Xóa nội dung tìm kiếm khi nhấn vào nút "X"
            controller.clear();
          },
        ),
      ),
      textInputAction: TextInputAction.search,
      onSubmitted: widget.onSubmit,
    );
  }
}
