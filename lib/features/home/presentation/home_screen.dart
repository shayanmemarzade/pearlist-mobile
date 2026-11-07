import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_nav_bar.dart';
import '../../add_item/presentation/add_item_sheet.dart';
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
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.data});

  final HomeData data;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeData _data = widget.data;

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.data, widget.data)) _data = widget.data;
  }

  Future<void> _addItem() async {
    final item = await showAddItemSheet(
      context,
      listName: _data.activeList.name,
      stores: _data.stores,
    );
    if (item == null || !mounted) return;
    // TODO: send [item] to the items API; this only updates the screen.
    setState(() => _data = _data.withItemAdded(item.name));
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    // Figma leaves 32px under the nav bar; on devices with a home indicator
    // the system inset is about the same, elsewhere keep a 16px minimum.
    final navBottom = math.max(MediaQuery.viewPaddingOf(context).bottom, 16.0);
    final partner = data.activeList.members.where((p) => !p.isMe).firstOrNull;

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
                  child: ListView(
                    // Leave room so the last card can scroll above the nav.
                    padding: EdgeInsets.only(
                      top: 12,
                      bottom: navBottom + AppNavBar.height + 24,
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ActiveListCard(
                          list: data.activeList,
                          onAddItem: _addItem,
                          onOpenList: () {
                            // TODO: open the list.
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      OtherListsSection(
                        lists: data.otherLists,
                        templates: data.templates,
                        onNewList: () {
                          // TODO: open "New list".
                        },
                        onOpenList: (list) {
                          // TODO: open [list].
                        },
                        onTemplate: (template) {
                          // TODO: create a list from [template].
                        },
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: RecentActivitySection(
                          activities: data.activities,
                          partnerName: partner?.name,
                          onViewAll: () {
                            // TODO: open the full activity feed.
                          },
                        ),
                      ),
                    ],
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
                onAddPressed: _addItem,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
