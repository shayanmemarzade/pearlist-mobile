import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/phone_format.dart';
import '../../../../core/widgets/app_pill_field.dart';

/// US phone number input with the "US ⌄" segment (Figma: "Input field /
/// Phone"). Formats as "(415) 555-0132" while typing.
class PhoneField extends StatelessWidget {
  const PhoneField({
    super.key,
    required this.controller,
    this.error,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String? error;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return AppPillField(
      hint: '(555) 000-0000',
      controller: controller,
      error: error,
      autofocus: true,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.telephoneNumberNational],
      inputFormatters: const [UsPhoneInputFormatter()],
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      leading: const _CountrySegment(),
    );
  }
}

/// Only US numbers are supported for now, so the segment is a label rather
/// than a picker.
// TODO: turn into a country picker when other countries are supported.
class _CountrySegment extends StatelessWidget {
  const _CountrySegment();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Country: United States',
      excludeSemantics: true,
      child: Container(
        width: 68,
        height: double.infinity,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.only(left: 16, right: 6),
        decoration: const BoxDecoration(
          border: Border(right: BorderSide(color: AppColors.borderGrayLight)),
        ),
        child: Row(
          children: [
            Text('US', style: AppTextStyles.body1Regular),
            const SizedBox(width: 2),
            SvgPicture.asset(AppIcons.chevronDown, width: 18, height: 18),
          ],
        ),
      ),
    );
  }
}

