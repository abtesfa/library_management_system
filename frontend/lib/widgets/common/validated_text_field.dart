import 'package:flutter/material.dart';

import 'form_validators.dart';
import 'required_label.dart';

class ValidatedTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final String? helperText;
  final TextEditingController controller;

  final bool required;
  final bool email;
  final bool phone;
  final bool positiveInteger;
  final bool nonNegativeNumber;
  final bool showOptionalLabel;

  final TextInputType keyboardType;
  final int maxLines;
  final bool obscureText;
  final bool enabled;

  final String? Function(String?)? customValidator;
  final void Function(String)? onChanged;
  final VoidCallback? onTap;

  const ValidatedTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.helperText,
    this.required = false,
    this.email = false,
    this.phone = false,
    this.positiveInteger = false,
    this.nonNegativeNumber = false,
    this.showOptionalLabel = true,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.obscureText = false,
    this.enabled = true,
    this.customValidator,
    this.onChanged,
    this.onTap,
  });

  String? _validate(String? value) {
    if (required && (value == null || value.trim().isEmpty)) {
      return '$label is required.';
    }

    if (email) {
      final result = FormValidators.email(
        value,
        required: required,
      );
      if (result != null) return result;
    }

    if (phone) {
      final result = FormValidators.phone(
        value,
        required: required,
      );
      if (result != null) return result;
    }

    if (positiveInteger) {
      if (value == null || value.trim().isEmpty) {
        return required ? '$label is required.' : null;
      }

      final result = FormValidators.positiveInteger(value);
      if (result != null) return result;
    }

    if (nonNegativeNumber) {
      if (value == null || value.trim().isEmpty) {
        return required ? '$label is required.' : null;
      }

      final result = FormValidators.nonNegativeNumber(value);
      if (result != null) return result;
    }

    return customValidator?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: obscureText ? 1 : maxLines,
      obscureText: obscureText,
      enabled: enabled,
      onChanged: onChanged,
      onTap: onTap,
      validator: _validate,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        label: RequiredLabel(
          label: label,
          required: required,
          showOptionalLabel: showOptionalLabel,
        ),
        hintText: hint,
        helperText: helperText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Color(0xFFD0D7E2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Color(0xFF0052CC),
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.red,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}