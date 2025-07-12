import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stackit_frontend/config/theme.dart';
import 'package:stackit_frontend/core/utils/date_utils.dart' as date_utils;
import 'package:stackit_frontend/core/utils/helpers.dart';
import 'package:stackit_frontend/data/models/answer_model.dart';
import 'package:stackit_frontend/presentation/providers/answer_provider.dart';
import 'package:stackit_frontend/presentation/providers/auth_provider.dart';
import 'package:stackit_frontend/presentation/providers/question_provider.dart';
import 'package:stackit_frontend/presentation/providers/vote_provider.dart';
import 'package:stackit_frontend/presentation/routes/app_routes.dart';
import 'package:stackit_frontend/presentation/widgets/answer/answer_form.dart';
import 'package:stackit_frontend/presentation/widgets/answer/answer_list.dart';
import 'package:stackit_frontend/presentation/widgets/answer/vote_widget.dart';
import 'package:stackit_frontend/presentation/widgets/common/loading_widget.dart';

class QuestionDetailScreen extends StatefulWidget {
  const QuestionDetailScreen({super.key});

  @override
  State<QuestionDetailScreen> createState() => _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends State<QuestionDetailScreen> {
  bool _isAddingAnswer = false;
  bool _isEditingAnswer = false;
  Answer? _editingAnswer;

  @override
  void initState() {
    super.initState();
    // Load the question data if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final questionProvider = Provider.of<QuestionProvider>(context, listen: false);
      final question = questionProvider.selectedQuestion;
      
      if (question == null) {
        // If no question is selected, go back
        Navigator.pop(context);
      } else {
        // Load votes for the question
        Provider.of<VoteProvider>(context, listen: false).fetchUserVotes();
      }
    });
  }

  void _toggleAddAnswer() {
    setState(() {
      _isAddingAnswer = !_isAddingAnswer;
      _isEditingAnswer = false;
      _editingAnswer = null;
    });
  }

  void _startEditAnswer(Answer answer) {
    setState(() {
      _isEditingAnswer = true;
      _isAddingAnswer = false;
      _editingAnswer = answer;
    });
  }

  void _cancelEditAnswer() {
    setState(() {
      _isEditingAnswer = false;
      _editingAnswer = null;
    });
  }

  Future<void> _acceptAnswer(int answerId) async {
    final answerProvider = Provider.of<AnswerProvider>(context, listen: false);
    await answerProvider.acceptAnswer(answerId);
    
    if (!mounted) return;
    if (answerProvider.status == AnswerStatus.success) {
      Helpers.showSnackBar(context, 'Answer has been accepted');
    } else if (answerProvider.status == AnswerStatus.error) {
      Helpers.showSnackBar(
        context, 
        answerProvider.errorMessage, 
        isError: true,
      );
    }
  }

  Future<void> _deleteAnswer(int answerId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Answer'),
        content: const Text('Are you sure you want to delete this answer?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!mounted) return;
      final answerProvider = Provider.of<AnswerProvider>(context, listen: false);
      await answerProvider.deleteAnswer(answerId);
      
      if (!mounted) return;
      
      if (answerProvider.status == AnswerStatus.success) {
        Helpers.showSnackBar(context, 'Answer has been deleted');
      } else if (answerProvider.status == AnswerStatus.error) {
        Helpers.showSnackBar(
          context, 
          answerProvider.errorMessage, 
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuestionProvider>(
      builder: (context, questionProvider, child) {
        final question = questionProvider.selectedQuestion;
        
        if (question == null) {
          return const Scaffold(
            body: Center(child: LoadingWidget()),
          );
        }
        
        final authProvider = Provider.of<AuthProvider>(context);
        final isQuestionAuthor = authProvider.user?.id == question.userId;
        final isAuthenticated = authProvider.isAuthenticated;
        
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Question',
              style: AppTextStyles.h2.copyWith(fontSize: 18),
            ),
            actions: [
              if (isAuthenticated && isQuestionAuthor)
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () {
                    // Navigate to edit question screen
                    Navigator.pushNamed(context, AppRoutes.askQuestion, arguments: question);
                  },
                  tooltip: 'Edit Question',
                ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQuestionHeader(question),
                  const Divider(height: 32),
                  _buildAnswerSection(question),
                  const SizedBox(height: 16),
                  if (!_isAddingAnswer && !_isEditingAnswer && isAuthenticated)
                    _buildAddAnswerButton(),
                  if (_isAddingAnswer)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: AnswerForm(
                        questionId: question.id,
                        onSuccess: _toggleAddAnswer,
                      ),
                    ),
                  if (_isEditingAnswer && _editingAnswer != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: AnswerForm(
                        questionId: question.id,
                        initialContent: _editingAnswer!.content,
                        isEditing: true,
                        answerId: _editingAnswer!.id,
                        onSuccess: _cancelEditAnswer,
                      ),
                    ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuestionHeader(question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.title,
          style: AppTextStyles.h1,
        ),
        const SizedBox(height: 16),
        _buildQuestionMeta(question),
        const SizedBox(height: 16),
        _buildQuestionContent(question),
        const SizedBox(height: 16),
        _buildQuestionTags(question),
      ],
    );
  }

  Widget _buildQuestionMeta(question) {
    final authorName = question.author?.username ?? 'Anonymous';
    final authorAvatar = question.author?.avatarUrl;
    
    return Row(
      children: [
        if (authorAvatar != null) ...[
          CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage(authorAvatar),
          ),
        ] else ...[
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary,
            child: Text(
              Helpers.getInitials(authorName),
              style: const TextStyle(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              authorName,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(
              'Asked ${date_utils.DateUtils.formatTimeAgo(question.createdAt)}',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        const Spacer(),
        Row(
          children: [
            const Icon(Icons.visibility_outlined, size: 16),
            const SizedBox(width: 4),
            Text(
              Helpers.formatNumber(question.viewCount),
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.question_answer_outlined, size: 16),
            const SizedBox(width: 4),
            Text(
              Helpers.formatNumber(question.answerCount),
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuestionContent(question) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VoteWidget(
          targetType: 'question',
          targetId: question.id,
          voteCount: question.voteCount,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            question.description,
            style: AppTextStyles.body1,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionTags(question) {
    final tags = question.tags ?? [];
    
    if (tags.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            tag.name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAnswerSection(question) {
    return AnswerList(
      question: question,
      onAcceptAnswer: (answerId) => _acceptAnswer(answerId),
      onEditAnswer: (answer) => _startEditAnswer(answer),
      onDeleteAnswer: (answerId) => _deleteAnswer(answerId),
    );
  }

  Widget _buildAddAnswerButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: _toggleAddAnswer,
        icon: const Icon(Icons.add),
        label: const Text('Add Your Answer'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }
}

