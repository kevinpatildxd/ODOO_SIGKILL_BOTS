import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stackit_frontend/data/models/notification_model.dart' as model;
import 'package:stackit_frontend/presentation/providers/notification_provider.dart';
import 'package:stackit_frontend/presentation/widgets/notification/notification_list.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, _) {
              if (provider.notifications.isEmpty) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.delete_sweep),
                tooltip: 'Clear all notifications',
                onPressed: () {
                  _showClearConfirmation(context);
                },
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: NotificationList(
          onNotificationTap: (notification) {
            _handleNotificationTap(context, notification);
          },
        ),
      ),
    );
  }

  void _showClearConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear Notifications'),
          content: const Text('Are you sure you want to clear all notifications?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Clear All'),
              onPressed: () {
                Navigator.of(context).pop();
                Provider.of<NotificationProvider>(context, listen: false)
                    .clearNotifications();
              },
            ),
          ],
        );
      },
    );
  }

  void _handleNotificationTap(BuildContext context, model.Notification notification) {
    // Navigate based on notification type and reference
    if (notification.referenceType != null && notification.referenceId != null) {
      switch (notification.referenceType) {
        case 'question':
          Navigator.pushNamed(
            context, 
            '/question-detail',
            arguments: notification.referenceId,
          );
          break;
        case 'answer':
          // Typically you would navigate to the question that contains this answer
          // You could store the questionId in addition to the answerId in the notification
          // For now, we'll just show a snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Navigating to answer ${notification.referenceId}'),
              duration: const Duration(seconds: 2),
            ),
          );
          break;
        default:
          // Default case for unknown reference types
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Unknown notification type: ${notification.referenceType}'),
              duration: const Duration(seconds: 2),
            ),
          );
      }
    }
  }
} 