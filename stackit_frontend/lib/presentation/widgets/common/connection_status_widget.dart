import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stackit_frontend/core/services/socket_service.dart';

/// A widget that displays the current connection status.
///
/// This widget shows a banner with the current connection status,
/// and provides visual feedback when connection is lost or restored.
class ConnectionStatusWidget extends StatelessWidget {
  /// Creates a [ConnectionStatusWidget].
  const ConnectionStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    
    return ValueListenableBuilder<bool>(
      valueListenable: socketService.isConnected,
      builder: (context, isConnected, _) {
        if (isConnected) {
          return const SizedBox.shrink(); // No need to show anything when connected
        }
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: isConnected ? 0 : 36.0,
          color: Colors.red.shade700,
          child: isConnected 
            ? null 
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.cloud_off,
                    color: Colors.white,
                    size: 16.0,
                  ),
                  const SizedBox(width: 8.0),
                  const Text(
                    'You are currently offline. Some features may be limited.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.0,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  TextButton(
                    onPressed: () {
                      socketService.connect();
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      minimumSize: Size.zero,
                    ),
                    child: const Text(
                      'Try again',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.0,
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

/// A widget that displays a small indicator for connection status.
///
/// This widget shows a small dot indicating connection status in
/// a corner of the screen, suitable for persistent display.
class ConnectionStatusDot extends StatelessWidget {
  /// Creates a [ConnectionStatusDot].
  const ConnectionStatusDot({super.key});

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    
    return ValueListenableBuilder<bool>(
      valueListenable: socketService.isConnected,
      builder: (context, isConnected, _) {
        return Tooltip(
          message: isConnected ? 'Connected' : 'Offline',
          child: Container(
            width: 12.0,
            height: 12.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isConnected ? Colors.green : Colors.red,
              border: Border.all(
                color: Theme.of(context).scaffoldBackgroundColor,
                width: 2.0,
              ),
            ),
          ),
        );
      },
    );
  }
} 