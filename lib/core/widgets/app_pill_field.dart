import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_assets.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_input_shell.dart';

/// Pill-shaped text input of the sign-up and invite screens (Figma:
/// "Input field", radius 32). Green border while focused; red border, a
/// danger icon and a message underneath when [error] is set.
class AppPillField extends StatefulWidget {
  const AppPillField({
    super.key,
    required this.hint,
    required this.controller,
    this.label,
    this.prefixIcon,
    this.leading,
    this.error,
    this.autofocus = false,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.autofillHints,
    this.onChanged,
    this.onSubmitted,
  });

  final String hint;
  final TextEditingController controller;
  final String? label;

  /// 18px icon before the text (email, shop…).
  final Widget? prefixIcon;

  /// A segment at the start of the field with its own padding, e.g. the
  /// "US ⌄" country picker. Replaces the field's left padding.
  final Widget? leading;

  /// Message shown under the field; also turns the border red.
  final String? error;
  final bool autofocus;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  State<AppPillField> createState() => _AppPillFieldState();
}

class _AppPillFieldState extends State<AppPillField> {
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
    final leading = widget.leading;
    final error = widget.error;

    final border = error != null
        ? AppColors.errorBorder
        : _focusNode.hasFocus
            ? AppColors.borderPrimary
            : AppColors.borderGrayLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(label, style: AppTextStyles.body2Medium),
          ),
        GestureDetector(
          onTap: _focusNode.requestFocus,
          behavior: HitTestBehavior.opaque,
          child: AppInputShell(
            radius: 32,
            borderColor: border,
            padding: EdgeInsets.only(left: leading == null ? 16 : 0, right: 16),
            child: Row(
              children: [
                ?leading,
                if (prefix != null) ...[prefix, const SizedBox(width: 8)],
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    autofocus: widget.autofocus,
                    keyboardType: widget.keyboardType,
                    textInputAction: widget.textInputAction,
                    textCapitalization: widget.textCapitalization,
                    inputFormatters: widget.inputFormatters,
                    autofillHints: widget.autofillHints,
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
                if (error != null) ...[
                  const SizedBox(width: 8),
                  SvgPicture.asset(
                    AppIcons.danger,
                    width: 18,
                    height: 18,
                    colorFilter: const ColorFilter.mode(
                      AppColors.errorBorder,
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 16),
            child: Text(
              error,
              style: AppTextStyles.xsRegular.copyWith(color: AppColors.error),
            ),
          ),
      ],
    );
  }
}
