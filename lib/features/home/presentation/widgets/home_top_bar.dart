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
    this.title = 'Shopping list',
    this.hasUnread = false,
  });

  final String title;

  /// Green dot on the bell.
  final bool hasUnread;
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
              title,
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
            tooltip: hasUnread ? 'Notifications, unread' : 'Notifications',
            onPressed: onNotifications,
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                SvgPicture.asset(AppIcons.bell, width: 18, height: 18),
                if (hasUnread)
                  Positioned(
                    right: -1,
                    top: -1,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: const Color(0xFF45C188),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
