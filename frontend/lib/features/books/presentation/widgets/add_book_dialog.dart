import 'dart:async';

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:camera_scanner/camera_scanner.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../domain/entities/book_metadata.dart';
import '../../domain/usecases/create_book.dart';
import '../../domain/usecases/lookup_book_by_isbn.dart';

class AddBookDialog extends StatefulWidget {
  final List<dynamic> categories;
  final CreateBook createBook;
  final LookupBookByIsbn lookupBook;

  const AddBookDialog({
    required this.categories,
    required this.createBook,
    required this.lookupBook,
    super.key,
  });

  @override
  State<AddBookDialog> createState() => _AddBookDialogState();
}

class _AddBookDialogState extends State<AddBookDialog> {
  static const Color _blue = Color(0xFFF25635);
  static const Color _dark = Color(0xFF514746);
  static const Color _muted = Color(0xFF746E69);
  static const Color _line = Color(0xFFD5D2C7);
  static const Color _panel = Color(0xFFFBE2D9);

  final _formKey = GlobalKey<FormState>();
  final _isbnController = TextEditingController();
  final _isbnFocusNode = FocusNode();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _publisherController = TextEditingController();
  final _editionController = TextEditingController();
  final _yearController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _copiesController = TextEditingController(text: '1');
  final _locationController = TextEditingController();

  int? _categoryId;
  BookMetadata? _metadata;
  bool _lookingUp = false;
  bool _saving = false;
  bool _scanMode = false;
  String? _lookupMessage;
  String? _saveError;

  @override
  void dispose() {
    _isbnController.dispose();
    _isbnFocusNode.dispose();
    _titleController.dispose();
    _authorController.dispose();
    _publisherController.dispose();
    _editionController.dispose();
    _yearController.dispose();
    _descriptionController.dispose();
    _copiesController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  String _normalizedIsbn(String value) =>
      value.replaceAll(RegExp(r'[^0-9Xx]'), '').toUpperCase();

  String? _validateIsbn(String? value) {
    final isbn = _normalizedIsbn(value ?? '');
    if (isbn.isEmpty) return 'ISBN is required';
    if (!RegExp(r'^(?:\d{9}[\dX]|\d{13})$').hasMatch(isbn)) {
      return 'Enter a valid 10- or 13-digit ISBN';
    }
    return null;
  }

  Future<void> _lookupIsbn() async {
    final isbn = _normalizedIsbn(_isbnController.text);
    final validationError = _validateIsbn(isbn);
    if (validationError != null) {
      setState(() {
        _lookupMessage = validationError;
        _metadata = null;
      });
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _lookingUp = true;
      _lookupMessage = null;
      _saveError = null;
    });

    try {
      final result = await widget.lookupBook(isbn);
      if (!mounted) return;

      setState(() {
        _isbnController.text = isbn;
        _metadata = result;
        if (result == null) {
          _lookupMessage = 'No book details found for this ISBN.';
        } else {
          _fillFromMetadata(result);
          _lookupMessage = 'Book details found.';
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _metadata = null;
        _lookupMessage = 'Lookup failed: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _lookingUp = false;
        });
      }
    }
  }

  void _fillFromMetadata(BookMetadata metadata) {
    _setWhenPresent(_titleController, metadata.title);
    _setWhenPresent(_authorController, metadata.author);
    _setWhenPresent(_publisherController, metadata.publisher);
    _setWhenPresent(_editionController, metadata.edition);
    if (metadata.publicationYear != null) {
      _yearController.text = metadata.publicationYear.toString();
    }
    _setWhenPresent(_descriptionController, metadata.description);
  }

  void _setWhenPresent(TextEditingController controller, String? value) {
    if (value != null && value.trim().isNotEmpty) {
      controller.text = value.trim();
    }
  }

