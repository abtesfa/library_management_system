import 'package:flutter/material.dart';

import '../../domain/entities/staff_member.dart';
import '../../../../core/di/injector.dart';
import '../../domain/usecases/get_all_staff.dart';
import '../../domain/usecases/add_staff.dart';
import '../../domain/usecases/update_staff.dart';
import '../../domain/usecases/update_staff_status.dart';

class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  State<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
  static const Color primary = Color(0xFFF25635);
  static const Color dark = Color(0xFF171717);
  static const Color muted = Color(0xFF666666);
  static const Color borderColor = Color(0xFFD9D9D9);
  static const Color backgroundColor = Color(0xFFFBF1E4);

  final GetAllStaff _getAllStaffUseCase = injector.getAllStaff;
  final AddStaff _addStaffUseCase = injector.addStaff;
  final UpdateStaff _updateStaffUseCase = injector.updateStaff;
  final UpdateStaffStatus _updateStaffStatusUseCase =
      injector.updateStaffStatus;

  final TextEditingController _searchController = TextEditingController();

  List<StaffMember> _staff = [];

  bool _isLoading = true;
  String? _errorMessage;

  String _selectedRole = 'All Roles';

  final List<String> _positions = [
    'Chief Circulation Librarian',
    'Cataloging Specialist',
    'Reference Librarian',
    'Acquisitions Librarian',
    'Digital Resources Librarian',
    'Archivist',
  ];

  final Map<String, String> _permissionLabels = {
    'ADD_BOOK': 'Add Books',
    'EDIT_BOOK': 'Edit Book Information',
    'DELETE_BOOK': 'Delete Books',
    'MANAGE_COPIES': 'Manage Physical Copies',
    'BORROW_BOOK': 'Borrow / Issue Books',
    'RETURN_BOOK': 'Return Books',
    'RENEW_BOOK': 'Renew Borrowed Books',
    'VIEW_MEMBERS': 'View Members',
    'MANAGE_MEMBERS': 'Add and Edit Members',
    'COLLECT_FINE': 'Collect Fines',
    'WAIVE_FINE': 'Waive Fines',
    'VIEW_REPORTS': 'View Reports',
    'GENERATE_REPORTS': 'Generate Reports',
    'CONFIGURE_SETTINGS': 'Configure LMS Settings',
    'MANAGE_STAFF': 'Manage Staff Members',
  };

  @override
  void initState() {
    super.initState();
    _loadStaff();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // VALIDATION HELPERS
  // ------------------------------------------------------------

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full Name is required.';
    }

    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    // Email and phone are both optional individually.
    // At least one of them must be entered.
    if (email.isEmpty) {
      return null;
    }

    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!emailPattern.hasMatch(email)) {
      return 'Please enter a valid email address.';
    }

    return null;
  }

  String? _validatePhone(String? value) {
    final phone = value?.trim() ?? '';

    if (phone.isEmpty) {
      return null;
    }

    // Allows digits, spaces, +, -, and parentheses.
    final allowedCharacters = RegExp(r'^[0-9+\-()\s]+$');

    if (!allowedCharacters.hasMatch(phone)) {
      return 'Please enter a valid phone number.';
    }

    final digits = phone.replaceAll(RegExp(r'\D'), '');

    if (digits.length < 7 || digits.length > 15) {
      return 'Phone number must contain 7 to 15 digits.';
    }

    return null;
  }

  String? _validateContact({
    required String email,
    required String phone,
  }) {
    if (email.trim().isEmpty && phone.trim().isEmpty) {
      return 'Please enter at least an email address or phone number.';
    }

    return null;
  }

  // ------------------------------------------------------------
  // LOAD STAFF
  // ------------------------------------------------------------

  Future<void> _loadStaff() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final staffList = await _getAllStaffUseCase();

      if (!mounted) return;

      setState(() {
        _staff = staffList;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // ------------------------------------------------------------
  // STAFF HELPERS
  // ------------------------------------------------------------

  String _normalizeStatus(String status) {
    return status.toUpperCase() == 'ACTIVE' ? 'Active' : 'Inactive';
  }

  String _displayRole(String role) {
    final normalized = role.toUpperCase();

    if (normalized == 'ADMIN' || normalized == 'ADMINISTRATOR') {
      return 'Administrator';
    }

    if (normalized == 'LIBRARIAN') {
      return 'Librarian';
    }

    return role;
  }

  String _displayStaffId(String id) {
    final number = int.tryParse(id);

    if (number == null) {
      return 'STF-$id';
    }

    return 'STF-${number.toString().padLeft(4, '0')}';
  }

  List<StaffMember> get _filteredStaff {
    final query = _searchController.text.trim().toLowerCase();

    return _staff.where((staff) {
      final matchesSearch = staff.name.toLowerCase().contains(query) ||
          staff.email.toLowerCase().contains(query) ||
          staff.id.toLowerCase().contains(query);

      final role = staff.role.toUpperCase();

      final matchesRole = _selectedRole == 'All Roles' ||
          (_selectedRole == 'Administrator' &&
              (role == 'ADMIN' || role == 'ADMINISTRATOR')) ||
          (_selectedRole == 'Librarian' && role == 'LIBRARIAN');

      return matchesSearch && matchesRole;
    }).toList();
  }

  // ------------------------------------------------------------
  // ACTIVATE / DEACTIVATE STAFF
  // ------------------------------------------------------------

  Future<void> _toggleStatus(StaffMember staff) async {
    final isCurrentlyActive = _normalizeStatus(staff.status) == 'Active';

    final newStatus = isCurrentlyActive ? 'INACTIVE' : 'ACTIVE';

    final action = isCurrentlyActive ? 'deactivate' : 'activate';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            '${isCurrentlyActive ? 'Deactivate' : 'Activate'} Account',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: dark,
            ),
          ),
          content: Text(
            'Are you sure you want to $action the account for ${staff.name}?',
            style: const TextStyle(
              color: muted,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: muted),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: isCurrentlyActive ? Colors.red : primary,
                foregroundColor: Colors.white,
              ),
              child: Text(
                isCurrentlyActive ? 'Deactivate' : 'Activate',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    try {
      await _updateStaffStatusUseCase(
        staff.id,
        newStatus,
      );

      if (!mounted) return;

      await _loadStaff();

      if (!mounted) return;

      _showMessage(
        newStatus == 'ACTIVE'
            ? 'Staff account activated successfully.'
            : 'Staff account deactivated successfully.',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Status update failed: $e',
        isError: true,
      );
    }
  }

  // ------------------------------------------------------------
  // ADD / EDIT STAFF DIALOG
  // ------------------------------------------------------------

  void _openStaffDialog({StaffMember? existing}) {
    final formKey = GlobalKey<FormState>();

    final nameController = TextEditingController(
      text: existing?.name ?? '',
    );

    final emailController = TextEditingController(
      text: existing?.email ?? '',
    );

    final phoneController = TextEditingController(
      text: existing?.phoneNumber ?? '',
    );

    String selectedRole = existing == null
        ? 'LIBRARIAN'
        : (existing.role.toUpperCase() == 'ADMIN' ||
                existing.role.toUpperCase() == 'ADMINISTRATOR')
            ? 'ADMIN'
            : 'LIBRARIAN';

    // Position is optional. Do not automatically select one.
    String? selectedPosition = existing?.position;

    if (!_positions.contains(selectedPosition)) {
      selectedPosition = null;
    }

    final selectedPermissions =
        Set<String>.from(existing?.permissions ?? <String>{});

    String selectedStatus = _normalizeStatus(existing?.status ?? 'ACTIVE');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool isSaving = false;
        bool attemptedSave = false;

        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBE2D9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.person_add_alt_1,
                      color: primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      existing == null
                          ? 'Add Staff Member'
                          : 'Edit Staff Member',
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: dark,
                      ),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 560,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // FULL NAME - REQUIRED
                        _dialogLabel(
                          'Full Name',
                          isRequired: true,
                        ),

                        TextFormField(
                          controller: nameController,
                          enabled: !isSaving,
                          validator: _validateName,
                          decoration: _inputDecoration(
                            'Enter full name',
                            Icons.person_outline,
                          ),
                          textCapitalization: TextCapitalization.words,
                        ),

                        const SizedBox(height: 16),

                        // EMAIL - OPTIONAL INDIVIDUALLY
                        _dialogLabel('Email Address'),

                        TextFormField(
                          controller: emailController,
                          enabled: !isSaving,
                          validator: _validateEmail,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _inputDecoration(
                            'Enter email address',
                            Icons.email_outlined,
                          ).copyWith(
                            helperText: '',
                          ),
                          onChanged: (_) {
                            setDialogState(() {});

                            if (attemptedSave) {
                              formKey.currentState?.validate();
                            }
                          },
                        ),

                        const SizedBox(height: 16),

                        // PHONE - OPTIONAL INDIVIDUALLY
                        _dialogLabel('Phone Number'),

                        TextFormField(
                          controller: phoneController,
                          enabled: !isSaving,
                          validator: _validatePhone,
                          keyboardType: TextInputType.phone,
                          decoration: _inputDecoration(
                            'Enter phone number',
                            Icons.phone_outlined,
                          ),
                          onChanged: (_) {
                            setDialogState(() {});

                            if (attemptedSave) {
                              formKey.currentState?.validate();
                            }
                          },
                        ),

                        const SizedBox(height: 16),

                        // SYSTEM ROLE - REQUIRED
                        _dialogLabel(
                          'System Role',
                          isRequired: true,
                        ),

                        DropdownButtonFormField<String>(
                          initialValue: selectedRole,
                          isExpanded: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'System Role is required.';
                            }
                            return null;
                          },
                          decoration: _inputDecoration(
                            'Select system role',
                            Icons.security_outlined,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'ADMIN',
                              child: Text('Administrator'),
                            ),
                            DropdownMenuItem(
                              value: 'LIBRARIAN',
                              child: Text('Librarian'),
                            ),
                          ],
                          onChanged: isSaving
                              ? null
                              : (value) {
                                  if (value == null) return;

                                  setDialogState(() {
                                    selectedRole = value;
                                    selectedPosition = null;

                                    if (value == 'ADMIN') {
                                      selectedPermissions.clear();
                                    }
                                  });
                                },
                        ),

                        // LIBRARIAN-ONLY FIELDS
                        if (selectedRole == 'LIBRARIAN') ...[
                          const SizedBox(height: 16),
                          _dialogLabel('Librarian Position'),
                          DropdownButtonFormField<String>(
                            initialValue: selectedPosition,
                            isExpanded: true,
                            decoration: _inputDecoration(
                              'Select librarian position (Optional)',
                              Icons.work_outline,
                            ),
                            items: _positions.map((position) {
                              return DropdownMenuItem<String>(
                                value: position,
                                child: Text(
                                  position,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: isSaving
                                ? null
                                : (value) {
                                    setDialogState(() {
                                      selectedPosition = value;
                                    });
                                  },
                          ),
                          const SizedBox(height: 22),
                          const Divider(),
                          const SizedBox(height: 10),
                          const Text(
                            'Access Permissions',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: dark,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Customize what this librarian is allowed to access.',
                            style: TextStyle(
                              fontSize: 12,
                              color: muted,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFBE2D9),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFF6B7A5),
                              ),
                            ),
                            child: Column(
                              children: _permissionLabels.entries.map((entry) {
                                return CheckboxListTile(
                                  contentPadding: EdgeInsets.zero,
                                  dense: true,
                                  activeColor: primary,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  title: Text(
                                    entry.value,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: dark,
                                    ),
                                  ),
                                  value:
                                      selectedPermissions.contains(entry.key),
                                  onChanged: isSaving
                                      ? null
                                      : (checked) {
                                          setDialogState(() {
                                            if (checked == true) {
                                              selectedPermissions
                                                  .add(entry.key);
                                            } else {
                                              selectedPermissions
                                                  .remove(entry.key);
                                            }
                                          });
                                        },
                                );
                              }).toList(),
                            ),
                          ),
                        ],

                        const SizedBox(height: 18),

                        // ACCOUNT STATUS - REQUIRED
                        _dialogLabel(
                          'Account Status',
                          isRequired: true,
                        ),

                        DropdownButtonFormField<String>(
                          initialValue: selectedStatus,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Account Status is required.';
                            }
                            return null;
                          },
                          decoration: _inputDecoration(
                            'Select account status',
                            Icons.toggle_on_outlined,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Active',
                              child: Text('Active'),
                            ),
                            DropdownMenuItem(
                              value: 'Inactive',
                              child: Text('Inactive'),
                            ),
                          ],
                          onChanged: isSaving
                              ? null
                              : (value) {
                                  if (value != null) {
                                    setDialogState(() {
                                      selectedStatus = value;
                                    });
                                  }
                                },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
              actions: [
                TextButton(
                  onPressed:
                      isSaving ? null : () => Navigator.pop(dialogContext),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: muted),
                  ),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          attemptedSave = true;

                          setDialogState(() {});

                          // Validate all visible form fields.
                          if (!formKey.currentState!.validate()) {
                            return;
                          }

                          // At least one contact method is required.
                          final contactError = _validateContact(
                            email: emailController.text,
                            phone: phoneController.text,
                          );

                          if (contactError != null) {
                            _showMessage(
                              contactError,
                              isError: true,
                            );
                            return;
                          }

                          final newStaff = StaffMember(
                            id: existing?.id ?? '',
                            name: nameController.text.trim(),
                            email: emailController.text.trim(),
                            phoneNumber: phoneController.text.trim(),
                            role: selectedRole,
                            position: selectedRole == 'LIBRARIAN'
                                ? selectedPosition
                                : null,
                            status: selectedStatus,
                            permissions: selectedRole == 'LIBRARIAN'
                                ? selectedPermissions
                                : <String>{},
                          );

                          setDialogState(() {
                            isSaving = true;
                          });

                          try {
                            if (existing == null) {
                              await _addStaffUseCase(newStaff);
                            } else {
                              await _updateStaffUseCase(
                                existing.id,
                                newStaff,
                              );
                            }

                            if (!dialogContext.mounted) return;

                            Navigator.pop(dialogContext);

                            await _loadStaff();

                            if (!mounted) return;

                            _showMessage(
                              existing == null
                                  ? 'Staff member added successfully!'
                                  : 'Staff member updated successfully!',
                            );
                          } catch (e) {
                            if (!dialogContext.mounted) return;

                            setDialogState(() {
                              isSaving = false;
                            });

                            _showMessage(
                              'Unable to save staff member: $e',
                              isError: true,
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          existing == null ? 'Add Staff' : 'Save Changes',
                        ),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      nameController.dispose();
      emailController.dispose();
      phoneController.dispose();
    });
  }

  // ------------------------------------------------------------
  // FIELD LABEL
  // ------------------------------------------------------------

  Widget _dialogLabel(
    String label, {
    bool isRequired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: dark,
            ),
          ),
          if (isRequired)
            const Text(
              ' *',
              style: TextStyle(
                color: Colors.red,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            )
          else
            const Text(
              ' (Optional)',
              style: TextStyle(
                color: muted,
                fontSize: 11,
              ),
            ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // COMMON INPUT DECORATION
  // ------------------------------------------------------------

  InputDecoration _inputDecoration(
    String hint,
    IconData icon,
  ) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(
        icon,
        size: 19,
        color: muted,
      ),
      filled: true,
      fillColor: backgroundColor,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 13,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: borderColor,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: borderColor,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: primary,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Colors.red,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.5,
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // SNACKBAR
  // ------------------------------------------------------------

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              isError ? Colors.red.shade700 : const Color(0xFF059669),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
  }

  // ------------------------------------------------------------
  // MAIN SCREEN
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: primary,
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    final filteredStaff = _filteredStaff;

    final total = _staff.length;

    final active =
        _staff.where((s) => _normalizeStatus(s.status) == 'Active').length;

    final librarians =
        _staff.where((s) => s.role.toUpperCase() == 'LIBRARIAN').length;

    final admins = _staff.where((s) {
      final role = s.role.toUpperCase();
      return role == 'ADMIN' || role == 'ADMINISTRATOR';
    }).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildStatistics(
            total: total,
            active: active,
            librarians: librarians,
            admins: admins,
          ),
          const SizedBox(height: 24),
          _buildStaffDirectory(filteredStaff),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // ERROR STATE
  // ------------------------------------------------------------

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
              'Unable to load staff members.',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: dark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(color: muted),
            ),
            const SizedBox(height: 18),
            _HoverActionButton(
              label: 'Try Again',
              icon: Icons.refresh,
              onPressed: _loadStaff,
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // HEADER
  // ------------------------------------------------------------

  Widget _buildHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 600;

        const title = Row(
          children: [
            Icon(
              Icons.people_alt_outlined,
              color: primary,
              size: 30,
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Staff Management',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: dark,
                    ),
                  ),
                  Text(
                    'Manage staff members and access permissions',
                    style: TextStyle(
                      fontSize: 12,
                      color: muted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

        final addButton = _HoverActionButton(
          label: 'Add Staff Member',
          icon: Icons.add,
          onPressed: () => _openStaffDialog(),
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title,
              const SizedBox(height: 16),
              addButton,
            ],
          );
        }

        return Row(
          children: [
            const Expanded(child: title),
            const SizedBox(width: 12),
            addButton,
          ],
        );
      },
    );
  }

  // ------------------------------------------------------------
  // STATISTICS
  // ------------------------------------------------------------

  Widget _buildStatistics({
    required int total,
    required int active,
    required int librarians,
    required int admins,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 750;

        final cards = [
          _buildStatCard(
            'Total Staff',
            total.toString(),
            Icons.badge_outlined,
            primary,
          ),
          _buildStatCard(
            'Active Accounts',
            active.toString(),
            Icons.check_circle_outline,
            const Color(0xFF059669),
          ),
          _buildStatCard(
            'Librarians',
            librarians.toString(),
            Icons.assignment_ind_outlined,
            const Color(0xFFF25635),
          ),
          _buildStatCard(
            'Admins',
            admins.toString(),
            Icons.security,
            const Color(0xFFD97706),
          ),
        ];

        if (compact) {
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: cards.map((card) {
              return SizedBox(
                width: (constraints.maxWidth - 12) / 2,
                child: card,
              );
            }).toList(),
          );
        }

        return Row(
          children: cards.map((card) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: card,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return _HoverStatCard(
      label: label,
      value: value,
      icon: icon,
      color: color,
    );
  }

  // ------------------------------------------------------------
  // STAFF DIRECTORY
  // ------------------------------------------------------------

  Widget _buildStaffDirectory(
    List<StaffMember> filteredStaff,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Staff Directory',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: dark,
                  ),
                ),
              ),
              Text(
                '${filteredStaff.length} staff',
                style: const TextStyle(
                  fontSize: 12,
                  color: muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSearchAndFilter(),
          const SizedBox(height: 18),
          _buildStaffTable(filteredStaff),
          if (filteredStaff.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 36,
                      color: muted,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'No staff members found.',
                      style: TextStyle(
                        color: muted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // SEARCH AND ROLE FILTER
  // ------------------------------------------------------------

  Widget _buildSearchAndFilter() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 550;

        final searchField = TextField(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Search by name, email or staff ID...',
            prefixIcon: const Icon(
              Icons.search,
              color: primary,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    tooltip: 'Clear search',
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  )
                : null,
            filled: true,
            fillColor: backgroundColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: primary,
                width: 1.5,
              ),
            ),
          ),
        );

        final roleFilter = Container(
          width: stacked ? double.infinity : 205,
          decoration: BoxDecoration(
            color: const Color(0xFFFBE2D9),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: const Color(0xFFF6B7A5),
              width: 1.3,
            ),
          ),
          child: DropdownButtonFormField<String>(
            initialValue: _selectedRole,
            isExpanded: true,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: primary,
            ),
            dropdownColor: Colors.white,
            decoration: const InputDecoration(
              prefixIcon: Icon(
                Icons.filter_list_rounded,
                color: primary,
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 12,
              ),
            ),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: primary,
            ),
            items: const [
              DropdownMenuItem(
                value: 'All Roles',
                child: Text('All Roles'),
              ),
              DropdownMenuItem(
                value: 'Administrator',
                child: Text('Administrator'),
              ),
              DropdownMenuItem(
                value: 'Librarian',
                child: Text('Librarian'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _selectedRole = value ?? 'All Roles';
              });
            },
          ),
        );

        if (stacked) {
          return Column(
            children: [
              searchField,
              const SizedBox(height: 12),
              roleFilter,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: searchField),
            const SizedBox(width: 18),
            roleFilter,
          ],
        );
      },
    );
  }

  // ------------------------------------------------------------
  // STAFF TABLE
  // ------------------------------------------------------------

  Widget _buildStaffTable(List<StaffMember> filteredStaff) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(
          const Color(0xFFFBF1E4),
        ),
        headingTextStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: muted,
        ),
        dataTextStyle: const TextStyle(
          fontSize: 12,
          color: dark,
        ),
        horizontalMargin: 16,
        columnSpacing: 24,
        columns: const [
          DataColumn(label: Text('STAFF ID')),
          DataColumn(label: Text('NAME')),
          DataColumn(label: Text('ROLE / POSITION')),
          DataColumn(label: Text('STATUS')),
          DataColumn(label: Text('ACTIONS')),
        ],
        rows: filteredStaff.map((staff) {
          final isActive = _normalizeStatus(staff.status) == 'Active';

          return DataRow(
            cells: [
              DataCell(
                Text(
                  _displayStaffId(staff.id),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: primary,
                    fontSize: 12,
                  ),
                ),
              ),
              DataCell(
                SizedBox(
                  width: 190,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 17,
                        backgroundColor: const Color(0xFFFBE2D9),
                        child: Text(
                          staff.name.isEmpty
                              ? '?'
                              : staff.name[0].toUpperCase(),
                          style: const TextStyle(
                            color: primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              staff.name,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: dark,
                              ),
                            ),
                            Text(
                              staff.email,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10,
                                color: muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              DataCell(
                SizedBox(
                  width: 180,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _displayRole(staff.role),
                        style: const TextStyle(
                          fontSize: 12,
                          color: dark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (staff.position != null && staff.position!.isNotEmpty)
                        Text(
                          staff.position!,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            color: muted,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFFECFDF5)
                        : const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _normalizeStatus(staff.status),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isActive
                          ? const Color(0xFF059669)
                          : const Color(0xFFDC2626),
                    ),
                  ),
                ),
              ),
              DataCell(
                Row(
                  children: [
                    _HoverIconButton(
                      tooltip: 'Edit staff',
                      icon: Icons.edit_outlined,
                      color: primary,
                      onPressed: () => _openStaffDialog(existing: staff),
                    ),
                    _HoverIconButton(
                      tooltip:
                          isActive ? 'Deactivate account' : 'Activate account',
                      icon: isActive
                          ? Icons.person_off_outlined
                          : Icons.person_outline,
                      color: isActive ? Colors.red : Colors.green,
                      onPressed: () => _toggleStatus(staff),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ============================================================
// HOVER ACTION BUTTON
// ============================================================

class _HoverActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _HoverActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  State<_HoverActionButton> createState() => _HoverActionButtonState();
}

class _HoverActionButtonState extends State<_HoverActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(
          0,
          _isHovered ? -3 : 0,
          0,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: const Color(0xFFF25635).withValues(alpha: 0.22),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ]
              : [],
        ),
        child: ElevatedButton.icon(
          onPressed: widget.onPressed,
          icon: Icon(widget.icon, size: 18),
          label: Text(widget.label),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF25635),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: 17,
              vertical: 15,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// HOVER ICON BUTTON
// ============================================================

class _HoverIconButton extends StatefulWidget {
  final String tooltip;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _HoverIconButton({
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  State<_HoverIconButton> createState() => _HoverIconButtonState();
}

class _HoverIconButtonState extends State<_HoverIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: _isHovered
                ? widget.color.withValues(alpha: 0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            onPressed: widget.onPressed,
            icon: Icon(
              widget.icon,
              size: 19,
              color: widget.color,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// HOVER STATISTICS CARD
// ============================================================

class _HoverStatCard extends StatefulWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _HoverStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  State<_HoverStatCard> createState() => _HoverStatCardState();
}

class _HoverStatCardState extends State<_HoverStatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(
          0,
          _isHovered ? -4 : 0,
          0,
        ),
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered
                ? widget.color.withValues(alpha: 0.4)
                : const Color(0xFFD9D9D9),
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.10),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                widget.icon,
                color: widget.color,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF171717),
                    ),
                  ),
                  Text(
                    widget.label,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
