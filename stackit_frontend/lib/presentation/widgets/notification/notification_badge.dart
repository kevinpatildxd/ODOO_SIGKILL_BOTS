import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stackit_frontend/presentation/providers/notification_provider.dart';

class NotificationBadge extends StatelessWidget {
  /// The widget to display inside the badge.
  final Widget child;
  
  /// Whether to show the notification badge.
  /// If null, badge visibility is controlled by unread count.
  final bool? showBadge;
  
  /// The position of the badge.
  final BadgePosition position;
  
  /// The color of the badge.
  final Color? badgeColor;
  
  /// The text color of the badge.
  final Color? textColor;
  
  /// A custom builder for the badge if you want to completely customize its appearance.
  final Widget Function(BuildContext context, int count)? badgeBuilder;
  
  /// Minimum size of the badge.
  final double minSize;
  
  /// The padding between the badge and its contents.
  final EdgeInsetsGeometry padding;

  const NotificationBadge({
    super.key,
    required this.child,
    this.showBadge,
    this.position = const BadgePosition(),
    this.badgeColor,
    this.textColor,
    this.badgeBuilder,
    this.minSize = 20.0,
    this.padding = const EdgeInsets.all(2.0),
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, _) {
        final unreadCount = notificationProvider.unreadCount;
        final shouldShowBadge = showBadge ?? unreadCount > 0;
        
        if (!shouldShowBadge) {
          return child;
        }
        
        return Stack(
          clipBehavior: Clip.none,
          children: [
            child,
            Positioned(
              top: position.top,
              right: position.right,
              bottom: position.bottom,
              left: position.left,
              child: badgeBuilder?.call(context, unreadCount) ?? 
              _defaultBadgeBuilder(context, unreadCount),
            ),
          ],
        );
      },
    );
  }
  
  Widget _defaultBadgeBuilder(BuildContext context, int count) {
    final theme = Theme.of(context);
    return Container(
      padding: padding,
      constraints: BoxConstraints(minWidth: minSize, minHeight: minSize),
      decoration: BoxDecoration(
        color: badgeColor ?? theme.colorScheme.error,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          count > 99 ? '99+' : count.toString(),
          style: TextStyle(
            color: textColor ?? theme.colorScheme.onError,
            fontSize: 10.0,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class BadgePosition {
  final double? top;
  final double? right;
  final double? bottom;
  final double? left;

  const BadgePosition({
    this.top = -5,
    this.right = -5,
    this.bottom,
    this.left,
  });

  const BadgePosition.topStart({
    this.top = -5,
    this.right,
    this.bottom,
    this.left = -5,
  });

  const BadgePosition.topEnd({
    this.top = -5,
    this.right = -5,
    this.bottom,
    this.left,
  });

  const BadgePosition.bottomStart({
    this.top,
    this.right,
    this.bottom = -5,
    this.left = -5,
  });

  const BadgePosition.bottomEnd({
    this.top,
    this.right = -5,
    this.bottom = -5,
    this.left,
  });
}
