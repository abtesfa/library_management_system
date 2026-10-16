
import 'package:flutter/material.dart';

const Color primaryBlue = Color(0xFF0865F0);
const Color darkBlue = Color(0xFF07377D);
const Color textBlue = Color(0xFF0645A5);
const Color borderBlue = Color(0xFFD9E9FF);
const Color pageBackground = Color(0xFFF3F9FF);

class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  State<StaffManagementScreen> createState() =>
      _StaffManagementScreenState();
}

class StaffMember {
  StaffMember({
    required this.name,
    required this.employeeId,
    required this.role,
    required this.email,
    this.active = true,
  });

  String name;
  String employeeId;
  String role;
  String email;
  bool active;
}

class _StaffManagementScreenState
    extends State<StaffManagementScreen> {
  final TextEditingController searchController =
      TextEditingController();

  final List<StaffMember> staff = [
    StaffMember(
      name: 'Samuel Worku',
      employeeId: 'EMP-7701',
      role: 'Administrator',
      email: 'samuel.w@library.univ.et',
    ),
    StaffMember(
      name: 'Meron Alemu',
      employeeId: 'EMP-7708',
      role: 'Librarian',
      email: 'merona@library.univ.et',
    ),
    StaffMember(
      name: 'Yohannes Girma',
      employeeId: 'EMP-7715',
      role: 'Librarian',
      email: 'yohannes.g@library.univ.et',
    ),
    StaffMember(
      name: 'Hana Girma',
      employeeId: 'EMP-7718',
      role: 'Librarian',
      email: 'hana@library.univ.et',
    ),
    StaffMember(
      name: 'Tesfaye Abebe',
      employeeId: 'EMP-7720',
      role: 'Librarian',
      email: 'tesfaye.a@library.univ.et',
    ),
    StaffMember(
      name: 'Selam Tesfaye',
      employeeId: 'EMP-7721',
      role: 'Assistant Librarian',
      email: 'selam.t@library.univ.et',
    ),
  ];

  String selectedPermissionRole = 'Administrator';
  String roleFilter = 'All';
  int selectedPage = 1;

  final Map<String, bool> permissions = {
    'Manage all staff accounts': true,
    'Access LMS settings': true,
    'Manage book inventory': true,
    'View all records and reports': true,
    'System configuration': true,
  };

  final List<Map<String, String>> activities = [
    {
      'date': 'Jun 8, 2025   10:24 AM',
      'name': 'Samuel Worku',
      'action': 'Created',
      'details': 'New librarian account (EMP-7701)',
    },
    {
      'date': 'Jun 7, 2025   03:12 PM',
      'name': 'Meron Alemu',
      'action': 'Updated',
      'details': 'Role changed to Librarian',
    },
    {
      'date': 'Jun 6, 2025   11:45 AM',
      'name': 'Hana Girma',
      'action': 'Logged In',
      'details': 'System access',
    },
    {
      'date': 'Jun 5, 2025   09:32 AM',
      'name': 'Tesfaye Abebe',
      'action': 'Updated',
      'details': 'Permissions modified',
    },
  ];

  List<StaffMember> get filteredStaff {
    final query = searchController.text.toLowerCase();

    return staff.where((member) {
      final matchesSearch =
          member.name.toLowerCase().contains(query) ||
          member.employeeId.toLowerCase().contains(query) ||
          member.email.toLowerCase().contains(query);

      final matchesRole =
          roleFilter == 'All' || member.role == roleFilter;

      return matchesSearch && matchesRole;
    }).toList();
  }

  int get activeCount => staff.where((s) => s.active).length;

  int get administratorCount =>
      staff.where((s) => s.role == 'Administrator').length;

  int get librarianCount =>
      staff.where((s) => s.role == 'Librarian').length;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Row(
              children: [
                _buildSidebar(),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 1150;

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(17),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            _buildPageTitle(),
                            const SizedBox(height: 16),
                            if (wide)
                              Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 7,
                                    child: Column(
                                      children: [
                                        _buildStatistics(),
                                        const SizedBox(height: 14),
                                        _buildStaffTable(),
                                        const SizedBox(height: 14),
                                        _buildRecentActivity(),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      children: [
                                        _buildRolePermissions(),
                                        const SizedBox(height: 14),
                                        _buildQuickActions(),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            else
                              Column(
                                children: [
                                  _buildStatistics(),
                                  const SizedBox(height: 14),
                                  _buildRolePermissions(),
                                  const SizedBox(height: 14),
                                  _buildStaffTable(),
                                  const SizedBox(height: 14),
                                  _buildQuickActions(),
                                  const SizedBox(height: 14),
                                  _buildRecentActivity(),
                                ],
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 61,
      padding: const EdgeInsets.symmetric(horizontal: 19),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF07377D), Color(0xFF0865D9)],
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: primaryBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              size: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Library Management System',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ),
          const Icon(
            Icons.notifications_none_rounded,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(width: 24),
          const CircleAvatar(
            backgroundColor: Colors.white,
            radius: 18,
            child: Icon(
              Icons.person,
              color: primaryBlue,
              size: 26,
            ),
          ),
          const SizedBox(width: 10),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Admin',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'System Administrator',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 218,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF07377D), Color(0xFF06418F)],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 17),
          _navItem(Icons.home_rounded, 'Dashboard'),
          _navItem(Icons.settings_rounded, 'LMS Settings'),
          _navItem(
            Icons.people_alt_rounded,
            'Staff Management',
            selected: true,
          ),
          _navItem(Icons.menu_book_rounded, 'Book Inventory'),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 28),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.layers_rounded,
                    size: 36,
                    color: Colors.white,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Read More,\nLearn More,\nGrow More.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
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

  Widget _navItem(
    IconData icon,
    String title, {
    bool selected = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: selected ? primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Icon(icon, color: Colors.white, size: 26),
            const SizedBox(width: 14),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageTitle() {
    return Row(
      children: [
        const Icon(
          Icons.people_alt_rounded,
          color: primaryBlue,
          size: 37,
        ),
        const SizedBox(width: 17),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Staff Management',
                style: TextStyle(
                  color: textBlue,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Manage staff accounts, roles, permissions, and access to the system.',
                style: TextStyle(
                  color: Color(0xFF5082C8),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _showStaffDialog(),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add New Staff Member'),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatistics() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 650;

        final cards = [
          _statCard(
            'Total Staff',
            '${staff.length}',
            'Active accounts',
            Icons.people_alt_rounded,
            const Color(0xFFE2F0FF),
          ),
          _statCard(
            'Administrators',
            '$administratorCount',
            'Full access',
            Icons.shield_rounded,
            const Color(0xFFEAE4FF),
          ),
          _statCard(
            'Librarians',
            '$librarianCount',
            'Library operations',
            Icons.person_rounded,
            const Color(0xFFE5F2FF),
          ),
          _statCard(
            'Active Accounts',
            '$activeCount',
            'All active',
            Icons.check_circle_rounded,
            const Color(0xFFDCF9EB),
          ),
        ];

        if (compact) {
          return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: cards.map((card) {
              return SizedBox(
                width: (constraints.maxWidth - 10) / 2,
                child: card,
              );
            }).toList(),
          );
        }

        return Row(
          children: [
            for (int i = 0; i < cards.length; i++) ...[
              Expanded(child: cards[i]),
              if (i != cards.length - 1)
                const SizedBox(width: 12),
            ],
          ],
        );
      },
    );
  }

  Widget _statCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color iconBackground,
  ) {
    return Container(
      height: 101,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderBlue),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 51,
            height: 51,
            decoration: BoxDecoration(
              color: iconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: primaryBlue, size: 29),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: textBlue,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: textBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 23,
                  ),
                ),
                Text(
                  subtitle,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF5082C8),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffTable() {
    final members = filteredStaff;

    return _panel(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.person_pin_rounded,
                color: primaryBlue,
                size: 27,
              ),
              const SizedBox(width: 10),
              const Text(
                'Staff Members',
                style: TextStyle(
                  color: textBlue,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: 250,
                height: 38,
                child: TextField(
                  controller: searchController,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(
                    color: textBlue,
                    fontSize: 12,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search by name, ID or email...',
                    hintStyle: const TextStyle(
                      color: Color(0xFF7297C9),
                      fontSize: 11,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: primaryBlue,
                      size: 20,
                    ),
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: borderBlue,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: borderBlue,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _showFilters,
                icon: const Icon(
                  Icons.filter_list_rounded,
                  size: 18,
                ),
                label: const Text('Filters'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryBlue,
                  side: const BorderSide(color: borderBlue),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: const WidgetStatePropertyAll(
                Color(0xFFEDF6FF),
              ),
              dataRowMinHeight: 49,
              dataRowMaxHeight: 54,
              headingRowHeight: 39,
              horizontalMargin: 10,
              columnSpacing: 22,
              border: TableBorder.all(
                color: const Color(0xFFE3EEFC),
                borderRadius: BorderRadius.circular(7),
              ),
              columns: const [
                DataColumn(label: _TableHeading('Name')),
                DataColumn(label: _TableHeading('Employee ID')),
                DataColumn(label: _TableHeading('Role')),
                DataColumn(label: _TableHeading('Email')),
                DataColumn(label: _TableHeading('Status')),
                DataColumn(label: _TableHeading('Actions')),
              ],
              rows: members.map((member) {
                return DataRow(
                  cells: [
                    DataCell(
                      SizedBox(
                        width: 145,
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 15,
                              backgroundColor: Color(0xFFDDEEFF),
                              child: Icon(
                                Icons.person,
                                color: darkBlue,
                                size: 21,
                              ),
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Text(
                                member.name,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: textBlue,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        member.employeeId,
                        style: const TextStyle(
                          color: textBlue,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    DataCell(_roleBadge(member.role)),
                    DataCell(
                      Text(
                        member.email,
                        style: const TextStyle(
                          color: textBlue,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    DataCell(_statusBadge(member.active)),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _smallAction(
                            Icons.edit_rounded,
                            'Edit staff member',
                            () => _showStaffDialog(member: member),
                          ),
                          const SizedBox(width: 5),
                          _smallAction(
                            member.active
                                ? Icons.person_rounded
                                : Icons.person_off_rounded,
                            member.active
                                ? 'Deactivate account'
                                : 'Activate account',
                            () => _toggleStaff(member),
                          ),
                          PopupMenuButton<String>(
                            padding: EdgeInsets.zero,
                            iconSize: 20,
                            icon: const Icon(
                              Icons.more_vert,
                              color: primaryBlue,
                            ),
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showStaffDialog(member: member);
                              } else if (value == 'delete') {
                                _confirmDelete(member);
                              } else if (value == 'status') {
                                _toggleStaff(member);
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'edit',
                                child: Text('Edit'),
                              ),
                              PopupMenuItem(
                                value: 'status',
                                child: Text('Toggle status'),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              Text(
                'Showing ${members.length} of ${staff.length}',
                style: const TextStyle(
                  color: Color(0xFF5082C8),
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(34, 34),
                  padding: EdgeInsets.zero,
                  side: const BorderSide(color: borderBlue),
                ),
                child: const Icon(
                  Icons.chevron_left,
                  color: primaryBlue,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                height: 34,
                width: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: primaryBlue,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Text(
                  '1',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(34, 34),
                  padding: EdgeInsets.zero,
                  side: const BorderSide(color: borderBlue),
                ),
                child: const Icon(
                  Icons.chevron_right,
                  color: primaryBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _roleBadge(String role) {
    Color background;
    Color foreground;

    switch (role) {
      case 'Administrator':
        background = const Color(0xFFEDE4FF);
        foreground = const Color(0xFF743BFA);
        break;
      case 'Assistant Librarian':
        background = const Color(0xFFDDFBF5);
        foreground = const Color(0xFF008F83);
        break;
      case 'Technician':
        background = const Color(0xFFFFEBD8);
        foreground = const Color(0xFFB96008);
        break;
      default:
        background = const Color(0xFFE3F1FF);
        foreground = primaryBlue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: foreground.withValues(alpha: 0.15)),
      ),
      child: Text(
        role,
        style: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _statusBadge(bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFFDCF9EB)
            : const Color(0xFFFFE6E6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: active
              ? const Color(0xFFB7F0D4)
              : const Color(0xFFFFCACA),
        ),
      ),
      child: Text(
        active ? 'Active' : 'Inactive',
        style: TextStyle(
          color: active
              ? const Color(0xFF008A52)
              : Colors.red,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _smallAction(
    IconData icon,
    String tooltip,
    VoidCallback onTap,
  ) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 29,
          width: 29,
          decoration: BoxDecoration(
            color: const Color(0xFFE7F3FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 17, color: primaryBlue),
        ),
      ),
    );
  }

  Widget _buildRolePermissions() {
    final roleOptions = [
      'Administrator',
      'Librarian',
      'Assistant Librarian',
      'Technician',
    ];

    return _panel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.shield_rounded,
                color: primaryBlue,
                size: 24,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Role Permissions',
                  style: TextStyle(
                    color: textBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: selectedPermissionRole,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'Select role',
              labelStyle: const TextStyle(
                color: textBlue,
                fontSize: 12,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: borderBlue),
              ),
            ),
            items: roleOptions.map((role) {
              return DropdownMenuItem(
                value: role,
                child: Text(
                  role,
                  style: const TextStyle(fontSize: 11),
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => selectedPermissionRole = value);
              }
            },
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              const Icon(
                Icons.add,
                color: primaryBlue,
                size: 17,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  '$selectedPermissionRole Permissions',
                  style: const TextStyle(
                    color: textBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...permissions.entries.map((entry) {
            return SizedBox(
              height: 27,
              child: CheckboxListTile(
                value: entry.value,
                onChanged: (value) {
                  setState(() {
                    permissions[entry.key] = value ?? false;
                  });
                },
                contentPadding: EdgeInsets.zero,
                dense: true,
                visualDensity: VisualDensity.compact,
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: primaryBlue,
                title: Text(
                  entry.key,
                  style: const TextStyle(
                    color: textBlue,
                    fontSize: 11,
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Permission selections updated locally.',
                    ),
                  ),
                );
              },
              child: const Text('Apply Permissions'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return _panel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.bolt_rounded,
                color: primaryBlue,
                size: 25,
              ),
              SizedBox(width: 10),
              Text(
                'Quick Actions',
                style: TextStyle(
                  color: textBlue,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _quickAction(
                  Icons.add_circle_outline,
                  'Add Staff Member',
                  'Create a new account',
                  () => _showStaffDialog(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _quickAction(
                  Icons.person_outline,
                  'Manage Roles',
                  'Assign or change roles',
                  _showRoleDialog,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _quickAction(
                  Icons.lock_outline_rounded,
                  'Permissions',
                  'Set access rights',
                  _showPermissionDialog,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _quickAction(
                  Icons.cancel_outlined,
                  'Deactivate Account',
                  'Disable staff access',
                  _showDeactivateDialog,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickAction(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        height: 98,
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: borderBlue),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: primaryBlue, size: 26),
            const SizedBox(height: 7),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: primaryBlue,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF5082C8),
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return _panel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                color: primaryBlue,
                size: 24,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Recent Staff Activity',
                  style: TextStyle(
                    color: textBlue,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  _showMessage(
                    'Showing all recorded staff activity.',
                  );
                },
                child: const Text(
                  'View All  →',
                  style: TextStyle(fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 34,
              dataRowMinHeight: 34,
              dataRowMaxHeight: 39,
              horizontalMargin: 10,
              columnSpacing: 24,
              headingRowColor: const WidgetStatePropertyAll(
                Color(0xFFEDF6FF),
              ),
              border: TableBorder.all(
                color: const Color(0xFFE3EEFC),
                borderRadius: BorderRadius.circular(7),
              ),
              columns: const [
                DataColumn(label: _TableHeading('Date & Time')),
                DataColumn(label: _TableHeading('Staff Name')),
                DataColumn(label: _TableHeading('Action')),
                DataColumn(label: _TableHeading('Details')),
              ],
              rows: activities.map((activity) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        activity['date']!,
                        style: const TextStyle(
                          color: textBlue,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        activity['name']!,
                        style: const TextStyle(
                          color: textBlue,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    DataCell(
                      _activityBadge(activity['action']!),
                    ),
                    DataCell(
                      Text(
                        activity['details']!,
                        style: const TextStyle(
                          color: textBlue,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _activityBadge(String action) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE1F2FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        action,
        style: const TextStyle(
          color: primaryBlue,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _panel({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderBlue),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  void _showStaffDialog({StaffMember? member}) {
    final nameController = TextEditingController(
      text: member?.name ?? '',
    );
    final idController = TextEditingController(
      text: member?.employeeId ?? '',
    );
    final emailController = TextEditingController(
      text: member?.email ?? '',
    );
    String role = member?.role ?? 'Librarian';

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text(
                member == null
                    ? 'Add New Staff Member'
                    : 'Edit Staff Member',
                style: const TextStyle(color: textBlue),
              ),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _dialogField('Full Name', nameController),
                      const SizedBox(height: 12),
                      _dialogField('Employee ID', idController),
                      const SizedBox(height: 12),
                      _dialogField('Email', emailController),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: role,
                        decoration: const InputDecoration(
                          labelText: 'Role',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Administrator',
                            child: Text('Administrator'),
                          ),
                          DropdownMenuItem(
                            value: 'Librarian',
                            child: Text('Librarian'),
                          ),
                          DropdownMenuItem(
                            value: 'Assistant Librarian',
                            child: Text('Assistant Librarian'),
                          ),
                          DropdownMenuItem(
                            value: 'Technician',
                            child: Text('Technician'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() => role = value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    final id = idController.text.trim();
                    final email = emailController.text.trim();

                    if (name.isEmpty ||
                        id.isEmpty ||
                        email.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please complete all fields.',
                          ),
                        ),
                      );
                      return;
                    }

                    final duplicateId = staff.any(
                      (s) =>
                          s.employeeId.toLowerCase() ==
                              id.toLowerCase() &&
                          s != member,
                    );

                    final duplicateEmail = staff.any(
                      (s) =>
                          s.email.toLowerCase() ==
                              email.toLowerCase() &&
                          s != member,
                    );

                    if (duplicateId || duplicateEmail) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Employee ID or email already exists.',
                          ),
                        ),
                      );
                      return;
                    }

                    setState(() {
                      if (member == null) {
                        staff.add(
                          StaffMember(
                            name: name,
                            employeeId: id,
                            role: role,
                            email: email,
                          ),
                        );
                        activities.insert(0, {
                          'date': 'Just now',
                          'name': name,
                          'action': 'Created',
                          'details': 'New staff account ($id)',
                        });
                      } else {
                        member.name = name;
                        member.employeeId = id;
                        member.role = role;
                        member.email = email;
                        activities.insert(0, {
                          'date': 'Just now',
                          'name': name,
                          'action': 'Updated',
                          'details': 'Staff details updated',
                        });
                      }
                    });

                    Navigator.pop(dialogContext);
                    _showMessage(
                      member == null
                          ? 'Staff member added.'
                          : 'Staff member updated.',
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _dialogField(
    String label,
    TextEditingController controller,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  void _showFilters() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Filter Staff'),
        content: DropdownButtonFormField<String>(
          value: roleFilter,
          decoration: const InputDecoration(
            labelText: 'Role',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'All', child: Text('All roles')),
            DropdownMenuItem(
              value: 'Administrator',
              child: Text('Administrator'),
            ),
            DropdownMenuItem(
              value: 'Librarian',
              child: Text('Librarian'),
            ),
            DropdownMenuItem(
              value: 'Assistant Librarian',
              child: Text('Assistant Librarian'),
            ),
            DropdownMenuItem(
              value: 'Technician',
              child: Text('Technician'),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() => roleFilter = value);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _toggleStaff(StaffMember member) {
    setState(() {
      member.active = !member.active;
      activities.insert(0, {
        'date': 'Just now',
        'name': member.name,
        'action': 'Updated',
        'details': member.active
            ? 'Account activated'
            : 'Account deactivated',
      });
    });

    _showMessage(
      member.active
          ? '${member.name} account activated.'
          : '${member.name} account deactivated.',
    );
  }

  void _confirmDelete(StaffMember member) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Staff Member'),
        content: Text(
          'Are you sure you want to delete ${member.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              setState(() {
                staff.remove(member);
                activities.insert(0, {
                  'date': 'Just now',
                  'name': member.name,
                  'action': 'Deleted',
                  'details': 'Staff account removed',
                });
              });
              Navigator.pop(dialogContext);
              _showMessage('Staff member deleted.');
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showRoleDialog() {
    String selectedRole = 'Librarian';

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            title: const Text('Manage Staff Roles'),
            content: DropdownButtonFormField<String>(
              value: selectedRole,
              decoration: const InputDecoration(
                labelText: 'Available role',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Administrator',
                  child: Text('Administrator'),
                ),
                DropdownMenuItem(
                  value: 'Librarian',
                  child: Text('Librarian'),
                ),
                DropdownMenuItem(
                  value: 'Assistant Librarian',
                  child: Text('Assistant Librarian'),
                ),
                DropdownMenuItem(
                  value: 'Technician',
                  child: Text('Technician'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setDialogState(() => selectedRole = value);
                }
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Close'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedPermissionRole = selectedRole;
                  });
                  Navigator.pop(dialogContext);
                },
                child: const Text('Select Role'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showPermissionDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Manage Permissions'),
        content: const Text(
          'Choose a role in the Role Permissions panel, then update its permissions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDeactivateDialog() {
    final activeStaff = staff.where((s) => s.active).toList();
    StaffMember? selected = activeStaff.isNotEmpty
        ? activeStaff.first
        : null;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            title: const Text('Deactivate Staff Account'),
            content: SizedBox(
              width: 380,
              child: DropdownButtonFormField<StaffMember>(
                value: selected,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Select staff member',
                  border: OutlineInputBorder(),
                ),
                items: activeStaff.map((member) {
                  return DropdownMenuItem(
                    value: member,
                    child: Text(
                      '${member.name} (${member.employeeId})',
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setDialogState(() => selected = value);
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: selected == null
                    ? null
                    : () {
                        final member = selected!;
                        Navigator.pop(dialogContext);
                        _toggleStaff(member);
                      },
                child: const Text('Deactivate'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _TableHeading extends StatelessWidget {
  final String text;

  const _TableHeading(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: textBlue,
        fontSize: 11,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
