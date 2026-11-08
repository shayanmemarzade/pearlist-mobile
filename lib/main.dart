import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'data/sample_data.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // TODO: replace the sample data with a repository backed by the API.
  runApp(PearListApp(repository: SampleData.repository(SampleState.shared)));
}
