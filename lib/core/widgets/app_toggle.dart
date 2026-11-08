import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Small switch (Figma: "Toggle"), 36×20 or 44×24.
class AppToggle extends StatelessWidget {
  const AppToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.large = false,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;

  /// 44×24 variant (Figma "Add new list" sheet) instead of 36×20.
  final bool large;

  static const Duration _duration = Duration(milliseconds: 150);
  static const BorderRadius _radius = BorderRadius.all(Radius.circular(12));

  @override
  Widget build(BuildContext context) {
    final onChanged = this.onChanged;
    final knob = large ? 20.0 : 16.0;

    return Opacity(
      opacity: onChanged == null ? 0.5 : 1,
      child: Semantics(
        toggled: value,
        enabled: onChanged != null,
        child: GestureDetector(
          onTap: onChanged == null ? null : () => onChanged(!value),
          child: AnimatedContainer(
            duration: _duration,
            width: large ? 44 : 36,
            height: large ? 24 : 20,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: value ? AppColors.primary : AppColors.background,
              borderRadius: _radius,
            ),
            // The off track is the same colour as the sheet, so outline it
            // to keep the control visible. Drawn on top so it doesn't shift
            // the knob.
            foregroundDecoration: BoxDecoration(
              borderRadius: _radius,
              border: Border.all(
                color: value ? AppColors.primary : AppColors.borderGrayLight,
              ),
            ),
            child: AnimatedAlign(
              duration: _duration,
              curve: Curves.easeOut,
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: knob,
                height: knob,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceForeground,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowSmall,
                      offset: Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
