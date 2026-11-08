import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_toggle.dart';
import '../../../data/pear_repository.dart';
import 'profile_widgets.dart';

/// Push notification switches (Figma "Notification", 2269:6726). Changes
/// apply right away.
class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = PearScope.of(context);
    final prefs = repo.notificationPrefs;
    final partner = repo.connections.firstOrNull?.firstName ?? 'your partner';

    Widget row(String title, String subtitle, bool value,
            ValueChanged<bool> onChanged) =>
        MergeSemantics(
          child: GestureDetector(
            onTap: () => onChanged(!value),
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTextStyles.body1Medium),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppTextStyles.body2Regular
                            .copyWith(color: AppColors.typographyQuaternary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                AppToggle(value: value, onChanged: onChanged, large: true),
              ],
            ),
          ),
        );

    return ProfilePage(
      title: 'Notification',
      description: 'Choose what’s worth a buzz. You’ll always see '
          'changes when you open the app.',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProfileCard(
            children: [
              row(
                'Partner adds an item',
                'When $partner adds something to a shared list',
                prefs.partnerAdds,
                (v) => repo.setNotificationPrefs(prefs.copyWith(partnerAdds: v)),
              ),
              row(
                'Partner completes an item',
                'When $partner checks off an item or marks a wish bought',
                prefs.partnerCompletes,
                (v) => repo
                    .setNotificationPrefs(prefs.copyWith(partnerCompletes: v)),
              ),
              row(
                'Shared list invitation',
                'When someone invites you to a list or accepts your invite',
                prefs.invitations,
                (v) =>
                    repo.setNotificationPrefs(prefs.copyWith(invitations: v)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Turn off all Pear List notifications in your phone’s '
            'Settings.',
            style: AppTextStyles.smallRegular,
          ),
        ],
      ),
    );
  }
}
