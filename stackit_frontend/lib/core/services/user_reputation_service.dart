import 'package:flutter/foundation.dart';
import 'package:stackit_frontend/core/services/socket_service.dart';

/// A service that manages user reputation updates.
///
/// This service handles real-time reputation updates using the SocketService.
class UserReputationService {
  // Singleton instance
  static final UserReputationService _instance = UserReputationService._internal();
  
  // Dependencies
  final SocketService _socketService = SocketService();
  
  // Reputation state
  final Map<String, int> _userReputations = {};
  final ValueNotifier<Map<String, int>> reputationsNotifier = ValueNotifier<Map<String, int>>({});
  
  // Private constructor for singleton pattern
  UserReputationService._internal() {
    _setupSocketListeners();
  }
  
  // Factory constructor to return the singleton instance
  factory UserReputationService() {
    return _instance;
  }
  
  /// Sets up socket event listeners for reputation updates.
  void _setupSocketListeners() {
    _socketService.socket.on('user:reputation', _handleReputationEvent);
  }
  
  /// Handles reputation update events from the socket.
  void _handleReputationEvent(dynamic data) {
    try {
      final String userId = data['userId'];
      final int reputation = data['reputation'];
      
      _userReputations[userId] = reputation;
      reputationsNotifier.value = Map.from(_userReputations);
      
      if (kDebugMode) {
        print('User reputation updated: $userId, $reputation');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error handling reputation event: $e');
      }
    }
  }
  
  /// Gets the current reputation for a user.
  ///
  /// [userId] is the ID of the user.
  /// [defaultReputation] is the default value if no reputation is found.
  /// Returns the user's reputation.
  int getUserReputation(String userId, {int defaultReputation = 0}) {
    return _userReputations[userId] ?? defaultReputation;
  }
  
  /// Updates the local reputation cache with the latest values.
  ///
  /// [userReputations] is a map of user IDs to reputation values.
  void updateReputations(Map<String, int> userReputations) {
    _userReputations.addAll(userReputations);
    reputationsNotifier.value = Map.from(_userReputations);
  }
  
  /// Clears the reputation cache.
  void clearReputations() {
    _userReputations.clear();
    reputationsNotifier.value = {};
  }
  
  /// Cleans up resources when the service is no longer needed.
  void dispose() {
    _socketService.socket.off('user:reputation', _handleReputationEvent);
  }
} 