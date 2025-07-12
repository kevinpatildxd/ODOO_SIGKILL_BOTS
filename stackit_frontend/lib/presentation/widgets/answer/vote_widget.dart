import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stackit_frontend/config/theme.dart';
import 'package:stackit_frontend/presentation/providers/vote_provider.dart';
import 'package:stackit_frontend/core/utils/helpers.dart';

class VoteWidget extends StatelessWidget {
  final String targetType; // 'question' or 'answer'
  final int targetId;
  final int voteCount;
  final bool isVertical;
  final bool showCount;
  final double iconSize;

  const VoteWidget({
    super.key,
    required this.targetType,
    required this.targetId,
    required this.voteCount,
    this.isVertical = true,
    this.showCount = true,
    this.iconSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    final voteProvider = Provider.of<VoteProvider>(context);
    final userVoteType = voteProvider.getVoteTypeFor(targetType, targetId);
    final isLoading = voteProvider.isLoading;

    Widget buildVoteCount() {
      return Padding(
        padding: isVertical
            ? const EdgeInsets.symmetric(vertical: 4)
            : const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          Helpers.formatNumber(voteCount),
          style: TextStyle(
            fontSize: iconSize * 0.7,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
      );
    }

    Widget buildUpvoteButton() {
      final isUpvoted = userVoteType == 1;
      
      return IconButton(
        icon: Icon(
          isUpvoted ? Icons.arrow_upward : Icons.arrow_upward_outlined,
          size: iconSize,
        ),
        color: isUpvoted ? AppColors.success : null,
        onPressed: isLoading
            ? null
            : () => _handleVote(context, isUpvoted ? 0 : 1),
        splashRadius: iconSize * 0.8,
        tooltip: isUpvoted ? 'Remove upvote' : 'Upvote',
      );
    }

    Widget buildDownvoteButton() {
      final isDownvoted = userVoteType == -1;
      
      return IconButton(
        icon: Icon(
          isDownvoted ? Icons.arrow_downward : Icons.arrow_downward_outlined,
          size: iconSize,
        ),
        color: isDownvoted ? AppColors.error : null,
        onPressed: isLoading
            ? null
            : () => _handleVote(context, isDownvoted ? 0 : -1),
        splashRadius: iconSize * 0.8,
        tooltip: isDownvoted ? 'Remove downvote' : 'Downvote',
      );
    }

    if (isVertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildUpvoteButton(),
          if (showCount) buildVoteCount(),
          buildDownvoteButton(),
        ],
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildDownvoteButton(),
          if (showCount) buildVoteCount(),
          buildUpvoteButton(),
        ],
      );
    }
  }

  void _handleVote(BuildContext context, int voteType) {
    final voteProvider = Provider.of<VoteProvider>(context, listen: false);
    final currentVoteType = voteProvider.getVoteTypeFor(targetType, targetId);
    
    if (currentVoteType == voteType) {
      // Remove vote if clicking on the same button
      voteProvider.deleteVote(targetType, targetId);
    } else if (voteType == 0) {
      // Remove vote if voteType is 0
      voteProvider.deleteVote(targetType, targetId);
    } else {
      // Add/update vote
      voteProvider.vote(targetType, targetId, voteType);
    }
  }
}
