import 'package:flutter/material.dart';

import 'core/theme/app_colors.dart';
import 'core/theme/app_text_styles.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_nav_bar.dart';
import 'data/pear_repository.dart';
import 'data/sample_data.dart';
import 'features/home/presentation/home_screen.dart';

/// Preview of Home and everything reachable from it, with sample data.
///
///   flutter run -t lib/main_home_preview.dart
///
/// Tap the chip above the nav bar to cycle through the four Figma states.
/// Each state keeps its own data, so changes survive switching back.
void main() => runApp(const _HomePreviewApp());

class _HomePreviewApp extends StatefulWidget {
  const _HomePreviewApp();

  @override
  State<_HomePreviewApp> createState() => _HomePreviewAppState();
}

class _HomePreviewAppState extends State<_HomePreviewApp> {
  final Map<SampleState, PearRepository> _repos = {
    for (final s in SampleState.values) s: SampleData.repository(s),
  };
  SampleState _state = SampleState.shared;

  void _next() => setState(() {
        final values = SampleState.values;
        _state = values[(_state.index + 1) % values.length];
      });

  @override
  Widget build(BuildContext context) {
    return PearScope(
      repository: _repos[_state]!,
      child: MaterialApp(
        title: 'Pear List — preview',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: Builder(
          builder: (context) {
            final bottom = MediaQuery.viewPaddingOf(context).bottom;
            return Stack(
              children: [
                const HomeScreen(),
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
                          'State: ${_state.label}',
                          style: AppTextStyles.xsMedium,
                        ),
                        backgroundColor: AppColors.surfacePrimaryLight,
                        onPressed: _next,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
