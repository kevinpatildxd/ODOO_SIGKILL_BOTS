import 'package:flutter/material.dart';
import 'package:stackit_frontend/config/theme.dart';
import 'package:stackit_frontend/data/models/question_model.dart';
import 'package:stackit_frontend/core/utils/date_utils.dart' as date_utils;
import 'package:stackit_frontend/core/utils/helpers.dart';

class QuestionCard extends StatelessWidget {
  final Question question;
  final VoidCallback? onTap;

  const QuestionCard({
    super.key,
    required this.question,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                question.title,
                style: AppTextStyles.h2.copyWith(fontSize: 18),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                question.description,
                style: AppTextStyles.body1,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              _buildTagList(),
              const SizedBox(height: 12),
              _buildCardFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTagList() {
    final tags = question.tags ?? [];
    
    if (tags.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return SizedBox(
      height: 30,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tags.length > 3 ? 3 : tags.length,
        itemBuilder: (context, index) {
          final tag = tags[index];
          
          if (index == 2 && tags.length > 3) {
            return Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '+${tags.length - 2}',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 12,
                ),
              ),
            );
          }
          
          return Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              tag.name,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardFooter(BuildContext context) {
    return Row(
      children: [
        _buildStatItem(
          Icons.thumb_up_outlined,
          Helpers.formatNumber(question.voteCount),
          'votes',
        ),
        const SizedBox(width: 16),
        _buildStatItem(
          Icons.question_answer_outlined,
          Helpers.formatNumber(question.answerCount),
          'answers',
        ),
        const SizedBox(width: 16),
        _buildStatItem(
          Icons.visibility_outlined,
          Helpers.formatNumber(question.viewCount),
          'views',
        ),
        const Spacer(),
        _buildAuthorInfo(),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String count, String label) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.onSurface.withOpacity(0.6),
        ),
        const SizedBox(width: 4),
        Text(
          count,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurface.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildAuthorInfo() {
    final author = question.author;
    final authorName = author?.username ?? 'Anonymous';
    
    return Row(
      children: [
        if (author?.avatarUrl != null) ...[
          CircleAvatar(
            radius: 12,
            backgroundImage: NetworkImage(author!.avatarUrl!),
          ),
        ] else ...[
          CircleAvatar(
            radius: 12,
            backgroundColor: AppColors.primary,
            child: Text(
              Helpers.getInitials(authorName),
              style: const TextStyle(
                color: AppColors.onPrimary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              authorName,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            Text(
              date_utils.DateUtils.formatTimeAgo(question.createdAt),
              style: TextStyle(
                fontSize: 10,
                color: AppColors.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
