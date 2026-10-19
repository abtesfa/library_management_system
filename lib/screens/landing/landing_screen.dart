import 'package:flutter/material.dart';

import '/../models/user.dart';
import '/../widgets/dialogs/sign_in_dialog.dart';
import '/../data/mock_library_data.dart';
import '/../models/book.dart';
import '/../config/app_images.dart';

class LandingScreen extends StatelessWidget {
  final Function(UserRole role) onEnterPortal;
  final GlobalKey homeKey = GlobalKey();
  final GlobalKey booksKey = GlobalKey();
  final GlobalKey categoriesKey = GlobalKey();
  final GlobalKey aboutKey = GlobalKey();
  final GlobalKey contactKey = GlobalKey();

  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  LandingScreen({
    super.key,
    required this.onEnterPortal,
  });

  void _openSignIn(
    BuildContext context, [
    UserRole role = UserRole.admin,
  ]) {
    showDialog(
      context: context,
      builder: (ctx) => SignInDialog(
        initialRole: role,
        onSignIn: onEnterPortal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final featuredBooks = MockLibraryData.getInitialBooks().take(6).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          color: const Color(0xFF0052CC),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.menu_book,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Library Management System',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _navLink('Home', true, () => _scrollToSection(homeKey)),
                  _navLink(
                      'Browse Books', false, () => _scrollToSection(booksKey)),
                  _navLink('Categories', false,
                      () => _scrollToSection(categoriesKey)),
                  _navLink('About', false, () => _scrollToSection(aboutKey)),
                  _navLink(
                      'Contact', false, () => _scrollToSection(contactKey)),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => _openSignIn(context),
                    icon: const Icon(Icons.login, size: 16),
                    label: const Text('Sign In'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0052CC),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. HERO SECTION
            Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(36),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFBFDBFE),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.menu_book,
                                size: 14,
                                color: Color(0xFF1D4ED8),
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Knowledge Builds a Brighter Future',
                                style: TextStyle(
                                  color: Color(0xFF1D4ED8),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                              height: 1.15,
                            ),
                            children: [
                              TextSpan(text: 'Discover. Learn. '),
                              TextSpan(
                                text: 'Grow.',
                                style: TextStyle(
                                  color: Color(0xFF1877F2),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'The Library Management System helps you '
                          'explore thousands of books, manage your '
                          'reading journey, and access knowledge '
                          'whenever you need it.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFFCBD5E1),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.search,
                                size: 20,
                                color: Color(0xFF94A3B8),
                              ),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Search books, authors, ISBN...',
                                    hintStyle: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF94A3B8),
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () => _openSignIn(
                                  context,
                                  UserRole.reader,
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1877F2),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text('Search'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 32),

                  // LIBRARY IMAGE WITH 1,200+ BOOKS TEXT
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 300,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFBFDBFE),
                        ),
                        image: const DecorationImage(
                          image: NetworkImage(
                            'https://images.unsplash.com/photo-1507842217343-583bb7270b66?w=1200',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.10),
                              Colors.black.withValues(alpha: 0.78),
                            ],
                          ),
                        ),
                        alignment: Alignment.bottomLeft,
                        padding: const EdgeInsets.all(24),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.auto_stories,
                              size: 38,
                              color: Colors.white,
                            ),
                            SizedBox(height: 12),
                            Text(
                              '1,200+ Books',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Discover a world of knowledge',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. LIBRARY STATISTICS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  children: [
                    _buildMetric(
                      Icons.book,
                      '1,200+',
                      'Books Available',
                    ),
                    _buildMetric(
                      Icons.people_outline,
                      '350+',
                      'Registered Members',
                    ),
                    _buildMetric(
                      Icons.access_time,
                      '24/7',
                      'Online Access',
                    ),
                    _buildMetric(
                      Icons.shield_outlined,
                      'Secure',
                      '& Reliable',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 3. FEATURE CARDS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: _buildFeatureCard(
                      icon: Icons.menu_book,
                      title: 'Browse Books',
                      desc: 'Explore our collection of books and find '
                          'your next read across diverse genres.',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildFeatureCard(
                      icon: Icons.search,
                      title: 'Search & Discover',
                      desc: 'Find books by title, author, ISBN, or '
                          'category and discover your next read.',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 4. FEATURED BOOKS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.auto_stories,
                              color: Color(0xFF0052CC),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Featured Books',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        TextButton.icon(
                          onPressed: () => _openSignIn(
                            context,
                            UserRole.reader,
                          ),
                          icon: const Text(
                            'View All Books',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1877F2),
                            ),
                          ),
                          label: const Icon(
                            Icons.arrow_forward,
                            size: 14,
                            color: Color(0xFF1877F2),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 260,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: featuredBooks.length,
                        separatorBuilder: (ctx, i) => const SizedBox(width: 12),
                        itemBuilder: (ctx, index) {
                          return _buildBookCard(
                            context,
                            featuredBooks[index],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 5. HOW IT WORKS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'How It Works',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Access library services in three simple steps.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStep(
                          '1',
                          'Create an Account',
                          'Sign up as a member and get access to '
                              'library services.',
                        ),
                        const SizedBox(width: 16),
                        _buildStep(
                          '2',
                          'Discover a Book',
                          'Search our collection by title, author, '
                              'or category.',
                        ),
                        const SizedBox(width: 16),
                        _buildStep(
                          '3',
                          'Borrow or Reserve',
                          'Reserve a book and enjoy your reading '
                              'journey.',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // 6. FOOTER
            _buildLandingFooter(context),
          ],
        ),
      ),
    );
  }

  // FOOTER
  Widget _buildLandingFooter(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF002D72),
      padding: const EdgeInsets.fromLTRB(32, 36, 32, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final brand = _footerBrand();
              final links = _footerLinks(context);
              final contact = _footerContact();

              if (constraints.maxWidth < 700) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    brand,
                    const SizedBox(height: 28),
                    links,
                    const SizedBox(height: 28),
                    contact,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: brand),
                  const SizedBox(width: 32),
                  Expanded(child: links),
                  const SizedBox(width: 32),
                  Expanded(child: contact),
                ],
              );
            },
          ),
          const SizedBox(height: 28),
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.18),
          ),
          const SizedBox(height: 16),
          const Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 8,
            children: [
              Text(
                '© 2026 Library Management System. All rights reserved.',
                style: TextStyle(
                  color: Color(0xFFBFDBFE),
                  fontSize: 12,
                ),
              ),
              Text(
                'Better Readers · Stronger Communities · Brighter Futures',
                style: TextStyle(
                  color: Color(0xFFBFDBFE),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _footerBrand() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.menu_book,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Library Management System',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const Text(
          'Discover books, build knowledge, and make reading part '
          'of your everyday journey. Your next great read starts here.',
          style: TextStyle(
            color: Color(0xFFBFDBFE),
            fontSize: 13,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _footerLinks(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'QUICK LINKS',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 14),
        _footerLink('Home', () {}),
        _footerLink(
          'Browse Books',
          () => _openSignIn(context, UserRole.reader),
        ),
        _footerLink(
          'Reader Sign In',
          () => _openSignIn(context, UserRole.reader),
        ),
        _footerLink(
          'Staff Sign In',
          () => _openSignIn(context, UserRole.librarian),
        ),
      ],
    );
  }

  Widget _footerContact() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'CONTACT US',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.email_outlined,
              color: Color(0xFF93C5FD),
              size: 18,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'centralacademy@example.com',
                style: TextStyle(
                  color: Color(0xFFBFDBFE),
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.location_on_outlined,
              color: Color(0xFF93C5FD),
              size: 18,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                '5kilo,Addis Ababa',
                style: TextStyle(
                  color: Color(0xFFBFDBFE),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _footerLink(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFFBFDBFE),
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // TOP NAVIGATION LINK
  Widget _navLink(
    String text,
    bool isActive,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: InkWell(
        onTap: onTap,
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white70,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // STATISTICS
  Widget _buildMetric(
    IconData icon,
    String value,
    String label,
  ) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF0052CC),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // FEATURE CARDS
  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF0052CC),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // FEATURED BOOK CARD
  Widget _buildBookCard(BuildContext context, Book book) {
    final isAvailable = book.status == 'Available';
    final title = book.title.toLowerCase();

    final String? coverUrl = title.contains('clean code')
        ? AppImages.cleanCode
        : title.contains('atomic habits')
            ? AppImages.atomicHabits
            : title.contains('martian')
                ? AppImages.theMartian
                : title.contains('design patterns')
                    ? AppImages.designPatterns
                    : title.contains('think like a monk')
                        ? AppImages.thinkLikeAMonk
                        : title.contains('dune')
                            ? AppImages.dune
                            : title.contains('sapiens')
                                ? AppImages.sapiens
                                : null;

    return Container(
      width: 190,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            height: 140,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: coverUrl != null
                  ? Image.network(
                      coverUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildCoverPlaceholder(book.title);
                      },
                    )
                  : _buildCoverPlaceholder(book.title),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            book.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Color(0xFF0F172A),
            ),
          ),
          Text(
            book.author,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF64748B),
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isAvailable
                        ? const Color(0xFFECFDF5)
                        : const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    book.status,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isAvailable
                          ? const Color(0xFF047857)
                          : const Color(0xFFB45309),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: () => _openSignIn(
                  context,
                  UserRole.reader,
                ),
                child: const Text(
                  'Reserve',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1877F2),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // BOOK COVER FALLBACK
  Widget _buildCoverPlaceholder(String title) {
    return Container(
      width: double.infinity,
      height: 140,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1E3A8A),
            Color(0xFF3B82F6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8),
      child: Text(
        title,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  // HOW IT WORKS STEPS
  Widget _buildStep(
    String number,
    String title,
    String description,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: const Color(0xFF1877F2),
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
