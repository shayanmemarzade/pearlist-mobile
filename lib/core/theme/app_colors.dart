import 'package:flutter/material.dart';

/// Color tokens from the Pear List Figma file.
/// Names mirror the Figma variables (e.g. `surface/background` -> [background]).
abstract final class AppColors {
  // Surface
  static const Color background = Color(0xFFF8F5EE); // surface/background

  // Text
  static const Color headingBlack = Color(0xFF131514); // text/heading-black
  static const Color body2 = Color(0xFF767877); // text/body-2
  static const Color textOnButton = Color(0xFFFFFFFF); // text/button

  // Buttons
  static const Color buttonBlack = Color(0xFF1A1A1A); // button/black/default

  // Brand
  static const Color primary = Color(0xFF386641); // pear green
  static const Color primary50 = Color(0xFFDBEBDE); // primary/50
}
