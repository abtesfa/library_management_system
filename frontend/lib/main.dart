import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_colors.dart';
import 'core/di/injector.dart';
import 'features/auth/domain/entities/user.dart';
import 'features/books/presentation/screens/admin_inventory_screen.dart';
import 'features/settings/presentation/screens/admin_settings_screen.dart';
import 'features/staff/presentation/screens/staff_management_screen.dart';
import 'features/landing/presentation/screens/landing_screen.dart';
import 'features/borrowing/presentation/screens/librarian_desk_screen.dart';
import 'features/notifications/presentation/screens/librarian_notifications_screen.dart';
import 'features/dashboard/presentation/screens/student_home_screen.dart';
import 'features/borrowing/presentation/screens/student_my_books_screen.dart';
import 'features/reservations/presentation/screens/student_reservations_screen.dart';
import 'features/library/presentation/providers/library_service.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/header/top_header_bar.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => LibraryService(),
      child: const LibraryManagementApp(),
    ),
  );
}

class LibraryManagementApp extends StatelessWidget {
  const LibraryManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: context.watch<LibraryService>().settings.libraryName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainShell(),
    );
  }
}

/// Switches between the landing page and the three role portals.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  /// Nav index each portal opens on.
  static const int _adminStartIndex = 3; // Book Inventory
  static const int _defaultStartIndex = 0; // Desk / Student Home

  bool _isLandingMode = true;
  UserRole _currentRole = UserRole.admin;
  UserAccount? _currentAccount;
  int _selectedNavIndex = _adminStartIndex;

  void _enterPortal(UserAccount account) {
    final role = account.role;
    final permissions = account.permissions;

    int initialIndex = _defaultStartIndex;
    if (role == UserRole.admin) {
      initialIndex = _adminStartIndex;
    } else if (role == UserRole.librarian) {
      if (permissions.contains('ADD_BOOK') ||
          permissions.contains('EDIT_BOOK') ||
          permissions.contains('DELETE_BOOK')) {
        initialIndex = 2;
      } else if (permissions.contains('MANAGE_STAFF')) {
        initialIndex = 3;
      } else if (permissions.contains('CONFIGURE_SETTINGS')) {
        initialIndex = 4;
      } else {
        initialIndex = 0;
      }
    }

    setState(() {
      _isLandingMode = false;
      _currentAccount = account;
      _currentRole = role;
      _selectedNavIndex = initialIndex;
    });
  }

  void _returnToLanding() {
    setState(() {
      _isLandingMode = true;
      _currentAccount = null;
    });
  }

  

