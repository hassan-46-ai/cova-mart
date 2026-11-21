/// Normalises Arabic/English text so search ignores diacritics, hamza forms
/// and ta-marbuta / alef-maqsura differences.
String normalizeSearch(String input) {
  var t = input.toLowerCase().trim();
  t = t.replaceAll(RegExp('[\u064B-\u065F\u0670\u0640]'), '');
  t = t
      .replaceAll(RegExp('[أإآ]'), 'ا')
      .replaceAll('ى', 'ي')
      .replaceAll('ة', 'ه');
  return t;
}

/// First letter of a name, for avatars.
String initialOf(String name) {
  final t = name.trim();
  return t.isEmpty ? '?' : String.fromCharCode(t.runes.first).toUpperCase();
}
