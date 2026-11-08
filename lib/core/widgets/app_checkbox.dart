import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// 20px rounded checkbox (Figma: "Checkbox"). The tap target is 32px.
class AppCheckbox extends StatelessWidget {
  const AppCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.semanticLabel,
  });

  final bool value;
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
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: value ? AppColors.primary : AppColors.surfaceForeground,
              borderRadius: const BorderRadius.all(Radius.circular(6)),
              border: Border.all(color: AppColors.primary),
            ),
            child: value
                ? const Icon(
                    Icons.check_rounded,
                    size: 14,
                    color: AppColors.textOnButton,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
