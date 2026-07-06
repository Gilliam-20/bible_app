import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/bible_controller.dart';
import '../../models/bible_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/reusable_widgets.dart';

class ReaderPage extends StatefulWidget {
  final BibleBook book;
  final int chapter;

  const ReaderPage({super.key, required this.book, required this.chapter});

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  final ctrl = Get.find<BibleController>();
  late int _chapter;
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _chapter = widget.chapter;
    _loadChapter();
  }

  void _loadChapter() {
    ctrl.loadChapter(widget.book, _chapter);
    _scroll.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _goPrev() {
    if (_chapter > 1) {
      setState(() => _chapter--);
      _loadChapter();
    }
  }

  void _goNext() {
    if (_chapter < widget.book.chapters) {
      setState(() => _chapter++);
      _loadChapter();
    }
  }

  void _copySelected() {
    final ch = ctrl.currentChapter.value;
    if (ch == null) return;
    final selected = ch.verses
        .where((v) => ctrl.selectedVerses.contains(v.number))
        .map((v) => '${ch.bookName} ${ch.chapter}:${v.number} — ${v.text}')
        .join('\n\n');
    Clipboard.setData(ClipboardData(text: selected));
    Get.snackbar('Copied', 'Verses copied to clipboard',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2));
    ctrl.clearSelection();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      body: SafeArea(
        child: Column(children: [
          _ReaderAppBar(
            book: widget.book,
            chapter: _chapter,
            onFontIncrease: () { ctrl.increaseFontSize(); ctrl.saveFontSize(); },
            onFontDecrease: () { ctrl.decreaseFontSize(); ctrl.saveFontSize(); },
            onToggleVerseNumbers: () =>
                ctrl.showVerseNumbers.value = !ctrl.showVerseNumbers.value,
          ),
          Expanded(
            child: Obx(() {
              if (ctrl.isLoadingChapter.value) return _buildLoading();
              if (ctrl.error.value.isNotEmpty) return _buildError();
              final ch = ctrl.currentChapter.value;
              if (ch == null) return const SizedBox.shrink();
              return _VerseList(chapter: ch, scrollCtrl: _scroll);
            }),
          ),
          // ── Selection bar ──────────────────────────────────────
          Obx(() {
            if (ctrl.selectedVerses.isEmpty) return const SizedBox.shrink();
            return _SelectionBar(
              count: ctrl.selectedVerses.length,
              onCopy: _copySelected,
              onClear: ctrl.clearSelection,
            );
          }),
          // ── Navigation bar ─────────────────────────────────────
          _ChapterNavBar(
            chapter: _chapter,
            totalChapters: widget.book.chapters,
            onPrev: _goPrev,
            onNext: _goNext,
          ),
        ]),
      ),
    );
  }

  Widget _buildLoading() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: 8,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => ShimmerBox(height: 60 + (__ % 3) * 20.0),
    );
  }

  Widget _buildError() {
    return EmptyState(
      icon: Icons.error_outline,
      title: 'Chapter not found',
      subtitle: ctrl.error.value,
      action: ElevatedButton.icon(
        onPressed: _loadChapter,
        icon: const Icon(Icons.refresh),
        label: const Text('Retry'),
        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.gold),
      ),
    );
  }
}

// ── Reader app bar ────────────────────────────────────────────
class _ReaderAppBar extends StatelessWidget {
  final BibleBook book;
  final int chapter;
  final VoidCallback onFontIncrease;
  final VoidCallback onFontDecrease;
  final VoidCallback onToggleVerseNumbers;

  const _ReaderAppBar({
    required this.book,
    required this.chapter,
    required this.onFontIncrease,
    required this.onFontDecrease,
    required this.onToggleVerseNumbers,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      decoration: const BoxDecoration(
        color: AppTheme.bgDeep,
        border: Border(bottom: BorderSide(color: AppTheme.divider)),
      ),
      child: Row(children: [
        GestureDetector(
          onTap: () => Get.back(),
          child: const Padding(
            padding: EdgeInsets.all(10),
            child: Icon(Icons.arrow_back_ios_new, color: AppTheme.gold, size: 20),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(book.name, style: AppTheme.display(16)),
              Text('Chapter $chapter',
                  style: AppTheme.label(12, color: AppTheme.gold)),
            ],
          ),
        ),
        GoldIconButton(icon: Icons.text_decrease, onTap: onFontDecrease, tooltip: 'Decrease font'),
        const SizedBox(width: 6),
        GoldIconButton(icon: Icons.text_increase, onTap: onFontIncrease, tooltip: 'Increase font'),
        const SizedBox(width: 6),
        Obx(() {
          final ctrl = Get.find<BibleController>();
          return GoldIconButton(
            icon: ctrl.showVerseNumbers.value ? Icons.format_list_numbered : Icons.subject,
            onTap: onToggleVerseNumbers,
            tooltip: 'Toggle verse numbers',
          );
        }),
      ]),
    );
  }
}

