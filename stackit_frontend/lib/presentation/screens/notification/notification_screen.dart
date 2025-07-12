import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stackit_frontend/config/theme.dart';
import 'package:stackit_frontend/presentation/providers/notification_provider.dart';
import 'package:stackit_frontend/presentation/widgets/common/loading_widget.dart';
import 'package:stackit_frontend/presentation/widgets/common/error_widget.dart';
import 'package:stackit_frontend/presentation/widgets/common/empty_state_widget.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    await Provider.of<NotificationProvider>(context, listen: false)
        .getNotifications(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.status == NotificationStatus.loading && provider.notifications.isEmpty) {
            return const LoadingWidget();
          }

          if (provider.status == NotificationStatus.error) {
            return CustomErrorWidget(
              message: provider.errorMessage,
              onRetry: _loadNotifications,
            );
          }

          final notifications = provider.notifications;
          
          if (notifications.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.notifications_none_outlined,
              title: 'No Notifications',
              message: 'You don\'t have any notifications yet',
            );
          }

          return RefreshIndicator(
            onRefresh: _loadNotifications,
            child: ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getNotificationColor(notification.type),
                    child: Icon(
                      _getNotificationIcon(notification.type),
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    notification.title,
                    style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.message,
                        style: AppTextStyles.body2,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(notification.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    // Navigate to the relevant screen based on notification type
                    // This will be implemented in a later phase
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'answer':
        return AppColors.primary;
      case 'vote':
        return AppColors.success;
      case 'comment':
        return AppColors.secondary;
      default:
        return AppColors.primary;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'answer':
        return Icons.question_answer;
      case 'vote':
        return Icons.thumb_up;
      case 'comment':
        return Icons.comment;
      default:
        return Icons.notifications;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
} 