import 'package:flutter/material.dart';
import 'package:stackit_frontend/config/theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final bool automaticallyImplyLeading;
  final double elevation;
  final Color? backgroundColor;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.automaticallyImplyLeading = true,
    this.elevation = 4.0,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: AppTextStyles.h2.copyWith(
          color: AppColors.onPrimary,
        ),
      ),
      centerTitle: centerTitle,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: leading,
      actions: actions,
      elevation: elevation,
      backgroundColor: backgroundColor ?? AppColors.primary,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// Extension methods for common app bar variations
extension CustomAppBarExtensions on CustomAppBar {
  // App bar with a search action
  static CustomAppBar withSearch(String title, VoidCallback onSearchTap) {
    return CustomAppBar(
      title: title,
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: onSearchTap,
        ),
      ],
    );
  }

  // App bar with a back button
  static CustomAppBar withBack(BuildContext context, String title) {
    return CustomAppBar(
      title: title,
      automaticallyImplyLeading: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  // App bar with a notification icon
  static CustomAppBar withNotification(String title, VoidCallback onNotificationTap, {int notificationCount = 0}) {
    return CustomAppBar(
      title: title,
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: onNotificationTap,
            ),
            if (notificationCount > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    notificationCount > 9 ? '9+' : '$notificationCount',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.onPrimary,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
