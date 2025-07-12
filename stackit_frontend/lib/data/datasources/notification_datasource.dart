import 'package:dio/dio.dart';
import 'package:stackit_frontend/core/network/api_client.dart';
import 'package:stackit_frontend/core/network/api_endpoints.dart';
import 'package:stackit_frontend/core/network/network_exceptions.dart';
import 'package:stackit_frontend/data/models/notification_model.dart';
import 'package:stackit_frontend/data/models/paginated_response.dart';

class NotificationDataSource {
  final Dio _dio = ApiClient.dio;

  NotificationDataSource(ApiClient apiClient);

  Future<PaginatedResponse<Notification>> getNotifications({
    int page = 1,
    int limit = 10,
    bool? isRead,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
      };

      if (isRead != null) {
        queryParams['isRead'] = isRead;
      }

      final response = await _dio.get(
        ApiEndpoints.notifications,
        queryParameters: queryParams,
      );

      return PaginatedResponse<Notification>.fromJson(
        response.data,
        (json) => Notification.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    } catch (e) {
      throw NetworkException(message: e.toString());
    }
  }

  Future<Notification> markAsRead(int id) async {
    try {
      final response = await _dio.put(
        '${ApiEndpoints.notifications}/$id/read',
      );
      return Notification.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    } catch (e) {
      throw NetworkException(message: e.toString());
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _dio.put('${ApiEndpoints.notifications}/read-all');
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    } catch (e) {
      throw NetworkException(message: e.toString());
    }
  }

  Future<void> deleteNotification(int id) async {
    try {
      await _dio.delete('${ApiEndpoints.notifications}/$id');
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    } catch (e) {
      throw NetworkException(message: e.toString());
    }
  }
}
