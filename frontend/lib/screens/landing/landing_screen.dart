import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user.dart';
import '../../models/book.dart';
import '../../widgets/dialogs/sign_in_dialog.dart';
import '../../config/app_images.dart';
import '../../services/library_service.dart';

class LandingScreen extends StatefulWidget {
  final Function(UserRole role) onEnterPortal;

  const LandingScreen({
    super.key,
    required this.onEnterPortal,
  });

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  // Continuous floating animation for the large hero image.
  late final AnimationController _heroFloatController;
  late final Animation<double> _heroFloatAnimation;

  @override
  void initState() {
    super.initState();

    _heroFloatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _heroFloatAnimation = Tween<double>(
      begin: -7,
      end: 7,
    ).animate(
      CurvedAnimation(
        parent: _heroFloatController,
        curve: Curves.easeInOut,
      ),
    );
  }

  // SIGN IN
  void _openSignIn(
    BuildContext context, [
    UserRole role = UserRole.admin,
  ]) {
    showDialog(
      context: context,
      builder: (ctx) => SignInDialog(
        initialRole: role,
        onSignIn: widget.onEnterPortal,
      ),
    );
  }

  // SEARCH BOOKS
  void _searchBooks(String query) {
    setState(() {
      _searchQuery = query.trim();
    });
  }

