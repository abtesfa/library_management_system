import 'package:flutter/material.dart';

class RequiredLabel extends StatelessWidget {
  final String label;
  final bool required;
  final bool showOptionalLabel;

  const RequiredLabel({
    super.key,
    required this.label,
    this.required = false,
    this.showOptionalLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: label,
            style: const TextStyle(
              color: Color(0xFF263445),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (required)
            const TextSpan(
              text: ' *',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (!required && showOptionalLabel)
            const TextSpan(
              text: ' (Optional)',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
        ],
      ),
    );
  }
}