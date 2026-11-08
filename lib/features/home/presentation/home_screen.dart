import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_nav_bar.dart';
import '../../../data/pear_repository.dart';
import '../../add_item/presentation/add_item_sheet.dart';
import '../../add_list/presentation/add_list_sheet.dart';
import '../../list/presentation/list_screen.dart';
import '../domain/home_models.dart';
import 'widgets/active_list_card.dart';
import 'widgets/home_top_bar.dart';
import 'widgets/other_lists_section.dart';
import 'widgets/recent_activity_section.dart';

/// Home / Shopping page (Figma section "Home / Shopping page", 2200:7293).
///
/// One screen covers all four designed states — they differ only by data:
/// empty vs. filled list, shared vs. private, other lists vs. templates,
/// activity vs. empty activity.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openList(BuildContext context, String listId,
      {bool justCreated = false}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ListScreen(listId: listId, justCreated: justCreated),
      ),
    );
  }

  Future<void> _addItem(BuildContext context, HomeData data) async {
    final item = await showAddItemSheet(
      context,
      listName: data.activeList.name,
      stores: data.stores,
    );
    if (item == null || !context.mounted) return;
    PearScope.read(context).addItem(data.activeList.id, item);
  }

  Future<void> _newList(BuildContext context, {String? name}) async {
    final request = await showAddListSheet(context, initialName: name);
    if (request == null || !context.mounted) return;
    final list = PearScope.read(context).createList(request);
    _openList(context, list.id, justCreated: true);
  }

  @override
  Widget build(BuildContext context) {
    final data = HomeData.fromRepository(PearScope.of(context));

    // Figma leaves 32px under the nav bar; on devices with a home indicator
    // the system inset is about the same, elsewhere keep a 16px minimum.
    final navBottom = math.max(MediaQuery.viewPaddingOf(context).bottom, 16.0);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            Column(
              children: [
                SafeArea(
                  bottom: false,
                  child: HomeTopBar(
                    onProfile: () {
                      // TODO: open profile.
                    },
                    onNotifications: () {
                      // TODO: open notifications.
                    },
                  ),
                ),
                Expanded(
                  child: data == null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: AppButton(
                              label: 'Create your first list',
                              onPressed: () => _newList(context),
                            ),
                          ),
                        )
                      : _HomeContent(
                          data: data,
                          bottomInset: navBottom + AppNavBar.height + 24,
                          onAddItem: () => _addItem(context, data),
                          onOpenList: (id) => _openList(context, id),
                          onNewList: ({name}) => _newList(context, name: name),
                        ),
                ),
              ],
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: navBottom,
              child: AppNavBar(
                selected: AppNavTab.shopping,
                onSelected: (tab) {
                  // TODO: switch to Wishes / Places once those pages exist.
                },
                onAddPressed: data == null
                    ? () => _newList(context)
                    : () => _addItem(context, data),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({
    required this.data,
    required this.bottomInset,
    required this.onAddItem,
    required this.onOpenList,
    required this.onNewList,
  });

  final HomeData data;
  final double bottomInset;
  final VoidCallback onAddItem;
  final ValueChanged<String> onOpenList;
  final void Function({String? name}) onNewList;

  @override
  Widget build(BuildContext context) {
    final partner =
        data.activeList.members.where((p) => !p.isMe).firstOrNull;

    return ListView(
      // Leave room so the last card can scroll above the nav.
      padding: EdgeInsets.only(top: 12, bottom: bottomInset),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ActiveListCard(
            list: data.activeList,
            onAddItem: onAddItem,
            onOpenList: () => onOpenList(data.activeList.id),
          ),
        ),
        const SizedBox(height: 20),
        OtherListsSection(
          lists: data.otherLists,
          templates: data.templates,
          onNewList: () => onNewList(),
          onOpenList: (list) => onOpenList(list.id),
          onTemplate: (template) => onNewList(name: template.name),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: RecentActivitySection(
            activities: data.activities,
            partnerName: partner?.firstName,
            onViewAll: () {
              // TODO: open the full activity feed.
            },
          ),
        ),
      ],
    );
  }
}
