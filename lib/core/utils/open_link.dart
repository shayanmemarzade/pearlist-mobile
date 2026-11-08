import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens a web link in the browser, or an address in the maps app.
/// Shows a short message when nothing can open it.
Future<void> openLinkOrAddress(BuildContext context, String value) async {
  final text = value.trim();
  final parsed = Uri.tryParse(text);
  final uri = parsed != null &&
          (parsed.scheme == 'http' || parsed.scheme == 'https') &&
          parsed.host.isNotEmpty
      ? parsed
      // Anything else is an address: search it in Maps.
      : Uri.https('www.google.com', '/maps/search/', {
          'api': '1',
          'query': text,
        });
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
