import 'package:flutter/material.dart';

class HtmlContent extends StatelessWidget {
  final String htmlData;

  const HtmlContent({super.key, required this.htmlData});

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
