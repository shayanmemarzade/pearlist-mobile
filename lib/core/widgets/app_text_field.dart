import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_input_shell.dart';

/// Labelled single-line text input (Figma: "Input field").
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.autofocus = false,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.sentences,
    this.onSubmitted,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final bool autofocus;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onSubmitted;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppFieldLabel(widget.label),
        // Tapping anywhere in the box (not just on the text line) focuses it.
        GestureDetector(
          onTap: _focusNode.requestFocus,
          behavior: HitTestBehavior.opaque,
          child: AppInputShell(
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              autofocus: widget.autofocus,
              textInputAction: widget.textInputAction,
              textCapitalization: widget.textCapitalization,
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
        ),
      ],
    );
  }
}
