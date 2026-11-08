import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';

/// Four code boxes (Figma: "_Mega input field base", 84×64). A single
/// hidden text field takes the input, so paste and SMS autofill work.
class OtpInput extends StatefulWidget {
  const OtpInput({
    super.key,
    required this.controller,
    this.length = 4,
    this.error = false,
    this.onCompleted,
    this.onChanged,
  });

  final TextEditingController controller;
  final int length;

  /// Red borders after a wrong code.
  final bool error;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_rebuild);
    widget.controller.addListener(_rebuild);
  }

  @override
  void didUpdateWidget(OtpInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_rebuild);
      widget.controller.addListener(_rebuild);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_rebuild);
    _focusNode.dispose();
    super.dispose();
  }

  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final code = widget.controller.text;
    final digitStyle = GoogleFonts.lora(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: AppColors.body1,
    );
    final placeholderStyle = GoogleFonts.lora(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: AppColors.textDisable,
    );

    return Semantics(
      label: 'Verification code',
      textField: true,
      child: GestureDetector(
        onTap: _focusNode.requestFocus,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            // The real input: invisible, but focusable and autofill-able.
            Positioned.fill(
              child: Opacity(
                opacity: 0,
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  maxLength: widget.length,
                  showCursor: false,
                  enableInteractiveSelection: false,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    widget.onChanged?.call(value);
                    if (value.length == widget.length) {
                      widget.onCompleted?.call(value);
                    }
                  },
                ),
              ),
            ),
            Row(
              children: [
                for (var i = 0; i < widget.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: _Box(
                      text: i < code.length ? code[i] : '0',
                      filled: i < code.length,
                      active: _focusNode.hasFocus &&
                          (i == code.length ||
                              (code.length == widget.length &&
                                  i == widget.length - 1)),
                      error: widget.error,
                      style: i < code.length ? digitStyle : placeholderStyle,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({
    required this.text,
    required this.filled,
    required this.active,
    required this.error,
    required this.style,
  });

  final String text;
  final bool filled;
  final bool active;
  final bool error;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final border = error
        ? AppColors.errorBorder
        : active
            ? AppColors.borderPrimary
            : AppColors.borderGrayLight;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      height: 64,
      constraints: const BoxConstraints(maxWidth: 84),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surfaceForeground,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        border: Border.all(color: border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            offset: Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Text(text, style: style),
    );
  }
}
