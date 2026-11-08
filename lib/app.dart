import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'data/pear_repository.dart';
import 'features/onboarding/presentation/splash_screen.dart';

class PearListApp extends StatelessWidget {
  const PearListApp({super.key, required this.repository});

  final PearRepository repository;

  @override
  Widget build(BuildContext context) {
    return PearScope(
      repository: repository,
      child: MaterialApp(
        title: 'Pear List',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const SplashScreen(),
      ),
    );
  }
}
