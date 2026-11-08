import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_input_shell.dart';

/// Single-line text input with an optional label (Figma: "Input field").
/// The border turns green while focused.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.hint,
    required this.controller,
    this.label,
    this.labelColor,
    this.prefixIcon,
    this.autofocus = false,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.sentences,
    this.onChanged,
    this.onSubmitted,
  });

  final String hint;
  final TextEditingController controller;
  final String? label;

  /// Defaults to heading black; the list settings sheet uses grey.
  final Color? labelColor;

  /// 18px icon before the text (e.g. "+" in "New aisle name").
  final Widget? prefixIcon;
  final bool autofocus;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.label;
    final prefix = widget.prefixIcon;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              label,
              style: AppTextStyles.body2Medium.copyWith(
                color: widget.labelColor ?? AppColors.headingBlack,
              ),
            ),
          ),
        // Tapping anywhere in the box (not just on the text line) focuses it.
        GestureDetector(
          onTap: _focusNode.requestFocus,
          behavior: HitTestBehavior.opaque,
          child: AppInputShell(
            borderColor: _focusNode.hasFocus
                ? AppColors.borderPrimary
                : AppColors.borderGrayLight,
            child: Row(
              children: [
                if (prefix != null) ...[prefix, const SizedBox(width: 8)],
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    autofocus: widget.autofocus,
                    textInputAction: widget.textInputAction,
                    textCapitalization: widget.textCapitalization,
                    onChanged: widget.onChanged,
                    onSubmitted: widget.onSubmitted,
                    cursorColor: AppColors.headingBlack,
                    style: AppTextStyles.body1Regular,
                    decoration: InputDecoration.collapsed(
                      hintText: widget.hint,
                      hintStyle: AppTextStyles.body1Regular
                          .copyWith(color: AppColors.textDisable),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
