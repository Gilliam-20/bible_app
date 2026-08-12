import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/bible_controller.dart';
import '../../theme/app_theme.dart';
import '../../widgets/reusable_widgets.dart';
import '../chapters/chapters_page.dart';

class BooksPage extends StatefulWidget {
  const BooksPage({super.key});

  @override
  State<BooksPage> createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _searchCtrl = TextEditingController();
  final ctrl = Get.find<BibleController>();

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text('Books', style: AppTheme.display(24)),
                      const Spacer(),
                      Obx(
                        () => Text(
                          '${ctrl.books.length} books',
                          style: AppTheme.label(13, color: AppTheme.textDim),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  BibleSearchBar(
                    controller: _searchCtrl,
                    onChanged: (v) => ctrl.searchQuery.value = v,
                    hint: 'Search books…',
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            // ── Tabs ─────────────────────────────────────────────
            _GoldTabBar(controller: _tabs),
            const SizedBox(height: 8),
            // ── Content ──────────────────────────────────────────
            Expanded(
              child: Obx(() {
                if (ctrl.isLoadingBooks.value) return _buildShimmer();

                return TabBarView(
                  controller: _tabs,
                  children: [
                    _BookList(books: ctrl.filteredBooks),
                    _BookList(
                      books: ctrl.filteredBooks.where((b) => b.isOT).toList(),
                    ),
                    _BookList(
                      books: ctrl.filteredBooks.where((b) => !b.isOT).toList(),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: 8,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, __) => const ShimmerBox(height: 72),
    );
  }
}

// ── Gold tab bar ──────────────────────────────────────────────
class _GoldTabBar extends StatelessWidget {
  final TabController controller;
  const _GoldTabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 40,
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.divider),
      ),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          color: AppTheme.gold,
          borderRadius: BorderRadius.circular(8),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelStyle: AppTheme.label(13, weight: FontWeight.w700),
        unselectedLabelStyle: AppTheme.label(13),
        labelColor: AppTheme.bgDeep,
        unselectedLabelColor: AppTheme.textDim,
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Old Testament'),
          Tab(text: 'New Testament'),
        ],
      ),
    );
  }
}

// ── Book list ─────────────────────────────────────────────────
class _BookList extends StatelessWidget {
  final List books;
  const _BookList({required this.books});

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off,
        title: 'No books found',
        subtitle: 'Try a different search term',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      itemCount: books.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final book = books[i];
        return BookTile(
          book: book,
          onTap: () => Get.to(
            () => ChaptersPage(book: book),
            transition: Transition.rightToLeft,
          ),
        );
      },
    );
  }
}
