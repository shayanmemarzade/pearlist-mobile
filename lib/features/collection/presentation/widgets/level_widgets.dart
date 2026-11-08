import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/models.dart';
import '../../domain/kind_copy.dart';

/// "♡ Must have" / "Want to visit" pill (Figma: "Badgs").
class LevelBadge extends StatelessWidget {
  const LevelBadge({super.key, required this.kind, required this.level});

  final ListKind kind;
  final ItemLevel level;

  @override
  Widget build(BuildContext context) {
    final colors = levelBadgeColors(level);
    final icon = kind.levelBadgeIcon(level);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            SvgPicture.asset(icon, width: 12, height: 12),
            const SizedBox(width: 4),
          ],
          Text(
            kind.levelLabel(level),
            style: AppTextStyles.badge.copyWith(color: colors.foreground),
          ),
        ],
      ),
    );
  }
}

/// Must have / Would Love / Nice to Have picker (Figma: "Tabs / Tab bar"
/// with leading icons).
class LevelSelector extends StatelessWidget {
  const LevelSelector({
    super.key,
    required this.kind,
    required this.value,
    required this.onChanged,
  });

  final ListKind kind;
  final ItemLevel value;
  final ValueChanged<ItemLevel> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(kind.levelTitle, style: AppTextStyles.body2Medium),
        ),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: AppColors.surfaceForeground,
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
          child: Row(
            children: [
              for (final level in ItemLevel.values) ...[
                if (level != ItemLevel.values.first) const SizedBox(width: 4),
                Expanded(
                  child: _LevelTab(
                    kind: kind,
                    level: level,
                    selected: level == value,
                    onTap: () => onChanged(level),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _LevelTab extends StatelessWidget {
  const _LevelTab({
    required this.kind,
    required this.level,
    required this.selected,
    required this.onTap,
  });

  final ListKind kind;
  final ItemLevel level;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: selected ? AppColors.surfacePrimaryLight : null,
            borderRadius: const BorderRadius.all(Radius.circular(12)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                kind.levelIcon(level),
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(
                  selected ? kind.levelIconSelected : AppColors.iconInactive,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  kind.levelLabel(level),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body2Medium.copyWith(
                    color: selected ? AppColors.textPrimary : AppColors.body2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
