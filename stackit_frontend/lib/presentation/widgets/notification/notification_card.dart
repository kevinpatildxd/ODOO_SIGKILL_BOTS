import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stackit_frontend/data/models/notification_model.dart' as model;
import 'package:stackit_frontend/presentation/providers/notification_provider.dart';

class NotificationCard extends StatelessWidget {
  final model.Notification notification;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onDelete;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
    this.onMarkAsRead,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    
    return Dismissible(
      key: Key('notification_${notification.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (direction) async {
        if (onDelete != null) {
          onDelete!();
          return true;
        } else {
          await notificationProvider.deleteNotification(notification.id);
          return true;
        }
      },
      child: Card(
        elevation: 1.0,
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        color: notification.isRead ? null : theme.colorScheme.surfaceVariant.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: notification.isRead 
              ? BorderSide.none 
              : BorderSide(color: theme.colorScheme.primary.withOpacity(0.2)),
        ),
        child: InkWell(
          onTap: () {
            if (onTap != null) {
              onTap!();
            }
            
            if (!notification.isRead) {
              if (onMarkAsRead != null) {
                onMarkAsRead!();
              } else {
                notificationProvider.markAsRead(notification.id);
              }
            }
          },
          borderRadius: BorderRadius.circular(8.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNotificationIcon(context),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        notification.message,
                        style: theme.textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        _formatDate(notification.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                          fontSize: 11.0,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!notification.isRead)
                  Container(
                    width: 8.0,
                    height: 8.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.primary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(BuildContext context) {
    final theme = Theme.of(context);
    
    IconData iconData;
    Color iconColor;
    
    switch (notification.type.toLowerCase()) {
      case 'answer':
        iconData = Icons.comment;
        iconColor = Colors.green;
        break;
      case 'vote':
        iconData = Icons.thumb_up;
        iconColor = Colors.blue;
        break;
      case 'mention':
        iconData = Icons.alternate_email;
        iconColor = Colors.purple;
        break;
      case 'system':
        iconData = Icons.system_update;
        iconColor = Colors.orange;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = theme.colorScheme.primary;
    }
    
    return Container(
      width: 40.0,
      height: 40.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: iconColor.withOpacity(0.1),
      ),
      child: Center(
        child: Icon(
          iconData,
          color: iconColor,
          size: 20.0,
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
