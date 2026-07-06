import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/bible_controller.dart';
import '../../theme/app_theme.dart';
import '../../widgets/reusable_widgets.dart';
import '../verses/reader_page.dart';

class BookmarksPage extends StatelessWidget {
  const BookmarksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<BibleController>();

    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      body: SafeArea(
        child: Column(children: [
          // ── Header ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(children: [
              Text('Bookmarks', style: AppTheme.display(24)),
              const Spacer(),
              Obx(() => Text('${ctrl.bookmarks.length}',
                  style: AppTheme.label(13, color: AppTheme.textDim))),
            ]),
          ),
          const GoldDivider(),
          // ── List ────────────────────────────────────────────
          Expanded(
            child: Obx(() {
              if (ctrl.bookmarks.isEmpty) {
                return const EmptyState(
                  icon: Icons.bookmark_border,
                  title: 'No bookmarks yet',
                  subtitle:
                      'Tap a verse while reading, then tap the bookmark icon to save it here.',
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                itemCount: ctrl.bookmarks.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final bm = ctrl.bookmarks[i];
                  return BookmarkTile(
                    bookmark: bm,
                    onDelete: () => ctrl.removeBookmark(bm),
                    onTap: () {
                      final book = ctrl.bookById(bm.bookId);
                      if (book != null) {
                        Get.to(
                          () => ReaderPage(book: book, chapter: bm.chapter),
                          transition: Transition.rightToLeft,
                        );
                      }
                    },
                  );
                },
              );
            }),
          ),
        ]),
      ),
    );
  }
}
