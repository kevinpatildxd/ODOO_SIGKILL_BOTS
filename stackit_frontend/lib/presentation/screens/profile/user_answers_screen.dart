import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stackit_frontend/data/models/answer_model.dart';
import 'package:stackit_frontend/presentation/providers/auth_provider.dart';
import 'package:stackit_frontend/presentation/providers/answer_provider.dart';
import 'package:stackit_frontend/presentation/widgets/common/loading_widget.dart';
import 'package:stackit_frontend/presentation/widgets/common/error_widget.dart' as app_error;
import 'package:stackit_frontend/presentation/widgets/common/empty_state_widget.dart';
import 'package:stackit_frontend/presentation/widgets/answer/answer_card.dart';

class UserAnswersScreen extends StatefulWidget {
  const UserAnswersScreen({super.key});

  @override
  State<UserAnswersScreen> createState() => _UserAnswersScreenState();
}

class _UserAnswersScreenState extends State<UserAnswersScreen> {
  late ScrollController _scrollController;
  List<Answer> _userAnswers = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  int _currentPage = 1;
  bool _hasMorePages = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchUserAnswers();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMorePages) {
      _loadMoreAnswers();
    }
  }

  Future<void> _fetchUserAnswers() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final answerProvider = Provider.of<AnswerProvider>(context, listen: false);
      
      if (authProvider.user == null) {
        setState(() {
          _hasError = true;
          _errorMessage = 'User is not authenticated';
          _isLoading = false;
        });
        return;
      }

      final userId = authProvider.user!.id;
      final answers = await answerProvider.getUserAnswers(userId, page: 1);
      
      setState(() {
        _userAnswers = answers.items;
        _hasMorePages = answers.hasNext;
        _currentPage = 1;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreAnswers() async {
    if (_isLoading || !_hasMorePages) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final answerProvider = Provider.of<AnswerProvider>(context, listen: false);
      
      if (authProvider.user == null) return;

      final userId = authProvider.user!.id;
      final nextPage = _currentPage + 1;
      final answers = await answerProvider.getUserAnswers(userId, page: nextPage);
      
      setState(() {
        _userAnswers.addAll(answers.items);
        _hasMorePages = answers.hasNext;
        _currentPage = nextPage;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Answers'),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchUserAnswers,
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading && _userAnswers.isEmpty) {
      return const Center(
        child: LoadingWidget(),
      );
    }

    if (_hasError) {
      return Center(
        child: app_error.ErrorWidget(
          message: _errorMessage,
          onRetry: _fetchUserAnswers,
        ),
      );
    }

    if (_userAnswers.isEmpty) {
      return const Center(
        child: EmptyStateWidget(
          icon: Icons.comment,
          message: "You haven't answered any questions yet",
          subMessage: "Answers you provide will appear here",
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _userAnswers.length + (_isLoading && _hasMorePages ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _userAnswers.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        final answer = _userAnswers[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: AnswerCard(
            answer: answer,
            showQuestionTitle: true,
            onTap: () {
              Navigator.pushNamed(
                context,
                '/question-detail',
                arguments: answer.questionId,
              );
            },
          ),
        );
      },
    );
  }
}