  Future<void> _scanBarcode() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.linux) {
      setState(() {
        _scanMode = false;
        _lookupMessage =
            'Camera scanning is not supported on Linux in this app. '
            'Type the ISBN or use a USB barcode scanner in the ISBN field.';
      });
      _isbnFocusNode.requestFocus();
      return;
    }

    final isbn = !kIsWeb && defaultTargetPlatform == TargetPlatform.windows
        ? await showDialog<String>(
            context: context,
            barrierDismissible: false,
            builder: (context) => const _WindowsBarcodeScannerDialog(),
          )
        : await showDialog<String>(
            context: context,
            builder: (context) => const _BarcodeScannerDialog(),
          );
    if (!mounted) return;
    setState(() {
      _scanMode = false;
    });
    if (isbn == null) return;
    _isbnController.text = isbn;
    await _lookupIsbn();
  }

  Future<void> _saveBook() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
      _saveError = null;
    });

    try {
      await widget.createBook({
        'title': _titleController.text.trim(),
        'authorName': _authorController.text.trim(),
        'categoryId': _categoryId,
        'numberOfCopies': int.parse(_copiesController.text.trim()),
        'location': _optional(_locationController.text),
        'isbn': _normalizedIsbn(_isbnController.text),
        'publisher': _optional(_publisherController.text),
        'edition': _optional(_editionController.text),
        'publicationYear': int.tryParse(_yearController.text.trim()),
        'description': _optional(_descriptionController.text),
        'coverImage': _metadata?.coverImage,
      });
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _saveError = 'Could not add book: $error';
      });
    }
  }

  String? _optional(String value) => value.trim().isEmpty ? null : value.trim();

  int? _categoryValue(dynamic category) {
    final value = category['categoryId'];
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  String _categoryName(dynamic category) =>
      category['categoryName']?.toString() ?? 'Unnamed category';

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final dialogWidth = (screenSize.width - 32).clamp(320.0, 1040.0).toDouble();
    final dialogHeight =
        (screenSize.height - 40).clamp(420.0, 720.0).toDouble();

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: SizedBox(
        width: dialogWidth,
        height: dialogHeight,
        child: Column(
          children: [
            _buildHeader(),
            const Divider(height: 1, color: _line),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 760) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildLookupPanel(compact: true),
                          const SizedBox(height: 20),
                          _buildBookForm(),
                        ],
                      ),
                    );
                  }
                  return Row(
                    children: [
                      SizedBox(
                        width: 350,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(18),
                          child: _buildLookupPanel(),
                        ),
                      ),
                      const VerticalDivider(width: 1, color: _line),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: _buildBookForm(),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 15, 14, 15),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: const Color(0xFFFBE2D9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.library_add, color: _blue),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Add New Book',
              style: TextStyle(
                color: _dark,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Close',
            onPressed: _saving ? null : () => Navigator.pop(context, false),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildLookupPanel({bool compact = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F4F7),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            children: [
              _modeButton(
                label: 'Scan Barcode',
                icon: Icons.barcode_reader,
                selected: _scanMode,
                onTap: () {
                  setState(() => _scanMode = true);
                  _scanBarcode();
                },
              ),
              _modeButton(
                label: 'Enter ISBN',
                icon: Icons.keyboard,
                selected: !_scanMode,
                onTap: () => setState(() => _scanMode = false),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: _saving ? null : _scanBarcode,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: compact ? 130 : 144,
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF6B7A5)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.qr_code_scanner, size: 38, color: _blue),
                const SizedBox(height: 6),
                const Text(
                  'Scan Book Barcode',
                  style: TextStyle(fontWeight: FontWeight.w700, color: _dark),
                ),
                const SizedBox(height: 4),
                Text(
                  'Use your camera to scan an ISBN barcode',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _muted, fontSize: compact ? 11 : 12),
                ),
              ],
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text('OR', style: TextStyle(color: _muted)),
              ),
              Expanded(child: Divider()),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _isbnController,
                focusNode: _isbnFocusNode,
                enabled: !_saving && !_lookingUp,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.search,
                onFieldSubmitted: (_) => _lookupIsbn(),
                decoration: _decoration('Enter ISBN', Icons.qr_code),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: _saving || _lookingUp ? null : _lookupIsbn,
              icon: _lookingUp
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.search),
              label: const Text('Lookup'),
              style: FilledButton.styleFrom(
                backgroundColor: _blue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 15,
                ),
              ),
            ),
          ],
        ),
        if (_lookupMessage != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _metadata == null
                  ? const Color(0xFFFFF4ED)
                  : const Color(0xFFE9F9EF),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                color: _metadata == null
                    ? const Color(0xFFFCD2B8)
                    : const Color(0xFFA6E4B7),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _metadata == null ? Icons.info_outline : Icons.check_circle,
                  size: 18,
                  color: _metadata == null
                      ? const Color(0xFFB54708)
                      : const Color(0xFF079455),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(_lookupMessage!)),
              ],
            ),
          ),
        ],
        if (_metadata != null) ...[
          const SizedBox(height: 12),
          _buildMetadataCard(_metadata!),
        ],
      ],
    );
  }

  Widget _modeButton({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: selected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(7),
        child: InkWell(
          borderRadius: BorderRadius.circular(7),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: selected ? _blue : _muted),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected ? _blue : _muted,
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetadataCard(BookMetadata metadata) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE4E7EC)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 84,
            height: 124,
            child: metadata.coverImage == null
                ? _coverPlaceholder()
                : ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.network(
                      metadata.coverImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _coverPlaceholder(),
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9F9EF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Google Books',
                    style: TextStyle(fontSize: 11, color: Color(0xFF067647)),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  metadata.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _dark,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (metadata.author.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      metadata.author,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: _dark, fontSize: 12),
                    ),
                  ),
                if (metadata.publisher != null)
                  _metadataDetail(Icons.business, metadata.publisher!),
                if (metadata.publicationYear != null)
                  _metadataDetail(
                    Icons.calendar_month,
                    metadata.publicationYear.toString(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _coverPlaceholder() => Container(
        color: const Color(0xFFF2F4F7),
        child: const Icon(Icons.menu_book, size: 34, color: _muted),
      );

  Widget _metadataDetail(IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Row(
          children: [
            Icon(icon, size: 14, color: _muted),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: _muted, fontSize: 11),
              ),
            ),
          ],
        ),
      );

  Widget _buildBookForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final twoColumns = constraints.maxWidth >= 500;
              if (!twoColumns) {
                return Column(
                  children: [
                    _field(_titleController, 'Book Title', required: true),
                    _field(_isbnController, 'ISBN',
                        required: true, validator: _validateIsbn),
                    _field(_authorController, 'Author', required: true),
                    _field(_publisherController, 'Publisher'),
                    _field(_editionController, 'Edition'),
                    _field(_yearController, 'Publication Year', numeric: true),
                  ],
                );
              }
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _field(
                          _titleController,
                          'Book Title',
                          required: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _field(
                          _isbnController,
                          'ISBN',
                          required: true,
                          validator: _validateIsbn,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _field(
                          _authorController,
                          'Author',
                          required: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                          child: _field(_publisherController, 'Publisher')),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: _field(_editionController, 'Edition')),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _field(
                          _yearController,
                          'Publication Year',
                          numeric: true,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          _field(
            _descriptionController,
            'Description',
            maxLines: 3,
          ),
          _dialogLabel('Category', required: true),
          DropdownButtonFormField<int>(
            initialValue: _categoryId,
            isExpanded: true,
            decoration: _decoration('Choose a category', Icons.category),
            items: widget.categories
                .map((category) {
                  final id = _categoryValue(category);
                  if (id == null) return null;
                  return DropdownMenuItem<int>(
                    value: id,
                    child: Text(_categoryName(category)),
                  );
                })
                .whereType<DropdownMenuItem<int>>()
                .toList(),
            onChanged:
                _saving ? null : (value) => setState(() => _categoryId = value),
            validator: (value) =>
                value == null ? 'Please select a category' : null,
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 500) {
                return Column(
                  children: [
                    _field(_locationController, 'Shelf Location'),
                    _field(
                      _copiesController,
                      'Number of Copies',
                      required: true,
                      numeric: true,
                      minimum: 1,
                    ),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      child: _field(_locationController, 'Shelf Location')),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _field(
                      _copiesController,
                      'Number of Copies',
                      required: true,
                      numeric: true,
                      minimum: 1,
                    ),
                  ),
                ],
              );
            },
          ),
          if (_saveError != null) ...[
            const SizedBox(height: 6),
            Text(
              _saveError!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _saving ? null : () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: _saving ? null : _saveBook,
                icon: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(_saving ? 'Saving...' : 'Save Book'),
                style: FilledButton.styleFrom(
                  backgroundColor: _blue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dialogLabel(String label, {bool required = false}) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: _dark,
                fontSize: 13,
              ),
            ),
            if (required) const Text(' *', style: TextStyle(color: Colors.red)),
          ],
        ),
      );

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = false,
    bool numeric = false,
    int? minimum,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _dialogLabel(label, required: required),
          TextFormField(
            controller: controller,
            enabled: !_saving,
            keyboardType: numeric ? TextInputType.number : TextInputType.text,
            maxLines: maxLines,
            decoration: _decoration('Enter ${label.toLowerCase()}',
                numeric ? Icons.numbers : Icons.edit_outlined),
            validator: validator ??
                (value) {
                  final text = value?.trim() ?? '';
                  if (required && text.isEmpty) return '$label is required';
                  if (numeric && text.isNotEmpty) {
                    final number = int.tryParse(text);
                    if (number == null) return 'Enter a valid whole number';
                    if (minimum != null && number < minimum) {
                      return 'Enter at least $minimum';
                    }
                    if (label == 'Publication Year' &&
                        (number < 1000 || number > DateTime.now().year + 1)) {
                      return 'Enter a valid publication year';
                    }
                  }
                  return null;
                },
          ),
        ],
      ),
    );
  }

  InputDecoration _decoration(String hint, IconData icon) => InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 19, color: _muted),
        filled: true,
        fillColor: const Color(0xFFFCFCFD),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: _line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: _line),
        ),
      );
}

