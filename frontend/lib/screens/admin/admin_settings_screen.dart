
import 'package:flutter/material.dart';
import '../../services/settings_api_service.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() =>
      _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final SettingsApiService _apiService = SettingsApiService();

  late TextEditingController _nameController;
  late TextEditingController _dailyBooksController;
  late TextEditingController _borrowDaysController;
  late TextEditingController _renewalLimitController;
  late TextEditingController _fineController;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  static const Color primaryBlue = Color(0xFF0052CC);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color borderColor = Color(0xFFE2E8F0);

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController();
    _dailyBooksController = TextEditingController();
    _borrowDaysController = TextEditingController();
    _renewalLimitController = TextEditingController();
    _fineController = TextEditingController();

    _nameController.addListener(_refreshSummary);
    _dailyBooksController.addListener(_refreshSummary);
    _borrowDaysController.addListener(_refreshSummary);
    _renewalLimitController.addListener(_refreshSummary);
    _fineController.addListener(_refreshSummary);

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
  // LOAD SETTINGS FROM BACKEND
  // =========================================================

  Future<void> _loadSettings() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _apiService.getSettings();

      if (!mounted) return;

      _nameController.text =
          data['libraryName']?.toString() ?? '';

      _dailyBooksController.text =
          data['maxBooksPerDay']?.toString() ?? '3';

      _borrowDaysController.text =
          data['maxBorrowingDays']?.toString() ?? '14';

      _renewalLimitController.text =
          data['renewalLimit']?.toString() ?? '2';

      _fineController.text =
          data['finePerDay']?.toString() ?? '5.00';

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
  // SAVE SETTINGS TO BACKEND
  // =========================================================

  Future<void> _saveSettings() async {
    if (_isSaving) return;

    if (!_formKey.currentState!.validate()) {
      _showMessage(
        'Please correct the highlighted fields.',
        isError: true,
      );
      return;
    }

    final libraryName = _nameController.text.trim();

    final dailyBooks =
        int.tryParse(_dailyBooksController.text.trim());

    final borrowDays =
        int.tryParse(_borrowDaysController.text.trim());

    final renewalLimit =
        int.tryParse(_renewalLimitController.text.trim());

    final fine =
        double.tryParse(_fineController.text.trim());

    if (dailyBooks == null ||
        borrowDays == null ||
        renewalLimit == null ||
        fine == null ||
        !fine.isFinite) {
      _showMessage(
        'Please enter valid settings.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _apiService.updateSettings(
        libraryName: libraryName,
        maxBooksPerDay: dailyBooks,
        maxBorrowingDays: borrowDays,
        renewalLimit: renewalLimit,
        finePerDay: fine,
      );

      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      _showMessage(
        'LMS settings saved successfully!',
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
    _dailyBooksController.removeListener(_refreshSummary);
    _borrowDaysController.removeListener(_refreshSummary);
    _renewalLimitController.removeListener(_refreshSummary);
    _fineController.removeListener(_refreshSummary);

    _nameController.dispose();
    _dailyBooksController.dispose();
    _borrowDaysController.dispose();
    _renewalLimitController.dispose();
    _fineController.dispose();

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
                final bool compact =
                    constraints.maxWidth < 950;

                final settingsContent = Column(
                  children: [
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
                                    controller:
                                        _dailyBooksController,
                                    label:
                                        'Maximum Books Per Day',
                                    suffix: 'Books',
                                    minimum: 1,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildNumberField(
                                    controller:
                                        _borrowDaysController,
                                    label:
                                        'Maximum Loan Duration',
                                    suffix: 'Days',
                                    minimum: 1,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildNumberField(
                                    controller:
                                        _renewalLimitController,
                                    label: 'Renewal Limit',
                                    suffix: 'Times',
                                    minimum: 0,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildNumberField(
                                    controller: _fineController,
                                    label:
                                        'Overdue Fine Per Day',
                                    prefix: 'ETB ',
                                    decimal: true,
                                  ),
                                ],
                              );
                            }

                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildNumberField(
                                        controller:
                                            _dailyBooksController,
                                        label:
                                            'Maximum Books Per Day',
                                        suffix: 'Books',
                                        minimum: 1,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: _buildNumberField(
                                        controller:
                                            _borrowDaysController,
                                        label:
                                            'Maximum Loan Duration',
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
                                        controller:
                                            _renewalLimitController,
                                        label: 'Renewal Limit',
                                        suffix: 'Times',
                                        minimum: 0,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: _buildNumberField(
                                        controller: _fineController,
                                        label:
                                            'Overdue Fine Per Day',
                                        prefix: 'ETB ',
                                        decimal: true,
                                      ),
                                    ),
                                  ],
                                ),
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
  // HEADER
  // =========================================================

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
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
            'Daily Borrowing Limit',
            '${_dailyBooksController.text} Books',
          ),

          _summaryTile(
            'Borrow Period',
            '${_borrowDaysController.text} Days',
          ),

          _summaryTile(
            'Renewal Limit',
            '${_renewalLimitController.text} Times',
          ),

          _summaryTile(
            'Daily Late Fee',
            'ETB ${_fineController.text}',
          ),

          const SizedBox(height: 20),

          // SAVE BUTTON
          SizedBox(
            width: double.infinity,
            child: _HoverActionButton(
              label: _isSaving
                  ? 'Saving...'
                  : 'Save LMS Settings',
              icon: _isSaving
                  ? Icons.hourglass_top
                  : Icons.save_outlined,
              onPressed: _isSaving
                  ? () {}
                  : _saveSettings,
              backgroundColor: primaryBlue,
            ),
          ),

          const SizedBox(height: 10),

          // RELOAD BUTTON
          SizedBox(
            width: double.infinity,
            child: _HoverActionButton(
              label: 'Reload Saved Settings',
              icon: Icons.refresh,
              onPressed: _isSaving ? () {} : _loadSettings,
              backgroundColor: const Color(0xFFEFF6FF),
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
    this.backgroundColor = const Color(0xFF1877F2),
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
                    color: widget.foregroundColor.withValues(alpha: 0.15),
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
