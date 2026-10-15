import 'package:flutter/material.dart';

import '../../config/app_theme.dart';

enum StatusBadgeType {
  available,
  onLoan,
  overdue,
  completed,
  lowStock,
  dueSoon,
  ready,
  custom,
}

class StatusBadge extends StatelessWidget {
  final String label;
  final StatusBadgeType type;
  final Color? customBg;
  final Color? customText;

  const StatusBadge({
    super.key,
    required this.label,
    this.type = StatusBadgeType.available,
    this.customBg,
    this.customText,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color textColor;

    switch (type) {
      case StatusBadgeType.available:
      case StatusBadgeType.completed:
        bg = AppColors.successBg;
        textColor = AppColors.successText;
        break;
      case StatusBadgeType.overdue:
        bg = AppColors.errorBg;
        textColor = AppColors.errorText;
        break;
      case StatusBadgeType.lowStock:
      case StatusBadgeType.dueSoon:
        bg = AppColors.warningBg;
        textColor = AppColors.warningText;
        break;
      case StatusBadgeType.onLoan:
      case StatusBadgeType.ready:
        bg = AppColors.infoBg;
        textColor = AppColors.infoText;
        break;
      case StatusBadgeType.custom:
        bg = customBg ?? AppColors.borderSubtle;
        textColor = customText ?? AppColors.textPrimary;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
