
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

  Widget _buildLibraryLogo(String? logoUrl) {
    final imageUrl = _getLogoUrl(logoUrl);

    return Container(
      width: 36,
      height: 36,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: imageUrl == null
            ? const Icon(
                Icons.menu_book,
                color: Colors.white,
                size: 23,
              )
            : Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.menu_book,
                    color: Colors.white,
                    size: 23,
                  );
                },
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
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          color: AppColors.primary,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: onReturnToLanding,
                child: Row(
                  children: [
                    _buildLibraryLogo(settings.logoUrl),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 220),
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
              ),
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
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () =>
                                onSelectNav(item['index'] as int),
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
              PopupMenuButton<String>(
                offset: const Offset(0, 52),
                tooltip: 'Profile menu',
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
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
                  const PopupMenuItem(
                    value: 'change_password',
                    child: Row(
                      children: [
                        Icon(Icons.lock_outline, size: 18),
                        SizedBox(width: 10),
                        Text('Change Password'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'change_photo',
                    child: Row(
                      children: [
                        Icon(Icons.photo_camera_outlined, size: 18),
                        SizedBox(width: 10),
                        Text('Change Photo'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, size: 18),
                        SizedBox(width: 10),
                        Text('Logout'),
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
                    children: [
                      CircleAvatar(
                        radius: 17,
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        backgroundImage:
                            currentAccount?.avatarBytes != null
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
                      const SizedBox(width: 8),
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
              ),
            ],
          ),
        );
      },
    );
  }
}
