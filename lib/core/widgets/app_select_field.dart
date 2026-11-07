import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_assets.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_input_shell.dart';

/// Labelled dropdown (Figma: "Select"). The menu opens below the field, on
/// top of whatever is underneath, and closes on selection or outside tap.
class AppSelectField<T> extends StatefulWidget {
  const AppSelectField({
    super.key,
    required this.label,
    required this.hint,
    required this.options,
    required this.optionLabel,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String hint;
  final List<T> options;
  final String Function(T option) optionLabel;
  final T? value;
  final ValueChanged<T> onChanged;

  @override
  State<AppSelectField<T>> createState() => _AppSelectFieldState<T>();
}

class _AppSelectFieldState<T> extends State<AppSelectField<T>> {
  final _menu = OverlayPortalController();
  final _link = LayerLink();
  final _tapGroup = Object();
  double _width = 0;

  bool get _open => _menu.isShowing;

  void _toggle() {
    FocusScope.of(context).unfocus();
    setState(() => _open ? _menu.hide() : _menu.show());
  }

  void _close() {
    if (_open) setState(_menu.hide);
  }

  void _select(T option) {
    widget.onChanged(option);
    _close();
  }

  @override
  Widget build(BuildContext context) {
    final value = widget.value;

    return TapRegion(
      groupId: _tapGroup,
      onTapOutside: (_) => _close(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppFieldLabel(widget.label),
          LayoutBuilder(
            builder: (context, constraints) {
              _width = constraints.maxWidth;
              return CompositedTransformTarget(
                link: _link,
                child: OverlayPortal(
                  controller: _menu,
                  overlayChildBuilder: _buildMenu,
                  child: Semantics(
                    button: true,
                    expanded: _open,
                    label: widget.label,
                    value: value == null ? null : widget.optionLabel(value),
                    child: GestureDetector(
                      onTap: _toggle,
                      behavior: HitTestBehavior.opaque,
                      child: AppInputShell(
                        borderColor: _open
                            ? AppColors.borderPrimary
                            : AppColors.borderGrayLight,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                value == null
                                    ? widget.hint
                                    : widget.optionLabel(value),
                                style: AppTextStyles.body1Regular.copyWith(
                                  color: value == null
                                      ? AppColors.textDisable
                                      : AppColors.headingBlack,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            SvgPicture.asset(
                              _open ? AppIcons.arrowUp : AppIcons.arrowDown,
                              width: 18,
                              height: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenu(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(16));
    return CompositedTransformFollower(
      link: _link,
      targetAnchor: Alignment.bottomLeft,
      offset: const Offset(0, 6),
      child: Align(
        alignment: Alignment.topLeft,
        child: TapRegion(
          groupId: _tapGroup,
          child: SizedBox(
            width: _width,
            child: DecoratedBox(
              // Figma: "_Select menu" — Drop Shadow-m.
              decoration: const BoxDecoration(
                borderRadius: radius,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowMedium,
                    offset: Offset(0, 6),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Material(
                color: AppColors.surfaceForeground,
                shape: const RoundedRectangleBorder(
                  borderRadius: radius,
                  side: BorderSide(color: AppColors.borderGrayLight),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final option in widget.options)
                      InkWell(
                        onTap: () => _select(option),
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            widget.optionLabel(option),
                            style: AppTextStyles.body1Medium.copyWith(
                              color: option == widget.value
                                  ? AppColors.textPrimary
                                  : AppColors.headingBlack,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
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
