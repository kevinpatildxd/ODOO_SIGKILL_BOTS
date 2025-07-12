import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stackit_frontend/data/models/notification_model.dart' as model;
import 'package:stackit_frontend/presentation/providers/notification_provider.dart';
import 'package:stackit_frontend/presentation/widgets/common/empty_state_widget.dart';
import 'package:stackit_frontend/presentation/widgets/common/error_widget.dart' as app_error;
import 'package:stackit_frontend/presentation/widgets/common/loading_widget.dart';
import 'package:stackit_frontend/presentation/widgets/notification/notification_card.dart';

class NotificationList extends StatefulWidget {
  /// Function called when a notification is tapped
  final Function(model.Notification notification)? onNotificationTap;
  
  /// Maximum height of the notification list
  final double? maxHeight;
  
  /// Whether to show the "Mark All as Read" button
  final bool showMarkAllAsRead;
  
  /// Whether to allow fetching more notifications when user scrolls to bottom
  final bool enablePagination;
  
  /// A function to override the standard behavior when marking a notification as read
  final Function(model.Notification notification)? onMarkAsRead;

  const NotificationList({
    super.key,
    this.onNotificationTap,
    this.maxHeight,
    this.showMarkAllAsRead = true,
    this.enablePagination = true,
    this.onMarkAsRead,
  });

  @override
  State<NotificationList> createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    
    if (widget.enablePagination) {
      _scrollController.addListener(_scrollListener);
    }
    
    // Fetch notifications when widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notificationProvider = 
          Provider.of<NotificationProvider>(context, listen: false);
      notificationProvider.getNotifications(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final notificationProvider = 
          Provider.of<NotificationProvider>(context, listen: false);
      if (!notificationProvider.isLoading && notificationProvider.hasMore) {
        notificationProvider.getNotifications(refresh: false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.showMarkAllAsRead && notificationProvider.unreadCount > 0)
              _buildMarkAllAsReadButton(context, notificationProvider),
            Flexible(
              child: _buildNotificationListContent(notificationProvider),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMarkAllAsReadButton(
      BuildContext context, NotificationProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: TextButton(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: BorderSide(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            ),
          ),
        ),
        onPressed: () => provider.markAllAsRead(),
        child: Text(
          'Mark all as read',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationListContent(NotificationProvider provider) {
    final isInitialLoading = 
        provider.status == NotificationStatus.loading &&
        provider.notifications.isEmpty;
        
    if (isInitialLoading) {
      return const Center(child: LoadingWidget());
    }

    if (provider.status == NotificationStatus.error &&
        provider.notifications.isEmpty) {
      return Center(
        child: app_error.ErrorWidget(
          message: provider.errorMessage,
          onRetry: () => provider.getNotifications(refresh: true),
        ),
      );
    }

    if (provider.notifications.isEmpty) {
      return const Center(
        child: EmptyStateWidget(
          icon: Icons.notifications_none,
          title: 'No notifications yet',
          message: 'When you receive notifications, they\'ll appear here',
        ),
      );
    }

    final listWidget = ListView.builder(
      controller: _scrollController,
      shrinkWrap: true,
      padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
      itemCount: provider.notifications.length +
          (provider.isLoading && provider.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == provider.notifications.length) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final notification = provider.notifications[index];
        return NotificationCard(
          key: ValueKey('notification_card_${notification.id}'),
          notification: notification,
          onTap: widget.onNotificationTap != null
              ? () => widget.onNotificationTap?.call(notification)
              : null,
          onMarkAsRead: widget.onMarkAsRead != null
              ? () => widget.onMarkAsRead?.call(notification)
              : null,
        );
      },
    );

    if (widget.maxHeight != null) {
      return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: widget.maxHeight!),
        child: listWidget,
      );
    }

    return listWidget;
  }
}
