import 'package:flutter/material.dart';

/// Color tokens from the Pear List Figma file.
/// Names mirror the Figma variables (e.g. `surface/background` -> [background]).
abstract final class AppColors {
  // Surface
  static const Color background = Color(0xFFF8F5EE); // surface/background
  static const Color surfaceForeground = Color(0xFFFFFFFF); // surface/foreground
  static const Color surfacePrimaryLight = Color(0xFFDBEBDE); // surface/primary-light

  // Text
  static const Color headingBlack = Color(0xFF131514); // text/heading-black
  static const Color body1 = Color(0xFF373A38); // text/body-1
  static const Color body2 = Color(0xFF767877); // text/body-2
  static const Color textPrimary = Color(0xFF386641); // text/primary
  static const Color textOnButton = Color(0xFFFFFFFF); // text/button
  static const Color textDisable = Color(0xFFBCC0BD); // text/disable
  static const Color typographySecondary = Color(0xFF292F35); // typography/secundary

  // Buttons
  static const Color buttonBlack = Color(0xFF1A1A1A); // button/black/default
  static const Color buttonBlackDisable = Color(0xFFDCDFDD); // button/black/disable
  static const Color buttonPrimary = Color(0xFF386641); // button/primary/default
  static const Color buttonLink = Color(0xFF386641); // button/link/default

  // Borders
  static const Color borderGrayLight = Color(0xFFDCDFDD); // border/gray-light
  static const Color borderGrayDark = Color(0xFFA8ABA9); // border/gray-dark
  static const Color borderPrimary = Color(0xFF386641); // border/primary

  // Icons
  static const Color iconInactive = Color(0xFF919392); // unselected nav icons

  // Effects
  static const Color glassFill = Color(0x4DFFFFFF); // white 30% (glass buttons)
  static const Color shadowSoft = Color(0x1A000000); // black 10%, blur 32
  static const Color shadowSmall = Color(0x0F000000); // Drop Shadow-s, black 6%
  static const Color shadowMedium = Color(0x14000000); // Drop Shadow-m, black 8%
  static const Color shadowActionBar = Color(0x40000000); // black 25%, blur 10
  static const Color overlay = Color(0x59000000); // modal overlay, black 35%

  // Brand
  static const Color primary = Color(0xFF386641); // pear green
  static const Color primary50 = Color(0xFFDBEBDE); // primary/50
}
