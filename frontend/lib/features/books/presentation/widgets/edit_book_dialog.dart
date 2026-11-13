import 'package:flutter/material.dart';

import '../../domain/entities/book.dart';
import '../../domain/usecases/update_book.dart';

class EditBookDialog extends StatefulWidget {
  final Book book;
  final List<dynamic> categories;
  final UpdateBook updateBook;

  const EditBookDialog({
    required this.book,
    required this.categories,
    required this.updateBook,
    super.key,
  });

  @override
  State<EditBookDialog> createState() => _EditBookDialogState();
}

class _EditBookDialogState extends State<EditBookDialog> {
  static const Color _primary = Color(0xFFF25635);
  static const Color _dark = Color(0xFF514746);

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _authorController;
  late final TextEditingController _isbnController;
  late final TextEditingController _locationController;
  late final TextEditingController _publisherController;
  late final TextEditingController _editionController;
  late final TextEditingController _yearController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _coverImageController;

  int? _categoryId;
  bool _saving = false;
  String? _saveError;

  @override
  void initState() {
    super.initState();
    final book = widget.book;
    _titleController = TextEditingController(text: book.title);
    _authorController = TextEditingController(text: book.author);
    _isbnController = TextEditingController(text: book.isbn);
    _locationController = TextEditingController(text: book.location);
    _publisherController = TextEditingController(text: book.publisher ?? '');
    _editionController = TextEditingController(text: book.edition ?? '');
    _yearController = TextEditingController(
      text: book.publicationYear?.toString() ?? '',
    );
    _descriptionController =
        TextEditingController(text: book.description ?? '');
    _coverImageController = TextEditingController(text: book.coverImage ?? '');

    for (final category in widget.categories) {
      if (_categoryName(category).toLowerCase() ==
          book.category.toLowerCase()) {
        _categoryId = _categoryValue(category);
        break;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _isbnController.dispose();
    _locationController.dispose();
    _publisherController.dispose();
    _editionController.dispose();
    _yearController.dispose();
    _descriptionController.dispose();
    _coverImageController.dispose();
    super.dispose();
  }

  int? _categoryValue(dynamic category) {
    if (category is! Map) return null;
    final value = category['categoryId'];
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  String _categoryName(dynamic category) {
    if (category is! Map) return 'Unnamed category';
    return category['categoryName']?.toString() ?? 'Unnamed category';
  }

  String? _requiredValue(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label is required.';
    return null;
  }

  String? _validateIsbn(String? value) {
    final isbn = _normalizedIsbn(value ?? '');
    if (isbn.isEmpty) return null;
    if (!RegExp(r'^(?:\d{9}[\dX]|\d{13})$').hasMatch(isbn)) {
      return 'Enter a valid 10- or 13-digit ISBN.';
    }
    return null;
  }

  String _normalizedIsbn(String value) =>
      value.replaceAll(RegExp(r'[^0-9Xx]'), '').toUpperCase();

  String? _validateYear(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final year = int.tryParse(value.trim());
    if (year == null || year < 0) return 'Enter a valid publication year.';
    return null;
  }

  String? _optional(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
      _saveError = null;
    });

    try {
      await widget.updateBook(widget.book.id, {
        'title': _titleController.text.trim(),
        'authorName': _authorController.text.trim(),
        'categoryId': _categoryId,
        'location': _optional(_locationController),
        'isbn': _normalizedIsbn(_isbnController.text).isEmpty
            ? null
            : _normalizedIsbn(_isbnController.text),
        'publisher': _optional(_publisherController),
        'edition': _optional(_editionController),
        'publicationYear': int.tryParse(_yearController.text.trim()),
        'description': _optional(_descriptionController),
        'coverImage': _optional(_coverImageController),
      });

      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _saveError = 'Could not update book: $error';
      });
    }
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _primary, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: const Text(
        'Edit Book',
        style: TextStyle(color: _dark, fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: _decoration('Title'),
                  validator: (value) => _requiredValue(value, 'Title'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _authorController,
                  decoration: _decoration('Author'),
                  validator: (value) => _requiredValue(value, 'Author'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: _categoryId,
                  decoration: _decoration('Category'),
                  items: widget.categories
                      .map(
                        (category) => DropdownMenuItem<int>(
                          value: _categoryValue(category),
                          child: Text(_categoryName(category)),
                        ),
                      )
                      .where((item) => item.value != null)
                      .toList(),
                  onChanged: _saving
                      ? null
                      : (value) => setState(() => _categoryId = value),
                  validator: (value) =>
                      value == null ? 'Select a category.' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _isbnController,
                  decoration: _decoration('ISBN (optional)'),
                  validator: _validateIsbn,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _locationController,
                  decoration: _decoration('Shelf location'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _publisherController,
                  decoration: _decoration('Publisher (optional)'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _editionController,
                  decoration: _decoration('Edition (optional)'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _yearController,
                  decoration: _decoration('Publication year (optional)'),
                  keyboardType: TextInputType.number,
                  validator: _validateYear,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  decoration: _decoration('Description (optional)'),
                  minLines: 2,
                  maxLines: 4,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _coverImageController,
                  decoration: _decoration('Cover image URL (optional)'),
                  keyboardType: TextInputType.url,
                ),
                if (_saveError != null) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _saveError!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: _primary,
            foregroundColor: Colors.white,
          ),
          child: Text(_saving ? 'Saving...' : 'Save changes'),
        ),
      ],
    );
  }
}
