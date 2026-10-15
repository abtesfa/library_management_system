
import 'package:flutter/material.dart';

const Color primaryBlue = Color(0xFF0052CC);
const Color navyBlue = Color(0xFF063778);
const Color pageBackground = Color(0xFFF4F9FF);
const Color borderBlue = Color(0xFFD9EAFE);

class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  State<StaffManagementScreen> createState() =>
      _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _staff = [
    {
      'name': 'Samuel Worku',
      'id': 'EMP-7701',
      'role': 'Administrator',
      'email': 'samuel.w@library.univ.et',
      'status': 'Active',
    },
    {
      'name': 'Meron Alemu',
      'id': 'EMP-7708',
      'role': 'Librarian',
      'email': 'merona@library.univ.et',
      'status': 'Active',
    },
    {
      'name': 'Yohannes Girma',
      'id': 'EMP-7715',
      'role': 'Librarian',
      'email': 'yohannes.g@library.univ.et',
      'status': 'Active',
    },
    {
      'name': 'Hana Girma',
      'id': 'EMP-7718',
      'role': 'Librarian',
      'email': 'hana@library.univ.et',
      'status': 'Active',
    },
    {
      'name': 'Tesfaye Abebe',
      'id': 'EMP-7720',
      'role': 'Librarian',
      'email': 'tesfaye.a@library.univ.et',
      'status': 'Active',
    },
    {
      'name': 'Selam Tesfaye',
      'id': 'EMP-7721',
      'role': 'Assistant Librarian',
      'email': 'selam.t@library.univ.et',
      'status': 'Active',
    },
  ];

  final Map<String, List<String>> _rolePermissions = {
    'Administrator': [
      'Manage all staff accounts',
      'Access LMS settings',
      'Manage book inventory',
      'View all records and reports',
      'System configuration',
    ],
    'Librarian': [
      'Manage book inventory',
      'Borrow and return books',
      'Manage reservations',
      'View circulation records',
      'Send reader notifications',
    ],
    'Assistant Librarian': [
      'Search book inventory',
      'Register book returns',
      'View assigned circulation records',
    ],
  };

  final Map<String, Set<String>> _selectedPermissions = {};

  String _selectedRole = 'Administrator';
  String _filterRole = 'All Roles';

  final List<Map<String, String>> _activity = [
    {
      'date': 'Jun 8, 2025   10:24 AM',
      'name': 'Samuel Worku',
      'action': 'Created',
      'details': 'New staff account (EMP-7701)',
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredStaff {
    final query = _searchController.text.toLowerCase().trim();

    return _staff.where((member) {
      final matchesSearch = member['name']
              .toString()
              .toLowerCase()
              .contains(query) ||
          member['id'].toString().toLowerCase().contains(query) ||
          member['email'].toString().toLowerCase().contains(query);

      final matchesRole =
          _filterRole == 'All Roles' || member['role'] == _filterRole;

      return matchesSearch && matchesRole;
    }).toList();
  }

  int get _activeCount =>
      _staff.where((s) => s['status'] == 'Active').length;

  int get _administratorCount =>
      _staff.where((s) => s['role'] == 'Administrator').length;

  int get _librarianCount =>
      _staff.where((s) => s['role'] == 'Librarian').length;

  Color _roleColor(String role) {
    switch (role) {
      case 'Administrator':
        return const Color(0xFF7C3AED);
      case 'Assistant Librarian':
        return const Color(0xFF009688);
      default:
        return primaryBlue;
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth >= 1050;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (isDesktop) _buildSidebar(),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(
                            constraints.maxWidth < 600 ? 12 : 18,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildPageHeading(isDesktop),
                              const SizedBox(height: 18),
                              _buildStatistics(),
                              const SizedBox(height: 14),
                              if (isDesktop)
                                _buildDesktopContent()
                              else
                                _buildMobileContent(),
                            ],
                          ),
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
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF073477), Color(0xFF0872EB)],
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.menu_book_rounded,
              color: Colors.white, size: 34),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Library Management System',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => _showMessage('No new notifications.'),
            icon: const Icon(Icons.notifications_none,
                color: Colors.white, size: 27),
          ),
          const CircleAvatar(
            radius: 17,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: primaryBlue),
          ),
          const SizedBox(width: 10),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Admin',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              Text('System Administrator',
                  style: TextStyle(color: Colors.white70, fontSize: 10)),
            ],
          ),
          const SizedBox(width: 10),
          PopupMenuButton<String>(
            iconColor: Colors.white,
            onSelected: (value) => _showMessage('$value selected.'),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'Profile', child: Text('Profile')),
              PopupMenuItem(value: 'Settings', child: Text('Settings')),
              PopupMenuItem(value: 'Logout', child: Text('Logout')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 218,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF063778), Color(0xFF00316E)],
        ),
      ),
      child: Column(
        children: [
          _navItem(Icons.home_rounded, 'Dashboard'),
          _navItem(Icons.settings, 'LMS Settings'),
          _navItem(Icons.people_alt_rounded, 'Staff Management',
              selected: true),
          _navItem(Icons.menu_book_rounded, 'Book Inventory'),
          const Spacer(),
          const Icon(Icons.layers_rounded,
              color: Colors.white, size: 38),
          const SizedBox(height: 8),
          const Text(
            'Read More,\nLearn More,\nGrow More.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, height: 1.5),
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label,
      {bool selected = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected ? primaryBlue : Colors.transparent,
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          borderRadius: BorderRadius.circular(9),
          onTap: () {
            if (!selected) {
              _showMessage('$label screen will be connected next.');
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 13),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 25),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
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

  Widget _buildPageHeading(bool isDesktop) {
    return Row(
      children: [
        const Icon(Icons.people_alt_rounded,
            size: 36, color: primaryBlue),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Staff Management',
                style: TextStyle(
                  color: Color(0xFF0849A8),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Manage staff accounts, roles, permissions, and access to the system.',
                style: TextStyle(color: primaryBlue, fontSize: 12),
              ),
            ],
          ),
        ),
        if (isDesktop)
          FilledButton.icon(
            onPressed: _showAddStaffDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add New Staff Member'),
          ),
      ],
    );
  }

  Widget _buildStatistics() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 900 ? 4 : width >= 550 ? 2 : 1;
        final cardWidth = (width - (columns - 1) * 12) / columns;

        final stats = [
          (
            'Total Staff',
            '${_staff.length}',
            'Active accounts',
            Icons.people_alt_rounded,
            primaryBlue
          ),
          (
            'Administrators',
            '$_administratorCount',
            'Full access',
            Icons.shield_rounded,
            const Color(0xFF7755EE)
          ),
          (
            'Librarians',
            '$_librarianCount',
            'Library operations',
            Icons.person,
            primaryBlue
          ),
          (
            'Active Accounts',
            '$_activeCount',
            'All active',
            Icons.check_circle_rounded,
            const Color(0xFF12A76A)
          ),
        ];

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: stats.map((stat) {
            return SizedBox(
              width: cardWidth,
              child: _statCard(
                stat.$1,
                stat.$2,
                stat.$3,
                stat.$4,
                stat.$5,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _statCard(String title, String value, String subtitle,
      IconData icon, Color color) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: color.withValues(alpha: 0.10),
            child: Icon(icon, color: color, size: 27),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: primaryBlue,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Text(value,
                    style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF064DAF))),
                Text(subtitle,
                    style: const TextStyle(
                        color: primaryBlue, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 7,
          child: Column(
            children: [
              _buildStaffDirectory(),
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
              _buildPermissions(),
              const SizedBox(height: 14),
              _buildQuickActions(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileContent() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _showAddStaffDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add New Staff Member'),
          ),
        ),
        const SizedBox(height: 14),
        _buildStaffDirectory(),
        const SizedBox(height: 14),
        _buildPermissions(),
        const SizedBox(height: 14),
        _buildQuickActions(),
        const SizedBox(height: 14),
        _buildRecentActivity(),
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: borderBlue),
      boxShadow: [
        BoxShadow(
          color: primaryBlue.withValues(alpha: 0.025),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Widget _buildStaffDirectory() {
    final staff = _filteredStaff;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.person_pin, color: primaryBlue, size: 27),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Staff Members',
                  style: TextStyle(
                      color: Color(0xFF064DAF),
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Filter staff',
                icon: const Icon(Icons.filter_list, color: primaryBlue),
                onSelected: (value) => setState(() => _filterRole = value),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'All Roles', child: Text('All Roles')),
                  PopupMenuItem(
                      value: 'Administrator', child: Text('Administrator')),
                  PopupMenuItem(value: 'Librarian', child: Text('Librarian')),
                  PopupMenuItem(
                      value: 'Assistant Librarian',
                      child: Text('Assistant Librarian')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search by name, ID or email...',
              hintStyle: const TextStyle(fontSize: 12),
              prefixIcon: const Icon(Icons.search, color: primaryBlue),
              suffixIcon: IconButton(
                tooltip: 'Clear search',
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
              ),
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: borderBlue),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: borderBlue),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (staff.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('No staff members match your search.'),
            )
          else
            ...staff.map(_staffRow),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Showing ${staff.length} of ${_staff.length}',
              style: const TextStyle(color: primaryBlue, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _staffRow(Map<String, dynamic> member) {
    final role = member['role'] as String;
    final roleColor = _roleColor(role);
    final isActive = member['status'] == 'Active';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: borderBlue)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: const Color(0xFFE1EEFF),
            child: Text(
              member['name'].toString()[0],
              style: const TextStyle(
                  color: primaryBlue, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member['name'],
                  style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF064DAF),
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 3),
                Text(
                  '${member['id']} · $role',
                  style: TextStyle(fontSize: 10, color: roleColor),
                ),
                Text(
                  member['email'],
                  style: const TextStyle(fontSize: 10, color: primaryBlue),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFFE2F9EF)
                  : const Color(0xFFFFE8E8),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              member['status'],
              style: TextStyle(
                color: isActive
                    ? const Color(0xFF008752)
                    : Colors.red,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          PopupMenuButton<String>(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.more_vert, color: primaryBlue),
            onSelected: (action) {
              if (action == 'edit') {
                _showEditStaffDialog(member);
              } else if (action == 'status') {
                setState(() {
                  member['status'] =
                      member['status'] == 'Active' ? 'Inactive' : 'Active';
                });
              } else if (action == 'delete') {
                _confirmDeleteStaff(member);
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                  value: 'edit', child: Text('Edit staff')),
              PopupMenuItem(
                value: 'status',
                child: Text(isActive ? 'Deactivate account' : 'Activate account'),
              ),
              const PopupMenuItem(
                  value: 'delete', child: Text('Delete staff')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPermissions() {
    final permissions = _rolePermissions[_selectedRole] ?? [];
    final selected = _selectedPermissions.putIfAbsent(
      _selectedRole,
      () => Set<String>.from(permissions),
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.shield, color: primaryBlue),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Role Permissions',
                  style: TextStyle(
                      color: Color(0xFF064DAF),
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: _selectedRole,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Select role',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
            items: _rolePermissions.keys.map((role) {
              return DropdownMenuItem(value: role, child: Text(role));
            }).toList(),
            onChanged: (value) {
              if (value != null) setState(() => _selectedRole = value);
            },
          ),
          const SizedBox(height: 12),
         Text(
  '$_selectedRole Permissions',
  style: const TextStyle(
    color: Color(0xFF064DAF),
    fontWeight: FontWeight.bold,
    fontSize: 12,
  ),
         ),
          const SizedBox(height: 6),
          ...permissions.map((permission) {
            return CheckboxListTile(
              value: selected.contains(permission),
              onChanged: (checked) {
                setState(() {
                  if (checked == true) {
                    selected.add(permission);
                  } else {
                    selected.remove(permission);
                  }
                });
              },
              title: Text(permission,
                  style: const TextStyle(fontSize: 11)),
              activeColor: primaryBlue,
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              dense: true,
              visualDensity: VisualDensity.compact,
            );
          }),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _showMessage(
                'Permissions for $_selectedRole are saved locally for this session.',
              ),
              child: const Text('Save Permissions'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bolt, color: primaryBlue, size: 25),
              SizedBox(width: 8),
              Text(
                'Quick Actions',
                style: TextStyle(
                    color: Color(0xFF064DAF),
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.35,
            children: [
              _actionTile(Icons.person_add_alt_1, 'Add Staff Member',
                  'Create a new account', _showAddStaffDialog),
              _actionTile(Icons.manage_accounts, 'Manage Roles',
                  'Assign or change roles', () {
                _showMessage('Select a role in the Role Permissions panel.');
              }),
              _actionTile(Icons.lock_outline, 'Permissions',
                  'Set access rights', () {
                _showMessage('Choose a role and edit its permissions.');
              }),
              _actionTile(Icons.person_off, 'Account Status',
                  'Activate or deactivate', () {
                _showMessage('Use the menu beside a staff member.');
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Material(
      color: const Color(0xFFF7FBFF),
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: borderBlue),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: primaryBlue, size: 27),
              const SizedBox(height: 6),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: primaryBlue,
                    fontSize: 11,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: primaryBlue, fontSize: 9),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.access_time, color: primaryBlue),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Recent Staff Activity',
                  style: TextStyle(
                      color: Color(0xFF064DAF),
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._activity.map((item) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: borderBlue)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['date']!,
                      style: const TextStyle(
                          fontSize: 10, color: primaryBlue)),
                  const SizedBox(height: 4),
                  Text(item['name']!,
                      style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF064DAF),
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _activityBadge(item['action']!),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item['details']!,
                          style: const TextStyle(
                              fontSize: 10, color: primaryBlue),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _activityBadge(String action) {
    final color = action == 'Created'
        ? const Color(0xFF008752)
        : primaryBlue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        action,
        style: TextStyle(
            color: color, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }

  void _showAddStaffDialog() {
    _showStaffFormDialog();
  }

  void _showEditStaffDialog(Map<String, dynamic> member) {
    _showStaffFormDialog(member: member);
  }

  void _showStaffFormDialog({Map<String, dynamic>? member}) {
    final isEditing = member != null;
    final nameController =
        TextEditingController(text: member?['name'] ?? '');
    final idController = TextEditingController(text: member?['id'] ?? '');
    final emailController =
        TextEditingController(text: member?['email'] ?? '');
    String role = member?['role'] ?? 'Librarian';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? 'Edit Staff Member' : 'Add Staff Member'),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration:
                            const InputDecoration(labelText: 'Full name'),
                      ),
                      TextField(
                        controller: idController,
                        decoration:
                            const InputDecoration(labelText: 'Employee ID'),
                      ),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration:
                            const InputDecoration(labelText: 'Email address'),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: role,
                        decoration:
                            const InputDecoration(labelText: 'Staff role'),
                        items: _rolePermissions.keys.map((item) {
                          return DropdownMenuItem(
                            value: item,
                            child: Text(item),
                          );
                        }).toList(),
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
                FilledButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    final id = idController.text.trim();
                    final email = emailController.text.trim();

                    if (name.isEmpty ||
                        id.isEmpty ||
                        !email.contains('@')) {
                      _showMessage(
                          'Enter a name, employee ID, and valid email.');
                      return;
                    }

                    setState(() {
                      if (isEditing) {
                        member['name'] = name;
                        member['id'] = id;
                        member['email'] = email;
                        member['role'] = role;
                      } else {
                        final exists = _staff.any(
                          (s) => s['id'].toString().toLowerCase() ==
                              id.toLowerCase(),
                        );

                        if (exists) {
                          _showMessage('That employee ID already exists.');
                          return;
                        }

                        _staff.add({
                          'name': name,
                          'id': id,
                          'role': role,
                          'email': email,
                          'status': 'Active',
                        });

                        _activity.insert(0, {
                          'date': 'Just now',
                          'name': name,
                          'action': 'Created',
                          'details': 'New staff account ($id)',
                        });
                      }
                    });

                    if (!mounted) return;
                    Navigator.pop(dialogContext);
                    _showMessage(isEditing
                        ? 'Staff member updated.'
                        : 'Staff member added.');
                  },
                  child: Text(isEditing ? 'Save Changes' : 'Add Staff'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      nameController.dispose();
      idController.dispose();
      emailController.dispose();
    });
  }

  void _confirmDeleteStaff(Map<String, dynamic> member) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Staff Member?'),
        content: Text(
          'Are you sure you want to remove ${member['name']} from this sample directory?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                _staff.remove(member);
              });
              Navigator.pop(dialogContext);
              _showMessage('Staff member removed from sample data.');
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
