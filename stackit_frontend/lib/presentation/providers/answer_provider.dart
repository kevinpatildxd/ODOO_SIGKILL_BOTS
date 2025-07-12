import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:stackit_frontend/core/network/network_exceptions.dart';
import 'package:stackit_frontend/data/models/answer_model.dart';
import 'package:stackit_frontend/data/repositories/answer_repository.dart';
import 'package:stackit_frontend/data/models/paginated_response.dart';
import 'package:stackit_frontend/core/services/socket_service.dart';

enum AnswerStatus { initial, loading, success, error }

class AnswerProvider extends ChangeNotifier {
  final AnswerRepository _repository;
  final SocketService _socketService = SocketService();
  
  AnswerStatus _status = AnswerStatus.initial;
  List<Answer> _answers = [];
  String _errorMessage = '';
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMore = true;
  int? _currentQuestionId;
  
  // Stream subscription for socket events
  StreamSubscription? _answerStreamSubscription;
  
  AnswerProvider(this._repository) {
    // Listen to real-time answer updates
    _setupSocketListeners();
  }
  
  // Setup socket event listeners
  void _setupSocketListeners() {
    _answerStreamSubscription = _socketService.answerStream.listen(_handleAnswerEvent);
  }
  
  // Handle incoming answer events
  void _handleAnswerEvent(Map<String, dynamic> event) {
    final eventType = event['type'];
    final eventData = event['data'];
    
    if (kDebugMode) {
      print('Received answer event: $eventType');
    }
    
    switch (eventType) {
      case 'new':
        _handleNewAnswer(Answer.fromJson(eventData));
        break;
      case 'update':
        _handleAnswerUpdate(Answer.fromJson(eventData));
        break;
      case 'vote':
        _handleAnswerVoteUpdate(eventData);
        break;
      case 'accept':
        _handleAnswerAccept(Answer.fromJson(eventData));
        break;
      case 'delete':
        _handleAnswerDelete(eventData['id']);
        break;
      default:
        if (kDebugMode) {
          print('Unknown answer event type: $eventType');
        }
    }
  }
  
  // Handle a new answer event
  void _handleNewAnswer(Answer answer) {
    // Only add if related to current question and not already in list
    if (_currentQuestionId == answer.questionId && 
        !_answers.any((a) => a.id == answer.id)) {
      _answers.insert(0, answer);
      notifyListeners();
    }
  }
  
  // Handle an answer update event
  void _handleAnswerUpdate(Answer updatedAnswer) {
    // Only update if related to current question
    if (_currentQuestionId == updatedAnswer.questionId) {
      final index = _answers.indexWhere((a) => a.id == updatedAnswer.id);
      if (index != -1) {
        _answers[index] = updatedAnswer;
        notifyListeners();
      }
    }
  }
  
  // Handle an answer vote update event
  void _handleAnswerVoteUpdate(Map<String, dynamic> voteData) {
    final answerId = voteData['answerId'];
    final newVoteCount = voteData['voteCount'];
    
    final index = _answers.indexWhere((a) => a.id == answerId);
    if (index != -1) {
      _answers[index] = _answers[index].copyWith(votes: newVoteCount);
      notifyListeners();
    }
  }
  
  // Handle an answer accept event
  void _handleAnswerAccept(Answer acceptedAnswer) {
    // Only update if related to current question
    if (_currentQuestionId == acceptedAnswer.questionId) {
      // Update the accepted answer and unaccept any previously accepted answers
      bool updated = false;
      for (int i = 0; i < _answers.length; i++) {
        if (_answers[i].id == acceptedAnswer.id) {
          _answers[i] = acceptedAnswer;
          updated = true;
        } else if (_answers[i].isAccepted) {
          _answers[i] = _answers[i].copyWith(isAccepted: false);
          updated = true;
        }
      }
      
      if (updated) {
        notifyListeners();
      }
    }
  }
  
  // Handle an answer delete event
  void _handleAnswerDelete(int answerId) {
    final index = _answers.indexWhere((a) => a.id == answerId);
    if (index != -1) {
      _answers.removeAt(index);
      notifyListeners();
    }
  }
  
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
      
      // If we're changing questions, leave old room and join new one
      if (_currentQuestionId != null && _currentQuestionId != questionId) {
        _socketService.leaveRoom('question:$_currentQuestionId');
      }
      
      _currentQuestionId = questionId;
      
      // Join the room for this question's answers
      _socketService.joinRoom('question:$questionId');
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
      
      // Optimistic update - we'll add it to the UI immediately
      // The socket event will update other users' views
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
          _answers[i] = _answers[i].copyWith(isAccepted: false);
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
  
  // Vote on an answer
  Future<void> voteAnswer(int answerId, bool isUpvote) async {
    try {
      // Optimistic update
      final index = _answers.indexWhere((a) => a.id == answerId);
      if (index != -1) {
        final currentVotes = _answers[index].votes;
        final newVotes = isUpvote ? currentVotes + 1 : currentVotes - 1;
        _answers[index] = _answers[index].copyWith(votes: newVotes);
        notifyListeners();
      }
      
      // Call API
      await _repository.voteAnswer(answerId, isUpvote);
    } catch (e) {
      // Refresh to get the correct state
      if (_currentQuestionId != null) {
        getAnswers(_currentQuestionId!, refresh: true);
      }
      
      _errorMessage = e is NetworkException 
          ? e.message 
          : 'Failed to vote. Please try again.';
      notifyListeners();
    }
  }

  Future<PaginatedResponse<Answer>> getUserAnswers(int userId, {int page = 1, int limit = 10}) async {
    try {
      return await _repository.getAnswersByUserId(userId, page: page, limit: limit);
    } catch (e) {
      throw NetworkException(message: e.toString());
    }
  }
  
  void clearError() {
    _errorMessage = '';
    if (_status == AnswerStatus.error) {
      _status = AnswerStatus.initial;
    }
    notifyListeners();
  }
  
  void clearAnswers() {
    // Leave the question room if we have one
    if (_currentQuestionId != null) {
      _socketService.leaveRoom('question:$_currentQuestionId');
    }
    
    _answers = [];
    _currentPage = 1;
    _hasMore = true;
    _currentQuestionId = null;
    _status = AnswerStatus.initial;
    notifyListeners();
  }
  
  @override
  void dispose() {
    // Clean up subscriptions
    _answerStreamSubscription?.cancel();
    
    // Leave the question room if we have one
    if (_currentQuestionId != null) {
      _socketService.leaveRoom('question:$_currentQuestionId');
    }
    
    super.dispose();
  }
}
