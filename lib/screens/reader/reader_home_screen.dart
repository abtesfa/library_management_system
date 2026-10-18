import 'package:flutter/material.dart';
import '../../data/mock_library_data.dart';
import '../../models/book.dart';

class ReaderHomeScreen extends StatelessWidget {
  final VoidCallback onNavigateToMyBooks;

  const ReaderHomeScreen({super.key, required this.onNavigateToMyBooks});

  @override
  Widget build(BuildContext context) {
    final books = MockLibraryData.getInitialBooks();
    final borrowed = MockLibraryData.getReaderBorrowedBooks();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reader Hero Study Banner
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF003B95), Color(0xFF0052CC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('Welcome Back, Abiye!', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Continue Your Reading Journey',
                        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'You currently have 2 active borrowed books. 1 is due in 2 days.',
                        style: TextStyle(color: Color(0xFFBFDBFE), fontSize: 13),
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton(
                        onPressed: onNavigateToMyBooks,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF0052CC),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('View My Borrowed Books', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.school, size: 60, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Reading Snapshot
          Row(
            children: [
              _snapshotTile('Currently Borrowed', borrowed.length.toString(), Icons.book_outlined, const Color(0xFF0052CC)),
              const SizedBox(width: 16),
              _snapshotTile('Due This Week', '1 Book', Icons.warning_amber_rounded, const Color(0xFFD97706)),
              const SizedBox(width: 16),
              _snapshotTile('Books Read This Year', '14 Books', Icons.military_tech_outlined, const Color(0xFF059669)),
            ],
          ),
          const SizedBox(height: 28),

          // Recommended For You Grid
          const Text(
            'Recommended Books For You',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.8,
            ),
            itemCount: books.length,
            itemBuilder: (ctx, i) {
              final b = books[i];
              return _buildBookItem(context, b);
            },
          ),
        ],
      ),
    );
  }

  Widget _snapshotTile(String title, String val, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A))),
                Text(title, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookItem(BuildContext context, Book b) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(Icons.book, color: Colors.white70, size: 28),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  b.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 2),
                Text(
                  b.author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      b.location,
                      style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                    ),
                    InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Reservation submitted for "${b.title}"!'),
                            backgroundColor: const Color(0xFF0052CC),
                          ),
                        );
                      },
                      child: const Text('Reserve', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1877F2))),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
