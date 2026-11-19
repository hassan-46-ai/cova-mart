import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Builds the light / dark [ThemeData]. Manrope for English, Cairo for Arabic.
abstract final class AppTheme {
  static ThemeData light(Locale locale) => _build(Brightness.light, locale);
  static ThemeData dark(Locale locale) => _build(Brightness.dark, locale);

  static ThemeData _build(Brightness brightness, Locale locale) {
    final isLight = brightness == Brightness.light;
    final c = isLight ? CovaColors.light : CovaColors.dark;

    final scheme = ColorScheme(
      brightness: brightness,
      primary: isLight ? AppColors.black : AppColors.cyan,
      onPrimary: isLight ? AppColors.white : AppColors.black,
      secondary: AppColors.cyan,
      onSecondary: AppColors.black,
      error: AppColors.danger,
      onError: AppColors.white,
      surface: c.card,
      onSurface: c.text,
    );

    final base = ThemeData(brightness: brightness, useMaterial3: true, colorScheme: scheme);
    final fontTheme = locale.languageCode == 'ar'
        ? GoogleFonts.cairoTextTheme(base.textTheme)
        : GoogleFonts.manropeTextTheme(base.textTheme);
    final textTheme = fontTheme.apply(bodyColor: c.text, displayColor: c.text);

    final buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(18));
    final buttonText = textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w700);

    return base.copyWith(
      scaffoldBackgroundColor: c.background,
      textTheme: textTheme,
      extensions: [c],
      splashFactory: InkRipple.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: c.text,
        centerTitle: true,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          shape: buttonShape,
          foregroundColor: c.text,
          side: BorderSide(color: c.text, width: 1.3),
          textStyle: buttonText,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.text,
          textStyle: textTheme.titleSmall!.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.cardAlt,
        hintStyle: textTheme.bodyMedium!.copyWith(color: c.muted),
        labelStyle: textTheme.bodyMedium!.copyWith(color: c.muted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(cursorColor: scheme.primary),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isLight ? AppColors.black : c.cardAlt,
        contentTextStyle: textTheme.bodyMedium!.copyWith(color: AppColors.white),
        actionTextColor: AppColors.cyan,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.card,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dividerTheme: DividerThemeData(color: c.line, thickness: 1, space: 1),
    );
  }
}
