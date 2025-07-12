import 'package:dio/dio.dart';
import 'package:stackit_frontend/core/network/api_client.dart';
import 'package:stackit_frontend/core/network/api_endpoints.dart';
import 'package:stackit_frontend/core/network/network_exceptions.dart';
import 'package:stackit_frontend/data/models/tag_model.dart';
import 'package:stackit_frontend/data/models/paginated_response.dart';

class TagDataSource {
  final Dio _dio = ApiClient.dio;

  Future<PaginatedResponse<Tag>> getTags({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _dio.get(
        ApiEndpoints.tags,
        queryParameters: queryParams,
      );

      return PaginatedResponse<Tag>.fromJson(
        response.data,
        (json) => Tag.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    } catch (e) {
      throw NetworkException(message: e.toString());
    }
  }

  Future<List<Tag>> getAllTags() async {
    try {
      final response = await _dio.get(
        ApiEndpoints.tags,
        queryParameters: {
          'limit': 100, // Get a large number of tags
        },
      );

      final data = response.data['data'] as List;
      return data.map((json) => Tag.fromJson(json)).toList();
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    } catch (e) {
      throw NetworkException(message: e.toString());
    }
  }

  Future<Tag> getTagById(int id) async {
    try {
      final response = await _dio.get('${ApiEndpoints.tags}/$id');
      return Tag.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    } catch (e) {
      throw NetworkException(message: e.toString());
    }
  }
}
