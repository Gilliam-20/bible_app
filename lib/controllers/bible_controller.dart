import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/bible_models.dart';

class BibleController extends GetxController {
  // ── State ──────────────────────────────────────────────────
  final RxList<BibleBook> books = <BibleBook>[].obs;
  final RxList<BibleBook> filteredBooks = <BibleBook>[].obs;
  final Rx<BibleChapter?> currentChapter = Rx<BibleChapter?>(null);
  final RxBool isLoadingBooks = false.obs;
  final RxBool isLoadingChapter = false.obs;
  final RxString error = ''.obs;
  final RxString searchQuery = ''.obs;
  final RxList<Bookmark> bookmarks = <Bookmark>[].obs;
  final Rx<ReadingProgress?> lastRead = Rx<ReadingProgress?>(null);
  final RxSet<int> selectedVerses = <int>{}.obs;
  final RxDouble fontSize = 17.0.obs;
  final RxBool showVerseNumbers = true.obs;
  final RxList<BibleVerse> searchResults = <BibleVerse>[].obs;
  final RxBool isSearching = false.obs;

  // Cache loaded chapters in memory
  final Map<String, BibleChapter> _chapterCache = {};

  // Asset filenames are not consistently based on the book IDs in books.json.
  // Keep the mapping in one place so every book can be opened reliably.
  static const _assetFileNames = <String, String>{
    'jos': 'Jos', 'jdg': 'Jdg', '1ch': '1Chronicles',
    '2ch': '2Chronicles', 'ezr': 'Ezra', 'neh': 'Nehemiah',
    'est': 'Esther', 'job': 'Job', 'psa': 'Psalms', 'pro': 'Proverbs',
    'ecc': 'Ecclesiastes', 'sng': 'SongofSolomon', 'isa': 'Isaiah',
    'jer': 'Jeremiah', 'lam': 'Lamentations', 'ezk': 'Ezekiel',
    'dan': 'Daniel', 'hos': 'Hosea', 'jol': 'Joel', 'amo': 'Amos',
    'oba': 'Obadiah', 'jon': 'Jonah', 'mic': 'Micah', 'nam': 'Nahum',
    'hab': 'Habakkuk', 'zep': 'Zephaniah', 'hag': 'Haggai',
    'zec': 'Zechariah', 'mal': 'Malachi', 'mat': 'Matthew', 'mrk': 'Mark',
    'luk': 'Luke', 'jhn': 'John', 'act': 'Acts', 'rom': 'Romans',
    '1co': '1Corinthians', '2co': '2Corinthians', 'gal': 'Galatians',
    'eph': 'Ephesians', 'php': 'Philippians', 'col': 'Colossians',
    '1th': '1Thessalonians', '2th': '2Thessalonians', '1ti': '1Timothy',
    '2ti': '2Timothy', 'tit': 'Titus', 'phm': 'Philemon', 'heb': 'Hebrews',
    'jas': 'James', '1pe': '1Peter', '2pe': '2Peter', '1jn': '1John',
    '2jn': '2John', '3jn': '3John', 'jud': 'Jude', 'rev': 'Revelation',
  };

  /// Expose cache for search
  BibleChapter? chapterCacheFor(String key) => _chapterCache[key];

  @override
  void onInit() {
    super.onInit();
    _loadPreferences();
    loadBooks();
    ever(searchQuery, (_) => _filterBooks());
  }

  // ── Book loading ───────────────────────────────────────────
  Future<void> loadBooks() async {
    isLoadingBooks.value = true;
    error.value = '';
    try {
      final raw = await rootBundle.loadString('assets/bible/books.json');
      final List data = json.decode(raw) as List;
      books.value = data
          .map((e) => BibleBook.fromJson(e as Map<String, dynamic>))
          .toList();
      filteredBooks.value = books;
    } catch (e) {
      // Fallback: build a canonical 66-book list so the app doesn't crash
      // when the real JSON hasn't been added yet.
      books.value = _canonicalBooks();
      filteredBooks.value = books;
    } finally {
      isLoadingBooks.value = false;
    }
  }

