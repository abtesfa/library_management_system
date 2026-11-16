import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injector.dart';
import '../../domain/entities/user.dart';

class SignInDialog extends StatefulWidget {
  final ValueChanged<UserAccount> onSignIn;
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
  late TextEditingController _identifierController;
  late TextEditingController _passwordController;

  bool _obscurePassword = true;
  bool _isSigningIn = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _selectedRole = widget.initialRole;

    _identifierController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onRoleChanged(UserRole role) {
    setState(() {
      _selectedRole = role;
      _errorMessage = null;
    });
  }

  Future<void> _submit() async {
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text;

    if (identifier.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Enter your username/email and password.');
      return;
    }

    setState(() {
      _isSigningIn = true;
      _errorMessage = null;
    });

    try {
      final account = await injector.login(
        identifier: identifier,
        password: password,
        role: _selectedRole,
      );

      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onSignIn(account);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSigningIn = false;
        _errorMessage = error is TimeoutException
            ? 'Sign-in timed out. The server took too long to respond. Please try again.'
            : error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final roleLabel = switch (_selectedRole) {
      UserRole.admin => 'Administrator',
      UserRole.librarian => 'Librarian',
      UserRole.reader => 'Reader / Student',
    };

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: Colors.white,
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 18,
                ),
                color: AppColors.primary,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.menu_book,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sign In to Library System',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Sign in to your library dashboard',
                            style: TextStyle(
                              color: Color(0xFFF6B7A5),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white70,
                      ),
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
                    // Role selection
                    const Text(
                      '1. SELECT DASHBOARD ROLE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF555555),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        _buildRoleTab(
                          role: UserRole.admin,
                          label: 'Admin',
                          subtitle: 'System Admin',
                          icon: Icons.security,
                          activeColor: const Color(0xFFF25635),
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
                          activeColor: const Color(0xFFF25635),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Credentials
                    const Text(
                      '2. SIGN-IN CREDENTIALS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF555555),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),

                    TextField(
                      controller: _identifierController,
                      enabled: !_isSigningIn,
                      decoration: InputDecoration(
                        labelText: _selectedRole == UserRole.reader
                            ? 'Student ID or Email'
                            : 'Work Email',
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          size: 20,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        isDense: true,
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      enabled: !_isSigningIn,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          size: 20,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        isDense: true,
                      ),
                    ),

                    const SizedBox(height: 20),

                    if (_errorMessage != null) ...[
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Main sign-in button
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: _isSigningIn ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 1,
                        ),
                        child: Text(
                          _isSigningIn
                              ? 'Signing in...'
                              : 'Sign In to $roleLabel Dashboard',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
    final bool isSelected = _selectedRole == role;

    return Expanded(
      child: InkWell(
        onTap: () => _onRoleChanged(role),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 8,
          ),
          decoration: BoxDecoration(
            color:
                isSelected ? activeColor.withValues(alpha: 0.08) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? activeColor : const Color(0xFFD9D9D9),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 22,
                color: isSelected ? activeColor : const Color(0xFF666666),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? activeColor : const Color(0xFF333333),
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 9,
                  color: Color(0xFFAAA898),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
