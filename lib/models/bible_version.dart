// ── Bible version ───────────────────────────────────────────────
// Public-domain translations only, so every version can be freely
// cached offline without licensing restrictions. All versions are
// fetched from bible-api.com on first read and cached afterwards —
// see BibleRemoteService.
class BibleVersion {
  final String id; // e.g. 'kjv' — also the bible-api.com translation code
  final String name;
  final String abbreviation;

  const BibleVersion({
    required this.id,
    required this.name,
    required this.abbreviation,
  });
}

const kBibleVersions = <BibleVersion>[
  BibleVersion(id: 'kjv', name: 'King James Version', abbreviation: 'KJV'),
  BibleVersion(id: 'asv', name: 'American Standard Version', abbreviation: 'ASV'),
  BibleVersion(id: 'web', name: 'World English Bible', abbreviation: 'WEB'),
  BibleVersion(id: 'ylt', name: "Young's Literal Translation", abbreviation: 'YLT'),
  BibleVersion(id: 'bbe', name: 'Bible in Basic English', abbreviation: 'BBE'),
  BibleVersion(id: 'dra', name: 'Douay-Rheims 1899', abbreviation: 'DRA'),
];

BibleVersion versionById(String id) => kBibleVersions.firstWhere(
      (v) => v.id == id,
      orElse: () => kBibleVersions.first,
    );
