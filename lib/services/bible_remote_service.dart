import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/bible_models.dart';
import '../models/bible_version.dart';

/// Thrown when a non-bundled chapter can't be fetched. [isNetworkError]
/// distinguishes "you're offline and it isn't cached yet" from other
/// failures (bad response, translation not found, etc.).
class BibleFetchException implements Exception {
  final String message;
  final bool isNetworkError;
  BibleFetchException(this.message, {this.isNetworkError = false});

  @override
  String toString() => message;
}

/// Fetches chapters for non-bundled [BibleVersion]s from bible-api.com and
/// caches the raw response in shared_preferences so the same chapter reads
/// offline afterwards. Bundled versions (KJV) never go through this service.
class BibleRemoteService {
  static const _base = 'https://bible-api.com/';

  static String _cacheKey(BibleVersion version, BibleBook book, int chapter) =>
      'remote_chapter_${version.id}_${book.id}_$chapter';

  static Future<BibleChapter> fetchChapter(
    BibleVersion version,
    BibleBook book,
    int chapter,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = _cacheKey(version, book, chapter);

    final cached = prefs.getString(cacheKey);
    if (cached != null) {
      return _parse(
        json.decode(cached) as Map<String, dynamic>,
        book,
        chapter,
      );
    }

    final uri = Uri.parse(
      '$_base${Uri.encodeComponent(book.name)}+$chapter'
      '?translation=${version.id}',
    );

    http.Response response;
    try {
      response = await http.get(uri).timeout(const Duration(seconds: 12));
    } on SocketException {
      throw BibleFetchException(
        'No internet connection.',
        isNetworkError: true,
      );
    } on TimeoutException {
      throw BibleFetchException(
        'The request timed out.',
        isNetworkError: true,
      );
    } on http.ClientException {
      throw BibleFetchException(
        'No internet connection.',
        isNetworkError: true,
      );
    }

    if (response.statusCode != 200) {
      throw BibleFetchException(
        'Could not load ${book.name} $chapter in ${version.abbreviation} '
        '(server returned ${response.statusCode}).',
      );
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final verses = data['verses'] as List?;
    if (verses == null || verses.isEmpty) {
      throw BibleFetchException(
        '${version.abbreviation} has no text for ${book.name} $chapter.',
      );
    }

    await prefs.setString(cacheKey, response.body);
    return _parse(data, book, chapter);
  }

  static BibleChapter _parse(
    Map<String, dynamic> data,
    BibleBook book,
    int chapter,
  ) {
    final verses = (data['verses'] as List)
        .map(
          (v) => BibleVerse(
            number: v['verse'] as int,
            text: (v['text'] as String).trim(),
          ),
        )
        .toList();
    return BibleChapter(
      bookId: book.id,
      bookName: book.name,
      chapter: chapter,
      verses: verses,
    );
  }

  static Future<bool> isCached(
    BibleVersion version,
    BibleBook book,
    int chapter,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_cacheKey(version, book, chapter));
  }
}
