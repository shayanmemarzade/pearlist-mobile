import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_link_button.dart';
import '../../domain/home_models.dart';
import 'home_section_header.dart';

/// "Other lists" (horizontal cards) or, when the user has none yet,
/// "Start a list" (template chips). Full-bleed: handles its own 16px insets
/// so the card row can scroll off the screen edge.
class OtherListsSection extends StatelessWidget {
  const OtherListsSection({
    super.key,
    required this.lists,
    required this.templates,
    required this.onNewList,
    required this.onOpenList,
    required this.onTemplate,
    this.title = 'Other lists',
  });

  /// "Other lists" / "Other wishlists".
  final String title;

  final List<ListSummary> lists;
  final List<ListTemplate> templates;
  final VoidCallback onNewList;
  final ValueChanged<ListSummary> onOpenList;
  final ValueChanged<ListTemplate> onTemplate;

  static const EdgeInsets _inset = EdgeInsets.symmetric(horizontal: 16);

  @override
  Widget build(BuildContext context) {
    final hasLists = lists.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: _inset,
          child: HomeSectionHeader(
            title: hasLists ? title : 'Start a list',
            action: AppLinkButton(
              label: 'New List',
              onPressed: onNewList,
              leadingIcon: SvgPicture.asset(
                hasLists ? AppIcons.plusGreen : AppIcons.addGreen,
                width: 18,
                height: 18,
              ),
            ),
          ),
        ),
        SizedBox(height: hasLists ? 8 : 12),
        if (hasLists)
          SizedBox(
            height: 68,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: _inset,
              itemCount: lists.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) => _ListSummaryCard(
                summary: lists[index],
                onTap: () => onOpenList(lists[index]),
              ),
            ),
          )
        else
          Padding(
            padding: _inset,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in templates)
                  _TemplateChip(template: t, onTap: () => onTemplate(t)),
              ],
            ),
          ),
      ],
    );
  }
}

class _ListSummaryCard extends StatelessWidget {
  const _ListSummaryCard({required this.summary, required this.onTap});

  final ListSummary summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final noun = summary.kind == ListKind.places ? 'Place' : 'Item';
    final count = summary.itemCount == 1
        ? '1 $noun'
        : '${summary.itemCount} ${noun}s';

    return SizedBox(
      width: 191,
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(4),
              child: SvgPicture.asset(
                summary.icon == ListIcon.lock ? AppIcons.lock : AppIcons.list,
                width: 24,
                height: 24,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    summary.name,
                    style: AppTextStyles.body2SemiBold,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (summary.isShared)
                    Row(
                      children: [
                        AvatarStack(
                          size: 20,
                          people: [
                            for (final p in summary.members)
                              (name: p.name, imageUrl: p.avatarUrl),
                          ],
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            '$count · Shared',
                            style: AppTextStyles.smallRegular,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      '$count · Only you',
                      style: AppTextStyles.smallRegular,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Light-green chip (Figma: "Badgs").
class _TemplateChip extends StatelessWidget {
  const _TemplateChip({required this.template, required this.onTap});

  final ListTemplate template;
  final VoidCallback onTap;

  static const BorderRadius _radius = BorderRadius.all(Radius.circular(16));

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfacePrimaryLight,
      borderRadius: _radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: _radius,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 10, 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                switch (template.icon) {
                  ListIcon.lock => AppIcons.lockSmall,
                  ListIcon.place => AppIcons.pinGreen,
                  ListIcon.list => AppIcons.listSmall,
                },
                width: 16,
                height: 16,
              ),
              const SizedBox(width: 4),
              Text(
                template.name,
                style: AppTextStyles.body2Medium
                    .copyWith(color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
