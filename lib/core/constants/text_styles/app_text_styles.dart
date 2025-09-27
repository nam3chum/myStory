import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../views/settings_screen/setting_viewmodel.dart';

class AppTextStyles {
  static TextStyle body({
    required BuildContext context,
    required WidgetRef ref,
    double opacity = 1,
    double? fontSize,
  }) {
    final sizeOfText = fontSize ?? ref.watch(settingsProvider.select((value) => value.fontSize));
    final color = Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: opacity) ?? Colors.black;
    final fontFamily = ref.watch(settingsProvider.select((value) => value.fontFamily));
    return TextStyle(fontSize: sizeOfText, color: color, fontFamily: fontFamily);
  }

  static TextStyle title({required BuildContext context, required WidgetRef ref}) {
    final fontSize = ref.watch(settingsProvider.select((value) => value.fontSize));
    final fontFamily = ref.watch(settingsProvider.select((value) => value.fontFamily));
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize + 4,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }
}
