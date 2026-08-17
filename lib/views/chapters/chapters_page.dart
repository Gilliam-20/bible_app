import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/bible_controller.dart';
import '../../services/ad_service.dart';
import '../../models/bible_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/reusable_widgets.dart';
import '../verses/reader_page.dart';

class ChaptersPage extends StatelessWidget {
  final BibleBook book;
  const ChaptersPage({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<BibleController>();
    final lastChapter = ctrl.lastRead.value?.bookId == book.id
        ? ctrl.lastRead.value?.chapter
        : null;

    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      body: CustomScrollView(
        slivers: [
          // ── App bar ──────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            expandedHeight: 140,
            backgroundColor: AppTheme.bgDeep,
            leading: GestureDetector(
              onTap: () => Get.back(),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: AppTheme.gold,
                size: 20,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: _ChapterHeader(book: book),
              collapseMode: CollapseMode.none,
            ),
            title: Text(
              book.name,
              style: AppTheme.display(18, color: AppTheme.gold),
            ),
          ),
          // ── Chapter count ─────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Text(
                    '${book.chapters} Chapters',
                    style: AppTheme.label(13, color: AppTheme.textMid),
                  ),
                  const Spacer(),
                  TestamentBadge(testament: book.testament),
                ],
              ),
            ),
          ),
          if (lastChapter != null)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              sliver: SliverToBoxAdapter(
                child: _LastReadBanner(chapter: lastChapter, book: book),
              ),
            ),
          // ── Grid ─────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate((_, i) {
                final ch = i + 1;
                return Obx(
                  () => ChapterGridButton(
                    chapter: ch,
                    isActive:
                        ctrl.lastRead.value?.bookId == book.id &&
                        ctrl.lastRead.value?.chapter == ch,
                    onTap: () {
                      AdService.maybeShowChapterInterstitial();
                      Get.to(
                        () => ReaderPage(book: book, chapter: ch),
                        transition: Transition.rightToLeft,
                      );
                    },
                  ),
                );
              }, childCount: book.chapters),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Book header ───────────────────────────────────────────────
class _ChapterHeader extends StatelessWidget {
  final BibleBook book;
  const _ChapterHeader({required this.book});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0A0B10), AppTheme.bgDeep],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: book.isOT
                  ? AppTheme.accentSoft
                  : AppTheme.goldDim.withOpacity(0.3),
              border: Border.all(
                color: book.isOT ? AppTheme.accent : AppTheme.gold,
                width: 1.5,
              ),
            ),
            child: Text(
              book.abbreviation,
              style: AppTheme.label(
                13,
                color: book.isOT ? AppTheme.accent : AppTheme.gold,
                weight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(book.name, style: AppTheme.display(22)),
              Text(
                book.testament == 'OT' ? 'Old Testament' : 'New Testament',
                style: AppTheme.label(13, color: AppTheme.textDim),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Last read banner ──────────────────────────────────────────
class _LastReadBanner extends StatelessWidget {
  final int chapter;
  final BibleBook book;
  const _LastReadBanner({required this.chapter, required this.book});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.goldDim.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.goldDim.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.history, color: AppTheme.gold, size: 16),
          const SizedBox(width: 8),
          Text(
            'Last read: Chapter $chapter',
            style: AppTheme.label(13, color: AppTheme.textMid),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Get.to(
              () => ReaderPage(book: book, chapter: chapter),
              transition: Transition.rightToLeft,
            ),
            child: Text(
              'Continue →',
              style: AppTheme.label(
                13,
                color: AppTheme.gold,
                weight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
