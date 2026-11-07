import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/onboarding/presentation/splash_screen.dart';

class PearListApp extends StatelessWidget {
  const PearListApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pear List',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SplashScreen(),
    );
  }
}