Future<void> _changePassword() async {
  if (_currentAccount == null) return;

  final controllerCurrent = TextEditingController();
  final controllerNew = TextEditingController();
  final controllerConfirm = TextEditingController();

  bool obscureCurrent = true;
  bool obscureNew = true;
  bool obscureConfirm = true;

  try {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Widget passwordField({
              required String label,
              required TextEditingController controller,
              required bool obscure,
              required VoidCallback onToggle,
            }) {
              return TextField(
                controller: controller,
                obscureText: obscure,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF333333),
                ),
                decoration: InputDecoration(
                  labelText: label,
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF777777),
                  ),
                  suffixIcon: IconButton(
                    onPressed: onToggle,
                    icon: Icon(
                      obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: const Color(0xFF777777),
                      size: 21,
                    ),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFFAFAFA),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 17,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9),
                    borderSide: const BorderSide(
                      color: Color(0xFFDDDDDD),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9),
                    borderSide: const BorderSide(
                      color: Color(0xFFDDDDDD),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              );
            }

            return Dialog(
              backgroundColor: Colors.white,
              elevation: 10,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: SizedBox(
                width: 460,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 21,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(18),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.lock_outline_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Change Password',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop(false);
                            },
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Password fields
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        25,
                        25,
                        25,
                        22,
                      ),
                      child: Column(
                        children: [
                          passwordField(
                            label: 'Current Password',
                            controller: controllerCurrent,
                            obscure: obscureCurrent,
                            onToggle: () {
                              setDialogState(() {
                                obscureCurrent = !obscureCurrent;
                              });
                            },
                          ),
                          const SizedBox(height: 15),

                          passwordField(
                            label: 'New Password',
                            controller: controllerNew,
                            obscure: obscureNew,
                            onToggle: () {
                              setDialogState(() {
                                obscureNew = !obscureNew;
                              });
                            },
                          ),
                          const SizedBox(height: 15),

                          passwordField(
                            label: 'Confirm New Password',
                            controller: controllerConfirm,
                            obscure: obscureConfirm,
                            onToggle: () {
                              setDialogState(() {
                                obscureConfirm = !obscureConfirm;
                              });
                            },
                          ),

                          const SizedBox(height: 25),

                          // Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(dialogContext).pop(false);
                                },
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: Color(0xFF666666),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              FilledButton(
                                onPressed: () {
                                  Navigator.of(dialogContext).pop(true);
                                },
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 25,
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                ),
                                child: const Text(
                                  'Update',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (confirmed != true) return;

    final currentPassword = controllerCurrent.text.trim();
    final newPassword = controllerNew.text;
    final confirmPassword = controllerConfirm.text;

    if (currentPassword.isEmpty ||
        newPassword.trim().isEmpty ||
        confirmPassword.trim().isEmpty) {
      _showMessage(
        'Please complete all password fields.',
        isError: true,
      );
      return;
    }

    if (newPassword != confirmPassword) {
      _showMessage(
        'New passwords do not match.',
        isError: true,
      );
      return;
    }

    if (newPassword.length < 8) {
      _showMessage(
        'Password must be at least 8 characters.',
        isError: true,
      );
      return;
    }

    await injector.changePassword(
      identifier: _currentAccount!.email,
      currentPassword: currentPassword,
      newPassword: newPassword,
      role: _currentAccount!.role,
    );

    if (!mounted) return;

    _showMessage('Password updated successfully.');
  } catch (error) {
    if (!mounted) return;

    _showMessage(
      error.toString(),
      isError: true,
    );
  } finally {
    controllerCurrent.dispose();
    controllerNew.dispose();
    controllerConfirm.dispose();
  }
}


  Future<void> _changeProfilePhoto() async {
    final account = _currentAccount;
    if (account == null) return;

    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      if (pickedFile == null || !mounted) return;

      final photoBytes = await pickedFile.readAsBytes();
      if (photoBytes.length > 5 * 1024 * 1024) {
        _showMessage(
          'The selected photo is larger than 5 MB. Choose a smaller image.',
          isError: true,
        );
        return;
      }

      await injector.updateProfilePhoto(
        accountId: account.id.toString(),
        photoBytes: photoBytes,
        role: account.role,
      );

      if (!mounted || _currentAccount?.id != account.id) return;

      setState(() {
        _currentAccount = account.copyWith(avatarBytes: photoBytes);
      });

      _showMessage('Profile photo saved successfully.');
    } catch (error) {
      if (!mounted) return;
      _showMessage(error.toString(), isError: true);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              isError ? Colors.red.shade700 : Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLandingMode) {
      return LandingScreen(onEnterPortal: _enterPortal);
    }

    return Scaffold(
      body: Column(
        children: [
          TopHeaderBar(
            currentRole: _currentRole,
            selectedNavIndex: _selectedNavIndex,
            currentAccount: _currentAccount,
            onSelectNav: (index) => setState(() => _selectedNavIndex = index),
           onReturnToLanding: _returnToLanding,
          onChangePassword: _changePassword,
           onChangeProfilePhoto: _changeProfilePhoto,
            navItems: _navItemsForRole(),
          ),
          Expanded(
            child: Container(
              color: AppColors.background,
              width: double.infinity,
              child: _buildCurrentScreen(),
            ),
          ),
        ],
      ),
    );
  }

  /// Top navigation entries for the current role.
  List<Map<String, dynamic>> _navItemsForRole() {
    switch (_currentRole) {
      case UserRole.admin:
        return [
          {'index': 3, 'title': 'Book Inventory', 'icon': Icons.menu_book},
          {
            'index': 2,
            'title': 'Staff Management',
            'icon': Icons.people_alt_outlined,
          },
          {
            'index': 1,
            'title': 'LMS Settings',
            'icon': Icons.settings_outlined
          },
        ];
      case UserRole.librarian:
        {
          final permissions = _currentAccount?.permissions ?? const <String>{};
          final items = <Map<String, dynamic>>[];

          if (permissions.contains('BORROW_BOOK') ||
              permissions.contains('RETURN_BOOK') ||
              permissions.isEmpty) {
            items.add(
              {
                'index': 0,
                'title': 'Borrow & Return',
                'icon': Icons.swap_horiz
              },
            );
          }

          if (permissions.contains('ADD_BOOK') ||
              permissions.contains('EDIT_BOOK') ||
              permissions.contains('DELETE_BOOK')) {
            items.add(
              {'index': 2, 'title': 'Book Inventory', 'icon': Icons.menu_book},
            );
          }

          if (permissions.contains('MANAGE_STAFF')) {
            items.add(
              {
                'index': 3,
                'title': 'Staff Management',
                'icon': Icons.people_alt_outlined,
              },
            );
          }

          if (permissions.contains('CONFIGURE_SETTINGS')) {
            items.add(
              {
                'index': 4,
                'title': 'LMS Settings',
                'icon': Icons.settings_outlined,
              },
            );
          }

          if (permissions.contains('VIEW_NOTIFICATIONS') ||
              permissions.isEmpty) {
            items.add(
              {
                'index': 1,
                'title': 'Notifications',
                'icon': Icons.notifications_outlined,
              },
            );
          }

          if (items.isEmpty) {
            return [
              {
                'index': 0,
                'title': 'Borrow & Return',
                'icon': Icons.swap_horiz
              },
              {
                'index': 1,
                'title': 'Notifications',
                'icon': Icons.notifications_outlined,
              },
            ];
          }

          return items;
        }
      case UserRole.student:
        return [
          {'index': 0, 'title': 'Student Home', 'icon': Icons.home_outlined},
          {'index': 1, 'title': 'My Books', 'icon': Icons.bookmark_outline},
          {
            'index': 2,
            'title': 'Reservations',
            'icon': Icons.calendar_month_outlined,
          },
        ];
    }
  }

  /// Screen for the selected nav entry; unknown indexes open the portal's first screen.
  Widget _buildCurrentScreen() {
    switch (_currentRole) {
      case UserRole.admin:
        switch (_selectedNavIndex) {
          case 1:
            return const AdminSettingsScreen();
          case 2:
            return const StaffManagementScreen();
          default:
            return const AdminInventoryScreen();
        }
      case UserRole.librarian:
        switch (_selectedNavIndex) {
          case 1:
            return LibrarianNotificationsScreen(librarianPosition: _currentAccount?.title);
          case 2:
            return const AdminInventoryScreen();
          case 3:
            return const StaffManagementScreen();
          case 4:
            return const AdminSettingsScreen();
          default:
            return const LibrarianDeskScreen();
        }
      case UserRole.student:
        switch (_selectedNavIndex) {
          case 1:
            return StudentMyBooksScreen(
              studentId: _currentAccount!.id.toString(),
            );
          case 2:
            return StudentReservationsScreen(
              studentId: _currentAccount!.id.toString(),
            );
          default:
            return StudentHomeScreen(
              studentId: _currentAccount!.id,
              onNavigateToMyBooks: () => setState(() => _selectedNavIndex = 1),
            );
        }
    }
  }
}
