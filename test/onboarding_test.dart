import 'package:flutter_test/flutter_test.dart';
import 'package:pear_list/core/utils/phone_format.dart';
import 'package:pear_list/data/auth_service.dart';
import 'package:pear_list/data/invites.dart';
import 'package:pear_list/data/models.dart';
import 'package:pear_list/data/sample_data.dart';

void main() {
  group('US phone numbers', () {
    test('validates 10-digit NANP numbers', () {
      expect(isValidUsPhone('(415) 555-0132'), isTrue);
      expect(isValidUsPhone('+1 415 555 0132'), isTrue);
      expect(isValidUsPhone('415555013'), isFalse); // 9 digits
      expect(isValidUsPhone('(015) 555-0132'), isFalse); // area code 0
      expect(isValidUsPhone('(415) 155-0132'), isFalse); // exchange 1
    });

    test('formats partial and full input', () {
      expect(formatUsPhone(''), '');
      expect(formatUsPhone('41'), '(41');
      expect(formatUsPhone('41555'), '(415) 55');
      expect(formatUsPhone('4155550132'), '(415) 555-0132');
      expect(formatUsPhoneInternational('4155550132'), '+1 (415) 555-0132');
    });

    test('input formatter formats while typing and handles backspace', () {
      const f = UsPhoneInputFormatter();
      final typed = f.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: '4155550'),
      );
      expect(typed.text, '(415) 555-0');

      // Backspace over the "-" removes the digit before it too.
      final deleted = f.formatEditUpdate(
        const TextEditingValue(text: '(415) 555-'),
        const TextEditingValue(text: '(415) 555'),
      );
      expect(deleted.text, '(415) 55');
    });

    test('email check', () {
      expect(looksLikeEmail('sam@gmail.com'), isTrue);
      expect(looksLikeEmail('sam@gmail'), isFalse);
      expect(looksLikeEmail('sam gmail.com'), isFalse);
    });
  });

  test('mock auth accepts any 4-digit code but 0000', () async {
    const auth = MockAuthService();
    expect(await auth.verifyCode('4155550132', '1234'), isTrue);
    expect(await auth.verifyCode('4155550132', '0000'), isFalse);
    expect(await auth.verifyCode('4155550132', '123'), isFalse);
  });

  group('invites', () {
    test('free plan saves invites until upgrading', () {
      final repo = SampleData.repository(SampleState.privateOnly);
      expect(repo.isPro, isFalse);

      final sent = repo.sendInvites(
        const [InviteTarget(address: 'sam@gmail.com')],
        {ListKind.shopping},
      );
      expect(sent.single.status, InviteStatus.awaitingUpgrade);

      repo.upgradeToPro();
      expect(repo.isPro, isTrue);
      expect(repo.invites.single.status, InviteStatus.sent);
    });

    test('Pro sends right away and stops at the limit', () {
      final repo = SampleData.repository(SampleState.shared);
      expect(repo.isPro, isTrue);
      final targets = [
        for (var i = 0; i < kProInviteLimit + 2; i++)
          InviteTarget(name: 'P$i', address: '(415) 555-01$i$i'),
      ];
      final left = repo.invitesLeft; // The sample already invited Lena.
      final sent = repo.sendInvites(targets, {...ListKind.values});
      expect(sent, hasLength(left));
      expect(sent.every((i) => i.status == InviteStatus.sent), isTrue);
      expect(repo.invitesLeft, 0);
      expect(repo.sendInvites(targets, {ListKind.shopping}), isEmpty);
    });

    test('accepting an invitation adds the shared lists', () {
      final repo = SampleData.repository(SampleState.privateOnly);
      final before = repo.lists.length;
      repo.acceptInvite(SampleData.samInvite);
      final added = repo.lists.skip(before).toList();
      expect(added, hasLength(3));
      expect(added.every((l) => l.shared && l.owner.id == 'sam'), isTrue);
    });
  });

  test('sign-up saves the profile and favourite stores', () {
    final repo = SampleData.repository(SampleState.privateOnly);
    repo
      ..updateProfile(name: 'Mia', email: 'mia@mail.com')
      ..setFavoriteStores(['Costco', 'Walmart']);
    expect(repo.me.name, 'Mia');
    expect(repo.me.email, 'mia@mail.com');
    expect(repo.homeList!.stores, ['Costco', 'Walmart']);

    repo.updateProfile(email: '');
    expect(repo.me.email, isNull);
  });
}
