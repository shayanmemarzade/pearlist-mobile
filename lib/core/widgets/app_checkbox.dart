import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Rounded checkbox (Figma: "Checkbox"): 20px with radius 6 by default,
/// 16px/radius 4 in the store picker, a 20px circle in the contact picker.
/// The tap target adds 6px on every side.
class AppCheckbox extends StatelessWidget {
  const AppCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.semanticLabel,
    this.size = 20,
    this.radius = 6,
  });

  final bool value;
  final double size;

  /// Use half of [size] for a round checkbox.
  final double radius;
  final ValueChanged<bool>? onChanged;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final onChanged = this.onChanged;
    return Semantics(
      checked: value,
      label: semanticLabel,
      child: GestureDetector(
        onTap: onChanged == null ? null : () => onChanged(!value),
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: value ? AppColors.primary : AppColors.surfaceForeground,
              borderRadius: BorderRadius.all(Radius.circular(radius)),
              border: Border.all(color: AppColors.primary),
            ),
            child: value
                ? Icon(
                    Icons.check_rounded,
                    size: size * 0.7,
                    color: AppColors.textOnButton,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
