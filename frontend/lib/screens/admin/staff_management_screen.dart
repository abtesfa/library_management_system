
import 'package:flutter/material.dart';

import '../../models/staff.dart';
import '../../services/staff_api_service.dart';

class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  State<StaffManagementScreen> createState() =>
      _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
  static const Color primary = Color(0xFF0052CC);
  static const Color dark = Color(0xFF0F172A);
  static const Color muted = Color(0xFF64748B);

  final StaffApiService _staffApiService = StaffApiService();

  List<StaffMember> _staff = [];

  bool _isLoading = true;
  String? _errorMessage;

  final TextEditingController _searchController =
      TextEditingController();

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

  // Load staff members from Spring Boot.
  Future<void> _loadStaff() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final staffList = await _staffApiService.getAllStaff();

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

  // Convert backend status into UI status.
  String _normalizeStatus(String status) {
    return status.toUpperCase() == 'ACTIVE'
        ? 'Active'
        : 'Inactive';
  }

  // Search by name and filter by system role.
  List<StaffMember> get _filteredStaff {
    final query = _searchController.text.trim().toLowerCase();

    return _staff.where((staff) {
      final matchesName =
          staff.name.toLowerCase().contains(query);

      final role = staff.role.toUpperCase();

      final matchesRole = _selectedRole == 'All Roles' ||
          (_selectedRole == 'Administrator' &&
              (role == 'ADMIN' || role == 'ADMINISTRATOR')) ||
          (_selectedRole == 'Librarian' && role == 'LIBRARIAN');

      return matchesName && matchesRole;
    }).toList();
  }

  String _displayRole(String role) {
    final normalized = role.toUpperCase();

    if (normalized == 'ADMIN' ||
        normalized == 'ADMINISTRATOR') {
      return 'Administrator';
    }

    if (normalized == 'LIBRARIAN') {
      return 'Librarian';
    }

    return role;
  }

  // Format staff ID.
  String _displayStaffId(String id) {
    final number = int.tryParse(id);

    if (number == null) {
      return 'STF-$id';
    }

    return 'STF-${number.toString().padLeft(4, '0')}';
  }

  // Activate or deactivate a staff account in the database.
  Future<void> _toggleStatus(StaffMember staff) async {
    final currentStatus = _normalizeStatus(staff.status);

    final newStatus =
        currentStatus == 'Active' ? 'INACTIVE' : 'ACTIVE';

    try {
      await _staffApiService.updateStaffStatus(
        staff.id,
        newStatus,
      );

      if (!mounted) return;

      await _loadStaff();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newStatus == 'ACTIVE'
                ? 'Staff account activated successfully.'
                : 'Staff account deactivated successfully.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status update failed: $e'),
        ),
      );
    }
  }

  // Add and edit staff form.
  void _openStaffDialog({StaffMember? existing}) {
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
        : existing.role.toUpperCase() == 'ADMIN' ||
                existing.role.toUpperCase() == 'ADMINISTRATOR'
            ? 'ADMIN'
            : 'LIBRARIAN';

    String? selectedPosition = existing?.position;

    if (selectedRole == 'LIBRARIAN' &&
        !_positions.contains(selectedPosition)) {
      selectedPosition = _positions.first;
    }

    final selectedPermissions =
        Set<String>.from(existing?.permissions ?? {});

    String selectedStatus =
        _normalizeStatus(existing?.status ?? 'ACTIVE');

    showDialog(
      context: context,
      builder: (dialogContext) {
        bool isSaving = false;

        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: Text(
                existing == null
                    ? 'Add Staff Member'
                    : 'Edit Staff Member',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: dark,
                ),
              ),
              content: SizedBox(
                width: 560,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Full Name
                      _dialogLabel('Full Name'),
                      TextField(
                        controller: nameController,
                        decoration: _inputDecoration(
                          'Enter full name',
                          Icons.person_outline,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Email
                      _dialogLabel('Email Address'),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _inputDecoration(
                          'Enter email address',
                          Icons.email_outlined,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Phone
                      _dialogLabel('Phone Number'),
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: _inputDecoration(
                          'Enter phone number',
                          Icons.phone_outlined,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // System Role
                      _dialogLabel('System Role'),
                      DropdownButtonFormField<String>(
                        initialValue: selectedRole,
                        isExpanded: true,
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
                        onChanged: (value) {
                          if (value == null) return;

                          setDialogState(() {
                            selectedRole = value;

                            selectedPosition =
                                value == 'LIBRARIAN'
                                    ? _positions.first
                                    : null;
                          });
                        },
                      ),

                      // LIBRARIAN-ONLY SECTION
                      if (selectedRole == 'LIBRARIAN') ...[
                        const SizedBox(height: 16),

                        _dialogLabel('Librarian Position'),

                        DropdownButtonFormField<String>(
                          initialValue: selectedPosition,
                          isExpanded: true,
                          decoration: _inputDecoration(
                            'Select librarian position',
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
                          onChanged: (value) {
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
                            color: const Color(0xFFF0F6FF),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFBFDBFE),
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
                                value: selectedPermissions
                                    .contains(entry.key),
                                onChanged: (checked) {
                                  setDialogState(() {
                                    if (checked == true) {
                                      selectedPermissions.add(entry.key);
                                    } else {
                                      selectedPermissions.remove(entry.key);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ],

                      // Account Status for both roles.
                      const SizedBox(height: 18),

                      _dialogLabel('Account Status'),

                      DropdownButtonFormField<String>(
                        initialValue: selectedStatus,
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
                        onChanged: (value) {
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

              actionsPadding:
                  const EdgeInsets.fromLTRB(20, 0, 20, 18),

              actions: [
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: muted),
                  ),
                ),

                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          final name = nameController.text.trim();
                          final email = emailController.text.trim();
                          final phone = phoneController.text.trim();

                          if (name.isEmpty || email.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please enter the staff name and email.',
                                ),
                              ),
                            );
                            return;
                          }

                          if (!RegExp(
                            r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                          ).hasMatch(email)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please enter a valid email address.',
                                ),
                              ),
                            );
                            return;
                          }

                          if (selectedRole == 'LIBRARIAN' &&
                              selectedPosition == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please select a librarian position.',
                                ),
                              ),
                            );
                            return;
                          }

                          final newStaff = StaffMember(
                            id: existing?.id ?? '',
                            name: name,
                            email: email,
                            phoneNumber: phone,
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
                              await _staffApiService.addStaff(newStaff);
                            } else {
                              await _staffApiService.updateStaff(
                                existing.id,
                                newStaff,
                              );
                            }

                            if (!dialogContext.mounted) return;

                            Navigator.pop(dialogContext);

                            await _loadStaff();

                            if (!mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  existing == null
                                      ? 'Staff member added successfully!'
                                      : 'Staff member updated successfully!',
                                ),
                              ),
                            );
                          } catch (e) {
                            if (!dialogContext.mounted) return;

                            setDialogState(() {
                              isSaving = false;
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Unable to save staff member: $e',
                                ),
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
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
                          existing == null
                              ? 'Add Staff'
                              : 'Save Changes',
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

  // Input decoration.
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
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 13,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xFFE2E8F0),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xFFE2E8F0),
        ),
      ),
    );
  }

  Widget _dialogLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: dark,
        ),
      ),
    );
  }

  // Main screen.
  @override
  Widget build(BuildContext context) {
    // Loading state.
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: primary,
        ),
      );
    }

    // Error state.
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off,
                size: 45,
                color: Colors.red,
              ),
              const SizedBox(height: 12),
              const Text(
                'Unable to load staff members.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadStaff,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    final filteredStaff = _filteredStaff;

    final total = _staff.length;

    final active = _staff
        .where((s) => _normalizeStatus(s.status) == 'Active')
        .length;

    final librarians = _staff.where(
      (s) => s.role.toUpperCase() == 'LIBRARIAN',
    ).length;

    final admins = _staff.where(
      (s) =>
          s.role.toUpperCase() == 'ADMIN' ||
          s.role.toUpperCase() == 'ADMINISTRATOR',
    ).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Row(
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
                ),
              ),

              const SizedBox(width: 12),

              ElevatedButton.icon(
                onPressed: () => _openStaffDialog(),
                icon: const Icon(Icons.add, size: 17),
                label: const Text('Add Staff Member'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Statistics.
          LayoutBuilder(
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
                  const Color(0xFF7C3AED),
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
          ),

          const SizedBox(height: 24),

          // Staff Directory.
          Container(
            padding: const EdgeInsets.all(20),
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
                  'Staff Directory',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: dark,
                  ),
                ),

                const SizedBox(height: 16),

                // Search and role filter.
                LayoutBuilder(
                  builder: (context, constraints) {
                    final stacked = constraints.maxWidth < 550;

                    final searchField = TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Search staff by name...',
                        prefixIcon: const Icon(
                          Icons.search,
                          color: primary,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding:
                            const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                      ),
                    );

                    final roleFilter = Container(
                      width: stacked ? double.infinity : 205,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(
                          color: const Color(0xFFBFDBFE),
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
                ),

                const SizedBox(height: 18),

                // Staff table.
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor:
                        WidgetStateProperty.all(
                      const Color(0xFFF8FAFC),
                    ),
                    columns: const [
                      DataColumn(label: Text('STAFF ID')),
                      DataColumn(label: Text('NAME')),
                      DataColumn(label: Text('ROLE / POSITION')),
                      DataColumn(label: Text('STATUS')),
                      DataColumn(label: Text('ACTIONS')),
                    ],
                    rows: filteredStaff.map((staff) {
                      final isActive =
                          _normalizeStatus(staff.status) == 'Active';

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
                                    backgroundColor:
                                        const Color(0xFFEFF6FF),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _displayRole(staff.role),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: dark,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (staff.position != null)
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
                                IconButton(
                                  tooltip: 'Edit staff',
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 18,
                                    color: primary,
                                  ),
                                  onPressed: () =>
                                      _openStaffDialog(existing: staff),
                                ),
                                IconButton(
                                  tooltip: isActive
                                      ? 'Deactivate account'
                                      : 'Activate account',
                                  icon: Icon(
                                    isActive
                                        ? Icons.person_off_outlined
                                        : Icons.person_outline,
                                    size: 18,
                                    color: isActive
                                        ? Colors.red
                                        : Colors.green,
                                  ),
                                  onPressed: () => _toggleStatus(staff),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),

                if (filteredStaff.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'No staff members found.',
                        style: TextStyle(color: muted),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Statistics card.
  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: dark,
                  ),
                ),
                Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
