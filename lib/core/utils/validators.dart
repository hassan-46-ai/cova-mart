/// Input validation helpers. Each returns true when the value is valid.
abstract final class Validators {
  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final _egyptPhone = RegExp(r'^(\+?20|0)1[0125]\d{8}$');

  static bool email(String v) => _email.hasMatch(v.trim());

  /// Egyptian mobile: 01XXXXXXXXX, 201XXXXXXXXX or +201XXXXXXXXX.
  static bool egyptPhone(String v) => _egyptPhone.hasMatch(v.replaceAll(RegExp(r'[\s-]'), ''));

  static bool minLength(String v, int n) => v.length >= n;
}

/// Card checks used by the demo card form (nothing is charged or stored).
abstract final class CardValidators {
  /// Luhn checksum on a 13-16 digit number (spaces allowed).
  static bool number(String v) {
    final digits = v.replaceAll(' ', '');
    if (!RegExp(r'^\d{13,16}$').hasMatch(digits)) return false;
    var sum = 0;
    var alternate = false;
    for (var i = digits.length - 1; i >= 0; i--) {
      var n = int.parse(digits[i]);
      if (alternate) {
        n *= 2;
        if (n > 9) n -= 9;
      }
      sum += n;
      alternate = !alternate;
    }
    return sum % 10 == 0;
  }

  /// MM/YY that is not in the past.
  static bool expiry(String v, DateTime now) {
    final m = RegExp(r'^(\d{2})/(\d{2})$').firstMatch(v);
    if (m == null) return false;
    final month = int.parse(m.group(1)!);
    final year = 2000 + int.parse(m.group(2)!);
    if (month < 1 || month > 12) return false;
    return year > now.year || (year == now.year && month >= now.month);
  }

  static bool cvc(String v) => RegExp(r'^\d{3,4}$').hasMatch(v);
}
