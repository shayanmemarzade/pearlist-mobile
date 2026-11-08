import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_back_link.dart';
import '../../../core/widgets/glass_surface.dart';
import '../../../data/notifications.dart';
import '../../../data/pear_repository.dart';
import '../../invite/presentation/invitation_screens.dart';

/// Notification list (Figma section "Notification": empty 2602:42084,
/// all caught up 2613:42325, filled 2613:42444, menu 2625:42853).
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

enum _Filter { all, unread }

enum _MenuAction { markAllRead, clearAll }

class _NotificationsScreenState extends State<NotificationsScreen> {
  _Filter _filter = _Filter.all;

  Future<void> _openMenu(BuildContext buttonContext) async {
    final repo = PearScope.read(context);
    final box = buttonContext.findRenderObject()! as RenderBox;
    final overlay =
        Overlay.of(buttonContext).context.findRenderObject()! as RenderBox;
    final topLeft = box.localToGlobal(Offset(0, box.size.height + 4),
        ancestor: overlay);
    final action = await showMenu<_MenuAction>(
      context: context,
      color: AppColors.surfaceForeground,
      elevation: 4,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      position: RelativeRect.fromLTRB(
        topLeft.dx,
        topLeft.dy,
        overlay.size.width - topLeft.dx - box.size.width,
        0,
      ),
      items: [
        PopupMenuItem(
          value: _MenuAction.markAllRead,
          enabled: repo.unreadCount > 0,
          child: Text('Mark all as read', style: AppTextStyles.body1Regular),
        ),
        PopupMenuItem(
          value: _MenuAction.clearAll,
          enabled: repo.notifications.isNotEmpty,
          child: Text(
            'Clear all notifications',
            style: AppTextStyles.body1Regular,
          ),
        ),
      ],
    );
    switch (action) {
      case _MenuAction.markAllRead:
        repo.markAllNotificationsRead();
      case _MenuAction.clearAll:
        repo.clearNotifications();
      case null:
        break;
    }
  }

  void _open(AppNotification n) {
    final repo = PearScope.read(context);
    repo.markNotificationRead(n.id);
    final invite = n.invite;
    if (invite != null) {
      openIncomingInvite(context, invite, signedIn: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = PearScope.of(context);
    final all = repo.notifications;
    final shown = _filter == _Filter.all
        ? all
        : all.where((n) => !n.read).toList();
    final partner = repo.connections.firstOrNull?.firstName;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppBackLink(label: 'Home'),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 38,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Notification',
                              style: AppTextStyles.titleBold
                                  .copyWith(color: AppColors.headingBlack),
                            ),
                          ),
                          Builder(
                            builder: (buttonContext) => GlassIconButton(
                              tooltip: 'More',
                              onPressed: () => _openMenu(buttonContext),
                              icon: SvgPicture.asset(
                                AppIcons.more,
                                width: 18,
                                height: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _FilterTabs(
                      value: _filter,
                      unread: repo.unreadCount,
                      onChanged: (f) => setState(() => _filter = f),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: shown.isEmpty
                    ? _Empty(
                        caughtUp: _filter == _Filter.unread && all.isNotEmpty,
                        partnerName: partner,
                      )
                    : ListView.separated(
                        padding: EdgeInsets.fromLTRB(
                          16,
                          16,
                          16,
                          MediaQuery.viewPaddingOf(context).bottom + 24,
                        ),
                        itemCount: shown.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 4),
                        itemBuilder: (context, i) => _NotificationTile(
                          notification: shown[i],
                          onTap: () => _open(shown[i]),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterTabs extends StatelessWidget {
  const _FilterTabs({
    required this.value,
    required this.unread,
    required this.onChanged,
  });

  final _Filter value;
  final int unread;
  final ValueChanged<_Filter> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget tab(_Filter filter, String label, {int? count}) {
      final selected = filter == value;
      return Semantics(
        button: true,
        selected: selected,
        child: GestureDetector(
          onTap: () => onChanged(filter),
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: selected ? AppColors.surfacePrimaryLight : null,
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppTextStyles.body2Medium.copyWith(
                    color: selected ? AppColors.textPrimary : AppColors.body2,
                  ),
                ),
                if (count != null && count > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    constraints: const BoxConstraints(minWidth: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceForeground,
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      border: Border.all(color: AppColors.borderGrayLight),
                    ),
                    child: Text(
                      '$count',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.smallMedium
                          .copyWith(color: AppColors.body1),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          color: AppColors.surfaceForeground,
          borderRadius: BorderRadius.all(Radius.circular(14)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            tab(_Filter.all, 'All', count: unread),
            const SizedBox(width: 4),
            tab(_Filter.unread, 'Unread'),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  /// "5m", "1h", "2d".
  static String _shortAge(DateTime at) {
    final age = DateTime.now().difference(at);
    if (age.inMinutes < 1) return 'now';
    if (age.inHours < 1) return '${age.inMinutes}m';
    if (age.inDays < 1) return '${age.inHours}h';
    if (age.inDays < 7) return '${age.inDays}d';
    return '${age.inDays ~/ 7}w';
  }

  @override
  Widget build(BuildContext context) {
    final n = notification;
    final actor = n.actor;
    final unread = !n.read;

    final Widget leading = n.type == NotificationType.invite && actor != null
        ? AppAvatar(name: actor.name, imageUrl: actor.avatarUrl)
        : Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surfaceForeground,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderGrayLight),
            ),
            child: SvgPicture.asset(
              switch (n.type) {
                NotificationType.wishBought => AppIcons.notifGift,
                NotificationType.added => AppIcons.plusGreen,
                _ => AppIcons.notifCheck,
              },
              width: 18,
              height: 18,
            ),
          );

    return Semantics(
      button: true,
      label: unread ? 'Unread' : null,
      child: Material(
        color: unread ? AppColors.surfaceForeground : Colors.transparent,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                leading,
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(n.title, style: AppTextStyles.body1Medium),
                      const SizedBox(height: 2),
                      Text(n.body, style: AppTextStyles.body2Regular),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _shortAge(n.at),
                      style: AppTextStyles.body2Regular,
                    ),
                    if (unread) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF45C188),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.caughtUp, required this.partnerName});

  /// "You're all caught up" (Unread tab) vs "No notifications yet".
  final bool caughtUp;
  final String? partnerName;

  @override
  Widget build(BuildContext context) {
    final partner = partnerName ?? 'your partner';
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              AppImages.emptyNotifications,
              width: 156,
              height: 124,
            ),
            const SizedBox(height: 24),
            Text(
              caughtUp ? 'You’re all caught up' : 'No notifications yet',
              style: AppTextStyles.heading3Bold,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              caughtUp
                  ? 'No unread notifications. We’ll let you know when '
                      '$partner adds something or someone invites you.'
                  : 'When someone invites you to a list or $partner adds '
                      'items, you’ll see it here.',
              textAlign: TextAlign.center,
              style:
                  AppTextStyles.body1Regular.copyWith(color: AppColors.body2),
            ),
          ],
        ),
      ),
    );
  }
}
