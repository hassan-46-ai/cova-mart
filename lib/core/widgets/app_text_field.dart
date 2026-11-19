import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    this.inputFormatters,
    this.readOnly = false,
    this.onTap,
    this.maxLines = 1,
    this.autofillHints,
    this.textDirection,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;
  final VoidCallback? onTap;
  final int maxLines;
  final Iterable<String>? autofillHints;
  final TextDirection? textDirection;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textInputAction: textInputAction,
      onFieldSubmitted: onSubmitted,
      inputFormatters: inputFormatters,
      readOnly: readOnly,
      onTap: onTap,
      maxLines: maxLines,
      autofillHints: autofillHints,
      textDirection: textDirection,
      style: const TextStyle(fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 21, color: c.muted),
        suffixIcon: suffix,
      ),
    );
  }
}
