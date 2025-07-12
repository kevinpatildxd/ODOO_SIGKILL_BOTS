import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:stackit_frontend/core/services/socket_service.dart';
import 'package:stackit_frontend/core/services/storage_service.dart';

/// A service that manages user presence and activity features.
///
/// This service handles online status tracking, typing indicators,
/// and other real-time user activity features using the SocketService.
class UserPresenceService {
  // Singleton instance
  static final UserPresenceService _instance = UserPresenceService._internal();
  
  // Dependencies
  final SocketService _socketService = SocketService();
  final StorageService _storageService = StorageService();
  
  // User presence state
  final Map<String, bool> _onlineUsers = {};
  final Map<String, bool> _typingUsers = {};
  
  // Value notifiers for presence events
  final ValueNotifier<Map<String, bool>> onlineUsersNotifier = ValueNotifier<Map<String, bool>>({});
  final ValueNotifier<Map<String, bool>> typingUsersNotifier = ValueNotifier<Map<String, bool>>({});
  
  // Throttle control for typing indicators
  Timer? _typingTimer;
  bool _isCurrentlyTyping = false;
  String? _currentQuestionId;
  
  // Private constructor for singleton pattern
  UserPresenceService._internal();
  
  // Factory constructor to return the singleton instance
  factory UserPresenceService() {
    return _instance;
  }
  
  /// Initializes the user presence service.
  ///
  /// This should be called when the user logs in.
  void initialize() {
    // Listen for user presence events
    _socketService.socket.on('user:online', _handleUserOnlineEvent);
    _socketService.socket.on('user:offline', _handleUserOfflineEvent);
    _socketService.socket.on('user:typing', _handleUserTypingEvent);
    
    // Broadcast initial online status when connected
    _socketService.isConnected.addListener(_onSocketConnectionChanged);
  }
  
  /// Handles socket connection changes
  void _onSocketConnectionChanged() {
    if (_socketService.isConnected.value) {
      // When connected, broadcast online status
      final userId = _storageService.getUserId();
      if (userId != null) {
        broadcastOnlineStatus(userId);
      }
    }
  }
  
  /// Handles user online events from the socket.
  void _handleUserOnlineEvent(dynamic data) {
    try {
      final userId = data['userId'];
      
      if (userId != null && userId is String) {
        _onlineUsers[userId] = true;
        onlineUsersNotifier.value = Map.from(_onlineUsers);
        
        if (kDebugMode) {
          print('User online: $userId');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error handling user online event: $e');
      }
    }
  }
  
  /// Handles user offline events from the socket.
  void _handleUserOfflineEvent(dynamic data) {
    try {
      final userId = data['userId'];
      
      if (userId != null && userId is String) {
        _onlineUsers[userId] = false;
        onlineUsersNotifier.value = Map.from(_onlineUsers);
        
        if (kDebugMode) {
          print('User offline: $userId');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error handling user offline event: $e');
      }
    }
  }
  
  /// Handles user typing events from the socket.
  void _handleUserTypingEvent(dynamic data) {
    try {
      final userId = data['userId'];
      final questionId = data['questionId'];
      final isTyping = data['isTyping'];
      
      if (userId != null && questionId != null && isTyping != null) {
        if (questionId == _currentQuestionId) {
          _typingUsers[userId] = isTyping;
          typingUsersNotifier.value = Map.from(_typingUsers);
          
          if (kDebugMode) {
            print('User typing status changed: $userId, $isTyping');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error handling user typing event: $e');
      }
    }
  }
  
  /// Broadcasts the user's online status to other users.
  ///
  /// [userId] is the ID of the current user.
  void broadcastOnlineStatus(String userId) {
    if (_socketService.connected) {
      _socketService.emit('user:status', {
        'userId': userId,
        'status': 'online',
      });
    }
  }
  
  /// Sets the current question context for tracking typing indicators.
  ///
  /// [questionId] is the ID of the question being viewed.
  void setCurrentQuestion(String questionId) {
    _currentQuestionId = questionId;
    _typingUsers.clear();
    typingUsersNotifier.value = {};
  }
  
  /// Notifies that the user is typing in a question or answer.
  ///
  /// [questionId] is the ID of the question.
  /// [userId] is the ID of the current user.
  void notifyTyping(String questionId, String userId) {
    // Don't send repeated typing events
    if (!_isCurrentlyTyping) {
      _isCurrentlyTyping = true;
      
      if (_socketService.connected) {
        _socketService.emit('user:typing', {
          'userId': userId,
          'questionId': questionId,
          'isTyping': true,
        });
      }
    }
    
    // Reset the timer each time the user types
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 3), () {
      _isCurrentlyTyping = false;
      
      if (_socketService.connected) {
        _socketService.emit('user:typing', {
          'userId': userId,
          'questionId': questionId,
          'isTyping': false,
        });
      }
    });
  }
  
  /// Checks if a user is currently online.
  ///
  /// [userId] is the ID of the user to check.
  /// Returns true if the user is online, false otherwise.
  bool isUserOnline(String userId) {
    return _onlineUsers[userId] ?? false;
  }
  
  /// Gets a list of users who are currently typing in the current question.
  List<String> getTypingUsers() {
    return _typingUsers.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
  }
  
  /// Cleans up resources when the service is no longer needed.
  void dispose() {
    _typingTimer?.cancel();
    _socketService.isConnected.removeListener(_onSocketConnectionChanged);
    _socketService.socket.off('user:online', _handleUserOnlineEvent);
    _socketService.socket.off('user:offline', _handleUserOfflineEvent);
    _socketService.socket.off('user:typing', _handleUserTypingEvent);
  }
} 