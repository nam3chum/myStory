import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html;
class HtmlContent extends StatelessWidget {
  final String htmlData;

  const HtmlContent({super.key, required this.htmlData});

  //
  // String extractText(String htmlContent) {
  //   final document = html.parse(htmlContent);
  //   return document.body?.text ?? '';
  // }

  String simulateReadingLayout(String htmlContent) {
    final doc = html.parse(htmlContent);
    final buffer = StringBuffer();

    void walk(dom.Node node) {
      if (node is dom.Text) {
        buffer.write(
          node.text.replaceAll('\u00A0', ' '),
        );
      }
      else if (node is dom.Element) {
        switch (node.localName) {
          case 'br':
            buffer.write('\n');
            break;

          case 'p':
          case 'div':
            buffer.write('\n\n');
            break;
        }

        for (final child in node.nodes) {
          walk(child);
        }

        if (node.localName == 'p' || node.localName == 'div') {
          buffer.write('\n\n');
        }
      }
    }

    doc.body?.nodes.forEach(walk);

    return _normalizeLayout(buffer.toString());
  }
  String _normalizeLayout(String input) {
    return input
        .replaceAll(RegExp(r'\n{3,}'), '\n\n') // max 2 newline
        .replaceAll(RegExp(r'[ \t]+\n'), '\n')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    final plainText = simulateReadingLayout(htmlData);

    return Text(
      plainText,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            height: 1.8,
          ),
      textAlign: TextAlign.justify,
    );
  }
}