class _BarcodeScannerDialog extends StatefulWidget {
  const _BarcodeScannerDialog();

  @override
  State<_BarcodeScannerDialog> createState() => _BarcodeScannerDialogState();
}

class _BarcodeScannerDialogState extends State<_BarcodeScannerDialog> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [BarcodeFormat.ean13, BarcodeFormat.ean8],
  );
  bool _detected = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 480,
        height: 440,
        child: Column(
          children: [
            ListTile(
              title: const Text('Scan ISBN Barcode'),
              trailing: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ),
            Expanded(
              child: MobileScanner(
                controller: _controller,
                onDetect: (capture) {
                  if (_detected || capture.barcodes.isEmpty) return;
                  final value = capture.barcodes.first.rawValue;
                  if (value == null || value.isEmpty) return;
                  _detected = true;
                  Navigator.of(context).pop(value);
                },
                errorBuilder: (context, error) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Camera unavailable. Check camera permission or enter '
                      'the ISBN manually.\n${error.errorCode.name}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text('Place the book barcode inside the camera frame.'),
            ),
          ],
        ),
      ),
    );
  }
}

class _WindowsBarcodeScannerDialog extends StatefulWidget {
  const _WindowsBarcodeScannerDialog();

  @override
  State<_WindowsBarcodeScannerDialog> createState() =>
      _WindowsBarcodeScannerDialogState();
}

