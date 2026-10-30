
import 'package:flutter/material.dart';
import 'services/book_service.dart';

class ApiTestPage extends StatefulWidget {
  const ApiTestPage({super.key});

  @override
  State<ApiTestPage> createState() => _ApiTestPageState();
}

class _ApiTestPageState extends State<ApiTestPage> {
  final BookService bookService = BookService();

  late Future<List<dynamic>> booksFuture;

  @override
  void initState() {
    super.initState();

    // Request books when the screen opens
    booksFuture = bookService.getAllBooks();
  }
void loadBooks() {
  setState(() {
    booksFuture = bookService.getAllBooks();
  });
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
  title: const Text('API Connection Test'),
  actions: [
    IconButton(
      onPressed: loadBooks,
      icon: const Icon(Icons.refresh),
      tooltip: 'Refresh books',
    ),
  ],
),
      body: FutureBuilder<List<dynamic>>(
        future: booksFuture,
        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
              ),
            );
          }

          final books = snapshot.data ?? [];

          if (books.isEmpty) {
            return const Center(
              child: Text(
                'Connected successfully! No books found.',
              ),
            );
          }

          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];

              return ListTile(
                title: Text(book['title'] ?? 'No title'),
                subtitle: Text(
                  'ISBN: ${book['isbn']}',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
