import 'package:flutter/services.dart';

/// "1234567812345678" -> "1234 5678 1234 5678".
class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final d = digits.length > 16 ? digits.substring(0, 16) : digits;
    final buffer = StringBuffer();
    for (var i = 0; i < d.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(d[i]);
    }
    final text = buffer.toString();
    return TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}

/// "1228" -> "12/28".
class ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final d = digits.length > 4 ? digits.substring(0, 4) : digits;
    final text = d.length > 2 ? '${d.substring(0, 2)}/${d.substring(2)}' : d;
    return TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}
