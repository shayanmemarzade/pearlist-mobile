import 'invites.dart';
import 'models.dart';

/// What a notification is about; decides its icon and what tapping does.
enum NotificationType {
  /// Someone invited you to their lists (opens the invitation).
  invite,

  /// A partner checked items off.
  completed,

  /// A wish on your list was bought (the buyer stays secret).
  wishBought,

  /// A partner added something.
  added,
}

/// One entry on the Notification page (Figma section "Notification").
class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.at,
    this.actor,
    this.read = false,
    this.invite,
  });

  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime at;

  /// Shown as an avatar (invites); other types show an icon.
  final Person? actor;
  final bool read;

  /// For [NotificationType.invite].
  final IncomingInvite? invite;

  AppNotification copyWith({bool? read}) => AppNotification(
        id: id,
        type: type,
        title: title,
        body: body,
        at: at,
        actor: actor,
        read: read ?? this.read,
        invite: invite,
      );
}
