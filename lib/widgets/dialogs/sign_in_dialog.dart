import 'package:flutter/material.dart';
import '/../models/user.dart';

class SignInDialog extends StatefulWidget {
  final Function(UserRole role) onSignIn;
  final UserRole initialRole;

  const SignInDialog({
    super.key,
    required this.onSignIn,
    this.initialRole = UserRole.admin,
  });

  @override
  State<SignInDialog> createState() => _SignInDialogState();
}

class _SignInDialogState extends State<SignInDialog> {
  late UserRole _selectedRole;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole;
    final defaultAcc = HardcodedCredentials.getForRole(_selectedRole);
    _emailController = TextEditingController(text: defaultAcc.email);
    _passwordController = TextEditingController(text: defaultAcc.password);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onRoleChanged(UserRole role) {
    setState(() {
      _selectedRole = role;
      final acc = HardcodedCredentials.getForRole(role);
      _emailController.text = acc.email;
      _passwordController.text = acc.password;
    });
  }

  void _submit() {
    final email = _emailController.text.trim().toLowerCase();
    UserRole targetRole = _selectedRole;

    if (email.contains('admin')) {
      targetRole = UserRole.admin;
    } else if (email.contains('lib') || email.contains('sara')) {
      targetRole = UserRole.librarian;
    } else if (email.contains('reader') || email.contains('student')) {
      targetRole = UserRole.reader;
    }

    Navigator.of(context).pop();
    widget.onSignIn(targetRole);
  }

  @override
  Widget build(BuildContext context) {
    final activeAcc = HardcodedCredentials.getForRole(_selectedRole);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              color: const Color(0xFF0052CC),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.menu_book, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sign In to Library System',
                          style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Default credentials preloaded for all 3 dashboards',
                          style: TextStyle(color: Color(0xFFBFDBFE), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Role Selection Tabs
                  const Text(
                    '1. SELECT DASHBOARD ROLE',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569), letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildRoleTab(
                        role: UserRole.admin,
                        label: 'Admin',
                        subtitle: 'System Admin',
                        icon: Icons.security,
                        activeColor: const Color(0xFF0052CC),
                      ),
                      const SizedBox(width: 8),
                      _buildRoleTab(
                        role: UserRole.librarian,
                        label: 'Librarian',
                        subtitle: 'Desk Officer',
                        icon: Icons.assignment_turned_in,
                        activeColor: const Color(0xFF059669),
                      ),
                      const SizedBox(width: 8),
                      _buildRoleTab(
                        role: UserRole.reader,
                        label: 'Reader',
                        subtitle: 'Student User',
                        icon: Icons.person,
                        activeColor: const Color(0xFF7C3AED),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Destination Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.dashboard_customize, size: 20, color: Color(0xFF0052CC)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Destination: ${activeAcc.dashboardTitle}',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Name: ${activeAcc.name} (${activeAcc.title})',
                                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 2. Pre-filled Credentials Inputs
                  const Text(
                    '2. HARDCODED CREDENTIALS (DEFAULT)',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569), letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Username or Email',
                      prefixIcon: const Icon(Icons.email_outlined, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1877F2),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 1,
                      ),
                      child: Text(
                        'Sign In to ${activeAcc.roleDisplayName} Dashboard',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 3. Instant 1-Click Launch Buttons
                  const Divider(color: Color(0xFFE2E8F0)),
                  const SizedBox(height: 8),
                  const Text(
                    'DIRECT 1-CLICK LAUNCH:',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildQuickLaunch(UserRole.admin, 'Admin', const Color(0xFF0052CC)),
                      const SizedBox(width: 8),
                      _buildQuickLaunch(UserRole.librarian, 'Librarian', const Color(0xFF059669)),
                      const SizedBox(width: 8),
                      _buildQuickLaunch(UserRole.reader, 'Reader', const Color(0xFF7C3AED)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleTab({
    required UserRole role,
    required String label,
    required String subtitle,
    required IconData icon,
    required Color activeColor,
  }) {
    final isSelected = _selectedRole == role;

    return Expanded(
      child: InkWell(
        onTap: () => _onRoleChanged(role),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? activeColor.withValues(alpha: 0.08) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? activeColor : const Color(0xFFCBD5E1),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 22, color: isSelected ? activeColor : const Color(0xFF64748B)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? activeColor : const Color(0xFF334155),
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickLaunch(UserRole role, String label, Color color) {
    return Expanded(
      child: OutlinedButton(
        onPressed: () {
          Navigator.of(context).pop();
          widget.onSignIn(role);
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withValues(alpha: 0.4)),
          padding: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
