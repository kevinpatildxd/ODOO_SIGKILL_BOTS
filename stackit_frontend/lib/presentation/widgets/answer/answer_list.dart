import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stackit_frontend/config/theme.dart';
import 'package:stackit_frontend/data/models/answer_model.dart';
import 'package:stackit_frontend/data/models/question_model.dart';
import 'package:stackit_frontend/presentation/providers/answer_provider.dart';
import 'package:stackit_frontend/presentation/widgets/answer/answer_card.dart';
import 'package:stackit_frontend/presentation/widgets/common/empty_state_widget.dart';
import 'package:stackit_frontend/presentation/widgets/common/loading_widget.dart';
import 'package:stackit_frontend/presentation/widgets/common/error_widget.dart';

class AnswerList extends StatefulWidget {
  final Question question;
  final Function(int answerId)? onAcceptAnswer;
  final Function(Answer answer)? onEditAnswer;
  final Function(int answerId)? onDeleteAnswer;

  const AnswerList({
    super.key,
    required this.question,
    this.onAcceptAnswer,
    this.onEditAnswer,
    this.onDeleteAnswer,
  });

  @override
  State<AnswerList> createState() => _AnswerListState();
}

class _AnswerListState extends State<AnswerList> {
  String _sortOption = 'votes'; // Default sort option

  @override
  void initState() {
    super.initState();
    _loadAnswers();
  }

  Future<void> _loadAnswers() async {
    final answerProvider = Provider.of<AnswerProvider>(context, listen: false);
    await answerProvider.getAnswers(widget.question.id, refresh: true);
  }

  List<Answer> _getSortedAnswers(List<Answer> answers) {
    // First sort by accepted status
    final sortedAnswers = List<Answer>.from(answers);
    
    // Always put accepted answer first
    sortedAnswers.sort((a, b) {
      if (a.isAccepted && !b.isAccepted) return -1;
      if (!a.isAccepted && b.isAccepted) return 1;
      
      // Then sort by the selected option
      switch (_sortOption) {
        case 'votes':
          return b.votes.compareTo(a.votes);
        case 'newest':
          return b.createdAt.compareTo(a.createdAt);
        case 'oldest':
          return a.createdAt.compareTo(b.createdAt);
        default:
          return b.votes.compareTo(a.votes);
      }
    });
    
    return sortedAnswers;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AnswerProvider>(
      builder: (context, provider, child) {
        if (provider.status == AnswerStatus.loading && provider.answers.isEmpty) {
          return const Center(child: LoadingWidget());
        }
        
        if (provider.status == AnswerStatus.error) {
          return CustomErrorWidget(
            message: provider.errorMessage,
            onRetry: _loadAnswers,
          );
        }

        final answers = _getSortedAnswers(provider.answers);
        
        if (answers.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.question_answer_outlined,
            title: 'No Answers Yet',
            message: 'Be the first to answer this question',
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAnswerHeader(answers.length),
            const SizedBox(height: 8),
            _buildSortOptions(),
            const SizedBox(height: 16),
            ...List.generate(answers.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: AnswerCard(
                  answer: answers[index],
                  isQuestionAuthor: widget.question.author?.id == answers[index].userId,
                  onAccept: widget.onAcceptAnswer != null 
                      ? () => widget.onAcceptAnswer!(answers[index].id) 
                      : null,
                  onEdit: widget.onEditAnswer != null 
                      ? () => widget.onEditAnswer!(answers[index])
                      : null,
                  onDelete: widget.onDeleteAnswer != null 
                      ? () => widget.onDeleteAnswer!(answers[index].id)
                      : null,
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildAnswerHeader(int count) {
    return Text(
      '$count ${count == 1 ? 'Answer' : 'Answers'}',
      style: AppTextStyles.h2,
    );
  }

  Widget _buildSortOptions() {
    return Row(
      children: [
        const Text(
          'Sort by:',
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text('Votes'),
          selected: _sortOption == 'votes',
          onSelected: (selected) {
            if (selected) {
              setState(() => _sortOption = 'votes');
            }
          },
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text('Newest'),
          selected: _sortOption == 'newest',
          onSelected: (selected) {
            if (selected) {
              setState(() => _sortOption = 'newest');
            }
          },
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text('Oldest'),
          selected: _sortOption == 'oldest',
          onSelected: (selected) {
            if (selected) {
              setState(() => _sortOption = 'oldest');
            }
          },
        ),
      ],
    );
  }
}
