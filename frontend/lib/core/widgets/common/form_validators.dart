
import 'package:flutter/material.dart';

class FormValidators {
  static String? requiredField(
    String? value, {
    String fieldName = 'This field',
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }
    return null;
  }

  static String? email(String? value, {bool required = false}) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return required ? 'Email address is required.' : null;
    }

    final pattern = RegExp(
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
    );

    if (!pattern.hasMatch(text)) {
      return 'Enter a valid email address.';
    }

    return null;
  }

  static String? phone(String? value, {bool required = false}) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return required ? 'Phone number is required.' : null;
    }

    // Accepts digits, spaces, +, parentheses and hyphens.
    if (!RegExp(r'^[+0-9()\-\s]+$').hasMatch(text)) {
      return 'Enter a valid phone number.';
    }

    final digits = text.replaceAll(RegExp(r'\D'), '');

    if (digits.length < 7 || digits.length > 15) {
      return 'Phone number must contain 7–15 digits.';
    }

    return null;
  }

  static String? positiveInteger(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'This field is required.';
    }

    final number = int.tryParse(text);

    if (number == null || number <= 0) {
      return 'Enter a valid number greater than zero.';
    }

    return null;
  }

  static String? nonNegativeNumber(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'This field is required.';
    }

    final number = double.tryParse(text);

    if (number == null || number < 0) {
      return 'Enter a valid non-negative number.';
    }

    return null;
  }

  // Use this for Staff Management:
  // At least one of email or phone must be entered.
  static String? contactValidator({
    required TextEditingController emailController,
    required TextEditingController phoneController,
    required bool validateEmailField,
  }) {
    final emailValue = emailController.text.trim();
    final phoneValue = phoneController.text.trim();

    if (emailValue.isEmpty && phoneValue.isEmpty) {
      return 'Enter either an email address or a phone number.';
    }

    if (validateEmailField && emailValue.isNotEmpty) {
      return email(emailValue);
    }

    if (!validateEmailField && phoneValue.isNotEmpty) {
      return phone(phoneValue);
    }

    return null;
  }
}