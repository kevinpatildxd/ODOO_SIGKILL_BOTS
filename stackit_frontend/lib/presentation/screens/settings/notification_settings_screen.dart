import 'package:flutter/material.dart';
import 'package:stackit_frontend/presentation/widgets/common/app_bar.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _questionNotifications = true;
  bool _answerNotifications = true;
  bool _commentNotifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Notification Settings',
        showBackButton: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionTitle('Notification Channels'),
          _buildSwitchTile(
            'Email Notifications', 
            _emailNotifications,
            (value) => setState(() => _emailNotifications = value),
            'Receive notifications via email',
          ),
          _buildSwitchTile(
            'Push Notifications',
            _pushNotifications,
            (value) => setState(() => _pushNotifications = value),
            'Receive push notifications on your device',
          ),
          const Divider(),
          _buildSectionTitle('Notification Types'),
          _buildSwitchTile(
            'Questions',
            _questionNotifications,
            (value) => setState(() => _questionNotifications = value),
            'Notifications for questions you follow',
          ),
          _buildSwitchTile(
            'Answers',
            _answerNotifications,
            (value) => setState(() => _answerNotifications = value),
            'Notifications when your questions receive answers',
          ),
          _buildSwitchTile(
            'Comments',
            _commentNotifications,
            (value) => setState(() => _commentNotifications = value),
            'Notifications for comments on your posts',
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notification settings saved'),
                  duration: Duration(seconds: 2),
                ),
              );
              Navigator.pop(context);
            },
            child: const Text('Save Settings'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
  
  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged, String subtitle) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
