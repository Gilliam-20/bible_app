import 'package:flutter_test/flutter_test.dart';
import 'package:bible_app/models/bible_models.dart';

void main() {
  group('BibleVerse.fromJson', () {
    test('parses integer verse numbers', () {
      final v = BibleVerse.fromJson({'verse': 1, 'text': 'In the beginning'});
      expect(v.number, 1);
      expect(v.text, 'In the beginning');
    });

    test('parses string verse numbers (alternate data set shape)', () {
      final v = BibleVerse.fromJson({'verse': '12', 'text': 'Rejoice'});
      expect(v.number, 12);
      expect(v.text, 'Rejoice');
    });

    test('falls back to "number" key when "verse" is absent', () {
      final v = BibleVerse.fromJson({'number': 3, 'text': 'Let there be light'});
      expect(v.number, 3);
    });
  });

  group('BibleBook.fromJson', () {
    test('parses a fully populated book entry', () {
      final b = BibleBook.fromJson({
        'id': 'gen',
        'name': 'Genesis',
        'abbrev': 'Gen',
        'testament': 'OT',
        'chapters': 50,
      });
      expect(b.id, 'gen');
      expect(b.abbreviation, 'Gen');
      expect(b.isOT, isTrue);
      expect(b.chapters, 50);
    });

    test('defaults testament to OT and derives abbreviation when missing', () {
      final b = BibleBook.fromJson({
        'id': 'jhn',
        'name': 'John',
        'chapters': 21,
      });
      expect(b.testament, 'OT');
      expect(b.abbreviation, 'Joh');
    });
  });

  group('Bookmark JSON round-trip', () {
    test('toJson/fromJson preserves all fields', () {
      const bm = Bookmark(
        bookId: 'jhn',
        bookName: 'John',
        chapter: 3,
        verse: 16,
        text: 'For God so loved the world',
        createdAt: '2026-01-01T00:00:00.000',
      );
      final restored = Bookmark.fromJson(bm.toJson());
      expect(restored.bookId, bm.bookId);
      expect(restored.chapter, bm.chapter);
      expect(restored.verse, bm.verse);
      expect(restored.reference, 'John 3:16');
    });
  });

  group('ReadingProgress JSON round-trip', () {
    test('toJson/fromJson preserves lastRead as a DateTime', () {
      final rp = ReadingProgress(
        bookId: 'psa',
        bookName: 'Psalms',
        chapter: 23,
        lastRead: DateTime.utc(2026, 5, 1, 12),
      );
      final restored = ReadingProgress.fromJson(rp.toJson());
      expect(restored.lastRead, rp.lastRead);
      expect(restored.reference, 'Psalms 23');
    });
  });
}