// ── Verse list ────────────────────────────────────────────────
class _VerseList extends StatelessWidget {
  final BibleChapter chapter;
  final ScrollController scrollCtrl;

  const _VerseList({required this.chapter, required this.scrollCtrl});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<BibleController>();

    return Obx(() => ListView.builder(
      controller: scrollCtrl,
      padding: const EdgeInsets.fromLTRB(12, 20, 12, 20),
      itemCount: chapter.verses.length + 1,
      itemBuilder: (_, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
            child: Text(
              '${chapter.bookName} ${chapter.chapter}',
              style: AppTheme.display(26, color: AppTheme.gold),
            ),
          );
        }
        final verse = chapter.verses[i - 1];
        return VerseTile(
          verse: verse,
          isSelected: ctrl.selectedVerses.contains(verse.number),
          isBookmarked: ctrl.isBookmarked(verse.number),
          showNumber: ctrl.showVerseNumbers.value,
          fontSize: ctrl.fontSize.value,
          onTap: () => ctrl.toggleVerseSelection(verse.number),
          onLongPress: () => ctrl.toggleVerseSelection(verse.number),
          onBookmark: () => ctrl.bookmarkVerse(verse),
        );
      },
    ));
  }
}

// ── Selection action bar ──────────────────────────────────────
class _SelectionBar extends StatelessWidget {
  final int count;
  final VoidCallback onCopy;
  final VoidCallback onClear;

  const _SelectionBar({required this.count, required this.onCopy, required this.onClear});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<BibleController>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: AppTheme.bgSurface,
      child: Row(children: [
        Text('$count selected',
            style: AppTheme.label(13, color: AppTheme.gold, weight: FontWeight.w700)),
        const Spacer(),
        // Bookmark all selected
        GoldIconButton(
          icon: Icons.bookmark_add_outlined,
          tooltip: 'Bookmark selected',
          onTap: () {
            final ch = ctrl.currentChapter.value;
            if (ch == null) return;
            for (final v in ch.verses.where((v) => ctrl.selectedVerses.contains(v.number))) {
              ctrl.bookmarkVerse(v);
            }
            ctrl.clearSelection();
          },
        ),
        const SizedBox(width: 8),
        GoldIconButton(icon: Icons.copy, tooltip: 'Copy', onTap: onCopy),
        const SizedBox(width: 8),
        GoldIconButton(icon: Icons.close, tooltip: 'Clear', onTap: onClear),
      ]),
    );
  }
}

// ── Chapter prev/next navigation ──────────────────────────────
class _ChapterNavBar extends StatelessWidget {
  final int chapter;
  final int totalChapters;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _ChapterNavBar({
    required this.chapter,
    required this.totalChapters,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: AppTheme.bgCard,
        border: Border(top: BorderSide(color: AppTheme.divider)),
      ),
      child: Row(children: [
        _NavButton(
          label: '← Prev',
          enabled: chapter > 1,
          onTap: onPrev,
        ),
        Expanded(
          child: Text(
            '$chapter / $totalChapters',
            textAlign: TextAlign.center,
            style: AppTheme.label(13, color: AppTheme.textMid),
          ),
        ),
        _NavButton(
          label: 'Next →',
          enabled: chapter < totalChapters,
          onTap: onNext,
          alignRight: true,
        ),
      ]),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onTap;
  final bool alignRight;

  const _NavButton({
    required this.label,
    required this.enabled,
    required this.onTap,
    this.alignRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: enabled ? AppTheme.bgSurface : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: enabled ? AppTheme.divider : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: AppTheme.label(13,
              color: enabled ? AppTheme.gold : AppTheme.textDim,
              weight: enabled ? FontWeight.w700 : FontWeight.w400),
        ),
      ),
    );
  }
}
