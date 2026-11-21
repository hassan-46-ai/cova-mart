import 'package:flutter/material.dart';

/// Cova brand palette: electric cyan on black.
abstract final class AppColors {
  static const cyan = Color(0xFF38FFF8);
  static const black = Color(0xFF000000);
  static const white = Color(0xFFFFFFFF);
  static const star = Color(0xFFFFC83D);
  static const danger = Color(0xFFE5484D);
  static const success = Color(0xFF16A34A);
}

/// Semantic colours that differ between light and dark mode.
/// Read with `context.colors`.
@immutable
class CovaColors extends ThemeExtension<CovaColors> {
  const CovaColors({
    required this.background,
    required this.card,
    required this.cardAlt,
    required this.header,
    required this.onHeader,
    required this.text,
    required this.muted,
    required this.line,
    required this.accent,
    required this.onAccent,
    required this.fab,
    required this.onFab,
  });

  final Color background;
  final Color card;
  final Color cardAlt;
  final Color header;
  final Color onHeader;
  final Color text;
  final Color muted;
  final Color line;
  final Color accent;
  final Color onAccent;
  final Color fab;
  final Color onFab;

  static const light = CovaColors(
    background: Color(0xFFF6F8F9),
    card: Color(0xFFFFFFFF),
    cardAlt: Color(0xFFEFF2F4),
    header: Color(0xFF000000),
    onHeader: Color(0xFFFFFFFF),
    text: Color(0xFF0A0B0C),
    muted: Color(0xFF737B84),
    line: Color(0xFFE3E7EA),
    accent: AppColors.cyan,
    onAccent: AppColors.black,
    fab: AppColors.black,
    onFab: AppColors.cyan,
  );

  static const dark = CovaColors(
    background: Color(0xFF080909),
    card: Color(0xFF141617),
    cardAlt: Color(0xFF1D2022),
    header: Color(0xFF000000),
    onHeader: Color(0xFFFFFFFF),
    text: Color(0xFFF4F7F8),
    muted: Color(0xFF8B949C),
    line: Color(0xFF272B2E),
    accent: AppColors.cyan,
    onAccent: AppColors.black,
    fab: AppColors.cyan,
    onFab: AppColors.black,
  );

  @override
  CovaColors copyWith({
    Color? background,
    Color? card,
    Color? cardAlt,
    Color? header,
    Color? onHeader,
    Color? text,
    Color? muted,
    Color? line,
    Color? accent,
    Color? onAccent,
    Color? fab,
    Color? onFab,
  }) {
    return CovaColors(
      background: background ?? this.background,
      card: card ?? this.card,
      cardAlt: cardAlt ?? this.cardAlt,
      header: header ?? this.header,
      onHeader: onHeader ?? this.onHeader,
      text: text ?? this.text,
      muted: muted ?? this.muted,
      line: line ?? this.line,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      fab: fab ?? this.fab,
      onFab: onFab ?? this.onFab,
    );
  }

  @override
  CovaColors lerp(ThemeExtension<CovaColors>? other, double t) {
    if (other is! CovaColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return CovaColors(
      background: l(background, other.background),
      card: l(card, other.card),
      cardAlt: l(cardAlt, other.cardAlt),
      header: l(header, other.header),
      onHeader: l(onHeader, other.onHeader),
      text: l(text, other.text),
      muted: l(muted, other.muted),
      line: l(line, other.line),
      accent: l(accent, other.accent),
      onAccent: l(onAccent, other.onAccent),
      fab: l(fab, other.fab),
      onFab: l(onFab, other.onFab),
    );
  }
}

extension CovaColorsX on BuildContext {
  CovaColors get colors => Theme.of(this).extension<CovaColors>()!;
}
