import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_surface.dart';

/// Title row of the Figma "Top Bar" (Title with actions). The system status
/// bar above it is the real one, handled by SafeArea.
class HomeTopBar extends StatelessWidget {
  const HomeTopBar({
    super.key,
    required this.onProfile,
    required this.onNotifications,
  });

  final VoidCallback onProfile;
  final VoidCallback onNotifications;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Shopping list',
              style: AppTextStyles.heading3Bold,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GlassIconButton(
            tooltip: 'Profile',
            onPressed: onProfile,
            icon: SvgPicture.asset(AppIcons.user, width: 18, height: 18),
          ),
          const SizedBox(width: 8),
          GlassIconButton(
            tooltip: 'Notifications',
            onPressed: onNotifications,
            icon: SvgPicture.asset(AppIcons.bell, width: 18, height: 18),
          ),
        ],
      ),
    );
  }
}
