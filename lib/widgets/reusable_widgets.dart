import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../models/bible_models.dart';

// ── Gold divider with optional label ─────────────────────────
class GoldDivider extends StatelessWidget {
  final String? label;
  const GoldDivider({super.key, this.label});

  @override
  Widget build(BuildContext context) {
    if (label == null) {
      return Container(
        height: 1,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.transparent, AppTheme.goldDim, Colors.transparent],
          ),
        ),
      );
    }
    return Row(children: [
      const Expanded(child: GoldDivider()),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(label!, style: AppTheme.label(11, color: AppTheme.gold)),
      ),
      const Expanded(child: GoldDivider()),
    ]);
  }
}

// ── Testament badge ───────────────────────────────────────────
class TestamentBadge extends StatelessWidget {
  final String testament;
  const TestamentBadge({super.key, required this.testament});

  @override
  Widget build(BuildContext context) {
    final isOT = testament == 'OT';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isOT ? AppTheme.accentSoft : AppTheme.goldDim.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isOT ? AppTheme.accent : AppTheme.gold,
          width: 0.5,
        ),
      ),
      child: Text(
        testament,
        style: AppTheme.label(10,
            color: isOT ? AppTheme.accent : AppTheme.gold,
            weight: FontWeight.w700),
      ),
    );
  }
}

// ── Book list tile ────────────────────────────────────────────
class BookTile extends StatelessWidget {
  final BibleBook book;
  final VoidCallback onTap;

  const BookTile({super.key, required this.book, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(children: [
          // Abbreviation circle
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: book.isOT
                    ? [AppTheme.accentSoft, AppTheme.accent.withOpacity(0.3)]
                    : [AppTheme.goldDim.withOpacity(0.5), AppTheme.goldDim.withOpacity(0.15)],
              ),
            ),
            child: Text(
              book.abbreviation.substring(0, book.abbreviation.length.clamp(0, 3)),
              style: AppTheme.label(11,
                  color: book.isOT ? AppTheme.accent : AppTheme.gold,
                  weight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(book.name, style: AppTheme.body(15, weight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('${book.chapters} chapters',
                    style: AppTheme.label(12, color: AppTheme.textDim)),
              ],
            ),
          ),
          TestamentBadge(testament: book.testament),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: AppTheme.textDim, size: 18),
        ]),
      ),
    );
  }
}

// ── Chapter grid button ───────────────────────────────────────
class ChapterGridButton extends StatelessWidget {
  final int chapter;
  final bool isActive;
  final VoidCallback onTap;

  const ChapterGridButton({
    super.key,
    required this.chapter,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: isActive ? AppTheme.gold : AppTheme.bgCard,
          border: Border.all(
            color: isActive ? AppTheme.gold : AppTheme.divider,
          ),
          boxShadow: isActive
              ? [BoxShadow(color: AppTheme.gold.withOpacity(0.25), blurRadius: 8)]
              : null,
        ),
        child: Text(
          '$chapter',
          style: AppTheme.label(14,
              color: isActive ? AppTheme.bgDeep : AppTheme.textMid,
              weight: isActive ? FontWeight.w700 : FontWeight.w500),
        ),
      ),
    );
  }
}

// ── Verse tile ────────────────────────────────────────────────
class VerseTile extends StatelessWidget {
  final BibleVerse verse;
  final bool isSelected;
  final bool isBookmarked;
  final bool showNumber;
  final double fontSize;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onBookmark;

  const VerseTile({
    super.key,
    required this.verse,
    required this.isSelected,
    required this.isBookmarked,
    required this.showNumber,
    required this.fontSize,
    required this.onTap,
    required this.onLongPress,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: () {
        HapticFeedback.lightImpact();
        onLongPress();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? AppTheme.gold.withOpacity(0.12)
              : Colors.transparent,
          border: isSelected
              ? Border.all(color: AppTheme.gold.withOpacity(0.4))
              : Border.all(color: Colors.transparent),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showNumber)
              SizedBox(
                width: 28,
                child: Text(
                  '${verse.number}',
                  style: AppTheme.label(11, color: AppTheme.gold),
                ),
              ),
            Expanded(
              child: Text(
                verse.text,
                style: AppTheme.body(fontSize, color: AppTheme.parchment),
              ),
            ),
            if (isSelected)
              GestureDetector(
                onTap: onBookmark,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, top: 2),
                  child: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: isBookmarked ? AppTheme.gold : AppTheme.textDim,
                    size: 18,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Bookmark list tile ────────────────────────────────────────
class BookmarkTile extends StatelessWidget {
  final Bookmark bookmark;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const BookmarkTile({
    super.key,
    required this.bookmark,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('${bookmark.bookId}_${bookmark.chapter}_${bookmark.verse}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red.shade900,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.bgCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.bookmark, color: AppTheme.gold, size: 14),
                const SizedBox(width: 6),
                Text(bookmark.reference,
                    style: AppTheme.label(13, color: AppTheme.gold, weight: FontWeight.w700)),
                const Spacer(),
                Text(
                  _formatDate(bookmark.createdAt),
                  style: AppTheme.label(11, color: AppTheme.textDim),
                ),
              ]),
              const SizedBox(height: 8),
              Text(
                bookmark.text,
                style: AppTheme.body(14, color: AppTheme.textMid),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final d = DateTime.parse(iso);
      return '${d.day}/${d.month}/${d.year}';
    } catch (_) {
      return '';
    }
  }
}

// ── Search bar ────────────────────────────────────────────────
class BibleSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hint;

  const BibleSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hint = 'Search books...',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTheme.body(15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTheme.label(14, color: AppTheme.textDim),
          prefixIcon: const Icon(Icons.search, color: AppTheme.textDim, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

// ── Loading shimmer placeholder ───────────────────────────────
class ShimmerBox extends StatefulWidget {
  final double height;
  final double width;
  final double radius;
  const ShimmerBox({super.key, this.height = 20, this.width = double.infinity, this.radius = 8});

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
    _anim = Tween<double>(begin: -1, end: 2).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: [
              (_anim.value - 1).clamp(0, 1),
              _anim.value.clamp(0, 1),
              (_anim.value + 1).clamp(0, 1),
            ],
            colors: const [AppTheme.bgCard, AppTheme.bgSurface, AppTheme.bgCard],
          ),
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppTheme.goldDim, size: 56),
            const SizedBox(height: 20),
            Text(title, style: AppTheme.display(18), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(subtitle,
                style: AppTheme.label(14, color: AppTheme.textDim),
                textAlign: TextAlign.center),
            if (action != null) ...[const SizedBox(height: 24), action!],
          ],
        ),
      ),
    );
  }
}

// ── Gold icon button ──────────────────────────────────────────
class GoldIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  const GoldIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.bgCard,
            border: Border.all(color: AppTheme.divider),
          ),
          child: Icon(icon, color: AppTheme.gold, size: 20),
        ),
      ),
    );
  }
}
