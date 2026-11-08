import 'package:flutter_test/flutter_test.dart';
import 'package:pear_list/data/invites.dart';
import 'package:pear_list/data/preferences.dart';
import 'package:pear_list/data/sample_data.dart';
import 'package:pear_list/features/profile/presentation/profile_screen.dart';

void main() {
  group('connections', () {
    test('shared sample: Sam joined, Lena pending', () {
      final repo = SampleData.repository(SampleState.shared);
      expect(repo.connections.map((p) => p.firstName), ['Sam']);
      expect(repo.pendingInvites.map((i) => i.displayName), ['Lena']);
    });

    test('removing a partner takes them off every shared list', () {
      final repo = SampleData.repository(SampleState.shared);
      repo.removeConnection('sam');
      expect(repo.connections, isEmpty);
      expect(repo.partner, isNull);
      expect(
        repo.lists.every((l) => l.members.every((p) => p.id != 'sam')),
        isTrue,
      );
    });

    test('cancelling an invite frees a spot', () {
      final repo = SampleData.repository(SampleState.shared);
      final before = repo.invitesLeft;
      repo.cancelInvite('invite-lena');
      expect(repo.pendingInvites, isEmpty);
      expect(repo.invitesLeft, before + 1);
    });
  });

  group('notifications', () {
    test('read state and clearing', () {
      final repo = SampleData.repository(SampleState.shared);
      expect(repo.unreadCount, 1);
      repo.markNotificationRead('n1');
      expect(repo.unreadCount, 0);
      repo.clearNotifications();
      expect(repo.notifications, isEmpty);
    });

    test('the invite notification carries the list summaries', () {
      final repo = SampleData.repository(SampleState.shared);
      final invite = repo.notifications.first.invite!;
      expect(invite.summaries.length, 3);
    });
  });

  group('settings', () {
    test('notification switches count', () {
      const prefs = NotificationPrefs();
      expect(prefs.enabledCount, 3);
      expect(prefs.copyWith(invitations: false).enabledCount, 2);
    });

    test('plan label follows the subscription', () {
      final repo = SampleData.repository(SampleState.privateOnly);
      expect(planLabel(repo), 'Free');
      repo.upgradeToPro(billing: ProBilling.monthly);
      expect(planLabel(repo), 'Pro · monthly');
      repo.cancelPro();
      expect(repo.billing, isNull);
    });

    test('phone and email updates', () {
      final repo = SampleData.repository(SampleState.shared);
      repo.updateProfile(phone: '6285550102', email: 'new@mail.com');
      expect(repo.me.phone, '6285550102');
      expect(repo.me.email, 'new@mail.com');
      expect(repo.me.name, 'Olivia Rhye');
    });

    test('sent invites keep counting toward the limit', () {
      final repo = SampleData.repository(SampleState.shared);
      expect(repo.invitesLeft, kProInviteLimit - 1);
    });
  });
}
