import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/open_link.dart';
import '../../../../core/widgets/app_input_shell.dart';
import '../../domain/kind_copy.dart';

/// Link / address input with a "Paste link" button (Figma: "Input" with a
/// trailing link button).
class LinkField extends StatefulWidget {
  const LinkField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.labelHint,
    this.onChanged,
    this.keyboardType = TextInputType.url,
  });

  final String label;

  /// Grey suffix after the label, e.g. "(recommended)".
  final String? labelHint;
  final String hint;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final TextInputType keyboardType;

  @override
  State<LinkField> createState() => _LinkFieldState();
}

class _LinkFieldState extends State<LinkField> {
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

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim();
    if (text == null || text.isEmpty || !mounted) return;
    widget.controller.text = text;
    widget.onChanged?.call(text);
  }

  @override
  Widget build(BuildContext context) {
    final labelHint = widget.labelHint;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text.rich(
            TextSpan(
              text: widget.label,
              style: AppTextStyles.body2Medium,
              children: [
                if (labelHint != null)
                  TextSpan(
                    text: ' $labelHint',
                    style: AppTextStyles.body2Regular,
                  ),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: _focusNode.requestFocus,
          behavior: HitTestBehavior.opaque,
          child: AppInputShell(
            borderColor: _focusNode.hasFocus
                ? AppColors.borderPrimary
                : AppColors.borderGrayLight,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    onChanged: widget.onChanged,
                    keyboardType: widget.keyboardType,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    cursorColor: AppColors.headingBlack,
                    style: AppTextStyles.body1Regular,
                    decoration: InputDecoration.collapsed(
                      hintText: widget.hint,
                      hintStyle: AppTextStyles.body1Regular
                          .copyWith(color: AppColors.textDisable),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: _paste,
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Text(
                      'Paste link',
                      style: AppTextStyles.body2Medium
                          .copyWith(color: AppColors.buttonLink),
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

/// Saved link or address with an "Open link" / "Directions ↗" button
/// (Figma: "Address" in Place details).
class LinkBox extends StatelessWidget {
  const LinkBox({super.key, required this.label, required this.link});

  final String label;
  final String link;

  @override
  Widget build(BuildContext context) {
    final web = isWebLink(link);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(label, style: AppTextStyles.body2Medium),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceForeground,
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            border: Border.all(color: AppColors.borderGrayLight),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  web ? linkLabel(link) : link,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body1Regular
                      .copyWith(color: AppColors.body1, height: 24 / 16),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => openLinkOrAddress(context, link),
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        web ? 'Open link' : 'Directions',
                        style: AppTextStyles.body2Medium
                            .copyWith(color: AppColors.buttonLink),
                      ),
                      const SizedBox(width: 8),
                      SvgPicture.asset(
                        AppIcons.openExternal,
                        width: 18,
                        height: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
