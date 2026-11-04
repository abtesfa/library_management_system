
import 'package:flutter/material.dart';
import '../../services/settings_api_service.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final SettingsApiService _apiService = SettingsApiService();

  late TextEditingController _nameController;
  late TextEditingController _dailyBooksController;
  late TextEditingController _borrowDaysController;
  late TextEditingController _renewalLimitController;
  late TextEditingController _fineController;

  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

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

  void _refreshSummary() {
    if (mounted) setState(() {});
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _apiService.getSettings();

      if (!mounted) return;

      _nameController.text = data['libraryName']?.toString() ?? '';
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

  Future<void> _saveSettings() async {
    final libraryName = _nameController.text.trim();
    final dailyBooks = int.tryParse(_dailyBooksController.text.trim());
    final borrowDays = int.tryParse(_borrowDaysController.text.trim());
    final renewalLimit = int.tryParse(_renewalLimitController.text.trim());
    final fine = double.tryParse(_fineController.text.trim());

    if (libraryName.isEmpty ||
        dailyBooks == null || dailyBooks < 1 ||
        borrowDays == null || borrowDays < 1 ||
        renewalLimit == null || renewalLimit < 0 ||
        fine == null || !fine.isFinite || fine < 0) {
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

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? Colors.red : const Color(0xFF059669),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dailyBooksController.dispose();
    _borrowDaysController.dispose();
    _renewalLimitController.dispose();
    _fineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF0052CC),
        ),
      );
    }

    if (_errorMessage != null) {
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
              ElevatedButton.icon(
                onPressed: _loadSettings,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.settings,
                  color: Color(0xFF0052CC),
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
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Configure library information, borrowing limits, and fine policies',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Settings cards and summary
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    _buildCard(
                      title: 'Library Information',
                      icon: Icons.local_library_outlined,
                      children: [
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Library Name',
                            prefixIcon:
                                Icon(Icons.library_books_outlined),
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    _buildCard(
                      title: 'Circulation Policies & Limits',
                      icon: Icons.rule_folder_outlined,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _numberField(
                                controller: _dailyBooksController,
                                label: 'Maximum Books Per Day',
                                suffix: 'Books',
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _numberField(
                                controller: _borrowDaysController,
                                label: 'Maximum Loan Duration',
                                suffix: 'Days',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: _numberField(
                                controller: _renewalLimitController,
                                label: 'Renewal Limit',
                                suffix: 'Times',
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _numberField(
                                controller: _fineController,
                                label: 'Overdue Fine Per Day',
                                prefix: 'ETB ',
                                decimal: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 24),

              // Policy Summary
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Policy Summary',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),

                      const SizedBox(height: 14),

                      _summaryTile(
                        'Library',
                        _nameController.text,
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

                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton.icon(
                          onPressed: _isSaving ? null : _saveSettings,
                          icon: _isSaving
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.save, size: 18),
                          label: Text(
                            _isSaving
                                ? 'Saving...'
                                : 'Save LMS Settings',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0052CC),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: _isSaving ? null : _loadSettings,
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Reload Saved Settings'),
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

  Widget _numberField({
    required TextEditingController controller,
    required String label,
    String? suffix,
    String? prefix,
    bool decimal = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(
        decimal: decimal,
      ),
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        prefixText: prefix,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFF0052CC),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _summaryTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
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
                color: Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