  // ── Chapter loading ────────────────────────────────────────
  Future<void> loadChapter(BibleBook book, int chapter) async {
    final key = '${book.id}_$chapter';
    selectedVerses.clear();
    if (_chapterCache.containsKey(key)) {
      currentChapter.value = _chapterCache[key];
      _saveReadingProgress(book, chapter);
      return;
    }

    isLoadingChapter.value = true;
    error.value = '';
    try {
      // Expected path: assets/bible/books/<bookId>.json
      // File format: { "book": "genesis", "chapters": [ [ { "verse":1, "text":"..." }, ... ], ... ] }
      final fileName = _assetFileNames[book.id] ?? book.id;
      final raw = await rootBundle.loadString('assets/bible/books/$fileName.json');
      final Map<String, dynamic> data =
          json.decode(raw) as Map<String, dynamic>;
      final List chapters = data['chapters'] as List;
      if (chapter < 1 || chapter > chapters.length) {
        throw RangeError.range(chapter, 1, chapters.length, 'chapter');
      }
      final chapterData = chapters[chapter - 1];
      final List verseList = chapterData is Map
          ? chapterData['verses'] as List
          : chapterData as List;
      final verses = verseList.asMap().entries.map((e) {
        final v = e.value;
        if (v is Map<String, dynamic>) return BibleVerse.fromJson(v);
        // Plain string format: chapters[ch][verse] = "text"
        return BibleVerse(number: e.key + 1, text: v.toString());
      }).toList();

      final ch = BibleChapter(
        bookId: book.id,
        bookName: book.name,
        chapter: chapter,
        verses: verses,
      );
      _chapterCache[key] = ch;
      currentChapter.value = ch;
      _saveReadingProgress(book, chapter);
    } catch (e) {
      error.value =
          'Could not load ${book.name} chapter $chapter.\n'
          'The chapter data could not be read. Please try again.';
    } finally {
      isLoadingChapter.value = false;
    }
  }

  // ── Search ─────────────────────────────────────────────────
  void _filterBooks() {
    final q = searchQuery.value.toLowerCase().trim();
    if (q.isEmpty) {
      filteredBooks.value = books;
      return;
    }
    filteredBooks.value = books
        .where(
          (b) =>
              b.name.toLowerCase().contains(q) ||
              b.abbreviation.toLowerCase().contains(q),
        )
        .toList();
  }

  // ── Verse selection ────────────────────────────────────────
  void toggleVerseSelection(int verseNumber) {
    if (selectedVerses.contains(verseNumber)) {
      selectedVerses.remove(verseNumber);
    } else {
      selectedVerses.add(verseNumber);
    }
  }

  void clearSelection() => selectedVerses.clear();

