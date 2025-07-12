import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository.dart';
import 'socket_service.dart';

/// A service that manages notifications and real-time updates.
///
/// This service handles notification storage, retrieval, and real-time
/// updates using the SocketService. It follows the singleton pattern
/// to ensure only one instance exists throughout the app.
class NotificationService {
  // Singleton instance
  static final NotificationService _instance = NotificationService._internal();
  
  // Dependencies
  final SocketService _socketService = SocketService();
  late NotificationRepository _notificationRepository;
  
  // Local cache of notifications
  final List<Notification> _notifications = [];
  
  // Stream controller for notification updates
  final _notificationStreamController = StreamController<List<Notification>>.broadcast();
  
  // Notification state
  ValueNotifier<int> unreadCount = ValueNotifier<int>(0);
  ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  
  // Storage key constants
  static const String _notificationsKey = 'stackit_notifications';
  static const String _lastFetchTimeKey = 'stackit_last_notification_fetch';
  
  // Public streams that components can listen to
  Stream<List<Notification>> get notificationsStream => _notificationStreamController.stream;
  
  // Private constructor for singleton pattern
  NotificationService._internal();
  
  // Factory constructor to return the singleton instance
  factory NotificationService() {
    return _instance;
  }
  
  /// Initializes the notification service.
  ///
  /// [notificationRepository] is the repository for notification data.
  void initialize(NotificationRepository notificationRepository) {
    _notificationRepository = notificationRepository;
    
    // Set up listeners for real-time notification updates
    _socketService.notificationStream.listen(_handleNotificationEvent);
    
    // Load cached notifications on startup
    _loadCachedNotifications();
  }
  
  /// Handles incoming notification events from the socket.
  void _handleNotificationEvent(Map<String, dynamic> event) {
    final eventType = event['type'];
    final eventData = event['data'];
    
    if (kDebugMode) {
      print('Received notification event: $eventType');
    }
    
    switch (eventType) {
      case 'new':
        _handleNewNotification(Notification.fromJson(eventData));
        break;
      case 'read':
        _handleNotificationRead(eventData['id']);
        break;
      default:
        if (kDebugMode) {
          print('Unknown notification event type: $eventType');
        }
    }
  }
  
  /// Handles a new notification received via socket.
  void _handleNewNotification(Notification notification) {
    // Add to local cache
    _notifications.insert(0, notification);
    
    // Increment unread count
    unreadCount.value++;
    
    // Update stream
    _notificationStreamController.add(List.from(_notifications));
    
    // Save to local storage
    _saveNotificationsToCache();
  }
  
  /// Handles marking a notification as read.
  void _handleNotificationRead(String notificationId) {
    // Find and update the notification in the local cache
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      
      // Update unread count
      _updateUnreadCount();
      
      // Update stream
      _notificationStreamController.add(List.from(_notifications));
      
      // Save to local storage
      _saveNotificationsToCache();
    }
  }
  
  /// Updates the unread notification count.
  void _updateUnreadCount() {
    unreadCount.value = _notifications.where((n) => !n.isRead).length;
  }
  
  /// Loads cached notifications from shared preferences.
  Future<void> _loadCachedNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getStringList(_notificationsKey);
      
      if (notificationsJson != null) {
        _notifications.clear();
        _notifications.addAll(
          notificationsJson
              .map((json) => Notification.fromRawJson(json))
              .toList(),
        );
        
        _updateUnreadCount();
        _notificationStreamController.add(List.from(_notifications));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading cached notifications: $e');
      }
    }
  }
  
  /// Saves notifications to shared preferences.
  Future<void> _saveNotificationsToCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = _notifications
          .map((notification) => notification.toRawJson())
          .toList();
      
      await prefs.setStringList(_notificationsKey, notificationsJson);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving notifications to cache: $e');
      }
    }
  }
  
  /// Fetches notifications from the server.
  ///
  /// [refresh] determines whether to force a fresh fetch.
  Future<void> fetchNotifications({bool refresh = false}) async {
    try {
      isLoading.value = true;
      
      // Check if we should fetch based on last fetch time
      if (!refresh && !await _shouldFetchNotifications()) {
        isLoading.value = false;
        return;
      }
      
      final notifications = await _notificationRepository.getNotifications();
      
      _notifications.clear();
      _notifications.addAll(notifications);
      
      _updateUnreadCount();
      _notificationStreamController.add(List.from(_notifications));
      
      // Save to local storage
      _saveNotificationsToCache();
      
      // Update last fetch time
      _updateLastFetchTime();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching notifications: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Marks a notification as read.
  ///
  /// [notificationId] is the ID of the notification to mark as read.
  Future<void> markAsRead(String notificationId) async {
    try {
      // Optimistic update
      _handleNotificationRead(notificationId);
      
      // Call API
      await _notificationRepository.markNotificationAsRead(notificationId);
    } catch (e) {
      if (kDebugMode) {
        print('Error marking notification as read: $e');
      }
      
      // Refresh to get the correct state
      fetchNotifications(refresh: true);
    }
  }
  
  /// Marks all notifications as read.
  Future<void> markAllAsRead() async {
    try {
      // Optimistic update
      for (int i = 0; i < _notifications.length; i++) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
      
      unreadCount.value = 0;
      _notificationStreamController.add(List.from(_notifications));
      
      // Save to local storage
      _saveNotificationsToCache();
      
      // Call API
      await _notificationRepository.markAllNotificationsAsRead();
    } catch (e) {
      if (kDebugMode) {
        print('Error marking all notifications as read: $e');
      }
      
      // Refresh to get the correct state
      fetchNotifications(refresh: true);
    }
  }
  
  /// Determines if we should fetch new notifications based on last fetch time.
  ///
  /// Returns true if it's been at least 5 minutes since the last fetch.
  Future<bool> _shouldFetchNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastFetchTimeMs = prefs.getInt(_lastFetchTimeKey);
      
      if (lastFetchTimeMs == null) {
        return true;
      }
      
      final lastFetchTime = DateTime.fromMillisecondsSinceEpoch(lastFetchTimeMs);
      final now = DateTime.now();
      
      // Fetch if it's been at least 5 minutes
      return now.difference(lastFetchTime).inMinutes >= 5;
    } catch (e) {
      // If there's an error, fetch to be safe
      return true;
    }
  }
  
  /// Updates the last notification fetch time to now.
  Future<void> _updateLastFetchTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastFetchTimeKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating last fetch time: $e');
      }
    }
  }
  
  /// Gets the cached list of notifications.
  List<Notification> getNotifications() {
    return List.unmodifiable(_notifications);
  }
  
  /// Joins a notification room for a specific entity.
  ///
  /// [entityType] can be 'question' or 'user'.
  /// [entityId] is the ID of the entity to subscribe to.
  void subscribeToEntity(String entityType, String entityId) {
    _socketService.joinRoom('$entityType:$entityId');
  }
  
  /// Leaves a notification room for a specific entity.
  ///
  /// [entityType] can be 'question' or 'user'.
  /// [entityId] is the ID of the entity to unsubscribe from.
  void unsubscribeFromEntity(String entityType, String entityId) {
    _socketService.leaveRoom('$entityType:$entityId');
  }
  
  /// Cleans up resources when the service is no longer needed.
  void dispose() {
    _notificationStreamController.close();
  }
  
  /// Clears all notifications (for logout).
  void clear() {
    _notifications.clear();
    unreadCount.value = 0;
    _notificationStreamController.add([]);
    _saveNotificationsToCache();
  }
}
