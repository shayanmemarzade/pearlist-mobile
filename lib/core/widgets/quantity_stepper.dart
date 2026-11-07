import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_assets.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_input_shell.dart';

/// "− 1 +" control with a label (Figma: "Quantity Control").
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.label = 'Quantity',
    this.min = 1,
    this.max = 99,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final String label;
  final int min;
  final int max;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppFieldLabel(label),
        SizedBox(
          height: 46,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _StepButton(
                icon: AppIcons.minus,
                tooltip: 'Decrease quantity',
                onTap: value > min ? () => onChanged(value - 1) : null,
              ),
              const SizedBox(width: 16),
              Semantics(
                label: label,
                value: '$value',
                child: Text('$value', style: AppTextStyles.body2Medium),
              ),
              const SizedBox(width: 16),
              _StepButton(
                icon: AppIcons.plus,
                tooltip: 'Increase quantity',
                onTap: value < max ? () => onChanged(value + 1) : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final String icon;
  final String tooltip;
  final VoidCallback? onTap;

  static const _shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(16)),
    side: BorderSide(color: AppColors.buttonBlack),
  );

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Opacity(
        opacity: onTap == null ? 0.4 : 1,
        child: Material(
          color: AppColors.background,
          shape: _shape,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox.square(
              dimension: 34,
              child: Center(
                child: SvgPicture.asset(icon, width: 18, height: 18),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
