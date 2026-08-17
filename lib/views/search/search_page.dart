import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/bible_controller.dart';
import '../../models/bible_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/reusable_widgets.dart';
import '../verses/reader_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final ctrl = Get.find<BibleController>();
  final _searchCtrl = TextEditingController();
  final RxList<_SearchResult> _results = <_SearchResult>[].obs;
  final RxBool _loading = false.obs;

  static const _suggestions = [
    'love',
    'faith',
    'hope',
    'grace',
    'peace',
    'strength',
    'light',
    'truth',
    'joy',
    'prayer',
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().length < 2) {
      _results.clear();
      return;
    }

    _loading.value = true;
    final q = query.toLowerCase().trim();
    final hits = <_SearchResult>[];

    // Search through currently loaded chapters in cache
    for (final entry in ctrl.books) {
      // We only search books that have been loaded into cache
      // In a real app you'd search a pre-built index
      for (int c = 1; c <= entry.chapters; c++) {
        final key = '${entry.id}_$c';
        final cached = ctrl.chapterCacheFor(key);
        if (cached == null) continue;
        for (final verse in cached.verses) {
          if (verse.text.toLowerCase().contains(q)) {
            hits.add(
              _SearchResult(
                bookName: entry.name,
                bookId: entry.id,
                chapter: cached.chapter,
                verse: verse,
              ),
            );
            if (hits.length >= 100) break;
          }
        }
        if (hits.length >= 100) break;
      }
      if (hits.length >= 100) break;
    }

    _results.value = hits;
    _loading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppTheme.bgDeep,
      body: SafeArea(
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(bottom: keyboardInset),
          child: Column(
            children: [
              // ── Header ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Search', style: AppTheme.display(24)),
                    const SizedBox(height: 16),
                    BibleSearchBar(
                      controller: _searchCtrl,
                      onChanged: _search,
                      hint: 'Search verses, words, phrases…',
                    ),
                  ],
                ),
              ),
              // ── Results / suggestions ────────────────────────────
              Expanded(
                child: Obx(() {
                  if (_loading.value) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppTheme.gold),
                    );
                  }

                  if (_searchCtrl.text.isEmpty) {
                    return _SuggestionsPanel(
                      onSuggestion: (s) {
                        _searchCtrl.text = s;
                        _search(s);
                      },
                    );
                  }

                  if (_results.isEmpty) {
                    return EmptyState(
                      icon: Icons.search_off,
                      title: 'No results',
                      subtitle: _searchCtrl.text.length < 2
                          ? 'Type at least 2 characters'
                          : 'No verses found for "${_searchCtrl.text}".\n'
                                'Note: search only covers chapters you have already opened.',
                    );
                  }

                  return _ResultsList(
                    results: _results,
                    query: _searchCtrl.text,
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Search result model ───────────────────────────────────────
class _SearchResult {
  final String bookName;
  final String bookId;
  final int chapter;
  final BibleVerse verse;

  const _SearchResult({
    required this.bookName,
    required this.bookId,
    required this.chapter,
    required this.verse,
  });

  String get reference => '$bookName $chapter:${verse.number}';
}

// ── Results list ──────────────────────────────────────────────
class _ResultsList extends StatelessWidget {
  final List<_SearchResult> results;
  final String query;

  const _ResultsList({required this.results, required this.query});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<BibleController>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
          child: Row(
            children: [
              Text(
                '${results.length}${results.length == 100 ? '+' : ''} results',
                style: AppTheme.label(13, color: AppTheme.textDim),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            itemCount: results.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final r = results[i];
              return _ResultTile(
                result: r,
                query: query,
                onTap: () {
                  final book = ctrl.bookById(r.bookId);
                  if (book != null) {
                    Get.to(
                      () => ReaderPage(book: book, chapter: r.chapter),
                      transition: Transition.rightToLeft,
                    );
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ResultTile extends StatelessWidget {
  final _SearchResult result;
  final String query;
  final VoidCallback onTap;

  const _ResultTile({
    required this.result,
    required this.query,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
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
            Row(
              children: [
                Text(
                  result.reference,
                  style: AppTheme.label(
                    12,
                    color: AppTheme.gold,
                    weight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: AppTheme.textDim,
                  size: 12,
                ),
              ],
            ),
            const SizedBox(height: 8),
            _HighlightedText(text: result.verse.text, query: query),
          ],
        ),
      ),
    );
  }
}

// ── Highlighted text with search term marked ──────────────────
class _HighlightedText extends StatelessWidget {
  final String text;
  final String query;

  const _HighlightedText({required this.text, required this.query});

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(
        text,
        style: AppTheme.body(14, color: AppTheme.textMid),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      );
    }

    final lower = text.toLowerCase();
    final lq = query.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;

    while (true) {
      final idx = lower.indexOf(lq, start);
      if (idx == -1) {
        spans.add(
          TextSpan(
            text: text.substring(start),
            style: AppTheme.body(14, color: AppTheme.textMid),
          ),
        );
        break;
      }
      if (idx > start) {
        spans.add(
          TextSpan(
            text: text.substring(start, idx),
            style: AppTheme.body(14, color: AppTheme.textMid),
          ),
        );
      }
      spans.add(
        TextSpan(
          text: text.substring(idx, idx + query.length),
          style: AppTheme.body(
            14,
            color: AppTheme.gold,
            weight: FontWeight.w700,
          ),
        ),
      );
      start = idx + query.length;
    }

    return Text.rich(
      TextSpan(children: spans),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }
}

// ── Suggestions panel (shown when query is empty) ─────────────
class _SuggestionsPanel extends StatelessWidget {
  final ValueChanged<String> onSuggestion;

  const _SuggestionsPanel({required this.onSuggestion});

  static const _suggestions = [
    'love',
    'faith',
    'hope',
    'grace',
    'peace',
    'strength',
    'light',
    'truth',
    'joy',
    'prayer',
    'salvation',
    'mercy',
    'wisdom',
    'fear',
    'trust',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Try searching for',
            style: AppTheme.label(13, color: AppTheme.textDim),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _suggestions
                .map(
                  (s) => GestureDetector(
                    onTap: () => onSuggestion(s),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.bgCard,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.divider),
                      ),
                      child: Text(
                        s,
                        style: AppTheme.label(13, color: AppTheme.textMid),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 32),
          const EmptyState(
            icon: Icons.manage_search,
            title: 'Search the Scriptures',
            subtitle: 'Search is powered by chapters you have already read.',
          ),
        ],
      ),
    );
  }
}
