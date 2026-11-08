import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Multi-line input (Figma: "More info", 361×86 textarea).
class AppTextArea extends StatefulWidget {
  const AppTextArea({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.onChanged,
    this.minLines = 3,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final int minLines;

  @override
  State<AppTextArea> createState() => _AppTextAreaState();
}

class _AppTextAreaState extends State<AppTextArea> {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(widget.label, style: AppTextStyles.body2Medium),
        ),
        GestureDetector(
          onTap: _focusNode.requestFocus,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceForeground,
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              border: Border.all(
                color: _focusNode.hasFocus
                    ? AppColors.borderPrimary
                    : AppColors.borderGrayLight,
              ),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadowSmall,
                  offset: Offset(0, 2),
                  blurRadius: 6,
                ),
              ],
            ),
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              onChanged: widget.onChanged,
              minLines: widget.minLines,
              maxLines: 6,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
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
