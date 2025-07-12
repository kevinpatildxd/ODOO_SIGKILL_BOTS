import 'package:flutter/foundation.dart';
import 'package:stackit_frontend/core/network/network_exceptions.dart';
import 'package:stackit_frontend/data/models/paginated_response.dart';
import 'package:stackit_frontend/data/models/question_model.dart';
import 'package:stackit_frontend/data/repositories/question_repository.dart';

enum QuestionStatus { initial, loading, success, error }

class QuestionProvider extends ChangeNotifier {
  final QuestionRepository _repository;
  
  QuestionStatus _status = QuestionStatus.initial;
  List<Question> _questions = [];
  Question? _selectedQuestion;
  String _errorMessage = '';
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMore = true;
  String? _searchQuery;
  List<String>? _selectedTags;
  
  QuestionProvider(this._repository);
  
  // Getters
  QuestionStatus get status => _status;
  List<Question> get questions => _questions;
  Question? get selectedQuestion => _selectedQuestion;
  String get errorMessage => _errorMessage;
  bool get isLoading => _status == QuestionStatus.loading;
  bool get hasMore => _hasMore;
  int get currentPage => _currentPage;
  
  // Methods
  Future<void> getQuestions({
    bool refresh = false,
    String? search,
    List<String>? tags,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _questions = [];
      _hasMore = true;
      _searchQuery = search;
      _selectedTags = tags;
    }
    
    if (_status == QuestionStatus.loading || !_hasMore) {
      return;
    }
    
    _status = QuestionStatus.loading;
    _errorMessage = '';
    notifyListeners();
    
    try {
      final result = await _repository.getQuestions(
        page: _currentPage,
        limit: 10,
        search: _searchQuery,
        tags: _selectedTags,
      );
      
      if (refresh) {
        _questions = result.data;
      } else {
        _questions.addAll(result.data);
      }
      
      _totalPages = result.totalPages;
      _hasMore = _currentPage < _totalPages;
      _currentPage++;
      _status = QuestionStatus.success;
    } catch (e) {
      _status = QuestionStatus.error;
      _errorMessage = e is NetworkException 
          ? e.message 
          : 'Failed to fetch questions. Please try again.';
    }
    
    notifyListeners();
  }
  
  Future<void> getQuestionById(int id) async {
    _status = QuestionStatus.loading;
    _errorMessage = '';
    notifyListeners();
    
    try {
      final question = await _repository.getQuestionById(id);
      _selectedQuestion = question;
      _status = QuestionStatus.success;
    } catch (e) {
      _status = QuestionStatus.error;
      _errorMessage = e is NetworkException 
          ? e.message 
          : 'Failed to fetch question details. Please try again.';
    }
    
    notifyListeners();
  }
  
  Future<void> createQuestion(String title, String description, List<String> tags) async {
    _status = QuestionStatus.loading;
    _errorMessage = '';
    notifyListeners();
    
    try {
      final newQuestion = await _repository.createQuestion(title, description, tags);
      _questions.insert(0, newQuestion);
      _status = QuestionStatus.success;
    } catch (e) {
      _status = QuestionStatus.error;
      _errorMessage = e is NetworkException 
          ? e.message 
          : 'Failed to create question. Please try again.';
    }
    
    notifyListeners();
  }
  
  Future<void> updateQuestion(int id, String title, String description, List<String> tags) async {
    _status = QuestionStatus.loading;
    _errorMessage = '';
    notifyListeners();
    
    try {
      final updatedQuestion = await _repository.updateQuestion(id, title, description, tags);
      
      // Update in list if present
      final index = _questions.indexWhere((q) => q.id == id);
      if (index != -1) {
        _questions[index] = updatedQuestion;
      }
      
      // Update selected question if it's the same one
      if (_selectedQuestion?.id == id) {
        _selectedQuestion = updatedQuestion;
      }
      
      _status = QuestionStatus.success;
    } catch (e) {
      _status = QuestionStatus.error;
      _errorMessage = e is NetworkException 
          ? e.message 
          : 'Failed to update question. Please try again.';
    }
    
    notifyListeners();
  }
  
  Future<void> deleteQuestion(int id) async {
    _status = QuestionStatus.loading;
    _errorMessage = '';
    notifyListeners();
    
    try {
      await _repository.deleteQuestion(id);
      
      // Remove from list if present
      _questions.removeWhere((q) => q.id == id);
      
      // Clear selected question if it's the same one
      if (_selectedQuestion?.id == id) {
        _selectedQuestion = null;
      }
      
      _status = QuestionStatus.success;
    } catch (e) {
      _status = QuestionStatus.error;
      _errorMessage = e is NetworkException 
          ? e.message 
          : 'Failed to delete question. Please try again.';
    }
    
    notifyListeners();
  }
  
  void clearSelectedQuestion() {
    _selectedQuestion = null;
    notifyListeners();
  }
  
  void clearError() {
    _errorMessage = '';
    if (_status == QuestionStatus.error) {
      _status = QuestionStatus.initial;
    }
    notifyListeners();
  }
}
