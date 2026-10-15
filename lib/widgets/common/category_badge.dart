import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class CategoryBadge extends StatelessWidget {
  final String category;

  const CategoryBadge({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    // Generate distinct soft color tints based on category names
    Color bg = AppColors.infoBg;
    Color text = AppColors.infoText;

    final lower = category.toLowerCase();
    if (lower.contains('science') || lower.contains('fiction')) {
      bg = const Color(0xFFF3E8FF);
      text = const Color(0xFF7E22CE);
    } else if (lower.contains('self') || lower.contains('help')) {
      bg = const Color(0xFFEFF6FF);
      text = const Color(0xFF2563EB);
    } else if (lower.contains('computer') || lower.contains('software')) {
      bg = const Color(0xFFECFDF5);
      text = const Color(0xFF047857);
    } else if (lower.contains('history') || lower.contains('classic')) {
      bg = const Color(0xFFFFF1F2);
      text = const Color(0xFFBE123C);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        category,
        style: TextStyle(
          color: text,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}