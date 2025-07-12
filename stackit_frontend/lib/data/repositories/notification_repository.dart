import 'package:stackit_frontend/core/network/network_exceptions.dart';
import 'package:stackit_frontend/data/datasources/notification_datasource.dart';
import 'package:stackit_frontend/data/models/notification_model.dart';
import 'package:stackit_frontend/data/models/paginated_response.dart';

class NotificationRepository {
  final NotificationDataSource _dataSource;

  NotificationRepository(this._dataSource);

  Future<PaginatedResponse<Notification>> getNotifications({
    int page = 1,
    int limit = 10,
    bool? isRead,
  }) async {
    try {
      return await _dataSource.getNotifications(
        page: page,
        limit: limit,
        isRead: isRead,
      );
    } catch (e) {
      if (e is NetworkException) {
        rethrow;
      }
      throw NetworkException(message: e.toString());
    }
  }

  Future<Notification> markAsRead(int id) async {
    try {
      return await _dataSource.markAsRead(id);
    } catch (e) {
      if (e is NetworkException) {
        rethrow;
      }
      throw NetworkException(message: e.toString());
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _dataSource.markAllAsRead();
    } catch (e) {
      if (e is NetworkException) {
        rethrow;
      }
      throw NetworkException(message: e.toString());
    }
  }

  Future<void> deleteNotification(int id) async {
    try {
      await _dataSource.deleteNotification(id);
    } catch (e) {
      if (e is NetworkException) {
        rethrow;
      }
      throw NetworkException(message: e.toString());
    }
  }
}
