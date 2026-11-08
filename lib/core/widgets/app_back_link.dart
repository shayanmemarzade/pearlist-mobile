import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_assets.dart';
import '../theme/app_text_styles.dart';

/// "← Home" / "← Back to list" link at the top of a page.
class AppBackLink extends StatelessWidget {
  const AppBackLink({super.key, required this.label, this.onPressed});

  final String label;

  /// Defaults to popping the current route.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onPressed ?? () => Navigator.of(context).maybePop(),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(AppIcons.arrowLeft, width: 18, height: 18),
              const SizedBox(width: 8),
              Text(label, style: AppTextStyles.body2Medium),
            ],
          ),
        ),
      ),
    );
  }
}
