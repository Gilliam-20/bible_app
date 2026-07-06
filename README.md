# Scripture — Flutter Bible App

A premium Bible reading app built with **Flutter + GetX**, using direct navigation (no named routes, no bindings files).

---

## ✨ Features

| Feature | Description |
|---|---|
| 📖 All 66 Books | OT & NT, filterable tabs |
| 🔢 Chapter Grid | Tap any chapter number to open it |
| 📜 Verse Reader | Tap to select, long-press for haptics |
| 🔖 Bookmarks | Save & revisit verses (persisted via SharedPreferences) |
| 🔍 Search | Full-text search across cached chapters |
| 📏 Font Size | ±1pt adjustments, persisted |
| #️⃣ Verse Numbers | Toggle on/off |
| 📋 Copy | Copy selected verses to clipboard |
| ✨ Verse of the Day | Curated daily verse on home screen |
| 🕐 Last Read | "Continue reading" shortcut |
| 🌙 Dark Theme | Deep dark + gold — no light mode needed |

---

## 📁 Project Structure

```
lib/
├── main.dart
├── theme/
│   └── app_theme.dart           ← All colors, typography
├── models/
│   └── bible_models.dart        ← BibleBook, BibleVerse, BibleChapter, Bookmark
├── controllers/
│   └── bible_controller.dart    ← GetX controller (state + logic)
├── widgets/
│   └── reusable_widgets.dart    ← 10+ shared widgets
└── views/
    ├── home/home_page.dart       ← Dashboard + bottom nav
    ├── books/books_page.dart     ← Book list with OT/NT tabs
    ├── chapters/chapters_page.dart ← Chapter grid
    ├── verses/reader_page.dart   ← Verse reader
    ├── search/search_page.dart   ← Full-text search
    └── bookmarks/bookmarks_page.dart ← Saved verses
```

---

## 🗂️ Your Bible Asset Format

Place your files at:

```
assets/bible/
├── books.json          ← Book manifest (required)
└── books/
    ├── gen.json         ← Genesis
    ├── exo.json         ← Exodus
    ├── psa.json         ← Psalms
    ├── jhn.json         ← John
    └── ...              ← One file per book (66 total)
```

### `books.json`
```json
[
  { "id": "gen", "name": "Genesis", "abbrev": "Gen", "testament": "OT", "chapters": 50 },
  { "id": "jhn", "name": "John",    "abbrev": "Jhn", "testament": "NT", "chapters": 21 }
]
```

### Per-book file (e.g. `jhn.json`)
```json
{
  "book": "jhn",
  "chapters": [
    [
      { "verse": 1, "text": "In the beginning was the Word..." },
      { "verse": 2, "text": "He was with God in the beginning." }
    ],
    [ ... chapter 2 verses ... ]
  ]
}
```

The controller also supports plain string arrays:
```json
{ "chapters": [ ["Verse 1 text", "Verse 2 text"], [...] ] }
```

---

## 🧭 Navigation (no named routes)

```dart
// Go to chapters of a book
Get.to(() => ChaptersPage(book: book), transition: Transition.rightToLeft);

// Go directly to a chapter reader
Get.to(() => ReaderPage(book: book, chapter: 3), transition: Transition.rightToLeft);

// Go back
Get.back();
```

---

## 🏁 Getting Started

```bash
flutter pub get
flutter run
```

### pubspec.yaml — ensure assets are declared:
```yaml
flutter:
  assets:
    - assets/bible/
    - assets/bible/books/
```

---

## 🎨 Design Tokens

| Token | Value | Use |
|---|---|---|
| `bgDeep` | `#0D0E14` | Scaffold background |
| `bgCard` | `#161820` | Cards / bottom nav |
| `bgSurface` | `#1E2030` | Sheets / modals |
| `gold` | `#C9A84C` | Primary accent |
| `parchment` | `#F5EED8` | Body text |
| `accent` | `#4A6FA5` | OT / secondary |

Typography: **Playfair Display** (headings) + **Lora** (body) + **Inter** (labels)

---

## 📦 Dependencies

```yaml
get: ^4.6.6
shared_preferences: ^2.2.2
google_fonts: ^6.1.0
flutter_svg: ^2.0.9
animations: ^2.0.11
```
