import 'package:flutter/material.dart';

enum ViewMode { list, grid1, grid2, grid3 }

String themeModeToText(ThemeMode mode) {
  switch (mode) {
    case ThemeMode.light:
      return "Sáng";
    case ThemeMode.dark:
      return "Tối";
    case ThemeMode.system:
    return "Theo hệ thống";
  }
}