class _WindowsBarcodeScannerDialogState
    extends State<_WindowsBarcodeScannerDialog> {
  CameraScanner? _scanner;
  StreamSubscription<String>? _scanSubscription;
  int? _cameraId;
  bool _loading = true;
  bool _detected = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    final cameraId = _cameraId;
    final scanner = _scanner;
    if (cameraId != null && scanner != null) {
      unawaited(
        _releaseCamera().catchError((Object error, StackTrace stackTrace) {
          FlutterError.reportError(
            FlutterErrorDetails(
              exception: error,
              stack: stackTrace,
              library: 'book barcode scanner',
            ),
          );
        }),
      );
    }
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    String? errorMessage;
    try {
      final scanner = CameraScanner.registerWith();
      final cameras = await scanner.availableCameras();
      if (!mounted) return;
      if (cameras.isEmpty) {
        throw StateError('No camera was found on this PC.');
      }

      final cameraId = await scanner.createCameraWithSettings(
        cameras.first,
        const MediaSettings(
          resolutionPreset: ResolutionPreset.high,
          enableAudio: false,
        ),
      );
      _scanner = scanner;
      _cameraId = cameraId;
      _scanSubscription = scanner.onScan(cameraId).listen(_handleBarcode);
      await scanner.initializeCamera(cameraId, ratio: 1.0);
    } catch (error) {
      errorMessage = error.toString();
      try {
        await _releaseCamera();
      } catch (releaseError) {
        errorMessage =
            '$errorMessage\nCould not release the camera: $releaseError';
      }
    }

    if (!mounted) return;
    setState(() {
      _loading = false;
      _errorMessage = errorMessage == null
          ? null
          : 'Could not open the PC camera: $errorMessage\n\n'
              'Check that Windows camera access is enabled in '
              'Settings > Privacy & security > Camera.';
    });
  }

  Future<void> _releaseCamera() async {
    await _scanSubscription?.cancel();
    _scanSubscription = null;

    final cameraId = _cameraId;
    final scanner = _scanner;
    _cameraId = null;
    _scanner = null;
    if (cameraId != null && scanner != null) {
      await scanner.dispose(cameraId);
    }
  }

  void _handleBarcode(String value) {
    if (_detected || value.trim().isEmpty) return;
    setState(() => _detected = true);
    unawaited(_finish(value.trim()));
  }

  Future<void> _finish(String? value) async {
    try {
      await _releaseCamera();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _detected = false;
        _errorMessage = 'Could not close the PC camera: $error';
      });
      return;
    }

    if (mounted) Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    final scanner = _scanner;
    final cameraId = _cameraId;

    return PopScope(
      canPop: false,
      child: Dialog(
        child: SizedBox(
          width: 480,
          height: 440,
          child: Column(
            children: [
              ListTile(
                title: const Text('Scan ISBN Barcode'),
                trailing: IconButton(
                  onPressed: _loading || _detected
                      ? null
                      : () => unawaited(_finish(null)),
                  icon: const Icon(Icons.close),
                ),
              ),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : scanner != null && cameraId != null
                            ? scanner.buildPreview(cameraId)
                            : const Center(
                                child: Text('Camera preview is unavailable.'),
                              ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  _errorMessage == null
                      ? 'Place the book barcode inside the camera frame.'
                      : 'You can close this window and enter the ISBN manually.',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
