import 'models.dart';

/// How many people one Pro subscription can invite (Figma paywall:
/// "Invite up to 4 people").
const int kProInviteLimit = 4;

enum InviteStatus {
  /// Saved on the free plan; sent once the user upgrades.
  awaitingUpgrade,

  /// Text/email sent, waiting for the person to sign up.
  sent,

  /// The person signed up and is a member now.
  joined,
}

/// Someone to invite: typed in by hand (only [address]) or picked from
/// contacts (with a [name]).
class InviteTarget {
  const InviteTarget({required this.address, this.name});

  /// Email or phone number.
  final String address;
  final String? name;
}

/// An invite the user sent.
class Invite {
  const Invite({
    required this.id,
    required this.address,
    required this.lists,
    required this.status,
    required this.sentAt,
    this.name,
  });

  final String id;
  final String? name;

  /// Email or phone number the invite went to.
  final String address;
  final Set<ListKind> lists;
  final InviteStatus status;
  final DateTime sentAt;

  /// Name if known, otherwise the email/phone.
  String get displayName => name ?? address;

  Invite copyWith({InviteStatus? status}) => Invite(
        id: id,
        name: name,
        address: address,
        lists: lists,
        status: status ?? this.status,
        sentAt: sentAt,
      );
}

/// An invite someone else sent to this user (Figma: "Invitation").
class IncomingInvite {
  const IncomingInvite({
    required this.id,
    required this.from,
    required this.lists,
    this.valid = true,
  });

  final String id;
  final Person from;

  /// The lists the inviter turned on.
  final Set<ListKind> lists;

  /// False when it expired or was cancelled ("Invite no longer valid").
  final bool valid;
}
