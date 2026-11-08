import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Outside links used by the Profile page.
// TODO: replace the placeholder addresses with the real ones.
abstract final class AppLinks {
  static const String supportEmail = 'support@pearlist.app';
  static final Uri terms = Uri.https('pearlist.app', '/terms');
  static final Uri privacy = Uri.https('pearlist.app', '/privacy');
  static final Uri storeListing = Uri.https(
    'play.google.com',
    '/store/apps/details',
    {'id': 'com.pearlist.pear_list'},
  );
  static final Uri storeSubscriptions =
      Uri.https('play.google.com', '/store/account/subscriptions');

  static Uri supportMail({String subject = 'Pear List support'}) =>
      Uri(scheme: 'mailto', path: supportEmail, query: 'subject=$subject');
}

/// Opens [uri] outside the app; shows a short message if nothing can.
Future<void> launchExternal(BuildContext context, Uri uri) async {
  final messenger = ScaffoldMessenger.of(context);
  var opened = false;
  try {
    opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
  } on Exception {
    opened = false;
  }
  if (!opened) {
    messenger.showSnackBar(
      const SnackBar(content: Text('Couldn’t open that link.')),
    );
  }
}
