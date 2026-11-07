import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Text styles from the Pear List Figma file.
/// Headings use Lora, body text uses Inter Tight.
/// Figma letter spacing is in % of font size (2% of 16px = 0.32).
abstract final class AppTextStyles {
  /// "Pear List" title — Lora Medium 40.
  static TextStyle get displayTitle => GoogleFonts.lora(
        fontSize: 40,
        fontWeight: FontWeight.w500,
        color: AppColors.headingBlack,
      );

  /// Body 1/Medium — Inter Tight Medium 16 / 22, 2% tracking.
  static TextStyle get body1Medium => GoogleFonts.interTight(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 22 / 16,
        letterSpacing: 0.32,
        color: AppColors.headingBlack,
      );

  /// XS text/Regular — Inter Tight Regular 10 / 18, 3% tracking.
  static TextStyle get xsRegular => GoogleFonts.interTight(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        height: 18 / 10,
        letterSpacing: 0.3,
        color: AppColors.body2,
      );
}
