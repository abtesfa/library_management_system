import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../../features/auth/domain/entities/user.dart';
import '../../../features/library/presentation/providers/library_service.dart';
import '../../config/api_config.dart';

class TopHeaderBar extends StatelessWidget {
  final UserRole currentRole;
  final int selectedNavIndex;
  final UserAccount? currentAccount;
  final ValueChanged<int> onSelectNav;
  final VoidCallback onReturnToLanding;
  final VoidCallback onChangePassword;
  final VoidCallback onChangeProfilePhoto;
  final List<Map<String, dynamic>> navItems;

  const TopHeaderBar({
    super.key,
    required this.currentRole,
    required this.selectedNavIndex,
    required this.currentAccount,
    required this.onSelectNav,
    required this.onReturnToLanding,
    required this.onChangePassword,
    required this.onChangeProfilePhoto,
    required this.navItems,
  });

  // Resolve library logo URL
  String? _getLogoUrl(String? logoUrl) {
    final url = logoUrl?.trim() ?? '';

    if (url.isEmpty) return null;

    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    final apiUri = Uri.parse(ApiConfig.baseUrl);

    return apiUri.replace(
      path: url.startsWith('/') ? url : '/$url',
      query: null,
      fragment: null,
    ).toString();
  }

  // Library logo
  Widget _buildLibraryLogo(String? logoUrl) {
    final imageUrl = _getLogoUrl(logoUrl);

    return Container(
      width: 46,
      height: 46,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: imageUrl == null
            ? const Icon(
                Icons.menu_book,
                color: AppColors.primary,
                size: 30,
              )
            : Image.network(
                imageUrl,
                width: 42,
                height: 42,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.menu_book,
                    color: AppColors.primary,
                    size: 30,
                  );
                },
              ),
      ),
    );
  }

  // Show large profile photo preview
  void _showProfilePhoto(BuildContext context) {
    final photoBytes = currentAccount?.avatarBytes;

    if (photoBytes == null) return;

    showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.all(20),
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              Center(
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4.0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      photoBytes,
                      fit: BoxFit.contain,
                      width: 450,
                      height: 450,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.broken_image,
                          color: Colors.white,
                          size: 60,
                        );
                      },
                    ),
                  ),
                ),
              ),

              // Close button
              IconButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Profile photo button
  Widget _buildProfilePhoto(BuildContext context, String initials) {
    return InkWell(
      onTap: () => _showProfilePhoto(context),
      borderRadius: BorderRadius.circular(50),
      child: CircleAvatar(
        radius: 17,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        backgroundImage: currentAccount?.avatarBytes != null
            ? MemoryImage(currentAccount!.avatarBytes!)
            : null,
        child: currentAccount?.avatarBytes == null
            ? Text(
                initials,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
    );
  }

  // Profile menu
  
Widget _buildProfileMenu() {
  return PopupMenuButton<String>(
    offset: const Offset(0, 52),
    tooltip: 'Profile menu',
    color: Colors.white,
    elevation: 12,
    shadowColor: Colors.black.withValues(alpha: 0.15),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    ),
    onSelected: (value) {
      switch (value) {
        case 'change_password':
          onChangePassword();
          break;

        case 'change_photo':
          onChangeProfilePhoto();
          break;

        case 'logout':
          onReturnToLanding();
          break;
      }
    },
    itemBuilder: (context) => [
      PopupMenuItem(
        value: 'change_password',
        height: 64,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF2FF),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(
                Icons.lock_reset_rounded,
               color: Color(0xFF514746),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Change Password',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF514746),
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Update your account security',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF94A3B8),
              size: 20,
            ),
          ],
        ),
      ),

      PopupMenuItem(
        value: 'change_photo',
        height: 64,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F7F0),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(
                Icons.camera_alt_outlined,
              color: Color(0xFF514746),
                size: 21,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Change Photo',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                   color: Color(0xFF514746),
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Update your profile picture',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF94A3B8),
              size: 20,
            ),
          ],
        ),
      ),

      const PopupMenuDivider(height: 8),

      PopupMenuItem(
        value: 'logout',
        height: 58,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEEEE),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Color(0xFFDC2626),
                size: 21,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Logout',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFDC2626),
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF94A3B8),
              size: 20,
            ),
          ],
        ),
      ),
    ],
    child: Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (currentAccount != null) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  currentAccount!.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  currentAccount!.roleDisplayName,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(width: 4),
          const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.white,
            size: 18,
          ),
        ],
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final initials = currentAccount != null
        ? currentAccount!.name
            .trim()
            .split(RegExp(r'\s+'))
            .where((part) => part.isNotEmpty)
            .take(2)
            .map((part) => part[0].toUpperCase())
            .join()
        : 'L';

    return Consumer<LibraryService>(
      builder: (context, service, child) {
        final settings = service.settings;

        return Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          color: AppColors.primary,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Library logo and name
              Row(
                  children: [
                    _buildLibraryLogo(settings.logoUrl),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 220,
                          ),
                          child: Text(
                            settings.libraryName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            currentRole == UserRole.admin
                                ? 'Admin Portal'
                                : currentRole == UserRole.librarian
                                    ? 'Librarian Desk'
                                    : 'Student Portal',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              

              // Navigation items
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: navItems.map((item) {
                        final isSelected =
                            selectedNavIndex == item['index'];

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {
                              onSelectNav(item['index'] as int);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.1,
                                          ),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    item['icon'] as IconData,
                                    size: 16,
                                    color: isSelected
                                        ? const Color(0xFFF25635)
                                        : Colors.white.withValues(
                                            alpha: 0.85,
                                          ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    item['title'] as String,
                                    style: TextStyle(
                                      color: isSelected
                                          ? const Color(0xFFF25635)
                                          : Colors.white.withValues(
                                              alpha: 0.9,
                                            ),
                                      fontSize: 12,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),

              // Profile photo and profile menu
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildProfilePhoto(context, initials),
                  const SizedBox(width: 8),
                  _buildProfileMenu(),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
