import 'package:dio/dio.dart';
import 'package:stackit_frontend/core/network/api_client.dart';
import 'package:stackit_frontend/core/network/api_endpoints.dart';
import 'package:stackit_frontend/core/network/network_exceptions.dart';
import 'package:stackit_frontend/data/models/question_model.dart';
import 'package:stackit_frontend/data/models/question_request.dart';
import 'package:stackit_frontend/data/models/paginated_response.dart';

class QuestionDataSource {
  final Dio _dio = ApiClient.dio;

  QuestionDataSource(ApiClient apiClient);

  Future<PaginatedResponse<Question>> getQuestions({
    int page = 1,
    int limit = 10,
    String? search,
    List<String>? tags,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      if (tags != null && tags.isNotEmpty) {
        queryParams['tags'] = tags;
      }

      final response = await _dio.get(
        ApiEndpoints.questions,
        queryParameters: queryParams,
      );

      return PaginatedResponse<Question>.fromJson(
        response.data,
        (json) => Question.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    } catch (e) {
      throw NetworkException(message: e.toString());
    }
  }

  Future<Question> getQuestionById(int id) async {
    try {
      final response = await _dio.get('${ApiEndpoints.questionById}$id');
      return Question.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    } catch (e) {
      throw NetworkException(message: e.toString());
    }
  }

  Future<Question> createQuestion(CreateQuestionRequest request) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.askQuestion,
        data: request.toJson(),
      );
      return Question.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    } catch (e) {
      throw NetworkException(message: e.toString());
    }
  }

  Future<Question> updateQuestion(int id, UpdateQuestionRequest request) async {
    try {
      final response = await _dio.put(
        '${ApiEndpoints.questionById}$id',
        data: request.toJson(),
      );
      return Question.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    } catch (e) {
      throw NetworkException(message: e.toString());
    }
  }

  Future<void> deleteQuestion(int id) async {
    try {
      await _dio.delete('${ApiEndpoints.questionById}$id');
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    } catch (e) {
      throw NetworkException(message: e.toString());
    }
  }
}
