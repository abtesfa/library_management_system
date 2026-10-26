
import 'package:flutter/material.dart';

class AppImages {
  // Landing page banner
  static const String landingHero =
      'https://images.unsplash.com/photo-1507842217343-583bb7270b66?w=1600';

  // Book cover URLs
  static const String cleanCode =
      'https://covers.openlibrary.org/b/isbn/9780132350884-L.jpg';

  static const String atomicHabits =
      'https://covers.openlibrary.org/b/isbn/9780735211292-L.jpg';

  static const String theMartian =
      'https://covers.openlibrary.org/b/isbn/9780553418026-L.jpg';

  static const String designPatterns =
      'https://covers.openlibrary.org/b/isbn/9780201633610-L.jpg';

  static const String thinkLikeAMonk =
      'https://covers.openlibrary.org/b/isbn/9781982134488-L.jpg';

  static const String dune =
      'https://covers.openlibrary.org/b/isbn/9780441172719-L.jpg';

  static const String sapiens =
      'https://covers.openlibrary.org/b/isbn/9780062316097-L.jpg';

  // Reusable book cover widget
  static Widget bookCover({
    required String imageUrl,
    double width = 105,
    double height = 282,
    double borderRadius = 12,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;

          return Container(
            width: width,
            height: height,
            color: const Color(0xFFE8EEFA),
            alignment: Alignment.center,
            child: const CircularProgressIndicator(
              color: Color(0xFF0052CC),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: const Color(0xFF2457C5),
            alignment: Alignment.center,
            child: const Icon(
              Icons.menu_book,
              color: Colors.white,
              size: 36,
            ),
          );
        },
      ),
    );
  }
}
