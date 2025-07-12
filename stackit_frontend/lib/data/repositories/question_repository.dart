import 'package:stackit_frontend/core/network/network_exceptions.dart';
import 'package:stackit_frontend/data/datasources/question_datasource.dart';
import 'package:stackit_frontend/data/models/paginated_response.dart';
import 'package:stackit_frontend/data/models/question_model.dart';
import 'package:stackit_frontend/data/models/question_request.dart';

class QuestionRepository {
  final QuestionDataSource _dataSource;

  QuestionRepository(this._dataSource);

  Future<PaginatedResponse<Question>> getQuestions({
    int page = 1,
    int limit = 10,
    String? search,
    List<String>? tags,
  }) async {
    try {
      return await _dataSource.getQuestions(
        page: page,
        limit: limit,
        search: search,
        tags: tags,
      );
    } catch (e) {
      if (e is NetworkException) {
        rethrow;
      }
      throw NetworkException(message: e.toString());
    }
  }

  Future<Question> getQuestionById(int id) async {
    try {
      return await _dataSource.getQuestionById(id);
    } catch (e) {
      if (e is NetworkException) {
        rethrow;
      }
      throw NetworkException(message: e.toString());
    }
  }

  Future<Question> createQuestion(
    String title,
    String description,
    List<String> tags,
  ) async {
    try {
      final request = CreateQuestionRequest(
        title: title,
        description: description,
        tags: tags,
      );
      return await _dataSource.createQuestion(request);
    } catch (e) {
      if (e is NetworkException) {
        rethrow;
      }
      throw NetworkException(message: e.toString());
    }
  }

  Future<Question> updateQuestion(
    int id,
    String title,
    String description,
    List<String> tags,
  ) async {
    try {
      final request = UpdateQuestionRequest(
        title: title,
        description: description,
        tags: tags,
      );
      return await _dataSource.updateQuestion(id, request);
    } catch (e) {
      if (e is NetworkException) {
        rethrow;
      }
      throw NetworkException(message: e.toString());
    }
  }

  Future<void> deleteQuestion(int id) async {
    try {
      await _dataSource.deleteQuestion(id);
    } catch (e) {
      if (e is NetworkException) {
        rethrow;
      }
      throw NetworkException(message: e.toString());
    }
  }

  Future<void> voteQuestion(int id, bool isUpvote) async {
    try {
      await _dataSource.voteQuestion(id, isUpvote);
    } catch (e) {
      if (e is NetworkException) {
        rethrow;
      }
      throw NetworkException(message: e.toString());
    }
  }

  Future<PaginatedResponse<Question>> getQuestionsByUserId(
    int userId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      return await _dataSource.getQuestionsByUserId(
        userId,
        page: page,
        limit: limit,
      );
    } catch (e) {
      if (e is NetworkException) {
        rethrow;
      }
      throw NetworkException(message: e.toString());
    }
  }
}
