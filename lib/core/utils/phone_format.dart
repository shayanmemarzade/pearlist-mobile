import 'package:flutter/services.dart';

/// Digits only, without a leading US country code.
String phoneDigits(String input) {
  var digits = input.replaceAll(RegExp(r'\D'), '');
  if (digits.length == 11 && digits.startsWith('1')) {
    digits = digits.substring(1);
  }
  return digits;
}

/// A NANP number: 10 digits, area code and exchange not starting with 0/1.
bool isValidUsPhone(String input) {
  final d = phoneDigits(input);
  return d.length == 10 &&
      !d.startsWith(RegExp('[01]')) &&
      !d.substring(3).startsWith(RegExp('[01]'));
}

/// "(415) 555-0132" for up to 10 digits; partial input formats as typed.
String formatUsPhone(String input) {
  final d = phoneDigits(input);
  if (d.isEmpty) return '';
  if (d.length <= 3) return '($d';
  if (d.length <= 6) return '(${d.substring(0, 3)}) ${d.substring(3)}';
  final end = d.length > 10 ? 10 : d.length;
  return '(${d.substring(0, 3)}) ${d.substring(3, 6)}-${d.substring(6, end)}';
}

/// "+1 (415) 555-0132".
String formatUsPhoneInternational(String input) => '+1 ${formatUsPhone(input)}';

/// Rough email check, enough to enable a button.
bool looksLikeEmail(String input) =>
    RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$').hasMatch(input.trim());

/// Formats the US phone field as the user types.
class UsPhoneInputFormatter extends TextInputFormatter {
  const UsPhoneInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    // Deleting a formatting character (")", " ", "-") should delete the
    // digit before it, otherwise backspace gets stuck.
    final oldDigits = oldValue.text.replaceAll(RegExp(r'\D'), '');
    if (newValue.text.length < oldValue.text.length &&
        digits == oldDigits &&
        digits.isNotEmpty) {
      digits = digits.substring(0, digits.length - 1);
    }
    if (digits.length > 10) digits = digits.substring(0, 10);
    final text = formatUsPhone(digits);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
