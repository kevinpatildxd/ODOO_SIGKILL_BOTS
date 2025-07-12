import 'package:flutter/material.dart';
import 'package:stackit_frontend/config/theme.dart';
import 'package:stackit_frontend/data/models/answer_model.dart';
import 'package:stackit_frontend/core/utils/date_utils.dart' as date_utils;
import 'package:stackit_frontend/presentation/widgets/answer/vote_widget.dart';

class AnswerCard extends StatelessWidget {
  final Answer answer;
  final bool isQuestionAuthor;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onAccept;

  const AnswerCard({
    super.key,
    required this.answer,
    this.isQuestionAuthor = false,
    this.onEdit,
    this.onDelete,
    this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: answer.isAccepted 
            ? BorderSide(color: AppColors.success, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            VoteWidget(
              targetType: 'answer',
              targetId: answer.id,
              voteCount: answer.votes,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (answer.isAccepted)
                    _buildAcceptedBadge(),
                  Text(
                    answer.content,
                    style: AppTextStyles.body1,
                  ),
                  const SizedBox(height: 16),
                  _buildCardFooter(context),
                  if (isQuestionAuthor && !answer.isAccepted)
                    _buildAcceptButton(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAcceptedBadge() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle,
            color: AppColors.success,
            size: 16,
          ),
          const SizedBox(width: 4),
          const Text(
            'Accepted Answer',
            style: TextStyle(
              color: AppColors.success,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardFooter(BuildContext context) {
    final authorName = answer.user?.username ?? 'Anonymous';
    final authorAvatar = answer.user?.avatarUrl;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Spacer(),
        if (onEdit != null && answer.user != null)
          _buildActionButton(
            context,
            icon: Icons.edit_outlined,
            label: 'Edit',
            onPressed: onEdit,
          ),
        if (onDelete != null && answer.user != null)
          _buildActionButton(
            context,
            icon: Icons.delete_outline,
            label: 'Delete',
            onPressed: onDelete,
          ),
        const Spacer(),
        Text(
          'answered ${date_utils.DateUtils.formatTimeAgo(answer.createdAt)}',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(width: 8),
        if (authorAvatar != null) ...[
          CircleAvatar(
            radius: 12,
            backgroundImage: NetworkImage(authorAvatar),
          ),
        ] else ...[
          CircleAvatar(
            radius: 12,
            backgroundColor: AppColors.primary,
            child: Text(
              authorName.isNotEmpty ? authorName[0].toUpperCase() : '?',
              style: const TextStyle(
                color: AppColors.onPrimary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        const SizedBox(width: 4),
        Text(
          authorName,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        textStyle: const TextStyle(fontSize: 12),
        minimumSize: const Size(0, 28),
      ),
    );
  }

  Widget _buildAcceptButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: ElevatedButton.icon(
          onPressed: onAccept,
          icon: const Icon(Icons.check_circle_outline, size: 16),
          label: const Text('Accept Answer'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success,
            foregroundColor: AppColors.onPrimary,
            textStyle: const TextStyle(fontSize: 12),
            minimumSize: const Size(0, 32),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
      ),
    );
  }
}
