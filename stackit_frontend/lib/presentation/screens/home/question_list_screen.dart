import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stackit_frontend/config/theme.dart';
import 'package:stackit_frontend/data/models/question_model.dart';
import 'package:stackit_frontend/presentation/providers/question_provider.dart';
import 'package:stackit_frontend/presentation/routes/app_routes.dart';
import 'package:stackit_frontend/presentation/widgets/question/question_card.dart';
import 'package:stackit_frontend/presentation/widgets/common/loading_widget.dart';
import 'package:stackit_frontend/presentation/widgets/common/error_widget.dart';
import 'package:stackit_frontend/presentation/widgets/common/empty_state_widget.dart';

class QuestionListScreen extends StatefulWidget {
  const QuestionListScreen({super.key});

  @override
  State<QuestionListScreen> createState() => _QuestionListScreenState();
}

class _QuestionListScreenState extends State<QuestionListScreen> {
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    _loadQuestions();
    
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= 
          _scrollController.position.maxScrollExtent - 200) {
        _loadMoreQuestions();
      }
    });
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  Future<void> _loadQuestions() async {
    await Provider.of<QuestionProvider>(context, listen: false).getQuestions(refresh: true);
  }
  
  Future<void> _loadMoreQuestions() async {
    final questionProvider = Provider.of<QuestionProvider>(context, listen: false);
    if (!questionProvider.isLoading && questionProvider.hasMore) {
      await questionProvider.getQuestions();
    }
  }
  
  Future<void> _onRefresh() async {
    await _loadQuestions();
  }
  
  void _navigateToQuestionDetail(Question question) {
    final questionProvider = Provider.of<QuestionProvider>(context, listen: false);
    questionProvider.selectQuestion(question);
    Navigator.pushNamed(context, AppRoutes.questionDetail);
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<QuestionProvider>(
      builder: (context, questionProvider, child) {
        if (questionProvider.status == QuestionStatus.initial) {
          return const Center(child: LoadingWidget());
        }
        
        if (questionProvider.status == QuestionStatus.error) {
          return CustomErrorWidget(
            message: questionProvider.errorMessage,
            onRetry: _loadQuestions,
          );
        }
        
        final questions = questionProvider.questions;
        
        if (questions.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.question_answer_outlined,
            title: 'No Questions Found',
            message: 'Be the first to ask a question',
          );
        }
        
        return RefreshIndicator(
          onRefresh: _onRefresh,
          child: ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: questions.length + (questionProvider.hasMore ? 1 : 0),
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              if (index == questions.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              
              return QuestionCard(
                question: questions[index],
                onTap: () => _navigateToQuestionDetail(questions[index]),
              );
            },
          ),
        );
      },
    );
  }
}
