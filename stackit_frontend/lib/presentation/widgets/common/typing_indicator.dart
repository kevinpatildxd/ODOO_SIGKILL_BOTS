import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stackit_frontend/core/services/user_presence_service.dart';
import 'package:stackit_frontend/data/repositories/user_repository.dart';

/// A widget that displays typing indicators for users.
///
/// This widget shows when one or more users are currently typing
/// in a question or answer thread.
class TypingIndicator extends StatelessWidget {
  /// The ID of the question being viewed.
  final String questionId;
  
  /// Creates a [TypingIndicator].
  ///
  /// The [questionId] parameter is required and must not be null.
  const TypingIndicator({
    Key? key,
    required this.questionId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userPresenceService = Provider.of<UserPresenceService>(context, listen: false);
    final userRepository = Provider.of<UserRepository>(context, listen: false);
    
    // Set the current question context
    userPresenceService.setCurrentQuestion(questionId);
    
    return ValueListenableBuilder<Map<String, bool>>(
      valueListenable: userPresenceService.typingUsersNotifier,
      builder: (context, typingUsers, _) {
        final typingUserIds = typingUsers.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList();
            
        if (typingUserIds.isEmpty) {
          return const SizedBox.shrink(); // Nothing to show
        }
        
        return FutureBuilder<List<String>>(
          future: _getUsernames(userRepository, typingUserIds),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox.shrink();
            }
            
            final usernames = snapshot.data!;
            String typingText;
            
            if (usernames.length == 1) {
              typingText = '${usernames[0]} is typing...';
            } else if (usernames.length == 2) {
              typingText = '${usernames[0]} and ${usernames[1]} are typing...';
            } else {
              typingText = '${usernames.length} people are typing...';
            }
            
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  const _DotPulse(),
                  const SizedBox(width: 8.0),
                  Text(
                    typingText,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  
  /// Fetches usernames for the given user IDs.
  Future<List<String>> _getUsernames(UserRepository repository, List<String> userIds) async {
    try {
      final users = await repository.getUsersByIds(userIds);
      return users.map((user) => user.username).toList();
    } catch (e) {
      // If we can't get usernames, just use generic labels
      return List.generate(userIds.length, (i) => 'User ${i + 1}');
    }
  }
}

/// An animated dots typing indicator.
class _DotPulse extends StatefulWidget {
  const _DotPulse({Key? key}) : super(key: key);

  @override
  _DotPulseState createState() => _DotPulseState();
}

class _DotPulseState extends State<_DotPulse> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          children: List.generate(3, (index) {
            final delay = index * 0.3;
            final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: _controller,
                curve: Interval(
                  delay,
                  delay + 0.3,
                  curve: Curves.easeInOut,
                ),
              ),
            );
            
            return Container(
              width: 6.0,
              height: 6.0,
              margin: const EdgeInsets.symmetric(horizontal: 2.0),
              decoration: BoxDecoration(
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(
                  0.3 + (animation.value * 0.7),
                ),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
} 