import 'package:flutter/material.dart';

class LibrarianDeskScreen extends StatefulWidget {
  const LibrarianDeskScreen({super.key});

  @override
  State<LibrarianDeskScreen> createState() => _LibrarianDeskScreenState();
}

class _LibrarianDeskScreenState extends State<LibrarianDeskScreen> {
  final TextEditingController _studentIdController = TextEditingController(text: 'S-00123');
  final TextEditingController _bookSearchController = TextEditingController(text: 'The Great Gatsby');
  String _bookCondition = 'Good';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome back, Sara!',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const Text(
            'Borrow books, process returns, and keep track of your library activities.',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Borrow Book Card
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(color: Color(0xFFEFF6FF), shape: BoxShape.circle),
                            child: const Icon(Icons.book, color: Color(0xFF1877F2)),
                          ),
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Borrow Book', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text('Issue a book to a student', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text('Student ID *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _studentIdController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person_outline, size: 18),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text('Book Title or ISBN *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _bookSearchController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search, size: 18),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8)),
                        child: const Column(
                          children: [
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Title:', style: TextStyle(fontSize: 11, color: Colors.grey)), Text('The Great Gatsby', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))]),
                            SizedBox(height: 4),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Available Copies:', style: TextStyle(fontSize: 11, color: Colors.grey)), Text('4', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))]),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.book),
                          label: const Text('Confirm Borrowing'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1877F2),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),

              // Return Book Card with Overdue Fine Box
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(color: Color(0xFFECFDF5), shape: BoxShape.circle),
                            child: const Icon(Icons.swap_horiz, color: Color(0xFF10B981)),
                          ),
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Return Book', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text('Process a book return and check for fines', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Overdue Fine Card
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFECACA)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [Icon(Icons.warning_amber_rounded, size: 16, color: Colors.red), SizedBox(width: 4), Text('Overdue Fine', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 11))]),
                                SizedBox(height: 4),
                                Text('\$2.00', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red)),
                                Text('The book is 5 days overdue.', style: TextStyle(fontSize: 10, color: Colors.red)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Daily fine rate: \$0.40', style: TextStyle(fontSize: 11)),
                                Text('Overdue days: 5', style: TextStyle(fontSize: 11)),
                                Text('Total fine: \$2.00', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.red)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Book Condition', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                      Row(
                        children: ['Good', 'Minor damage', 'Lost'].map((cond) {
                          return Row(
                            children: [
                              Radio<String>(
                                value: cond,
                                groupValue: _bookCondition,
                                onChanged: (val) => setState(() => _bookCondition = val!),
                              ),
                              Text(cond, style: const TextStyle(fontSize: 11)),
                            ],
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.swap_horiz),
                          label: const Text('Confirm Return'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
