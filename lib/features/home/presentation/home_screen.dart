import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_nav_bar.dart';
import '../../../data/pear_repository.dart';
import '../../add_item/presentation/add_item_sheet.dart';
import '../../add_list/presentation/add_list_sheet.dart';
import '../../collection/domain/kind_copy.dart';
import '../../collection/presentation/add_collection_item_sheet.dart';
import '../../list/presentation/list_screen.dart';
import '../domain/home_models.dart';
import 'widgets/active_list_card.dart';
import 'widgets/home_top_bar.dart';
import 'widgets/other_lists_section.dart';
import 'widgets/recent_activity_section.dart';

/// The three tab pages: Shopping (Figma "Home / Shopping page", 2200:7293),
/// Wishes ("Wish List" → "Main page", 2282:15005) and Places ("Places
/// List" → "Main page", 2339:8912).
///
/// Each page covers its designed states by data: empty vs. filled list,
/// shared vs. private, other lists vs. templates, activity vs. none.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.initialTab = AppNavTab.shopping});

  final AppNavTab initialTab;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

ListKind _kindOf(AppNavTab tab) => switch (tab) {
      AppNavTab.shopping => ListKind.shopping,
      AppNavTab.wishes => ListKind.wishlist,
      AppNavTab.places => ListKind.places,
    };

class _HomeScreenState extends State<HomeScreen> {
  late AppNavTab _tab = widget.initialTab;

  ListKind get _kind => _kindOf(_tab);

  void _openList(String listId, {bool justCreated = false}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ListScreen(listId: listId, justCreated: justCreated),
      ),
    );
  }

  Future<void> _addTo(HomeData data) async {
    final repo = PearScope.read(context);
    final list = data.activeList;
    if (list.kind == ListKind.shopping) {
      final item = await showAddItemSheet(
        context,
        listName: list.name,
        stores: data.stores,
      );
      if (item == null || !mounted) return;
      repo.addItem(list.id, item);
    } else {
      final entry = await showAddCollectionItemSheet(
        context,
        kind: list.kind,
        listName: list.name,
      );
      if (entry == null || !mounted) return;
      repo.addCollectionItem(list.id, entry);
    }
  }

  Future<void> _newList({String? name}) async {
    final request = await showAddListSheet(
      context,
      initialName: name,
      initialKind: _kind,
    );
    if (request == null || !mounted) return;
    final list = PearScope.read(context).createList(request);
    _openList(list.id, justCreated: true);
  }

  @override
  Widget build(BuildContext context) {
    final kind = _kind;
    final data = HomeData.fromRepository(PearScope.of(context), kind: kind);

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
                    title: kind.pageTitle,
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
                              onPressed: _newList,
                            ),
                          ),
                        )
                      : _HomeContent(
                          // A fresh scroll position per tab.
                          key: ValueKey(kind),
                          data: data,
                          bottomInset: navBottom + AppNavBar.height + 24,
                          onAdd: () => _addTo(data),
                          onOpenList: _openList,
                          onNewList: ({name}) => _newList(name: name),
                        ),
                ),
              ],
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: navBottom,
              child: AppNavBar(
                selected: _tab,
                onSelected: (tab) => setState(() => _tab = tab),
                onAddPressed: data == null ? _newList : () => _addTo(data),
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
    super.key,
    required this.data,
    required this.bottomInset,
    required this.onAdd,
    required this.onOpenList,
    required this.onNewList,
  });

  final HomeData data;
  final double bottomInset;
  final VoidCallback onAdd;
  final void Function(String listId) onOpenList;
  final void Function({String? name}) onNewList;

  @override
  Widget build(BuildContext context) {
    final kind = data.activeList.kind;
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
            onAddItem: onAdd,
            onOpenList: () => onOpenList(data.activeList.id),
          ),
        ),
        const SizedBox(height: 20),
        OtherListsSection(
          title: kind.otherListsTitle,
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
            kind: kind,
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
