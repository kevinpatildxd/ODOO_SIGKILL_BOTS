import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stackit_frontend/config/theme.dart';
import 'package:stackit_frontend/presentation/providers/notification_provider.dart';
import 'package:stackit_frontend/presentation/widgets/notification/notification_badge.dart';

enum NavigationItem {
  home,
  search,
  askQuestion,
  notifications,
  profile,
}

class BottomNavigation extends StatelessWidget {
  final NavigationItem currentItem;
  final Function(NavigationItem) onItemSelected;

  const BottomNavigation({
    super.key,
    required this.currentItem,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                NavigationItem.home,
                Icons.home_outlined,
                Icons.home,
                'Home',
              ),
              _buildNavItem(
                context,
                NavigationItem.search,
                Icons.search_outlined,
                Icons.search,
                'Search',
              ),
              _buildAskButton(context),
              _buildNotificationItem(
                context,
                NavigationItem.notifications,
                Icons.notifications_outlined,
                Icons.notifications,
                'Alerts',
              ),
              _buildNavItem(
                context,
                NavigationItem.profile,
                Icons.person_outline,
                Icons.person,
                'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    NavigationItem item,
    IconData outlinedIcon,
    IconData filledIcon,
    String label,
  ) {
    final isSelected = currentItem == item;
    
    return InkWell(
      onTap: () => onItemSelected(item),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? filledIcon : outlinedIcon,
              color: isSelected ? AppColors.primary : AppColors.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.primary : AppColors.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNotificationItem(
    BuildContext context,
    NavigationItem item,
    IconData outlinedIcon,
    IconData filledIcon,
    String label,
  ) {
    final isSelected = currentItem == item;
    
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, _) {
        return InkWell(
          onTap: () => onItemSelected(item),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                NotificationBadge(
                  position: const BadgePosition(top: -5, right: -8),
                  minSize: 16,
                  child: Icon(
                    isSelected ? filledIcon : outlinedIcon,
                    color: isSelected ? AppColors.primary : AppColors.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? AppColors.primary : AppColors.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAskButton(BuildContext context) {
    return InkWell(
      onTap: () => onItemSelected(NavigationItem.askQuestion),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.add,
          color: AppColors.onPrimary,
          size: 28,
        ),
      ),
    );
  }
}
