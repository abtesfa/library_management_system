
import 'package:flutter/material.dart';

import 'admin/admin_dashboard_screen.dart';
import 'librarian/borrow_return_desk_screen.dart';
import 'reader/reader_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userIdController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedRole = 'Student';
  bool _obscurePassword = true;
  bool _isLoading = false;

  static const Color primaryBlue = Color(0xFF0755C9);
  static const Color darkBlue = Color(0xFF073B86);

  // Temporary credentials for testing only.
  // Replace these with your real authentication service later.
  final Map<String, Map<String, String>> _testAccounts = {
    'Admin': {
      'userId': 'admin',
      'password': 'admin123',
    },
    'Librarian': {
      'userId': 'librarian',
      'password': 'lib123',
    },
    'Student': {
      'userId': 'student',
      'password': 'student123',
    },
  };

  void _login() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final account = _testAccounts[_selectedRole]!;

    final validCredentials =
        _userIdController.text.trim() == account['userId'] &&
        _passwordController.text == account['password'];

    setState(() => _isLoading = false);

    if (!validCredentials) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid User ID, password, or selected role.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Widget destination;

    switch (_selectedRole) {
      case 'Admin':
        destination = const AdminDashboardScreen();
        break;
      case 'Librarian':
        destination = const BorrowReturnDeskScreen();
        break;
      case 'Student':
        destination = const ReaderHomeScreen();
        break;
      default:
        return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FD),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Card(
                elevation: 4,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const CircleAvatar(
                          radius: 34,
                          backgroundColor: Color(0xFFE5EEFF),
                          child: Icon(
                            Icons.local_library,
                            color: primaryBlue,
                            size: 38,
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Library Management System',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: darkBlue,
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Sign in to continue to your dashboard',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.blueGrey),
                        ),
                        const SizedBox(height: 28),

                        const Text(
                          'Account Role',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedRole,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.badge_outlined,
                              color: primaryBlue,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Admin',
                              child: Text('Admin'),
                            ),
                            DropdownMenuItem(
                              value: 'Librarian',
                              child: Text('Librarian'),
                            ),
                            DropdownMenuItem(
                              value: 'Student',
                              child: Text('Student / Reader'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedRole = value);
                            }
                          },
                        ),
                        const SizedBox(height: 18),

                        const Text(
                          'User ID',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _userIdController,
                          decoration: InputDecoration(
                            hintText: 'Enter your User ID',
                            prefixIcon: const Icon(
                              Icons.person_outline,
                              color: primaryBlue,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your User ID';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        const Text(
                          'Password',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: 'Enter your password',
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: primaryBlue,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
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
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) => _login(),
                        ),
                        const SizedBox(height: 24),

                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryBlue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Sign In',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        const Text(
                          'Temporary test accounts',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: darkBlue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Admin: admin / admin123\n'
                          'Librarian: librarian / lib123\n'
                          'Student: student / student123',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            height: 1.7,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
