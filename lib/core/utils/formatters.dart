import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

extension LocaleContextX on BuildContext {
  String get lang => Localizations.localeOf(this).languageCode;
  bool get isAr => lang == 'ar';
}

/// Display formatting that respects the active language.
abstract final class Fmt {
  /// 38 -> "EGP 38" / "38 ج.م". Decimals only when needed.
  static String money(BuildContext context, double value) {
    final n = value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(2);
    return context.isAr ? '$n ج.م' : 'EGP $n';
  }

  /// "19/11/2026 • 4:05 PM" (Western digits in both languages, AM/PM localised).
  static String dateTime(BuildContext context, DateTime d) {
    final s = DateFormat('dd/MM/yyyy • h:mm a', 'en').format(d);
    if (!context.isAr) return s;
    return s.replaceAll('AM', 'ص').replaceAll('PM', 'م');
  }

  static String rating(double v) => v.toStringAsFixed(1);
}
