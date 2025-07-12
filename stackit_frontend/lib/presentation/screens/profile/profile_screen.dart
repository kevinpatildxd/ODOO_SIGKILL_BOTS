import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stackit_frontend/data/models/user_model.dart';
import 'package:stackit_frontend/presentation/providers/auth_provider.dart';
import 'package:stackit_frontend/presentation/widgets/common/loading_widget.dart';
import 'package:stackit_frontend/presentation/widgets/common/error_widget.dart' as app_error;

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    if (authProvider.status == AuthStatus.loading) {
      return const Scaffold(
        body: Center(
          child: LoadingWidget(),
        ),
      );
    }
    
    if (authProvider.status == AuthStatus.error) {
      return Scaffold(
        body: Center(
          child: app_error.CustomErrorWidget(
            message: authProvider.errorMessage,
            onRetry: () {
              // Implement refresh logic if needed
            },
          ),
        ),
      );
    }
    
    if (authProvider.user == null) {
      return const Scaffold(
        body: Center(
          child: Text('You need to be logged in to view your profile'),
        ),
      );
    }
    
    final user = authProvider.user!;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
              // Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Implement refresh logic if needed
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(context, user),
              const SizedBox(height: 24),
              _buildStats(context, user),
              const SizedBox(height: 24),
              _buildNavigation(context),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildProfileHeader(BuildContext context, User user) {
    return Column(
      children: [
        Center(
          child: CircleAvatar(
            radius: 50,
            backgroundImage: user.avatarUrl != null 
              ? NetworkImage(user.avatarUrl!) 
              : null,
            child: user.avatarUrl == null 
              ? Text(
                  user.username.substring(0, 1).toUpperCase(),
                  style: const TextStyle(fontSize: 40),
                )
              : null,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            user.username,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            user.email,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
          ),
        ),
        if (user.bio != null && user.bio!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              user.bio!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildStats(BuildContext context, User user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stats',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(context, 'Reputation', '${user.reputation}'),
                _buildStatItem(context, 'Member Since', _formatDate(user.createdAt)),
                _buildStatItem(context, 'Role', user.role),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ],
    );
  }
  
  Widget _buildNavigation(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Activity',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.question_answer),
                title: const Text('My Questions'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pushNamed(context, '/user-questions');
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.comment),
                title: const Text('My Answers'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pushNamed(context, '/user-answers');
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.bookmark),
                title: const Text('Saved Questions'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Navigator.pushNamed(context, '/saved-questions');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
