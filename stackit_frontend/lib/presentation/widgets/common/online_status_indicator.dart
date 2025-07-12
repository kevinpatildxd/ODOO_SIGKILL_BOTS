import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stackit_frontend/core/services/user_presence_service.dart';

/// A widget that displays a user's online status.
///
/// This widget shows a small colored dot indicating whether a user is online.
class OnlineStatusIndicator extends StatelessWidget {
  /// The ID of the user whose online status will be displayed.
  final String userId;
  
  /// The size of the indicator dot.
  final double size;
  
  /// The stroke width for the border of the dot.
  final double strokeWidth;
  
  /// Creates an [OnlineStatusIndicator].
  ///
  /// The [userId] parameter is required and must not be null.
  /// The [size] parameter defaults to 10.0.
  /// The [strokeWidth] parameter defaults to 1.0.
  const OnlineStatusIndicator({
    Key? key,
    required this.userId,
    this.size = 10.0,
    this.strokeWidth = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userPresenceService = Provider.of<UserPresenceService>(context, listen: false);
    
    return ValueListenableBuilder<Map<String, bool>>(
      valueListenable: userPresenceService.onlineUsersNotifier,
      builder: (context, onlineUsers, _) {
        final isOnline = onlineUsers[userId] ?? false;
        
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isOnline ? Colors.green : Colors.grey,
            border: Border.all(
              color: Colors.white,
              width: strokeWidth,
            ),
          ),
        );
      },
    );
  }
} 