  // CLEAR SEARCH
  void _clearSearch() {
    _searchController.clear();

    setState(() {
      _searchQuery = '';
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _heroFloatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final libraryService = context.watch<LibraryService>();

    final allBooks = libraryService.books;

    // Remove duplicate books using ISBN.
    // If ISBN is missing, use the title instead.
    final Map<String, Book> uniqueBooks = {};

    for (final book in allBooks) {
      final isbn = book.isbn.trim().toLowerCase();
      final title = book.title.trim().toLowerCase();

      final key = isbn.isNotEmpty ? 'isbn:$isbn' : 'title:$title';

      uniqueBooks.putIfAbsent(key, () => book);
    }

    final distinctBooks = uniqueBooks.values.toList();

    // Display the first six unique books.
    final featuredBooks = distinctBooks.take(6).toList();

    // Search through unique books only.
    final searchResults = _searchQuery.isEmpty
        ? <Book>[]
        : distinctBooks.where((book) {
            final query = _searchQuery.toLowerCase();

            return book.title.toLowerCase().contains(query) ||
                book.author.toLowerCase().contains(query) ||
                book.isbn.toLowerCase().contains(query);
          }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),

      // APP BAR
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
        ),
      ),

      // PAGE BODY
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ==========================================
            // 1. HERO SECTION
            // ==========================================

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
                  // LEFT SIDE: HERO TEXT AND SEARCH

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
                          'Explore our library collection, find books you enjoy, '
                          'and borrow the ones you need for your studies or personal reading.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // PUBLIC BOOK SEARCH

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

                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: _searchBooks,
                                  onSubmitted: _searchBooks,
                                  decoration: InputDecoration(
                                    hintText:
                                        'Search books, authors, ISBN...',
                                    hintStyle: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF94A3B8),
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                    suffixIcon: _searchQuery.isNotEmpty
                                        ? IconButton(
                                            tooltip: 'Clear search',
                                            icon: const Icon(
                                              Icons.close,
                                              size: 18,
                                            ),
                                            onPressed: _clearSearch,
                                          )
                                        : null,
                                  ),
                                ),
                              ),

                              ElevatedButton(
                                onPressed: () {
                                  _searchBooks(_searchController.text);
                                  FocusScope.of(context).unfocus();
                                },
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

                        // SEARCH RESULTS

                        if (_searchQuery.isNotEmpty) ...[
                          const SizedBox(height: 10),

                          Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(
                              maxHeight: 240,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),

                            child: libraryService.isLoadingBooks
                                ? const Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                : libraryService.booksError != null
                                    ? Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          children: [
                                            const Text(
                                              'Unable to load books.',
                                              style: TextStyle(
                                                color: Color(0xFF64748B),
                                              ),
                                            ),

                                            TextButton(
                                              onPressed: libraryService
                                                  .loadBooksFromApi,
                                              child: const Text('Try Again'),
                                            ),
                                          ],
                                        ),
                                      )
                                    : searchResults.isEmpty
                                        ? const Padding(
                                            padding: EdgeInsets.all(16),
                                            child: Text(
                                              'No matching books found.',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Color(0xFF64748B),
                                                fontSize: 13,
                                              ),
                                            ),
                                          )
                                        : ListView.separated(
                                            shrinkWrap: true,
                                            itemCount: searchResults.length,
                                            separatorBuilder: (_, __) =>
                                                const Divider(height: 1),
                                            itemBuilder: (context, index) {
                                              final book =
                                                  searchResults[index];

                                              return ListTile(
                                                dense: true,
                                                leading: const CircleAvatar(
                                                  backgroundColor:
                                                      Color(0xFFEFF6FF),
                                                  child: Icon(
                                                    Icons.menu_book,
                                                    color: Color(0xFF1877F2),
                                                  ),
                                                ),
                                                title: Text(
                                                  book.title,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                subtitle: Text(
                                                  '${book.author} • ${book.isbn}',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                  ),
                                                ),
                                                trailing: Text(
                                                  book.availableCopies > 0
                                                      ? 'Available'
                                                      : 'Unavailable',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    color:
                                                        book.availableCopies >
                                                                0
                                                            ? Colors.green
                                                            : Colors.red,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(width: 32),

                  // ==========================================
                  // RIGHT SIDE: CONTINUOUSLY ANIMATED IMAGE
                  // ==========================================

                  Expanded(
                    flex: 2,
                    child: AnimatedBuilder(
                      animation: _heroFloatAnimation,

                      // The image is created once and reused.
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

                      // MOVE THE IMAGE UP AND DOWN CONTINUOUSLY.

                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(
                            0,
                            _heroFloatAnimation.value,
                          ),
                          child: child,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // ==========================================
            // 2. FEATURE CARDS
            // ==========================================

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

            // ==========================================
            // 3. FEATURED BOOKS
            // ==========================================

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

                    // LOADING, ERROR, EMPTY OR BOOK LIST

                    if (libraryService.isLoadingBooks)
                      const SizedBox(
                        height: 260,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (libraryService.booksError != null)
                      SizedBox(
                        height: 260,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.cloud_off,
                                size: 35,
                                color: Color(0xFF94A3B8),
                              ),

                              const SizedBox(height: 10),

                              const Text(
                                'Unable to load featured books.',
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                ),
                              ),

                              TextButton.icon(
                                onPressed: libraryService.loadBooksFromApi,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Try Again'),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (featuredBooks.isEmpty)
                      const SizedBox(
                        height: 180,
                        child: Center(
                          child: Text(
                            'No books available yet.',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                      )
                    else
                      SizedBox(
                        height: 260,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: featuredBooks.length,
                          separatorBuilder: (ctx, i) =>
                              const SizedBox(width: 12),
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

            // ==========================================
            // 4. HOW IT WORKS
            // ==========================================

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

            // ==========================================
            // 5. FOOTER
            // ==========================================

            _buildLandingFooter(context),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // FOOTER
  // ==========================================

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

  // FOOTER BRAND

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

  // FOOTER LINKS

  Widget _footerLinks(BuildContext context) {
    final services = [
      (
        icon: Icons.menu_book_rounded,
        title: 'Book Collection',
        description: 'Explore books across different subjects.',
      ),
      (
        icon: Icons.search_rounded,
        title: 'Book Search',
        description: 'Find books for study and reading.',
      ),
      (
        icon: Icons.bookmark_added_rounded,
        title: 'Borrowing Services',
        description: 'Borrow books for your learning needs.',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'LIBRARY SERVICES',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),

        const SizedBox(height: 12),

        ...services.map(
          (service) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  service.icon,
                  color: const Color(0xFF8DBBFF),
                  size: 22,
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        service.description,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // FOOTER CONTACT

  Widget _footerContact() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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

  // ==========================================
  // FEATURE CARDS (with hover animation)
  // ==========================================

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return _HoverLift(
      radius: 16,
      child: Container(
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
      ),
    );
  }

  // ==========================================
  // FEATURED BOOK CARD WITH HOVER ANIMATION
  // ==========================================

  Widget _buildBookCard(BuildContext context, Book book) {
    final isAvailable = book.availableCopies > 0;
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

    // Hover state for each individual book card.
    bool isHovered = false;

    return StatefulBuilder(
      builder: (context, setCardState) {
        return MouseRegion(
          cursor: SystemMouseCursors.click,

          onEnter: (_) {
            setCardState(() {
              isHovered = true;
            });
          },

          onExit: (_) {
            setCardState(() {
              isHovered = false;
            });
          },

          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,

            // Move the card upward and enlarge it on hover.
            transform: Matrix4.translationValues(
              0,
              isHovered ? -7 : 0,
              0,
            )..scale(isHovered ? 1.025 : 1.0),

            transformAlignment: Alignment.center,

            width: 190,
            padding: const EdgeInsets.all(12),

            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),

              border: Border.all(
                color: isHovered
                    ? const Color(0xFF93C5FD)
                    : const Color(0xFFE2E8F0),
              ),

              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0052CC).withValues(
                    alpha: isHovered ? 0.16 : 0,
                  ),
                  blurRadius: isHovered ? 18 : 0,
                  offset: Offset(0, isHovered ? 9 : 0),
                ),
              ],
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // BOOK COVER

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

                // BOOK TITLE

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

                // BOOK AUTHOR

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

                // AVAILABILITY AND RESERVE BUTTON

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
                          isAvailable ? 'Available' : 'Unavailable',
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
          ),
        );
      },
    );
  }

  // ==========================================
  // BOOK COVER FALLBACK
  // ==========================================

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

  // ==========================================
  // HOW IT WORKS STEPS
  // ==========================================

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

// =============================================================
// HOVER ANIMATION (lift + shadow + blue border)
// Used by the Browse Books and Search & Discover feature cards.
// =============================================================

class _HoverLift extends StatefulWidget {
  final Widget child;
  final double radius;

  const _HoverLift({
    required this.child,
    this.radius = 14,
  });

  @override
  State<_HoverLift> createState() => _HoverLiftState();
}

class _HoverLiftState extends State<_HoverLift> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(
          0,
          _isHovered ? -4 : 0,
          0,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 5,
                    offset: const Offset(0, 4),
                  ),
                ]
              : const [],
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          border: Border.all(
            color: _isHovered
    ? Colors.white
    : Colors.transparent,
width: 1.5,
          ),
        ),
        child: widget.child,
      ),
    );
  }
}