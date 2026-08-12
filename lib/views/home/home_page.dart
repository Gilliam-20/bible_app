import 'package:bible_app/models/bible_models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/bible_controller.dart';
import '../../theme/app_theme.dart';
import '../../widgets/reusable_widgets.dart';
import '../books/books_page.dart';
import '../bookmarks/bookmarks_page.dart';
import '../chapters/chapters_page.dart';
import '../search/search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tab = 0;

  final List<Widget> _pages = const [
    _HomeTab(),
    BooksPage(),
    SearchPage(),
    BookmarksPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _tab, children: _pages),
      bottomNavigationBar: _BottomNav(
        current: _tab,
        onChanged: (i) => setState(() => _tab = i),
      ),
    );
  }
}

// ── Bottom navigation ─────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int current;
  final ValueChanged<int> onChanged;

  const _BottomNav({required this.current, required this.onChanged});

  static const _items = [
    (Icons.home_rounded, Icons.home_outlined, 'Home'),
    (Icons.menu_book_rounded, Icons.menu_book_outlined, 'Books'),
    (Icons.search_rounded, Icons.search_outlined, 'Search'),
    (Icons.bookmark_rounded, Icons.bookmark_border_rounded, 'Saved'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.bgCard,
        border: Border(top: BorderSide(color: AppTheme.divider)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            children: List.generate(_items.length, (i) {
              final item = _items[i];
              final active = i == current;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        active ? item.$1 : item.$2,
                        color: active ? AppTheme.gold : AppTheme.textDim,
                        size: 22,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.$3,
                        style: AppTheme.label(
                          10,
                          color: active ? AppTheme.gold : AppTheme.textDim,
                          weight: active ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ── Home Tab ──────────────────────────────────────────────────
class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<BibleController>();

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: _HeroBanner(),
            collapseMode: CollapseMode.parallax,
          ),
          backgroundColor: AppTheme.bgDeep,
          title: Text('Kjv', style: AppTheme.display(18, color: AppTheme.gold)),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Continue reading
              Obx(() {
                final lr = ctrl.lastRead.value;
                if (lr == null) return const SizedBox.shrink();
                return _ContinueCard(progress: lr);
              }),
              const SizedBox(height: 28),
              Text(
                'Verse of the Day',
                style: AppTheme.display(16, color: AppTheme.gold),
              ),
              const SizedBox(height: 12),
              const _VerseOfDayCard(),
              const SizedBox(height: 28),
              const GoldDivider(label: 'QUICK ACCESS'),
              const SizedBox(height: 20),
              _QuickAccessGrid(),
            ]),
          ),
        ),
      ],
    );
  }
}

// ── Hero banner ───────────────────────────────────────────────
class _HeroBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Gradient background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0A0B10), Color(0xFF161820), AppTheme.bgDeep],
            ),
          ),
        ),
        // Decorative elements
        Positioned(
          top: -40,
          right: -40,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [AppTheme.gold.withOpacity(0.08), Colors.transparent],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'The Holy Bible',
                style: AppTheme.display(
                  28,
                  color: AppTheme.parchment,
                  weight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '66 Books · Old & New Testament',
                style: AppTheme.label(13, color: AppTheme.textMid),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Continue reading card ─────────────────────────────────────
class _ContinueCard extends StatelessWidget {
  final ReadingProgress progress;
  const _ContinueCard({required this.progress});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<BibleController>();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.accentSoft, Color(0xFF1A2540)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accent.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CONTINUE READING',
                  style: AppTheme.label(
                    10,
                    color: AppTheme.accent,
                    weight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  progress.reference,
                  style: AppTheme.display(20, color: AppTheme.parchment),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              final book = ctrl.bookById(progress.bookId);
              if (book != null) {
                Get.to(
                  () => ChaptersPage(book: book),
                  transition: Transition.rightToLeft,
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.accent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Open',
                style: AppTheme.label(
                  13,
                  color: Colors.white,
                  weight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Verse of the day card ─────────────────────────────────────
class _VerseOfDayCard extends StatelessWidget {
  const _VerseOfDayCard();

  // Curated list
  static const _verses = [
    (
      'John 3:16',
      'For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life.',
    ),
    ('Psalm 23:1', 'The Lord is my shepherd; I shall not want.'),
    (
      'Philippians 4:13',
      'I can do all this through him who gives me strength.',
    ),
    (
      'Jeremiah 29:11',
      'For I know the plans I have for you," declares the Lord, "plans to prosper you and not to harm you, plans to give you hope and a future.',
    ),
    (
      'Romans 8:28',
      'And we know that in all things God works for the good of those who love him, who have been called according to his purpose.',
    ),
    (
      'Proverbs 3:5',
      'Trust in the Lord with all your heart and lean not on your own understanding.',
    ),
    (
      'Isaiah 40:31',
      'But those who hope in the Lord will renew their strength. They will soar on wings like eagles; they will run and not grow weary, they will walk and not be faint.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final day = DateTime.now().dayOfYear % _verses.length;
    final verse = _verses[day];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.format_quote, color: AppTheme.gold, size: 28),
          const SizedBox(height: 12),
          Text(
            verse.$2,
            style: AppTheme.body(
              16,
              color: AppTheme.parchment,
            ).copyWith(fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 16),
          const GoldDivider(),
          const SizedBox(height: 12),
          Text(
            verse.$1,
            style: AppTheme.label(
              13,
              color: AppTheme.gold,
              weight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quick access grid ─────────────────────────────────────────
class _QuickAccessGrid extends StatelessWidget {
  final _items = const [
    (Icons.book_outlined, 'Genesis', 'gen', 1),
    (Icons.music_note_outlined, 'Psalms', 'psa', 1),
    (Icons.lightbulb_outline, 'Proverbs', 'pro', 1),
    (Icons.favorite_outline, 'John', 'jhn', 1),
    (Icons.star_outline, 'Matthew', 'mat', 1),
    (Icons.local_florist_outlined, 'Romans', 'rom', 1),
  ];

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<BibleController>();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: _items.length,
      itemBuilder: (_, i) {
        final item = _items[i];
        return GestureDetector(
          onTap: () {
            final book = ctrl.bookById(item.$3);
            if (book != null) {
              Get.to(
                () => ChaptersPage(book: book),
                transition: Transition.fadeIn,
              );
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.divider),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.$1, color: AppTheme.gold, size: 24),
                const SizedBox(height: 6),
                Text(
                  item.$2,
                  style: AppTheme.label(12, color: AppTheme.textMid),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Extension to get day of year
extension _DateExt on DateTime {
  int get dayOfYear {
    final start = DateTime(year, 1, 1);
    return difference(start).inDays;
  }
}

// Placeholder import to avoid unused warning (resolved by actual class usage)
// ign
