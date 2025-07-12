import 'package:flutter/foundation.dart';
import 'package:stackit_frontend/core/network/network_exceptions.dart';
import 'package:stackit_frontend/data/models/vote_model.dart';
import 'package:stackit_frontend/data/repositories/vote_repository.dart';

enum VoteStatus { initial, loading, success, error }

class VoteProvider extends ChangeNotifier {
  final VoteRepository _repository;
  
  VoteStatus _status = VoteStatus.initial;
  List<Vote> _userVotes = [];
  String _errorMessage = '';
  
  // Map to track votes by target type and id
  final Map<String, Map<int, Vote>> _votesByTarget = {
    'question': {},
    'answer': {}
  };
  
  VoteProvider(this._repository);
  
  // Getters
  VoteStatus get status => _status;
  List<Vote> get userVotes => _userVotes;
  String get errorMessage => _errorMessage;
  bool get isLoading => _status == VoteStatus.loading;
  
  // Get vote for a specific target
  Vote? getVoteForTarget(String targetType, int targetId) {
    if (_votesByTarget.containsKey(targetType) && 
        _votesByTarget[targetType]!.containsKey(targetId)) {
      return _votesByTarget[targetType]![targetId];
    }
    return null;
  }
  
  // Check if user has voted on a target
  bool hasVotedOn(String targetType, int targetId) {
    return getVoteForTarget(targetType, targetId) != null;
  }
  
  // Get vote type for a target (1 for upvote, -1 for downvote, null if not voted)
  int? getVoteTypeFor(String targetType, int targetId) {
    final vote = getVoteForTarget(targetType, targetId);
    return vote?.voteType;
  }
  
  // Methods
  Future<void> vote(String targetType, int targetId, int voteType) async {
    _status = VoteStatus.loading;
    _errorMessage = '';
    notifyListeners();
    
    try {
      final vote = await _repository.vote(targetType, targetId, voteType);
      
      // Update vote map
      if (!_votesByTarget.containsKey(targetType)) {
        _votesByTarget[targetType] = {};
      }
      _votesByTarget[targetType]![targetId] = vote;
      
      // Update user votes list
      _updateUserVotesList(vote);
      
      _status = VoteStatus.success;
    } catch (e) {
      _status = VoteStatus.error;
      _errorMessage = e is NetworkException 
          ? e.message 
          : 'Failed to process vote. Please try again.';
    }
    
    notifyListeners();
  }
  
  Future<void> deleteVote(String targetType, int targetId) async {
    final vote = getVoteForTarget(targetType, targetId);
    if (vote == null) {
      return;
    }
    
    _status = VoteStatus.loading;
    _errorMessage = '';
    notifyListeners();
    
    try {
      await _repository.deleteVote(vote.id);
      
      // Remove from vote map
      if (_votesByTarget.containsKey(targetType)) {
        _votesByTarget[targetType]!.remove(targetId);
      }
      
      // Remove from user votes list
      _userVotes.removeWhere((v) => v.id == vote.id);
      
      _status = VoteStatus.success;
    } catch (e) {
      _status = VoteStatus.error;
      _errorMessage = e is NetworkException 
          ? e.message 
          : 'Failed to remove vote. Please try again.';
    }
    
    notifyListeners();
  }
  
  Future<void> fetchUserVotes() async {
    _status = VoteStatus.loading;
    _errorMessage = '';
    notifyListeners();
    
    try {
      _userVotes = await _repository.getUserVotes();
      
      // Organize votes by target for quick lookup
      _organizeVotesByTarget();
      
      _status = VoteStatus.success;
    } catch (e) {
      _status = VoteStatus.error;
      _errorMessage = e is NetworkException 
          ? e.message 
          : 'Failed to fetch your votes. Please try again.';
    }
    
    notifyListeners();
  }
  
  void _organizeVotesByTarget() {
    // Reset the map
    _votesByTarget.forEach((key, value) => value.clear());
    
    // Fill with user votes
    for (final vote in _userVotes) {
      if (!_votesByTarget.containsKey(vote.targetType)) {
        _votesByTarget[vote.targetType] = {};
      }
      _votesByTarget[vote.targetType]![vote.targetId] = vote;
    }
  }
  
  void _updateUserVotesList(Vote vote) {
    // Remove any existing vote for the same target
    _userVotes.removeWhere((v) => 
      v.targetType == vote.targetType && v.targetId == vote.targetId);
    
    // Add the new vote
    _userVotes.add(vote);
  }
  
  void clearVotes() {
    _userVotes = [];
    _votesByTarget.forEach((key, value) => value.clear());
    notifyListeners();
  }
  
  void clearError() {
    _errorMessage = '';
    if (_status == VoteStatus.error) {
      _status = VoteStatus.initial;
    }
    notifyListeners();
  }
}
