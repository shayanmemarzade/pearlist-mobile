import 'package:flutter_test/flutter_test.dart';
import 'package:pear_list/core/theme/app_colors.dart';

// Replaces the default counter-app test, which no longer applies.
// Screen tests come later, once fonts are bundled for offline test runs.
void main() {
  test('background color matches the Figma surface/background token', () {
    expect(AppColors.background.toARGB32(), 0xFFF8F5EE);
  });
}
