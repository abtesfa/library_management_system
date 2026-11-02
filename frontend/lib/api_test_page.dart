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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Error State (shows network/parsing issues on screen)
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'Error: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        // Trigger rebuild/retry
                        (context as Element).markNeedsBuild();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          // 3. Empty State
          final books = snapshot.data ?? [];
          if (books.isEmpty) {
            return const Center(child: Text('No books found.'));
          }

          // 4. Success State
          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return ListTile(
                title: Text(book.title),
                subtitle: Text('${book.author} • ${book.status}'),
              );
            },
          );
        },
      ),
    );
  }
}
