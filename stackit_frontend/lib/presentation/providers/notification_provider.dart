import 'package:flutter/foundation.dart';
import 'package:stackit_frontend/core/network/network_exceptions.dart';
import 'package:stackit_frontend/data/models/notification_model.dart' as model;
import 'package:stackit_frontend/data/repositories/notification_repository.dart';

enum NotificationStatus { initial, loading, success, error }

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repository;
  
  NotificationStatus _status = NotificationStatus.initial;
  List<model.Notification> _notifications = [];
  String _errorMessage = '';
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMore = true;
  int _unreadCount = 0;
  
  NotificationProvider(this._repository);
  
  // Getters
  NotificationStatus get status => _status;
  List<model.Notification> get notifications => _notifications;
  String get errorMessage => _errorMessage;
  bool get isLoading => _status == NotificationStatus.loading;
  bool get hasMore => _hasMore;
  int get unreadCount => _unreadCount;
  
  // Methods
  Future<void> getNotifications({bool refresh = false, bool? isRead}) async {
    if (refresh) {
      _currentPage = 1;
      _notifications = [];
      _hasMore = true;
    }
    
    if (_status == NotificationStatus.loading || !_hasMore) {
      return;
    }
    
    _status = NotificationStatus.loading;
    _errorMessage = '';
    notifyListeners();
    
    try {
      final result = await _repository.getNotifications(
        page: _currentPage,
        limit: 10,
        isRead: isRead,
      );
      
      if (refresh) {
        _notifications = result.data;
      } else {
        _notifications.addAll(result.data);
      }
      
      _totalPages = result.totalPages;
      _hasMore = _currentPage < _totalPages;
      _currentPage++;
      _status = NotificationStatus.success;
      
      // Update unread count
      _updateUnreadCount();
    } catch (e) {
      _status = NotificationStatus.error;
      _errorMessage = e is NetworkException 
          ? e.message 
          : 'Failed to fetch notifications. Please try again.';
    }
    
    notifyListeners();
  }
  
  Future<void> markAsRead(int id) async {
    _status = NotificationStatus.loading;
    _errorMessage = '';
    notifyListeners();
    
    try {
      final updatedNotification = await _repository.markAsRead(id);
      
      // Update notification in list
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index] = updatedNotification;
      }
      
      _status = NotificationStatus.success;
      
      // Update unread count
      _updateUnreadCount();
    } catch (e) {
      _status = NotificationStatus.error;
      _errorMessage = e is NetworkException 
          ? e.message 
          : 'Failed to mark notification as read. Please try again.';
    }
    
    notifyListeners();
  }
  
  Future<void> markAllAsRead() async {
    if (_notifications.isEmpty) {
      return;
    }
    
    _status = NotificationStatus.loading;
    _errorMessage = '';
    notifyListeners();
    
    try {
      await _repository.markAllAsRead();
      
      // Update all notifications in the list to read
      for (int i = 0; i < _notifications.length; i++) {
        if (!_notifications[i].isRead) {
          _notifications[i] = model.Notification(
            id: _notifications[i].id,
            userId: _notifications[i].userId,
            type: _notifications[i].type,
            message: _notifications[i].message,
            targetId: _notifications[i].targetId,
            targetType: _notifications[i].targetType,
            isRead: true,
            createdAt: _notifications[i].createdAt,
          );
        }
      }
      
      _status = NotificationStatus.success;
      _unreadCount = 0;
    } catch (e) {
      _status = NotificationStatus.error;
      _errorMessage = e is NetworkException 
          ? e.message 
          : 'Failed to mark all notifications as read. Please try again.';
    }
    
    notifyListeners();
  }
  
  Future<void> deleteNotification(int id) async {
    _status = NotificationStatus.loading;
    _errorMessage = '';
    notifyListeners();
    
    try {
      await _repository.deleteNotification(id);
      
      // Remove notification from list
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        final wasUnread = !_notifications[index].isRead;
        _notifications.removeAt(index);
        if (wasUnread) {
          _unreadCount--;
        }
      }
      
      _status = NotificationStatus.success;
    } catch (e) {
      _status = NotificationStatus.error;
      _errorMessage = e is NetworkException 
          ? e.message 
          : 'Failed to delete notification. Please try again.';
    }
    
    notifyListeners();
  }
  
  void _updateUnreadCount() {
    _unreadCount = _notifications.where((n) => !n.isRead).length;
  }
  
  void clearError() {
    _errorMessage = '';
    if (_status == NotificationStatus.error) {
      _status = NotificationStatus.initial;
    }
    notifyListeners();
  }
  
  void clearNotifications() {
    _notifications = [];
    _currentPage = 1;
    _hasMore = true;
    _unreadCount = 0;
    _status = NotificationStatus.initial;
    notifyListeners();
  }
  
  // Method to handle real-time notification
  void addNotification(model.Notification notification) {
    _notifications.insert(0, notification);
    if (!notification.isRead) {
      _unreadCount++;
    }
    notifyListeners();
  }
}
