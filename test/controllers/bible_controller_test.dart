import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bible_app/controllers/bible_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late BibleController ctrl;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    ctrl = BibleController();
    ctrl.onInit();
    // loadBooks() and _loadPreferences() run as unawaited futures from
    // onInit(); let them settle before asserting on their results.
    await Future.delayed(const Duration(milliseconds: 50));
  });

  test('loads a full 66+ book canon with both testaments represented', () {
    expect(ctrl.books.length, greaterThanOrEqualTo(66));
    expect(ctrl.books.any((b) => b.testament == 'OT'), isTrue);
    expect(ctrl.books.any((b) => b.testament == 'NT'), isTrue);
  });

  test('bookById finds a known book and returns null for an unknown id', () {
    expect(ctrl.bookById('gen')?.name, 'Genesis');
    expect(ctrl.bookById('does-not-exist'), isNull);
  });

  test('search query filters the book list by name or abbreviation', () {
    ctrl.searchQuery.value = 'john';
    expect(ctrl.filteredBooks.any((b) => b.id == 'jhn'), isTrue);
    expect(ctrl.filteredBooks.any((b) => b.id == 'gen'), isFalse);

    ctrl.searchQuery.value = '';
    expect(ctrl.filteredBooks.length, ctrl.books.length);
  });

  test('font size increases and decreases within the 12-28 clamp', () {
    ctrl.fontSize.value = 27;
    ctrl.increaseFontSize();
    ctrl.increaseFontSize();
    expect(ctrl.fontSize.value, 28);

    ctrl.fontSize.value = 13;
    ctrl.decreaseFontSize();
    ctrl.decreaseFontSize();
    expect(ctrl.fontSize.value, 12);
  });

  test('verse selection toggles on and off', () {
    expect(ctrl.selectedVerses.contains(5), isFalse);
    ctrl.toggleVerseSelection(5);
    expect(ctrl.selectedVerses.contains(5), isTrue);
    ctrl.toggleVerseSelection(5);
    expect(ctrl.selectedVerses.contains(5), isFalse);
  });
}
