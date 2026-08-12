// ── Book ─────────────────────────────────────────────────────
class BibleBook {
  final String id;
  final String name;
  final String abbreviation;
  final String testament; // "OT" | "NT"
  final int chapters;

  const BibleBook({
    required this.id,
    required this.name,
    required this.abbreviation,
    required this.testament,
    required this.chapters,
  });

  factory BibleBook.fromJson(Map<String, dynamic> j) => BibleBook(
        id: j['id'] as String,
        name: j['name'] as String,
        abbreviation: j['abbrev'] as String? ?? j['name'].toString().substring(0, 3),
        testament: j['testament'] as String? ?? 'OT',
        chapters: j['chapters'] as int,
      );

  bool get isOT => testament == 'OT';
}

// ── Verse ─────────────────────────────────────────────────────
class BibleVerse {
  final int number;
  final String text;

  const BibleVerse({required this.number, required this.text});

  factory BibleVerse.fromJson(Map<String, dynamic> j) => BibleVerse(
        // The bundled translation stores verse numbers as strings, while
        // other supported data sets use integers.
        number: int.parse((j['verse'] ?? j['number']).toString()),
        text: j['text'].toString(),
      );
}

// ── Chapter ───────────────────────────────────────────────────
class BibleChapter {
  final String bookId;
  final String bookName;
  final int chapter;
  final List<BibleVerse> verses;

  const BibleChapter({
    required this.bookId,
    required this.bookName,
    required this.chapter,
    required this.verses,
  });
}

// ── Bookmark ──────────────────────────────────────────────────
class Bookmark {
  final String bookId;
  final String bookName;
  final int chapter;
  final int verse;
  final String text;
  final String createdAt;

  const Bookmark({
    required this.bookId,
    required this.bookName,
    required this.chapter,
    required this.verse,
    required this.text,
    required this.createdAt,
  });

  String get reference => '$bookName $chapter:$verse';

  Map<String, dynamic> toJson() => {
        'bookId': bookId,
        'bookName': bookName,
        'chapter': chapter,
        'verse': verse,
        'text': text,
        'createdAt': createdAt,
      };

  factory Bookmark.fromJson(Map<String, dynamic> j) => Bookmark(
        bookId: j['bookId'] as String,
        bookName: j['bookName'] as String,
        chapter: j['chapter'] as int,
        verse: j['verse'] as int,
        text: j['text'] as String,
        createdAt: j['createdAt'] as String,
      );
}

// ── Reading Plan (daily progress) ────────────────────────────
class ReadingProgress {
  final String bookId;
  final String bookName;
  final int chapter;
  final DateTime lastRead;

  const ReadingProgress({
    required this.bookId,
    required this.bookName,
    required this.chapter,
    required this.lastRead,
  });

  Map<String, dynamic> toJson() => {
        'bookId': bookId,
        'bookName': bookName,
        'chapter': chapter,
        'lastRead': lastRead.toIso8601String(),
      };

  factory ReadingProgress.fromJson(Map<String, dynamic> j) => ReadingProgress(
        bookId: j['bookId'] as String,
        bookName: j['bookName'] as String,
        chapter: j['chapter'] as int,
        lastRead: DateTime.parse(j['lastRead'] as String),
      );

  String get reference => '$bookName $chapter';
}
