
import 'package:flutter/material.dart';
import 'services/book_service.dart';
import 'models/book.dart';

class ApiTestPage extends StatefulWidget {
  const ApiTestPage({super.key});

  @override
  State<ApiTestPage> createState() => _ApiTestPageState();
}

class _ApiTestPageState extends State<ApiTestPage> {
  final BookService bookService = BookService();

  late Future<List<Book>> booksFuture;

  @override
  void initState() {
    super.initState();

    // Fetch books when the screen opens.
    booksFuture = bookService.getAllBooks();
  }

  // Refresh the book list.
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

      body: FutureBuilder<List<Book>>(
        future: booksFuture,
        builder: (context, snapshot) {

          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Error state
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 50,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Error: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: loadBooks,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Successfully loaded books
          final books = snapshot.data ?? [];

          // Empty state
          if (books.isEmpty) {
            return const Center(
              child: Text(
                'Connected successfully! No books found.',
              ),
            );
          }

          // Display books
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.menu_book),
                  ),
                  title: Text(
                    book.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'ISBN: ${book.isbn}',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
