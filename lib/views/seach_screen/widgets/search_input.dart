import 'package:flutter/material.dart';

class SearchInput extends StatelessWidget {
  final ValueChanged<String> onSubmit;

  const SearchInput({
    super.key,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      
      decoration: const InputDecoration(
        hintText: 'Nhập từ khóa tìm kiếm',
        prefixIcon: Icon(Icons.search),
        border:OutlineInputBorder(borderRadius:BorderRadius.all(Radius.circular(15))
        ),
      ),
      textInputAction: TextInputAction.search,
      onSubmitted: onSubmit,
    );
  }
}
