import 'package:flutter/material.dart';

class ThemeController extends ValueNotifier<bool> {
  ThemeController() : super(false);

  bool get isDark => value;

  void toggleTheme() {
    value = !value;
  }
}

final ThemeController themeController = ThemeController();