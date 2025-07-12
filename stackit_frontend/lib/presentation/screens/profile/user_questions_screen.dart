import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stackit_frontend/data/models/question_model.dart';
import 'package:stackit_frontend/presentation/providers/auth_provider.dart';
import 'package:stackit_frontend/presentation/providers/question_provider.dart';
import 'package:stackit_frontend/presentation/widgets/common/loading_widget.dart';
import 'package:stackit_frontend/presentation/widgets/common/error_widget.dart' as app_error;
import 'package:stackit_frontend/presentation/widgets/common/empty_state_widget.dart';
import 'package:stackit_frontend/presentation/widgets/question/question_card.dart';

class UserQuestionsScreen extends StatefulWidget {
  const UserQuestionsScreen({super.key});

  @override
  State<UserQuestionsScreen> createState() => _UserQuestionsScreenState();
}

class _UserQuestionsScreenState extends State<UserQuestionsScreen> {
  late ScrollController _scrollController;
  List<Question> _userQuestions = [];
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
      _fetchUserQuestions();
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
      _loadMoreQuestions();
    }
  }

  Future<void> _fetchUserQuestions() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final questionProvider = Provider.of<QuestionProvider>(context, listen: false);
      
      if (authProvider.user == null) {
        setState(() {
          _hasError = true;
          _errorMessage = 'User is not authenticated';
          _isLoading = false;
        });
        return;
      }

      final userId = authProvider.user!.id;
      final questions = await questionProvider.getUserQuestions(userId, page: 1);
      
      setState(() {
        _userQuestions = questions.items;
        _hasMorePages = questions.hasNext;
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

  Future<void> _loadMoreQuestions() async {
    if (_isLoading || !_hasMorePages) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final questionProvider = Provider.of<QuestionProvider>(context, listen: false);
      
      if (authProvider.user == null) return;

      final userId = authProvider.user!.id;
      final nextPage = _currentPage + 1;
      final questions = await questionProvider.getUserQuestions(userId, page: nextPage);
      
      setState(() {
        _userQuestions.addAll(questions.items);
        _hasMorePages = questions.hasNext;
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
        title: const Text('My Questions'),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchUserQuestions,
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading && _userQuestions.isEmpty) {
      return const Center(
        child: LoadingWidget(),
      );
    }

    if (_hasError) {
      return Center(
        child: app_error.ErrorWidget(
          message: _errorMessage,
          onRetry: _fetchUserQuestions,
        ),
      );
    }

    if (_userQuestions.isEmpty) {
      return const Center(
        child: EmptyStateWidget(
          icon: Icons.question_answer,
          title: "You haven't asked any questions yet",
          message: "Questions you ask will appear here",
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _userQuestions.length + (_isLoading && _hasMorePages ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _userQuestions.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        final question = _userQuestions[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: QuestionCard(
            question: question,
            onTap: () {
              Navigator.pushNamed(
                context,
                '/question-detail',
                arguments: question.id,
              );
            },
          ),
        );
      },
    );
  }
}
