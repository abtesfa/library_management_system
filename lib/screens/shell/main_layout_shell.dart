import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../widgets/common/left_side_bar.dart';
import '../../widgets/common/top_header.dart';

class MainLayoutShell extends StatelessWidget {
  final Widget child;

  const MainLayoutShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const TopHeader(),
          Expanded(
            child: Row(
              children: [
                const LeftSidebar(),
                Expanded(
                  child: Container(
                    color: AppColors.background,
                    child: child,
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