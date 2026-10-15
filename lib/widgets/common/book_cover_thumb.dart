import 'package:flutter/material.dart';

import '../../config/app_theme.dart';

class BookCoverThumb extends StatelessWidget {
  final String? imageUrl;
  final String title;
  final double width;
  final double height;

  const BookCoverThumb({
    super.key,
    this.imageUrl,
    required this.title,
    this.width = 48,
    this.height = 68,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border, width: 1),
        color: AppColors.borderSubtle,
      ),
      clipBehavior: Clip.antiAlias,
      child: (imageUrl != null && imageUrl!.isNotEmpty)
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _fallbackCover(),
            )
          : _fallbackCover(),
    );
  }

  Widget _fallbackCover() {
    return Container(
      color: AppColors.sidebarBlue.withValues(alpha: 0.1),
      padding: const EdgeInsets.all(4),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.menu_book, size: 18, color: AppColors.primaryBlue),
            const SizedBox(height: 2),
            Text(
              title,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
