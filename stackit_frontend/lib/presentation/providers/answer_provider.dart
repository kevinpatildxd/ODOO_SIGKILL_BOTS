import 'package:flutter/foundation.dart';
import 'package:stackit_frontend/core/network/network_exceptions.dart';
import 'package:stackit_frontend/data/models/answer_model.dart';
import 'package:stackit_frontend/data/models/paginated_response.dart';
import 'package:stackit_frontend/data/repositories/answer_repository.dart';

enum AnswerStatus { initial, loading, success, error }

class AnswerProvider extends ChangeNotifier {
  final AnswerRepository _repository;
  
  AnswerStatus _status = AnswerStatus.initial;
  List<Answer> _answers = [];
  String _errorMessage = '';
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMore = true;
  int? _currentQuestionId;
  
  AnswerProvider(this._repository);
  
  // Getters
  AnswerStatus get status => _status;
  List<Answer> get answers => _answers;
  String get errorMessage => _errorMessage;
  bool get isLoading => _status == AnswerStatus.loading;
  bool get hasMore => _hasMore;
  int get currentPage => _currentPage;
  
  // Methods
  Future<void> getAnswers(int questionId, {bool refresh = false}) async {
    if (refresh || _currentQuestionId != questionId) {
      _currentPage = 1;
      _answers = [];
      _hasMore = true;
      _currentQuestionId = questionId;
    }
    
    if (_status == AnswerStatus.loading || !_hasMore) {
      return;
    }
    
    _status = AnswerStatus.loading;
    _errorMessage = '';
    notifyListeners();
    
    try {
      final result = await _repository.getAnswersByQuestionId(
        questionId,
        page: _currentPage,
        limit: 10,
      );
      
      if (_currentPage == 1) {
        _answers = result.data;
      } else {
        _answers.addAll(result.data);
      }
      
      _totalPages = result.totalPages;
      _hasMore = _currentPage < _totalPages;
      _currentPage++;
      _status = AnswerStatus.success;
    } catch (e) {
      _status = AnswerStatus.error;
      _errorMessage = e is NetworkException 
          ? e.message 
          : 'Failed to fetch answers. Please try again.';
    }
    
    notifyListeners();
  }
  
  Future<void> createAnswer(int questionId, String content) async {
    _status = AnswerStatus.loading;
    _errorMessage = '';
    notifyListeners();
    
    try {
      final newAnswer = await _repository.createAnswer(questionId, content);
      _answers.insert(0, newAnswer);
      _status = AnswerStatus.success;
    } catch (e) {
      _status = AnswerStatus.error;
      _errorMessage = e is NetworkException 
          ? e.message 
          : 'Failed to create answer. Please try again.';
    }
    
    notifyListeners();
  }
  
  Future<void> updateAnswer(int id, String content) async {
    _status = AnswerStatus.loading;
    _errorMessage = '';
    notifyListeners();
    
    try {
      final updatedAnswer = await _repository.updateAnswer(id, content);
      
      // Update in list if present
      final index = _answers.indexWhere((a) => a.id == id);
      if (index != -1) {
        _answers[index] = updatedAnswer;
      }
      
      _status = AnswerStatus.success;
    } catch (e) {
      _status = AnswerStatus.error;
      _errorMessage = e is NetworkException 
          ? e.message 
          : 'Failed to update answer. Please try again.';
    }
    
    notifyListeners();
  }
  
  Future<void> deleteAnswer(int id) async {
    _status = AnswerStatus.loading;
    _errorMessage = '';
    notifyListeners();
    
    try {
      await _repository.deleteAnswer(id);
      
      // Remove from list if present
      _answers.removeWhere((a) => a.id == id);
      
      _status = AnswerStatus.success;
    } catch (e) {
      _status = AnswerStatus.error;
      _errorMessage = e is NetworkException 
          ? e.message 
          : 'Failed to delete answer. Please try again.';
    }
    
    notifyListeners();
  }
  
  Future<void> acceptAnswer(int id) async {
    _status = AnswerStatus.loading;
    _errorMessage = '';
    notifyListeners();
    
    try {
      final acceptedAnswer = await _repository.acceptAnswer(id);
      
      // Update the accepted answer and unaccept any previously accepted answers
      for (int i = 0; i < _answers.length; i++) {
        if (_answers[i].id == id) {
          _answers[i] = acceptedAnswer;
        } else if (_answers[i].isAccepted) {
          // Make a copy of the answer with isAccepted = false
          // This would need a proper copy method in the Answer model
          _answers[i] = Answer(
            id: _answers[i].id,
            questionId: _answers[i].questionId,
            userId: _answers[i].userId,
            content: _answers[i].content,
            isAccepted: false,
            votes: _answers[i].votes,
            createdAt: _answers[i].createdAt,
            updatedAt: _answers[i].updatedAt,
            user: _answers[i].user,
          );
        }
      }
      
      _status = AnswerStatus.success;
    } catch (e) {
      _status = AnswerStatus.error;
      _errorMessage = e is NetworkException 
          ? e.message 
          : 'Failed to accept answer. Please try again.';
    }
    
    notifyListeners();
  }
  
  void clearError() {
    _errorMessage = '';
    if (_status == AnswerStatus.error) {
      _status = AnswerStatus.initial;
    }
    notifyListeners();
  }
  
  void clearAnswers() {
    _answers = [];
    _currentPage = 1;
    _hasMore = true;
    _currentQuestionId = null;
    _status = AnswerStatus.initial;
    notifyListeners();
  }
}
