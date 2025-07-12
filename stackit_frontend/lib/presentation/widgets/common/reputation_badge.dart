import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stackit_frontend/core/services/user_reputation_service.dart';

/// A widget that displays a user's reputation as a badge.
///
/// This widget shows a badge with the user's reputation that
/// updates in real-time when reputation changes occur.
class ReputationBadge extends StatelessWidget {
  /// The ID of the user whose reputation will be displayed.
  final String userId;
  
  /// The initial reputation value to display.
  final int initialReputation;
  
  /// Whether to show an icon next to the reputation value.
  final bool showIcon;
  
  /// Creates a [ReputationBadge].
  ///
  /// The [userId] parameter is required and must not be null.
  /// The [initialReputation] parameter defaults to 0.
  /// The [showIcon] parameter defaults to true.
  const ReputationBadge({
    Key? key,
    required this.userId,
    this.initialReputation = 0,
    this.showIcon = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userReputationService = Provider.of<UserReputationService>(context, listen: false);
    
    return ValueListenableBuilder<Map<String, int>>(
      valueListenable: userReputationService.reputationsNotifier,
      builder: (context, reputations, _) {
        final reputation = reputations[userId] ?? initialReputation;
        final Color backgroundColor = _getBackgroundColor(reputation);
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showIcon)
                Icon(
                  Icons.workspace_premium,
                  size: 14.0,
                  color: Colors.white,
                ),
              if (showIcon)
                const SizedBox(width: 4.0),
              Text(
                reputation.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.0,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  /// Determines the badge color based on reputation value.
  Color _getBackgroundColor(int reputation) {
    if (reputation >= 10000) {
      return Colors.deepPurple; // Legendary
    } else if (reputation >= 5000) {
      return Colors.deepOrange; // Epic
    } else if (reputation >= 2000) {
      return Colors.amber.shade700; // Gold
    } else if (reputation >= 1000) {
      return Colors.blueAccent; // Expert
    } else if (reputation >= 500) {
      return Colors.green; // Trusted
    } else if (reputation >= 200) {
      return Colors.teal; // Established
    } else {
      return Colors.grey.shade600; // Beginner
    }
  }
} 