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

  /// Heading 3/Bold — Lora Bold 24.
  static TextStyle get heading3Bold => GoogleFonts.lora(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.headingBlack,
      );

  /// Title/Bold — Inter Tight Bold 18 / 24 (sheet titles).
  static TextStyle get titleBold => GoogleFonts.interTight(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 24 / 18,
        color: AppColors.typographySecondary,
      );

  /// Body 1/Regular — Inter Tight Regular 16 / 22, 2% tracking.
  static TextStyle get body1Regular => GoogleFonts.interTight(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 22 / 16,
        letterSpacing: 0.32,
        color: AppColors.headingBlack,
      );

  /// Body 1/Bold — Inter Tight Bold 16 / 22, 2% tracking.
  static TextStyle get body1Bold => GoogleFonts.interTight(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 22 / 16,
        letterSpacing: 0.32,
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

  /// Body 2/Regular — Inter Tight Regular 14 / 20, 2% tracking.
  static TextStyle get body2Regular => GoogleFonts.interTight(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
        letterSpacing: 0.28,
        color: AppColors.body2,
      );

  /// Body 2/Medium — Inter Tight Medium 14 / 20, 2% tracking.
  static TextStyle get body2Medium => GoogleFonts.interTight(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 20 / 14,
        letterSpacing: 0.28,
        color: AppColors.headingBlack,
      );

  /// Body 2/Semi Bold — Inter Tight SemiBold 14 / 18, 2% tracking.
  static TextStyle get body2SemiBold => GoogleFonts.interTight(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 18 / 14,
        letterSpacing: 0.28,
        color: AppColors.headingBlack,
      );

  /// Small text/Regular — Inter Tight Regular 12 / 18, 3% tracking.
  static TextStyle get smallRegular => GoogleFonts.interTight(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 18 / 12,
        letterSpacing: 0.36,
        color: AppColors.body2,
      );

  /// XS text/Regular — Inter Tight Regular 10 / 18, 3% tracking.
  static TextStyle get xsRegular => GoogleFonts.interTight(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        height: 18 / 10,
        letterSpacing: 0.3,
        color: AppColors.body2,
      );

  /// XS text/Medium — Inter Tight Medium 10 / 18, 3% tracking.
  static TextStyle get xsMedium => GoogleFonts.interTight(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        height: 18 / 10,
        letterSpacing: 0.3,
        color: AppColors.headingBlack,
      );
}
