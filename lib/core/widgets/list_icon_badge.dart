import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_assets.dart';
import '../theme/app_colors.dart';

/// 38px list icon: a white disc with an 18px icon on the blurred gradient
/// background (Figma: "List icon" / "Decorative background").
class ListIconBadge extends StatelessWidget {
  const ListIconBadge({super.key, this.icon = AppIcons.cart});

  /// SVG asset path of the 18px icon.
  final String icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 38,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(AppImages.listIconBackground, fit: BoxFit.cover),
            Center(
              child: Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceForeground,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppColors.shadowSoft, blurRadius: 32),
                  ],
                ),
                child: SvgPicture.asset(icon, width: 18, height: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
