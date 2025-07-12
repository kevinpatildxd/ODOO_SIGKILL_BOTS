import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:stackit_frontend/core/network/network_exceptions.dart';
import 'package:stackit_frontend/data/models/question_model.dart';
import 'package:stackit_frontend/data/repositories/question_repository.dart';
import 'package:stackit_frontend/core/services/socket_service.dart';

enum QuestionStatus { initial, loading, success, error }

class QuestionProvider extends ChangeNotifier {
  final QuestionRepository _repository;
  final SocketService _socketService = SocketService();
  
  QuestionStatus _status = QuestionStatus.initial;
  List<Question> _questions = [];
  Question? _selectedQuestion;
  String _errorMessage = '';
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMore = true;
  String? _searchQuery;
  List<String>? _selectedTags;
  
  // Stream subscription for socket events
  StreamSubscription? _questionStreamSubscription;
  
  QuestionProvider(this._repository) {
    // Listen to real-time question updates
    _setupSocketListeners();
  }
  
  // Setup socket event listeners
  void _setupSocketListeners() {
    _questionStreamSubscription = _socketService.questionStream.listen(_handleQuestionEvent);
  }
  
  // Handle incoming question events
  void _handleQuestionEvent(Map<String, dynamic> event) {
    final eventType = event['type'];
    final eventData = event['data'];
    
    if (kDebugMode) {
      print('Received question event: $eventType');
    }
    
    switch (eventType) {
      case 'new':
        _handleNewQuestion(Question.fromJson(eventData));
        break;
      case 'update':
        _handleQuestionUpdate(Question.fromJson(eventData));
        break;
      case 'vote':
        _handleQuestionVoteUpdate(eventData);
        break;
      case 'delete':
        _handleQuestionDelete(eventData['id']);
        break;
      default:
        if (kDebugMode) {
          print('Unknown question event type: $eventType');
        }
    }
  }
  
  // Handle a new question event
  void _handleNewQuestion(Question question) {
    // Only add to list if not already present
    if (!_questions.any((q) => q.id == question.id)) {
      _questions.insert(0, question);
      notifyListeners();
    }
  }
  
  // Handle a question update event
  void _handleQuestionUpdate(Question updatedQuestion) {
    // Update in list if present
    final index = _questions.indexWhere((q) => q.id == updatedQuestion.id);
    if (index != -1) {
      _questions[index] = updatedQuestion;
    }
    
    // Update selected question if it's the same one
    if (_selectedQuestion?.id == updatedQuestion.id) {
      _selectedQuestion = updatedQuestion;
    }
    
    notifyListeners();
  }
  
  // Handle a question vote update event
  void _handleQuestionVoteUpdate(Map<String, dynamic> voteData) {
    final questionId = voteData['questionId'];
    final newVoteCount = voteData['voteCount'];
    
    // Update in list if present
    final index = _questions.indexWhere((q) => q.id == questionId);
    if (index != -1) {
      _questions[index] = _questions[index].copyWith(voteCount: newVoteCount);
    }
    
    // Update selected question if it's the same one
    if (_selectedQuestion?.id == questionId) {
      _selectedQuestion = _selectedQuestion!.copyWith(voteCount: newVoteCount);
    }
    
    notifyListeners();
  }
  
  // Handle a question delete event
  void _handleQuestionDelete(int questionId) {
    // Remove from list if present
    _questions.removeWhere((q) => q.id == questionId);
    
    // Clear selected question if it's the same one
    if (_selectedQuestion?.id == questionId) {
      _selectedQuestion = null;
    }
    
    notifyListeners();
  }
  
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
      
      // Subscribe to real-time updates for this question
      _socketService.joinRoom('question:${question.id}');
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
      
      // Leave the question room
      _socketService.leaveRoom('question:$id');
      
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
  
  // Vote on a question
  Future<void> voteQuestion(int questionId, bool isUpvote) async {
    try {
      // Optimistic update
      final index = _questions.indexWhere((q) => q.id == questionId);
      if (index != -1) {
        final currentVoteCount = _questions[index].voteCount;
        final newVoteCount = isUpvote ? currentVoteCount + 1 : currentVoteCount - 1;
        _questions[index] = _questions[index].copyWith(voteCount: newVoteCount);
      }
      
      if (_selectedQuestion?.id == questionId) {
        final currentVoteCount = _selectedQuestion!.voteCount;
        final newVoteCount = isUpvote ? currentVoteCount + 1 : currentVoteCount - 1;
        _selectedQuestion = _selectedQuestion!.copyWith(voteCount: newVoteCount);
      }
      
      notifyListeners();
      
      // Call API
      await _repository.voteQuestion(questionId, isUpvote);
    } catch (e) {
      // Revert on error
      getQuestionById(questionId);
      _errorMessage = e is NetworkException 
          ? e.message 
          : 'Failed to vote. Please try again.';
      notifyListeners();
    }
  }
  
  // Select a question from the list without making an API call
  void selectQuestion(Question question) {
    // Leave previous question room if exists
    if (_selectedQuestion != null) {
      _socketService.leaveRoom('question:${_selectedQuestion!.id}');
    }
    
    _selectedQuestion = question;
    
    // Join new question room
    _socketService.joinRoom('question:${question.id}');
    
    notifyListeners();
  }
  
  void clearSelectedQuestion() {
    // Leave question room if exists
    if (_selectedQuestion != null) {
      _socketService.leaveRoom('question:${_selectedQuestion!.id}');
    }
    
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
  
  @override
  void dispose() {
    // Clean up subscriptions
    _questionStreamSubscription?.cancel();
    
    // Leave question room if exists
    if (_selectedQuestion != null) {
      _socketService.leaveRoom('question:${_selectedQuestion!.id}');
    }
    
    super.dispose();
  }
}
