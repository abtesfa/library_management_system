
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../../../../core/config/api_config.dart';
import '../../../../core/di/injector.dart';
import '../../../library/presentation/providers/library_service.dart';
import '../../domain/usecases/get_settings.dart';
import '../../domain/usecases/update_settings.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final GetSettings _getSettingsUseCase = injector.getSettings;
  final UpdateSettings _updateSettingsUseCase = injector.updateSettings;
  final ImagePicker _imagePicker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _maxBooksController;
  late TextEditingController _borrowDaysController;
  late TextEditingController _renewalLimitController;
  late TextEditingController _fineController;
  late TextEditingController _reservationHoldController;
  late TextEditingController _announcementTitleController;
  late TextEditingController _announcementMessageController;

  String _reservationHoldUnit = 'hours';
  String _announcementAudience = 'All Librarians';
  String _announcementPriority = 'Urgent';

  DateTime? _announcementValidUntil;

  XFile? _selectedLogo;
  String? _logoUrl;

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploadingLogo = false;

  String? _errorMessage;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  static const List<String> _librarianPositions = [
    'Librarian',
    'All Librarians',
    'Chief Circulation Librarian',
    'Cataloging Specialist',
    'Reference Librarian',
    'Acquisitions Librarian',
    'Digital Resources Librarian',
    'Archivist',
  ];

  static const Color primaryBlue = Color(0xFFF25635);
  static const Color textDark = Color(0xFF171717);
  static const Color textMuted = Color(0xFF666666);
  static const Color borderColor = Color(0xFFD9D9D9);

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController();
    _maxBooksController = TextEditingController();
    _borrowDaysController = TextEditingController();
    _renewalLimitController = TextEditingController();
    _fineController = TextEditingController();
    _reservationHoldController = TextEditingController();
    _announcementTitleController = TextEditingController();
    _announcementMessageController = TextEditingController();

    _nameController.addListener(_refreshSummary);
    _maxBooksController.addListener(_refreshSummary);
    _borrowDaysController.addListener(_refreshSummary);
    _renewalLimitController.addListener(_refreshSummary);
    _fineController.addListener(_refreshSummary);
    _reservationHoldController.addListener(_refreshSummary);

    _loadSettings();
  }

  // =========================================================
  // LIVE POLICY SUMMARY
  // =========================================================

  void _refreshSummary() {
    if (mounted) {
      setState(() {});
    }
  }

  // =========================================================
  // LOAD SETTINGS
  // =========================================================

  Future<void> _loadSettings() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _getSettingsUseCase();

      if (!mounted) return;

      _nameController.text = data['libraryName']?.toString() ?? '';

      _logoUrl = data['logoUrl']?.toString();

      _maxBooksController.text =
          data['maxBooksPerStudent']?.toString() ?? '3';

      _borrowDaysController.text =
          data['maxBorrowingDays']?.toString() ?? '';

      _renewalLimitController.text =
          data['renewalLimit']?.toString() ?? '2';

      _fineController.text =
          data['finePerDay']?.toString() ?? '5.00';

      final holdMinutes =
          (data['reservationHoldMinutes'] as num?)?.toInt() ?? 1440;

      if (holdMinutes % 1440 == 0) {
        _reservationHoldUnit = 'days';
        _reservationHoldController.text =
            (holdMinutes ~/ 1440).toString();
      } else if (holdMinutes % 60 == 0) {
        _reservationHoldUnit = 'hours';
        _reservationHoldController.text =
            (holdMinutes ~/ 60).toString();
      } else {
        _reservationHoldUnit = 'minutes';
        _reservationHoldController.text = holdMinutes.toString();
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  // =========================================================
  // LOGO IMAGE SELECTION
  // =========================================================

  Future<void> _pickLogo() async {
    if (_isUploadingLogo || _isSaving) return;

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
      );

      if (image == null || !mounted) return;

      setState(() {
        _selectedLogo = image;
      });
    } catch (e) {
      _showMessage(
        'Unable to select logo: $e',
        isError: true,
      );
    }
  }

  // =========================================================
  // RESOLVE LOGO URL
  // =========================================================

  String _resolveLogoUrl(String path) {
    if (path.startsWith('http://') ||
        path.startsWith('https://')) {
      return path;
    }

    final apiUri = Uri.parse(ApiConfig.baseUrl);

    return apiUri.replace(
      path: path.startsWith('/') ? path : '/$path',
      query: null,
      fragment: null,
    ).toString();
  }

  // =========================================================
  // UPLOAD LOGO
  // =========================================================

  Future<void> _uploadLogo() async {
    if (_isUploadingLogo || _selectedLogo == null) return;

    setState(() {
      _isUploadingLogo = true;
    });

    try {
      final imageBytes = await _selectedLogo!.readAsBytes();

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/settings/logo'),
      );

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: _selectedLogo!.name,
        ),
      );

      final streamedResponse = await request.send();

      final response = await http.Response.fromStream(
        streamedResponse,
      );

      if (response.statusCode != 200 &&
          response.statusCode != 201) {
        throw Exception(
          'Upload failed (${response.statusCode}): ${response.body}',
        );
      }

      final libraryService = Provider.of<LibraryService>(
        context,
        listen: false,
      );

      await libraryService.loadSettingsFromApi();

      final settings = await _getSettingsUseCase();

      if (!mounted) return;

      setState(() {
        _logoUrl = settings['logoUrl']?.toString();
        _selectedLogo = null;
        _isUploadingLogo = false;
      });

      _showMessage('Library logo uploaded successfully!');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isUploadingLogo = false;
      });

      _showMessage(
        'Unable to upload logo: $e',
        isError: true,
      );
    }
  }

  // =========================================================
  // LOGO SETTINGS CARD
  // =========================================================

  Widget _buildLogoCard() {
    return _buildCard(
      title: 'Library Logo',
      icon: Icons.image_outlined,
      children: [
        Center(
          child: Container(
            width: 150,
            height: 150,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFBF1E4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: _selectedLogo != null
                ? FutureBuilder<Uint8List>(
                    future: _selectedLogo!.readAsBytes(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Image.memory(
                          snapshot.data!,
                          fit: BoxFit.contain,
                        );
                      }

                      if (snapshot.hasError) {
                        return const Icon(
                          Icons.broken_image_outlined,
                          size: 65,
                          color: textMuted,
                        );
                      }

                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  )
                : _logoUrl != null && _logoUrl!.isNotEmpty
                    ? Image.network(
                        _resolveLogoUrl(_logoUrl!),
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) {
                          return const Icon(
                            Icons.menu_book,
                            size: 75,
                            color: primaryBlue,
                          );
                        },
                      )
                    : const Icon(
                        Icons.menu_book,
                        size: 75,
                        color: primaryBlue,
                      ),
          ),
        ),

        const SizedBox(height: 16),

        const Center(
          child: Text(
            'Your library logo will appear on the public landing page.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textMuted,
              fontSize: 12,
            ),
          ),
        ),

        const SizedBox(height: 16),

        LayoutBuilder(
          builder: (context, constraints) {
            final chooseButton = OutlinedButton.icon(
              onPressed: _isUploadingLogo || _isSaving
                  ? null
                  : _pickLogo,
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Choose Image'),
            );

            final uploadButton = ElevatedButton.icon(
              onPressed:
                  _selectedLogo == null || _isUploadingLogo
                      ? null
                      : _uploadLogo,
              icon: _isUploadingLogo
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.cloud_upload_outlined),
              label: Text(
                _isUploadingLogo ? 'Uploading...' : 'Upload Logo',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
              ),
            );

            if (constraints.maxWidth < 400) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  chooseButton,
                  const SizedBox(height: 10),
                  uploadButton,
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: chooseButton),
                const SizedBox(width: 12),
                Expanded(child: uploadButton),
              ],
            );
          },
        ),

        if (_selectedLogo != null) ...[
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: _isUploadingLogo
                  ? null
                  : () {
                      setState(() {
                        _selectedLogo = null;
                      });
                    },
              child: const Text('Cancel Selection'),
            ),
          ),
        ],
      ],
    );
  }

  // =========================================================
  // SAVE SETTINGS
  // =========================================================

  Future<void> _saveSettings() async {
    if (_isSaving || _isUploadingLogo) return;

    if (!_formKey.currentState!.validate()) {
      _showMessage(
        'Please correct the highlighted fields.',
        isError: true,
      );
      return;
    }

    final libraryName = _nameController.text.trim();

    final maxBooksPerStudent =
        int.tryParse(_maxBooksController.text.trim());

    final borrowDays =
        int.tryParse(_borrowDaysController.text.trim());

    final renewalLimit =
        int.tryParse(_renewalLimitController.text.trim());

    final fine = double.tryParse(_fineController.text.trim());

    final reservationHoldAmount =
        int.tryParse(_reservationHoldController.text.trim());

    final reservationHoldMinutes = reservationHoldAmount == null
        ? null
        : reservationHoldAmount *
            switch (_reservationHoldUnit) {
              'days' => 1440,
              'hours' => 60,
              _ => 1,
            };

    if (maxBooksPerStudent == null ||
        borrowDays == null ||
        renewalLimit == null ||
        fine == null ||
        !fine.isFinite ||
        reservationHoldMinutes == null ||
        reservationHoldMinutes < 1 ||
        reservationHoldMinutes > 2147483647) {
      _showMessage(
        'Please enter valid settings.',
        isError: true,
      );
      return;
    }

    final libraryService = Provider.of<LibraryService>(
      context,
      listen: false,
    );

    setState(() {
      _isSaving = true;
    });

    try {
      await _updateSettingsUseCase(
        libraryName: libraryName,
        maxBooksPerStudent: maxBooksPerStudent,
        maxBorrowingDays: borrowDays,
        renewalLimit: renewalLimit,
        finePerDay: fine,
        reservationHoldMinutes: reservationHoldMinutes,
      );

      await libraryService.loadSettingsFromApi();

      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      final settingsError = libraryService.settingsError;

      _showMessage(
        settingsError == null
            ? 'LMS settings saved successfully!'
            : 'Settings saved, but borrowing settings could not be refreshed: $settingsError',
        isError: settingsError != null,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      _showMessage(
        'Failed to save settings: $e',
        isError: true,
      );
    }
  }

  // =========================================================
  // MESSAGE
  // =========================================================

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isError
                    ? Icons.error_outline
                    : Icons.check_circle_outline,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor:
              isError ? Colors.red : const Color(0xFF059669),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // =========================================================
  // DISPOSE
  // =========================================================

  @override
  void dispose() {
    _nameController.removeListener(_refreshSummary);
    _maxBooksController.removeListener(_refreshSummary);
    _borrowDaysController.removeListener(_refreshSummary);
    _renewalLimitController.removeListener(_refreshSummary);
    _fineController.removeListener(_refreshSummary);
    _reservationHoldController.removeListener(_refreshSummary);

    _nameController.dispose();
    _maxBooksController.dispose();
    _borrowDaysController.dispose();
    _renewalLimitController.dispose();
    _fineController.dispose();
    _reservationHoldController.dispose();
    _announcementTitleController.dispose();
    _announcementMessageController.dispose();

    super.dispose();
  }

  // =========================================================
  // MAIN BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: primaryBlue,
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),

            LayoutBuilder(
              builder: (context, constraints) {
                final bool compact = constraints.maxWidth < 950;

                final settingsContent = Column(
                  children: [
                    _buildLogoCard(),
                    const SizedBox(height: 20),

                    _buildCard(
                      title: 'Library Information',
                      icon: Icons.local_library_outlined,
                      children: [
                        _buildTextField(
                          controller: _nameController,
                          label: 'Library Name',
                          icon: Icons.library_books_outlined,
                          requiredField: true,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    _buildCard(
                      title: 'Circulation Policies & Limits',
                      icon: Icons.rule_folder_outlined,
                      children: [
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final bool small =
                                constraints.maxWidth < 500;

                            if (small) {
                              return Column(
                                children: [
                                  _buildNumberField(
                                    controller: _maxBooksController,
                                    label: 'Maximum Books Per Student',
                                    suffix: 'Books',
                                    minimum: 1,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildNumberField(
                                    controller: _borrowDaysController,
                                    label: 'Maximum Loan Duration',
                                    suffix: 'Days',
                                    minimum: 1,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildNumberField(
                                    controller: _renewalLimitController,
                                    label: 'Renewal Limit',
                                    suffix: 'Times',
                                    minimum: 0,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildNumberField(
                                    controller: _fineController,
                                    label: 'Overdue Fine Per Day',
                                    prefix: 'ETB ',
                                    decimal: true,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildReservationHoldField(),
                                ],
                              );
                            }

                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildNumberField(
                                        controller: _maxBooksController,
                                        label: 'Maximum Books Per Student',
                                        suffix: 'Books',
                                        minimum: 1,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: _buildNumberField(
                                        controller: _borrowDaysController,
                                        label: 'Maximum Loan Duration',
                                        suffix: 'Days',
                                        minimum: 1,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildNumberField(
                                        controller: _renewalLimitController,
                                        label: 'Renewal Limit',
                                        suffix: 'Times',
                                        minimum: 0,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: _buildNumberField(
                                        controller: _fineController,
                                        label: 'Overdue Fine Per Day',
                                        prefix: 'ETB ',
                                        decimal: true,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildReservationHoldField(),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                );

                final summary = _buildPolicySummary();

                if (compact) {
                  return Column(
                    children: [
                      settingsContent,
                      const SizedBox(height: 20),
                      summary,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: settingsContent,
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 2,
                      child: summary,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // ANNOUNCEMENTS
  // =========================================================

  Future<void> _showAnnouncementDialog() async {
    _announcementTitleController.clear();
    _announcementMessageController.clear();

    setState(() {
      _announcementAudience = 'All Librarians';
      _announcementPriority = 'Urgent';
      _announcementValidUntil = null;
    });

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        String selectedAudience = _announcementAudience;
        String selectedPriority = _announcementPriority;
        DateTime? selectedValidUntil = _announcementValidUntil;

        Color priorityColor(String priority) {
          return switch (priority) {
            'Normal' => const Color(0xFF9CA3AF),
            'Important' => const Color(0xFF3B82F6),
            _ => const Color(0xFFEF4444),
          };
        }

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 24,
              ),
              titlePadding: EdgeInsets.zero,
              contentPadding:
                  const EdgeInsets.fromLTRB(20, 18, 20, 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Container(
                width: 620,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFF514746),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.menu_book,
                      color: Colors.white,
                      size: 36,
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Make Announcement',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Share important information with librarians',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              content: SizedBox(
                width: 520,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Share important information with librarians.',
                        style: TextStyle(color: textMuted),
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        controller: _announcementTitleController,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _announcementMessageController,
                        minLines: 3,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          labelText: 'Message',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 14),

                      LayoutBuilder(
                        builder: (context, constraints) {
                          final priorityField =
                              DropdownButtonFormField<String>(
                            initialValue: selectedPriority,
                            decoration: const InputDecoration(
                              labelText: 'Priority',
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              'Normal',
                              'Important',
                              'Urgent',
                            ].map((priority) {
                              return DropdownMenuItem(
                                value: priority,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: priorityColor(priority),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(priority),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setDialogState(() {
                                  selectedPriority = value;
                                  _announcementPriority = value;
                                });
                              }
                            },
                          );

                          final validUntilField = InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: dialogContext,
                                initialDate: selectedValidUntil ??
                                    DateTime.now().add(
                                      const Duration(days: 1),
                                    ),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365 * 5),
                                ),
                              );

                              if (date != null) {
                                setDialogState(() {
                                  selectedValidUntil = date;
                                  _announcementValidUntil = date;
                                });
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Valid Until (Optional)',
                                border: OutlineInputBorder(),
                                suffixIcon:
                                    Icon(Icons.calendar_today),
                              ),
                              child: Text(
                                selectedValidUntil == null
                                    ? 'Select date...'
                                    : '${selectedValidUntil!.year}-${selectedValidUntil!.month.toString().padLeft(2, '0')}-${selectedValidUntil!.day.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  color: selectedValidUntil == null
                                      ? textMuted
                                      : textDark,
                                ),
                              ),
                            ),
                          );

                          if (constraints.maxWidth < 460) {
                            return Column(
                              children: [
                                priorityField,
                                const SizedBox(height: 14),
                                validUntilField,
                              ],
                            );
                          }

                          return Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Expanded(child: priorityField),
                              const SizedBox(width: 14),
                              Expanded(child: validUntilField),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 14),

                      DropdownButtonFormField<String>(
                        initialValue: selectedAudience,
                        decoration: const InputDecoration(
                          labelText: 'Target Audience',
                          border: OutlineInputBorder(),
                        ),
                        items: _librarianPositions.map((position) {
                          return DropdownMenuItem(
                            value: position,
                            child: Text(position),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() {
                              selectedAudience = value;
                              _announcementAudience = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final title =
                        _announcementTitleController.text.trim();

                    final message =
                        _announcementMessageController.text.trim();

                    if (title.isEmpty || message.isEmpty) {
                      _showMessage(
                        'Enter both a title and message.',
                        isError: true,
                      );
                      return;
                    }

                    try {
                      final response = await http.post(
                        Uri.parse(
                          '${ApiConfig.baseUrl}/notifications/announcements',
                        ),
                        headers: const {
                          'Content-Type': 'application/json',
                        },
                        body: jsonEncode({
                          'title': title,
                          'message': message,
                          'priority':
                              selectedPriority.toUpperCase(),
                          'audiencePositions':
                              selectedAudience == 'All Librarians'
                                  ? <String>[]
                                  : <String>[selectedAudience],
                          'validFrom': null,
                          'validUntil':
                              selectedValidUntil == null
                                  ? null
                                  : '${selectedValidUntil!.year}-${selectedValidUntil!.month.toString().padLeft(2, '0')}-${selectedValidUntil!.day.toString().padLeft(2, '0')}',
                        }),
                      );

                      if (response.statusCode != 200 &&
                          response.statusCode != 201) {
                        throw Exception(
                          'Failed to send announcement: ${response.body}',
                        );
                      }

                      if (!dialogContext.mounted) return;

                      Navigator.of(dialogContext).pop();

                      _showMessage(
                        'Announcement sent successfully.',
                      );
                    } catch (e) {
                      _showMessage(
                        'Unable to send announcement: $e',
                        isError: true,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Send Announcement'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // =========================================================
  // HEADER
  // =========================================================

  Widget _buildHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final announcementButton = ElevatedButton.icon(
          onPressed: _showAnnouncementDialog,
          icon: const Icon(Icons.campaign_outlined, size: 18),
          label: const Text('Make Announcement'),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        );

        final heading = Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFBE2D9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.settings,
                color: primaryBlue,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LMS Settings',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Configure library information, borrowing limits, and fine policies.',
                    style: TextStyle(
                      fontSize: 12,
                      color: textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

        if (constraints.maxWidth < 600) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              heading,
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: announcementButton,
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: heading),
            const SizedBox(width: 12),
            announcementButton,
          ],
        );
      },
    );
  }

  // =========================================================
  // ERROR STATE
  // =========================================================

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 12),
            const Text(
              'Unable to load LMS settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            _HoverActionButton(
              label: 'Try Again',
              icon: Icons.refresh,
              onPressed: _loadSettings,
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // SETTINGS CARD
  // =========================================================

  Widget _buildCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: primaryBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  // =========================================================
  // TEXT FIELD
  // =========================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool requiredField = false,
  }) {
    return TextFormField(
      controller: controller,
      enabled: !_isSaving,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: textMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(
            color: primaryBlue,
            width: 1.5,
          ),
        ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 15,
        ),
      ),
      validator: (value) {
        if (requiredField &&
            (value == null || value.trim().isEmpty)) {
          return '$label is required';
        }

        return null;
      },
    );
  }

  // =========================================================
  // NUMBER FIELD
  // =========================================================

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    String? suffix,
    String? prefix,
    int minimum = 0,
    bool decimal = false,
  }) {
    return TextFormField(
      controller: controller,
      enabled: !_isSaving,
      keyboardType: TextInputType.numberWithOptions(
        decimal: decimal,
      ),
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        prefixText: prefix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(
            color: primaryBlue,
            width: 1.5,
          ),
        ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 15,
        ),
      ),
      validator: (value) {
        final text = value?.trim() ?? '';

        if (text.isEmpty) {
          return '$label is required';
        }

        if (decimal) {
          final number = double.tryParse(text);

          if (number == null || !number.isFinite) {
            return 'Enter a valid amount';
          }

          if (number < 0) {
            return 'Amount cannot be negative';
          }
        } else {
          final number = int.tryParse(text);

          if (number == null) {
            return 'Enter a valid whole number';
          }

          if (number < minimum) {
            return 'Minimum value is $minimum';
          }
        }

        return null;
      },
    );
  }

  // =========================================================
  // RESERVATION HOLD FIELD
  // =========================================================

  Widget _buildReservationHoldField() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final durationInput = TextFormField(
          controller: _reservationHoldController,
          enabled: !_isSaving,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Reservation Pickup Time Limit',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: const BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: const BorderSide(
                color: primaryBlue,
                width: 1.5,
              ),
            ),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 15,
            ),
          ),
          validator: (value) {
            final amount = int.tryParse(value?.trim() ?? '');

            if (amount == null || amount < 1) {
              return 'Enter a whole number greater than zero';
            }

            final multiplier = switch (_reservationHoldUnit) {
              'days' => 1440,
              'hours' => 60,
              _ => 1,
            };

            if (amount > 2147483647 ~/ multiplier) {
              return 'Pickup time limit is too large';
            }

            return null;
          },
        );

        final unitInput = DropdownButtonFormField<String>(
          initialValue: _reservationHoldUnit,
          decoration: InputDecoration(
            labelText: 'Unit',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: const BorderSide(color: borderColor),
            ),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 15,
            ),
          ),
          items: const [
            DropdownMenuItem(
              value: 'minutes',
              child: Text('Minutes'),
            ),
            DropdownMenuItem(
              value: 'hours',
              child: Text('Hours'),
            ),
            DropdownMenuItem(
              value: 'days',
              child: Text('Days'),
            ),
          ],
          onChanged: _isSaving
              ? null
              : (value) {
                  if (value != null) {
                    setState(() {
                      _reservationHoldUnit = value;
                    });
                  }
                },
        );

        if (constraints.maxWidth < 390) {
          return Column(
            children: [
              durationInput,
              const SizedBox(height: 12),
              unitInput,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: durationInput),
            const SizedBox(width: 14),
            Expanded(child: unitInput),
          ],
        );
      },
    );
  }

  // =========================================================
  // POLICY SUMMARY
  // =========================================================

  Widget _buildPolicySummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.fact_check_outlined,
                color: primaryBlue,
                size: 21,
              ),
              SizedBox(width: 8),
              Text(
                'Policy Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          _summaryTile(
            'Library',
            _nameController.text.isEmpty
                ? 'Not specified'
                : _nameController.text,
          ),

          _summaryTile(
            'Maximum Books Per Student',
            '${_maxBooksController.text} Books',
          ),

          _summaryTile(
            'Borrow Period',
            '${_borrowDaysController.text} Days',
          ),

          _summaryTile(
            'Reservation Pickup Limit',
            '${_reservationHoldController.text} '
                '${_reservationHoldUnit[0].toUpperCase()}'
                '${_reservationHoldUnit.substring(1)}',
          ),

          _summaryTile(
            'Renewal Limit',
            '${_renewalLimitController.text} Times',
          ),

          _summaryTile(
            'Fine Per Day',
            'ETB ${_fineController.text}',
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: _HoverActionButton(
              label: _isSaving ? 'Saving...' : 'Save LMS Settings',
              icon: _isSaving
                  ? Icons.hourglass_top
                  : Icons.save_outlined,
              onPressed: _isSaving || _isUploadingLogo
                  ? () {}
                  : _saveSettings,
              backgroundColor: primaryBlue,
            ),
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: _HoverActionButton(
              label: 'Reload Saved Settings',
              icon: Icons.refresh,
              onPressed: _isSaving || _isUploadingLogo
                  ? () {}
                  : _loadSettings,
              backgroundColor: const Color(0xFFFBE2D9),
              foregroundColor: primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // SUMMARY TILE
  // =========================================================

  Widget _summaryTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: textMuted,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================
// REUSABLE ANIMATED HOVER BUTTON
// =============================================================

class _HoverActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color foregroundColor;

  const _HoverActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.backgroundColor = const Color(0xFFF25635),
    this.foregroundColor = Colors.white,
  });

  @override
  State<_HoverActionButton> createState() =>
      _HoverActionButtonState();
}

class _HoverActionButtonState extends State<_HoverActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(
          0,
          _isHovered ? -3 : 0,
          0,
        ),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(9),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: widget.foregroundColor.withValues(
                      alpha: 0.15,
                    ),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(9),
            onTap: widget.onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 13,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.icon,
                    size: 18,
                    color: widget.foregroundColor,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      widget.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: widget.foregroundColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
