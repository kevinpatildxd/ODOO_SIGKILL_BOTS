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

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSearching = false;
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreResults();
    }
  }
  
  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      setState(() {
        _isSearching = true;
      });
      
      await Provider.of<QuestionProvider>(context, listen: false)
          .getQuestions(refresh: true, search: query);
      
      setState(() {
        _isSearching = false;
      });
    }
  }
  
  Future<void> _loadMoreResults() async {
    final questionProvider = Provider.of<QuestionProvider>(context, listen: false);
    if (!questionProvider.isLoading && questionProvider.hasMore) {
      await questionProvider.getQuestions();
    }
  }
  
  void _navigateToQuestionDetail(Question question) {
    final questionProvider = Provider.of<QuestionProvider>(context, listen: false);
    questionProvider.selectQuestion(question);
    Navigator.pushNamed(context, AppRoutes.questionDetail);
  }
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSearchBar(),
          const SizedBox(height: 16),
          Expanded(
            child: Consumer<QuestionProvider>(
              builder: (context, provider, child) {
                final questions = provider.questions;
                
                if (_isSearching) {
                  return const LoadingWidget(message: 'Searching...');
                }
                
                if (provider.status == QuestionStatus.error) {
                  return CustomErrorWidget(
                    message: provider.errorMessage,
                    onRetry: _search,
                  );
                }
                
                if (questions.isEmpty && _searchController.text.isNotEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.search_off_rounded,
                    title: 'No Results Found',
                    message: 'Try different keywords or filters',
                  );
                }
                
                if (questions.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.search_rounded,
                    title: 'Search Questions',
                    message: 'Enter keywords to find questions',
                  );
                }
                
                return ListView.separated(
                  controller: _scrollController,
                  itemCount: questions.length + (provider.hasMore ? 1 : 0),
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search questions...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    Provider.of<QuestionProvider>(context, listen: false)
                        .getQuestions(refresh: true);
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => _search(),
        onChanged: (value) {
          setState(() {});
        },
      ),
    );
  }
} 