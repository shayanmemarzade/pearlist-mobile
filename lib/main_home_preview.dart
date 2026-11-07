import 'package:flutter/material.dart';

import 'core/theme/app_colors.dart';
import 'core/theme/app_text_styles.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_nav_bar.dart';
import 'features/home/data/home_fixtures.dart';
import 'features/home/presentation/home_screen.dart';

/// Preview of the Home screen with sample data.
///
///   flutter run -t lib/main_home_preview.dart
///
/// Tap the chip above the nav bar to cycle through the four Figma states.
void main() => runApp(const _HomePreviewApp());

class _HomePreviewApp extends StatefulWidget {
  const _HomePreviewApp();

  @override
  State<_HomePreviewApp> createState() => _HomePreviewAppState();
}

class _HomePreviewAppState extends State<_HomePreviewApp> {
  final _states = HomeFixtures.all;
  int _index = 2; // "Shared"

  @override
  Widget build(BuildContext context) {
    final name = _states.keys.elementAt(_index);
    return MaterialApp(
      title: 'Pear List — Home preview',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: Builder(
        builder: (context) {
          final bottom = MediaQuery.viewPaddingOf(context).bottom;
          return Stack(
            children: [
              HomeScreen(data: _states[name]!),
              Positioned(
                left: 0,
                right: 0,
                bottom: (bottom < 16 ? 16 : bottom) + AppNavBar.height + 8,
                // The chip sits outside HomeScreen's Scaffold, so it needs
                // its own Material ancestor.
                child: Material(
                  type: MaterialType.transparency,
                  child: Center(
                    child: ActionChip(
                      label: Text(
                        'State: $name',
                        style: AppTextStyles.xsMedium,
                      ),
                      backgroundColor: AppColors.surfacePrimaryLight,
                      onPressed: () => setState(
                        () => _index = (_index + 1) % _states.length,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
