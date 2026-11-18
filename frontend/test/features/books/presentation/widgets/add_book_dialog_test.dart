import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:library_management_system/features/books/domain/entities/book_metadata.dart';
import 'package:library_management_system/features/books/domain/repositories/book_repository.dart';
import 'package:library_management_system/features/books/domain/usecases/create_book.dart';
import 'package:library_management_system/features/books/domain/usecases/lookup_book_by_isbn.dart';
import 'package:library_management_system/features/books/presentation/widgets/add_book_dialog.dart';

class _BookRepositoryFake extends Fake implements BookRepository {
  @override
  Future<BookMetadata?> lookupBookByIsbn(String isbn) async =>
      const BookMetadata(
        isbn: '9780132350884',
        title: 'Clean Code',
        author: 'Robert C. Martin',
        subjects: ['Software engineering'],
      );
}

void main() {
  testWidgets('shows the category matched from ISBN metadata', (tester) async {
    final repository = _BookRepositoryFake();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AddBookDialog(
            categories: const [
              {'categoryId': 7, 'categoryName': 'Software Engineering'},
            ],
            createBook: CreateBook(repository),
            lookupBook: LookupBookByIsbn(repository),
          ),
        ),
      ),
    );

    final isbnField = find.descendant(
      of: find.byWidgetPredicate(
        (widget) =>
            widget is InputDecorator &&
            widget.decoration.hintText == 'Enter ISBN',
      ),
      matching: find.byType(EditableText),
    );
    await tester.enterText(isbnField, '9780132350884');
    await tester.tap(find.text('Lookup'));
    await tester.pumpAndSettle();

    expect(find.text('Software Engineering'), findsOneWidget);
  });
}
