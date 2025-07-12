import 'package:dio/dio.dart';
import 'package:stackit_frontend/core/network/api_client.dart';
import 'package:stackit_frontend/core/network/api_endpoints.dart';
import 'package:stackit_frontend/core/network/network_exceptions.dart';
import 'package:stackit_frontend/data/models/answer_model.dart';
import 'package:stackit_frontend/data/models/answer_request.dart';
import 'package:stackit_frontend/data/models/paginated_response.dart';

class AnswerDataSource {
  final Dio _dio = ApiClient.dio;

  Future<PaginatedResponse<Answer>> getAnswersByQuestionId(
    int questionId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.answers,
        queryParameters: {
          'questionId': questionId,
          'page': page,
          'limit': limit,
        },
      );

      return PaginatedResponse<Answer>.fromJson(
        response.data,
        (json) => Answer.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    } catch (e) {
      throw NetworkException(message: e.toString());
    }
  }

  Future<Answer> getAnswerById(int id) async {
    try {
      final response = await _dio.get('${ApiEndpoints.answerById}$id');
      return Answer.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    } catch (e) {
      throw NetworkException(message: e.toString());
    }
  }

  Future<Answer> createAnswer(CreateAnswerRequest request) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.answers,
        data: request.toJson(),
      );
      return Answer.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    } catch (e) {
      throw NetworkException(message: e.toString());
    }
  }

  Future<Answer> updateAnswer(int id, UpdateAnswerRequest request) async {
    try {
      final response = await _dio.put(
        '${ApiEndpoints.answerById}$id',
        data: request.toJson(),
      );
      return Answer.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    } catch (e) {
      throw NetworkException(message: e.toString());
    }
  }

  Future<void> deleteAnswer(int id) async {
    try {
      await _dio.delete('${ApiEndpoints.answerById}$id');
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    } catch (e) {
      throw NetworkException(message: e.toString());
    }
  }

  Future<Answer> acceptAnswer(int id) async {
    try {
      final response = await _dio.put('${ApiEndpoints.answerById}$id/accept');
      return Answer.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    } catch (e) {
      throw NetworkException(message: e.toString());
    }
  }
}