  // ── Bookmarks ──────────────────────────────────────────────
  void bookmarkVerse(BibleVerse verse) {
    final ch = currentChapter.value;
    if (ch == null) return;
    final bm = Bookmark(
      bookId: ch.bookId,
      bookName: ch.bookName,
      chapter: ch.chapter,
      verse: verse.number,
      text: verse.text,
      createdAt: DateTime.now().toIso8601String(),
    );
    if (!bookmarks.any(
      (b) =>
          b.bookId == bm.bookId &&
          b.chapter == bm.chapter &&
          b.verse == bm.verse,
    )) {
      bookmarks.add(bm);
      _saveBookmarks();
      Get.snackbar(
        'Bookmarked',
        '${ch.bookName} ${ch.chapter}:${verse.number}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  void removeBookmark(Bookmark bm) {
    bookmarks.removeWhere(
      (b) =>
          b.bookId == bm.bookId &&
          b.chapter == bm.chapter &&
          b.verse == bm.verse,
    );
    _saveBookmarks();
  }

  bool isBookmarked(int verseNumber) {
    final ch = currentChapter.value;
    if (ch == null) return false;
    return bookmarks.any(
      (b) =>
          b.bookId == ch.bookId &&
          b.chapter == ch.chapter &&
          b.verse == verseNumber,
    );
  }

  // ── Font size ──────────────────────────────────────────────
  void increaseFontSize() =>
      fontSize.value = (fontSize.value + 1).clamp(12, 28).toDouble();
  void decreaseFontSize() =>
      fontSize.value = (fontSize.value - 1).clamp(12, 28).toDouble();

  // ── Navigation helpers ─────────────────────────────────────
  BibleBook? bookById(String id) => books.firstWhereOrNull((b) => b.id == id);

  // ── Persistence ────────────────────────────────────────────
  Future<void> _saveBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final list = bookmarks.map((b) => json.encode(b.toJson())).toList();
    await prefs.setStringList('bookmarks', list);
  }

  Future<void> _saveReadingProgress(BibleBook book, int chapter) async {
    final prefs = await SharedPreferences.getInstance();
    final p = ReadingProgress(
      bookId: book.id,
      bookName: book.name,
      chapter: chapter,
      lastRead: DateTime.now(),
    );
    lastRead.value = p;
    await prefs.setString('last_read', json.encode(p.toJson()));
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // Bookmarks
    final bms = prefs.getStringList('bookmarks') ?? [];
    bookmarks.value = bms
        .map((s) {
          try {
            return Bookmark.fromJson(json.decode(s) as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<Bookmark>()
        .toList();

    // Last read
    final lr = prefs.getString('last_read');
    if (lr != null) {
      try {
        lastRead.value = ReadingProgress.fromJson(
          json.decode(lr) as Map<String, dynamic>,
        );
      } catch (_) {
        await prefs.remove('last_read');
      }
    }

    // Font size
    fontSize.value = prefs.getDouble('font_size') ?? 17.0;
  }

  Future<void> saveFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('font_size', fontSize.value);
  }

  // ── Canonical 66-book fallback ─────────────────────────────
  static List<BibleBook> _canonicalBooks() {
    const ot = [
      ('gen', 'Genesis', 'Gen', 66),
      ('exo', 'Exodus', 'Exo', 40),
      ('lev', 'Leviticus', 'Lev', 27),
      ('num', 'Numbers', 'Num', 36),
      ('deu', 'Deuteronomy', 'Deu', 34),
      ('jos', 'Joshua', 'Jos', 24),
      ('jdg', 'Judges', 'Jdg', 21),
      ('rut', 'Ruth', 'Rut', 4),
      ('1sa', '1 Samuel', '1Sa', 31),
      ('2sa', '2 Samuel', '2Sa', 24),
      ('1ki', '1 Kings', '1Ki', 22),
      ('2ki', '2 Kings', '2Ki', 25),
      ('1ch', '1 Chronicles', '1Ch', 29),
      ('2ch', '2 Chronicles', '2Ch', 36),
      ('ezr', 'Ezra', 'Ezr', 10),
      ('neh', 'Nehemiah', 'Neh', 13),
      ('est', 'Esther', 'Est', 10),
      ('job', 'Job', 'Job', 42),
      ('psa', 'Psalms', 'Psa', 150),
      ('pro', 'Proverbs', 'Pro', 31),
      ('ecc', 'Ecclesiastes', 'Ecc', 12),
      ('sng', 'Song of Solomon', 'Sng', 8),
      ('isa', 'Isaiah', 'Isa', 66),
      ('jer', 'Jeremiah', 'Jer', 52),
      ('lam', 'Lamentations', 'Lam', 5),
      ('ezk', 'Ezekiel', 'Ezk', 48),
      ('dan', 'Daniel', 'Dan', 12),
      ('hos', 'Hosea', 'Hos', 14),
      ('jol', 'Joel', 'Jol', 3),
      ('amo', 'Amos', 'Amo', 9),
      ('oba', 'Obadiah', 'Oba', 1),
      ('jon', 'Jonah', 'Jon', 4),
      ('mic', 'Micah', 'Mic', 7),
      ('nam', 'Nahum', 'Nam', 3),
      ('hab', 'Habakkuk', 'Hab', 3),
      ('zep', 'Zephaniah', 'Zep', 3),
      ('hag', 'Haggai', 'Hag', 2),
      ('zec', 'Zechariah', 'Zec', 14),
      ('mal', 'Malachi', 'Mal', 4),
    ];
    const nt = [
      ('mat', 'Matthew', 'Mat', 28),
      ('mrk', 'Mark', 'Mrk', 16),
      ('luk', 'Luke', 'Luk', 24),
      ('jhn', 'John', 'Jhn', 21),
      ('act', 'Acts', 'Act', 28),
      ('rom', 'Romans', 'Rom', 16),
      ('1co', '1 Corinthians', '1Co', 16),
      ('2co', '2 Corinthians', '2Co', 13),
      ('gal', 'Galatians', 'Gal', 6),
      ('eph', 'Ephesians', 'Eph', 6),
      ('php', 'Philippians', 'Php', 4),
      ('col', 'Colossians', 'Col', 4),
      ('1th', '1 Thessalonians', '1Th', 5),
      ('2th', '2 Thessalonians', '2Th', 3),
      ('1ti', '1 Timothy', '1Ti', 6),
      ('2ti', '2 Timothy', '2Ti', 4),
      ('tit', 'Titus', 'Tit', 3),
      ('phm', 'Philemon', 'Phm', 1),
      ('heb', 'Hebrews', 'Heb', 13),
      ('jas', 'James', 'Jas', 5),
      ('1pe', '1 Peter', '1Pe', 5),
      ('2pe', '2 Peter', '2Pe', 3),
      ('1jn', '1 John', '1Jn', 5),
      ('2jn', '2 John', '2Jn', 1),
      ('3jn', '3 John', '3Jn', 1),
      ('jud', 'Jude', 'Jud', 1),
      ('rev', 'Revelation', 'Rev', 22),
    ];
    return [
      ...ot.map(
        (t) => BibleBook(
          id: t.$1,
          name: t.$2,
          abbreviation: t.$3,
          testament: 'OT',
          chapters: t.$4,
        ),
      ),
      ...nt.map(
        (t) => BibleBook(
          id: t.$1,
          name: t.$2,
          abbreviation: t.$3,
          testament: 'NT',
          chapters: t.$4,
        ),
      ),
    ];
  }
}
