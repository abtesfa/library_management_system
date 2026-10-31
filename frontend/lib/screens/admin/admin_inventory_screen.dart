import 'package:flutter/material.dart';
import '../../models/book.dart';

class AdminInventoryScreen extends StatefulWidget {
  const AdminInventoryScreen({super.key});

  @override
  State<AdminInventoryScreen> createState() => _AdminInventoryScreenState();
}

class _AdminInventoryScreenState extends State<AdminInventoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final String _selectedCategory = 'All Categories';
  final String _selectedStatus = 'All Statuses';

  final List<Book> _sampleBooks = [
    Book(id: '1', title: 'Atomic Habits', author: 'James Clear', isbn: '978-0735211292', category: 'Self-Help', totalCopies: 5, availableCopies: 3, status: 'Available', location: 'Shelf A1'),
    Book(id: '2', title: 'Dune', author: 'Frank Herbert', isbn: '978-0441013593', category: 'Science Fiction', totalCopies: 4, availableCopies: 1, status: 'Low Stock', location: 'Shelf B2'),
    Book(id: '3', title: 'The Great Gatsby', author: 'F. Scott Fitzgerald', isbn: '978-0743273567', category: 'Fiction', totalCopies: 6, availableCopies: 6, status: 'Available', location: 'Shelf C3'),
    Book(id: '4', title: 'Clean Code', author: 'Robert C. Martin', isbn: '978-0132350884', category: 'Computer Science', totalCopies: 3, availableCopies: 2, status: 'Available', location: 'Shelf D1'),
    Book(id: '5', title: 'Sapiens', author: 'Yuval Noah Harari', isbn: '978-0062316097', category: 'History', totalCopies: 5, availableCopies: 4, status: 'Available', location: 'Shelf E2'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBF3FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.menu_book, color: Color(0xFF0052CC), size: 28),
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Book Inventory',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                      Text(
                        'Manage book titles, authors, categories, physical copies, shelf locations, and availability status.',
                        style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add New Book'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1877F2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Search & Filter Bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search, size: 20, color: Color(0xFF94A3B8)),
                      hintText: 'Search by title, author, ISBN, or categories...',
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.search, size: 16),
                  label: const Text('Search'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1877F2),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 5 KPI Stat Cards
          Row(
            children: [
              _buildStatCard('Total Books', '1,248', 'titles in collection', Icons.book, const Color(0xFF3B82F6), const Color(0xFFEFF6FF)),
              const SizedBox(width: 12),
              _buildStatCard('Total Copies', '2,860', 'physical copies', Icons.layers, const Color(0xFF3B82F6), const Color(0xFFEFF6FF)),
              const SizedBox(width: 12),
              _buildStatCard('Available Copies', '2,341', 'available for loan', Icons.check_circle_outline, const Color(0xFF10B981), const Color(0xFFECFDF5)),
              const SizedBox(width: 12),
              _buildStatCard('On Loan', '487', 'currently borrowed', Icons.description_outlined, const Color(0xFFF59E0B), const Color(0xFFFEF3C7)),
              const SizedBox(width: 12),
              _buildStatCard('Reserved', '32', 'awaiting availability', Icons.access_time, const Color(0xFFEF4444), const Color(0xFFFEE2E2)),
            ],
          ),
          const SizedBox(height: 24),

          // Inventory Table
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Book Inventory List', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('Showing 1-10 of 1,248', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                    ],
                  ),
                ),
                const Divider(height: 1),
                DataTable(
                  columns: const [
                    DataColumn(label: Text('Title', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Author', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('ISBN', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Available', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Location', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: _sampleBooks.map((book) {
                    return DataRow(cells: [
                      DataCell(Text(book.title, style: const TextStyle(color: Color(0xFF1877F2), fontWeight: FontWeight.w600))),
                      DataCell(Text(book.author)),
                      DataCell(Text(book.isbn, style: const TextStyle(fontFamily: 'monospace'))),
                      DataCell(Text(book.category)),
                      DataCell(Text(book.totalCopies.toString())),
                      DataCell(Text(book.availableCopies.toString())),
                      DataCell(Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: book.status == 'Available' ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          book.status,
                          style: TextStyle(
                            color: book.status == 'Available' ? const Color(0xFF166534) : const Color(0xFFB45309),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )),
                      DataCell(Text(book.location)),
                    ]);
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String count, String subtitle, IconData icon, Color color, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                Text(count, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                Text(subtitle, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
