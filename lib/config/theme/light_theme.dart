import 'package:flutter/material.dart';

class LightTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.white,
    ),
    useMaterial3: true,
  );
  // final ThemeData lightTheme = ThemeData(
  //   brightness: Brightness.light,
  //   primaryColor: Colors.blue,
  //   textTheme: const TextTheme(
  //     bodyLarge: TextStyle(color: Colors.black),
  //   ),
  // );
}
