import 'package:dio/dio.dart';
import 'package:stackit_frontend/core/network/api_client.dart';
import 'package:stackit_frontend/core/network/api_endpoints.dart';
import 'package:stackit_frontend/core/network/network_exceptions.dart';
import 'package:stackit_frontend/data/models/user_model.dart';

class UserDataSource {
  final Dio _dio = ApiClient.dio;

  UserDataSource(ApiClient apiClient);

  Future<List<User>> getUsersByIds(List<String> userIds) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.users,
        queryParameters: {
          'ids': userIds.join(','),
        },
      );
      return (response.data['data'] as List)
          .map((json) => User.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    } catch (e) {
      throw NetworkException(message: e.toString());
    }
  }
}
