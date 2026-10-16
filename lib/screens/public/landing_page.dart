import 'dart:async';
import 'login.dart';
import 'package:flutter/material.dart';

const Color primaryBlue = Color(0xFF0860C9);
const Color brightBlue = Color(0xFF087BFF);
const Color darkBlue = Color(0xFF073B82);
const Color pageBg = Color(0xFFF4F9FF);
const Color borderBlue = Color(0xFFD7E9FF);
const Color textBlue = Color(0xFF073B8C);
const Color mutedBlue = Color(0xFF6795D8);

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  final GlobalKey _homeKey = GlobalKey();
  final GlobalKey _booksKey = GlobalKey();
  final GlobalKey _howKey = GlobalKey();
  final GlobalKey _contactKey = GlobalKey();

  String _search = '';
  String _category = 'All';
  bool _menuOpen = false;

  late final AnimationController _heroController;
  late final Animation<double> _heroFade;
  late final Animation<Offset> _heroSlide;

  final List<Book> _books = const [
    Book(
      title: 'Clean Code',
      author: 'Robert C. Martin',
      category: 'Programming',
      available: true,
      color: Color(0xFF071A40),
      subtitle: 'A HANDBOOK OF AGILE SOFTWARE CRAFTSMANSHIP',
    ),
    Book(
      title: 'Atomic Habits',
      author: 'James Clear',
      category: 'Self Improvement',
      available: true,
      color: Color(0xFFF5E8CC),
      subtitle: 'TINY CHANGES, REMARKABLE RESULTS',
    ),
    Book(
      title: 'The Martian',
      author: 'Andy Weir',
      category: 'Science Fiction',
      available: false,
      color: Color(0xFFFF702A),
      subtitle: 'SURVIVAL ON MARS',
    ),
    Book(
      title: 'Design Patterns',
      author: 'Erich Gamma',
      category: 'Software Engineering',
      available: true,
      color: Color(0xFF064BA9),
      subtitle: 'ELEMENTS OF REUSABLE SOFTWARE',
    ),
    Book(
      title: 'Think Like a Monk',
      author: 'Jay Shetty',
      category: 'Psychology',
      available: true,
      color: Color(0xFF1684C5),
      subtitle: 'TRAIN YOUR MIND FOR PEACE',
    ),
  ];

  @override
  void initState() {
    super.initState();

    _heroController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _heroFade = CurvedAnimation(parent: _heroController, curve: Curves.easeOut);

    _heroSlide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _heroController, curve: Curves.easeOutCubic),
        );

    _heroController.forward();
  }

  @override
  void dispose() {
    _heroController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _goTo(GlobalKey key) {
    setState(() => _menuOpen = false);

    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOutCubic,
        alignment: 0.04,
      );
    }
  }

  List<Book> get _filteredBooks {
    final query = _search.toLowerCase().trim();

    return _books.where((book) {
      final matchesQuery =
          query.isEmpty ||
          book.title.toLowerCase().contains(query) ||
          book.author.toLowerCase().contains(query) ||
          book.category.toLowerCase().contains(query);

      final matchesCategory = _category == 'All' || book.category == _category;

      return matchesQuery && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBg,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 850;

          return Stack(
            children: [
              SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    _navigation(wide),
                    _heroSection(),
                    _statistics(),
                    _quickActions(wide),
                    _featuredBooks(),
                    _howItWorks(wide),
                    _contactSection(),
                    _footer(wide),
                  ],
                ),
              ),
              if (!wide && _menuOpen) _mobileMenu(),
            ],
          );
        },
      ),
    );
  }

  // ---------------- NAVIGATION ----------------

  Widget _navigation(bool wide) {
    return Container(
      key: const ValueKey('navigation'),
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: wide ? 5.0 : 16, vertical: 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0753AB), Color(0xFF0874E5)],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x18003B85),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1450),
          child: Row(
            children: [
              const Icon(
                Icons.menu_book_rounded,
                color: Colors.white,
                size: 36,
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  'Library Management System',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: wide ? 21 : 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Spacer(),
              if (wide) ...[
                _navButton('Home', () => _goTo(_homeKey)),
                _navButton('Browse Books', () => _goTo(_booksKey)),
                _navButton('How It Works', () => _goTo(_howKey)),
                _navButton('Contact', () => _goTo(_contactKey)),
                const SizedBox(width: 12),
                _navPill('Sign In', outlined: true, onTap: _showSignIn),
                const SizedBox(width: 8),
                
              ] else
                IconButton(
                  onPressed: () => setState(() => _menuOpen = !_menuOpen),
                  icon: Icon(
                    _menuOpen ? Icons.close : Icons.menu,
                    color: Colors.white,
                  ),
                  tooltip: 'Open menu',
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navButton(String text, VoidCallback onTap) {
    return TextButton(
      onPressed: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _navPill(
    String text, {
    bool outlined = false,
    required VoidCallback onTap,
  }) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: outlined
            ? Colors.transparent
            : const Color(0xFF0786FF),
        side: BorderSide(color: outlined ? Colors.white70 : Colors.transparent),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 12),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _mobileMenu() {
    return Positioned(
      top: 64,
      right: 12,
      child: Material(
        color: Colors.white,
        elevation: 12,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 220,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _mobileMenuItem('Home', Icons.home, _homeKey),
              _mobileMenuItem('Browse Books', Icons.menu_book, _booksKey),
              _mobileMenuItem('How It Works', Icons.info_outline, _howKey),
              _mobileMenuItem('Contact Us', Icons.email_outlined, _contactKey),
              ListTile(
                leading: const Icon(Icons.login, color: primaryBlue),
                title: const Text('Sign In'),
                onTap: () {
                  Navigator.push(
                 context,
              MaterialPageRoute(
              builder: (context) => const LoginScreen(),
  ),
);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mobileMenuItem(String title, IconData icon, GlobalKey key) {
    return ListTile(
      leading: Icon(icon, color: primaryBlue),
      title: Text(title, style: const TextStyle(color: textBlue)),
      onTap: () => _goTo(key),
    );
  }

  // ---------------- HERO ----------------

  Widget _heroSection() {
    return Padding(
      key: _homeKey,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
      child: FadeTransition(
        opacity: _heroFade,
        child: SlideTransition(
          position: _heroSlide,
          child: Container(
            constraints: const BoxConstraints(minHeight: 280),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderBlue),
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFFE4F2FF),
                  Color(0xFFF9FCFF),
                  Color(0xFFD7EAFE),
                ],
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: LayoutBuilder(
              builder: (context, box) {
                final wide = box.maxWidth >= 700;

                return Stack(
                  children: [
                    // Full-width background image
                    Positioned.fill(child: _LibraryIllustration()),
                    // Light overlay behind the text on the left
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                const Color(0xFFE5F2FF).withValues(alpha: 1.0),
                                const Color(0xFFE5F2FF).withValues(alpha: 0.98),
                                const Color(0xFFE5F2FF).withValues(alpha: 0.85),
                                const Color(0xFFE5F2FF).withValues(alpha: 0.0),
                              ],
                              stops: const [0.0, 0.42, 0.58, 0.85],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Text and search stay above the image
                    Padding(
                      padding: EdgeInsets.all(wide ? 30 : 20),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: wide ? box.maxWidth * 0.59 : 520,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 16),
                            Text.rich(
                              TextSpan(
                                style: TextStyle(
                                  fontSize: wide ? 38 : 29,
                                  fontWeight: FontWeight.w900,
                                  height: 1.12,
                                  color: textBlue,
                                ),
                                children: const [
                                  TextSpan(text: 'Discover. Learn. '),
                                  TextSpan(
                                    text: 'Grow.',
                                    style: TextStyle(color: brightBlue),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Explore books, manage your reading journey, '
                              'and discover knowledge whenever you need it.',
                              style: TextStyle(
                                color: mutedBlue,
                                fontSize: 13,
                                height: 1.65,
                              ),
                            ),
                            const SizedBox(height: 18),
                            _searchBar(),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children:
                                  ['All', 'Books', 'Authors', 'Categories'].map(
                                    (item) {
                                      return _categoryChip(item);
                                    },
                                  ).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _searchBar() {
    return Container(
      height: 48,
      padding: const EdgeInsets.only(left: 14, right: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: borderBlue),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10005BC5),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: brightBlue),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _search = value),
              decoration: const InputDecoration(
                hintText: 'Search books, authors, categories...',
                hintStyle: TextStyle(fontSize: 11, color: mutedBlue),
                border: InputBorder.none,
                isDense: true,
              ),
              style: const TextStyle(fontSize: 12, color: textBlue),
            ),
          ),
          ElevatedButton(
            onPressed: () => _goTo(_booksKey),
            style: ElevatedButton.styleFrom(
              backgroundColor: brightBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Search', style: TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }

  Widget _categoryChip(String label) {
    final selected =
        _category == label ||
        (label == 'Books' && _category == 'All') ||
        (label == 'Authors' && _category == 'All') ||
        (label == 'Categories' && _category == 'All');

    return InkWell(
      onTap: () {
        setState(() {
          if (label == 'All' || label == 'Books') {
            _category = 'All';
          } else if (label == 'Authors') {
            _category = 'All';
          } else {
            _category = 'All';
          }
        });
        _goTo(_booksKey);
      },
      borderRadius: BorderRadius.circular(30),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? brightBlue : Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: selected ? brightBlue : borderBlue),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : textBlue,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ---------------- STATISTICS ----------------

  Widget _statistics() {
    final stats = [
      (Icons.menu_book_rounded, '1,200+', 'Books Available'),
      (Icons.groups_rounded, '350+', 'Registered Members'),
      (Icons.access_time_rounded, '24/7', 'Online Access'),
      (Icons.verified_user_rounded, 'Secure', '& Reliable'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: _panel(
        child: LayoutBuilder(
          builder: (context, box) {
            final columns = box.maxWidth < 520 ? 2 : 4;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: stats.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisExtent: 78,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                final stat = stats[index];
                return _statItem(stat.$1, stat.$2, stat.$3);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _statItem(IconData icon, String number, String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFD8EBFF),
            border: Border.all(color: const Color(0xFFBBDFFF)),
          ),
          child: Icon(icon, color: brightBlue, size: 27),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                number,
                style: const TextStyle(
                  color: primaryBlue,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                label,
                style: const TextStyle(color: mutedBlue, fontSize: 10),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------- QUICK ACTIONS ----------------

  Widget _quickActions(bool wide) {
    final actions = [
      (
        Icons.menu_book_rounded,
        'Browse Books',
        'Explore our collection of books and find your next read.',
        'View Books',
        () => _goTo(_booksKey),
      ),
      (
        Icons.search_rounded,
        'Search & Discover',
        'Find books by title, author, ISBN or category.',
        'Search Now',
        () => _goTo(_homeKey),
      ),
      (
        Icons.person_rounded,
        'Manage Your Account',
        'Track your loans, reservations and reading history.',
        'Go to Dashboard',
        _showSignIn,
      ),
      (
        Icons.account_balance_rounded,
        'For Librarians',
        'Manage books, members, loans and generate reports.',
        'Librarian Login',
        _showSignIn,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: LayoutBuilder(
        builder: (context, box) {
          final columns = box.maxWidth < 550
              ? 1
              : box.maxWidth < 950
              ? 2
              : 4;

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: actions.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: 140,
            ),
            itemBuilder: (context, index) {
              final item = actions[index];
              return _animatedCard(
                delay: index * 100,
                child: _panel(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _iconBubble(item.$1, size: 48),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.$2,
                              style: const TextStyle(
                                color: textBlue,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: Text(
                                item.$3,
                                style: const TextStyle(
                                  color: mutedBlue,
                                  fontSize: 10,
                                  height: 1.5,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: item.$5,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    item.$4,
                                    style: const TextStyle(
                                      color: brightBlue,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  const Icon(
                                    Icons.arrow_forward,
                                    size: 13,
                                    color: brightBlue,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ---------------- FEATURED BOOKS ----------------

  Widget _featuredBooks() {
    final books = _filteredBooks;

    return Padding(
      key: _booksKey,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: _panel(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.menu_book_rounded,
                  size: 30,
                  color: brightBlue,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Featured Books',
                        style: TextStyle(
                          color: primaryBlue,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'Discover popular books and reader favorites.',
                        style: TextStyle(color: mutedBlue, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _search = '');
                  },
                  child: const Text(
                    'Clear Search',
                    style: TextStyle(fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (books.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'No books found. Try another title or author.',
                    style: TextStyle(color: mutedBlue),
                  ),
                ),
              )
            else
              LayoutBuilder(
                builder: (context, box) {
                  final columns = box.maxWidth < 420
                      ? 1
                      : box.maxWidth < 750
                      ? 2
                      : box.maxWidth < 1050
                      ? 3
                      : 5;

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: books.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      mainAxisExtent: 270,
                    ),
                    itemBuilder: (context, index) {
                      final book = books[index];
                      return _animatedCard(
                        delay: index * 90,
                        child: _bookCard(book),
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _bookCard(Book book) {
    return _panel(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: _bookCover(book)),
          const SizedBox(height: 9),
          Text(
            book.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: textBlue,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            book.author,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: mutedBlue, fontSize: 10),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF4FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              book.category,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: primaryBlue, fontSize: 9),
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Icon(
                Icons.circle,
                size: 8,
                color: book.available
                    ? const Color(0xFF17C784)
                    : const Color(0xFFFFAA30),
              ),
              const SizedBox(width: 5),
              Text(
                book.available ? 'Available' : 'Borrowed',
                style: TextStyle(
                  fontSize: 10,
                  color: book.available
                      ? const Color(0xFF00A876)
                      : const Color(0xFFE68B12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 31,
            child: OutlinedButton(
              onPressed: () => _showBookDetails(book),
              style: OutlinedButton.styleFrom(
                foregroundColor: brightBlue,
                side: const BorderSide(color: Color(0xFF94C7FF)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.zero,
              ),
              child: const Text('View Details', style: TextStyle(fontSize: 10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bookCover(Book book) {
    return Container(
      width: 88,
      height: 125,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: book.color,
        borderRadius: BorderRadius.circular(5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22002660),
            blurRadius: 8,
            offset: Offset(2, 4),
          ),
        ],
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.auto_stories, color: Colors.white70, size: 18),
          Text(
            book.title.toUpperCase(),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: book.title == 'Atomic Habits'
                  ? const Color(0xFF793A14)
                  : Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
          Text(
            book.subtitle,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: book.title == 'Atomic Habits'
                  ? const Color(0xFF793A14)
                  : Colors.white70,
              fontSize: 5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- HOW IT WORKS ----------------

  Widget _howItWorks(bool wide) {
    final steps = [
      (
        Icons.person_add_alt_1,
        'Create an Account',
        'Sign up as a member and get access to your library.',
      ),
      (
        Icons.search,
        'Discover a Book',
        'Search our collection of books and categories.',
      ),
      (
        Icons.menu_book,
        'Borrow or Reserve',
        'Borrow a book, return it on time, and enjoy reading.',
      ),
    ];

    return Padding(
      key: _howKey,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: _panel(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.settings_suggest, color: brightBlue, size: 30),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How It Works',
                      style: TextStyle(
                        color: primaryBlue,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'Getting started takes just a few simple steps.',
                      style: TextStyle(color: mutedBlue, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, box) {
                final columns = box.maxWidth < 600 ? 1 : 3;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: steps.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 18,
                    mainAxisExtent: 115,
                  ),
                  itemBuilder: (context, index) {
                    final step = steps[index];

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: brightBlue,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(step.$1, color: brightBlue, size: 24),
                              const SizedBox(height: 7),
                              Text(
                                step.$2,
                                style: const TextStyle(
                                  color: textBlue,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                step.$3,
                                style: const TextStyle(
                                  color: mutedBlue,
                                  fontSize: 10,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- CONTACT US ----------------

  Widget _contactSection() {
    return Padding(
      key: _contactKey,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      child: _panel(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.mark_email_read_outlined,
                  color: brightBlue,
                  size: 30,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contact Us',
                        style: TextStyle(
                          color: primaryBlue,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'We are here to help! Reach out with questions or feedback.',
                        style: TextStyle(color: mutedBlue, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, box) {
                final columns = box.maxWidth < 600 ? 1 : 3;
                final contacts = [
                  (
                    Icons.phone_rounded,
                    'Phone',
                    '+251 11 123 4567',
                    'Call us during working hours.',
                  ),
                  (
                    Icons.email_rounded,
                    'Email',
                    'info@librarysystem.com',
                    'We will respond as soon as possible.',
                  ),
                  (
                    Icons.location_on_rounded,
                    'Address',
                    'Addis Ababa, Ethiopia',
                    'Visit us at our library location.',
                  ),
                ];

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: contacts.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: 100,
                  ),
                  itemBuilder: (context, index) {
                    final item = contacts[index];

                    return _panel(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          _iconBubble(item.$1, size: 43),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.$2,
                                  style: const TextStyle(
                                    color: textBlue,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                SelectableText(
                                  item.$3,
                                  style: const TextStyle(
                                    color: primaryBlue,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  item.$4,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: mutedBlue,
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- FOOTER ----------------

  Widget _footer(bool wide) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0753AB), Color(0xFF06428E)],
        ),
      ),
      child: Column(
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1300),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              runSpacing: 22,
              spacing: 35,
              children: [
                SizedBox(
                  width: 245,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.menu_book_rounded,
                        color: Colors.white,
                        size: 35,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Library Management System',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Read More, Learn More, Grow More.',
                              style: TextStyle(
                                color: Color(0xFFD0E5FF),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                _footerLinks('Quick Links', [
                  ('Home', () => _goTo(_homeKey)),
                  ('Browse Books', () => _goTo(_booksKey)),
                  ('How It Works', () => _goTo(_howKey)),
                  ('Contact Us', () => _goTo(_contactKey)),
                ]),
                _footerLinks('Library Rules', [
                  ('Borrowing Limits', _showRules),
                  ('Loan Periods', _showRules),
                  ('Overdue Fines', _showRules),
                  ('FAQs', _showRules),
                ]),
                _footerLinks('Contact Info', [
                  ('+251 11 123 4567', _showContactInfo),
                  ('info@librarysystem.com', _showContactInfo),
                  ('Addis Ababa, Ethiopia', _showContactInfo),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Divider(color: Color(0x557DBBFF)),
          const SizedBox(height: 8),
          const Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 8,
            spacing: 24,
            children: [
              Text(
                '© 2026 Library Management System. All rights reserved.',
                style: TextStyle(color: Colors.white70, fontSize: 9),
              ),
              Text(
                'Better Readers  •  Stronger Communities  •  Brighter Futures',
                style: TextStyle(color: Colors.white70, fontSize: 9),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _footerLinks(String heading, List<(String, VoidCallback)> links) {
    return SizedBox(
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            heading,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          ...links.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: InkWell(
                onTap: item.$2,
                child: Text(
                  item.$1,
                  style: const TextStyle(
                    color: Color(0xFFD0E5FF),
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- SHARED WIDGETS ----------------

  Widget _panel({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(12),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: borderBlue),
        boxShadow: const [
          BoxShadow(
            color: Color(0x09005BC5),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _iconBubble(IconData icon, {double size = 48}) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF80BBFF), Color(0xFF087BFF)],
        ),
      ),
      child: Icon(icon, color: Colors.white, size: size * 0.52),
    );
  }

  Widget _animatedCard({required Widget child, int delay = 0}) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(delay),
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 500 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 14 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  // ---------------- DIALOGS ----------------

  void _showBookDetails(Book book) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(book.title, style: const TextStyle(color: textBlue)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: _bookCover(book)),
            const SizedBox(height: 16),
            Text('Author: ${book.author}'),
            Text('Category: ${book.category}'),
            const SizedBox(height: 8),
            Text(
              book.available
                  ? 'This book is currently available.'
                  : 'This book is currently borrowed.',
              style: TextStyle(
                color: book.available ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (book.available)
            FilledButton(
              onPressed: () {
                
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
              },
              child: const Text('Sign in to Borrow'),
            ),
        ],
      ),
    );
  }

  
void _showSignIn() {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (context) => const LoginScreen(),
    ),
  );
}


  void _showRules() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Library Rules'),
        content: const Text(
          'Borrowing limits, loan periods and overdue fines should follow '
          'your library policies. Replace this sample dialog with your '
          'actual library rules.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showContactInfo() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact the Library'),
        content: const SelectableText(
          'Phone: +251 11 123 4567\n'
          'Email: info@librarysystem.com\n'
          'Address: Addis Ababa, Ethiopia',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

// ---------------- BOOK MODEL ----------------

class Book {
  final String title;
  final String author;
  final String category;
  final bool available;
  final Color color;
  final String subtitle;

  const Book({
    required this.title,
    required this.author,
    required this.category,
    required this.available,
    required this.color,
    required this.subtitle,
  });
}

// ---------------- HERO ILLUSTRATION ----------------

class _LibraryIllustration extends StatelessWidget {
  const _LibraryIllustration();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Full-width library background image
        Positioned.fill(
          child: Image.network(
            'https://images.unsplash.com/photo-1507842217343-583bb7270b66'
            '?auto=format&fit=crop&w=1800&q=90',
            fit: BoxFit.cover,
            alignment: Alignment.center,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: const Color(0xFFDCEEFF),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.local_library_rounded,
                  size: 90,
                  color: Color(0xFF087BFF),
                ),
              );
            },
          ),
        ),

        // Light blue overlay across the full image
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  const Color(0xFFE5F2FF).withValues(alpha: 0.95),
                  const Color(0xFFE5F2FF).withValues(alpha: 0.75),
                  const Color(0xFFE5F2FF).withValues(alpha: 0.15),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.32, 0.58, 1.0],
              ),
            ),
          ),
        ),

        // Handwritten slogan on the right side
        Positioned(
          top: 45,
          left: 0,
          right: 0,
          child: Align(
            alignment: Alignment.topCenter,
            child: FractionallySizedBox(
              widthFactor: 0.8,
              child: Align(
                alignment: Alignment.centerRight,
                child: Transform.rotate(
                  angle: -0.12,
                  child: const Text(
                    'A good book\nbuilds a better\ntomorrow',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF0052CC),
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                      height: 1.3,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Decorative underline below the slogan
        Positioned(
          top: 125,
          right: 60,
          child: Transform.rotate(
            angle: -0.25,
            child: Container(
              width: 45,
              height: 2,
              decoration: BoxDecoration(
                color: const Color(0xFF087BFF),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
