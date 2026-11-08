import 'package:flutter/material.dart';

/// Color tokens from the Pear List Figma file.
/// Names mirror the Figma variables (e.g. `surface/background` -> [background]).
abstract final class AppColors {
  // Surface
  static const Color background = Color(0xFFF8F5EE); // surface/background
  static const Color surfaceForeground = Color(0xFFFFFFFF); // surface/foreground
  static const Color surfacePrimaryLight = Color(0xFFDBEBDE); // surface/primary-light
  static const Color surfaceGray = Color(0xFFF4F5F5); // surface/gray
  static const Color warning50 = Color(0xFFFFF7E6); // warning/50
  static const Color secondary100 = Color(0xFFF8ECDF); // secondary/100
  static const Color primary200 = Color(0xFF9AB69F); // primary/200
  static const Color toastFill = Color(0xE6DBEBDE); // primary-light 90%
  static const Color badgeGrayText = Color(0xFF404040);

  // Text
  static const Color headingBlack = Color(0xFF131514); // text/heading-black
  static const Color body1 = Color(0xFF373A38); // text/body-1
  static const Color body2 = Color(0xFF767877); // text/body-2
  static const Color textPrimary = Color(0xFF386641); // text/primary
  static const Color textOnButton = Color(0xFFFFFFFF); // text/button
  static const Color textDisable = Color(0xFFBCC0BD); // text/disable
  static const Color typographySecondary = Color(0xFF292F35); // typography/secundary
  static const Color typographyTertiary = Color(0xFF4D5660); // typography/tertiary
  static const Color typographyQuaternary = Color(0xFF7E8994); // typography/quatenary
  static const Color textWarning = Color(0xFFD46B08); // text/warning
  static const Color error = Color(0xFF902922); // error/700, icon/error

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

  // Onboarding, invites and paywall
  static const Color errorBorder = Color(0xFFF1483C); // error/500, invalid input
  static const Color orDivider = Color(0xFFC9C9C9); // "or" between options
  static const Color invitationGreen = Color(0xFF223D27); // invitation tab
  static const Color paywallBackground = Color(0xFF16291A);
  static const Color gold = Color(0xFFDDA05F); // paywall ticks, "together"
  static const Color sage = Color(0xFF799B80); // backdrop ellipses
  static const Color sand = Color(0xFFEBC69F); // backdrop ellipse
  static const Color umber = Color(0xFF8B643B); // paywall backdrop ellipse
}
