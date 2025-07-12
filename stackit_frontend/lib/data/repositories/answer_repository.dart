import 'package:stackit_frontend/core/network/network_exceptions.dart';
import 'package:stackit_frontend/data/datasources/answer_datasource.dart';
import 'package:stackit_frontend/data/models/answer_model.dart';
import 'package:stackit_frontend/data/models/answer_request.dart';
import 'package:stackit_frontend/data/models/paginated_response.dart';

class AnswerRepository {
  final AnswerDataSource _dataSource;

  AnswerRepository(this._dataSource);

  Future<PaginatedResponse<Answer>> getAnswersByQuestionId(
    int questionId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      return await _dataSource.getAnswersByQuestionId(
        questionId,
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

  Future<Answer> getAnswerById(int id) async {
    try {
      return await _dataSource.getAnswerById(id);
    } catch (e) {
      if (e is NetworkException) {
        rethrow;
      }
      throw NetworkException(message: e.toString());
    }
  }

  Future<Answer> createAnswer(int questionId, String content) async {
    try {
      final request = CreateAnswerRequest(
        questionId: questionId,
        content: content,
      );
      return await _dataSource.createAnswer(request);
    } catch (e) {
      if (e is NetworkException) {
        rethrow;
      }
      throw NetworkException(message: e.toString());
    }
  }

  Future<Answer> updateAnswer(int id, String content) async {
    try {
      final request = UpdateAnswerRequest(content: content);
      return await _dataSource.updateAnswer(id, request);
    } catch (e) {
      if (e is NetworkException) {
        rethrow;
      }
      throw NetworkException(message: e.toString());
    }
  }

  Future<void> deleteAnswer(int id) async {
    try {
      await _dataSource.deleteAnswer(id);
    } catch (e) {
      if (e is NetworkException) {
        rethrow;
      }
      throw NetworkException(message: e.toString());
    }
  }

  Future<Answer> acceptAnswer(int id) async {
    try {
      return await _dataSource.acceptAnswer(id);
    } catch (e) {
      if (e is NetworkException) {
        rethrow;
      }
      throw NetworkException(message: e.toString());
    }
  }

  Future<void> voteAnswer(int id, bool isUpvote) async {
    try {
      await _dataSource.voteAnswer(id, isUpvote);
    } catch (e) {
      if (e is NetworkException) {
        rethrow;
      }
      throw NetworkException(message: e.toString());
    }
  }

  Future<PaginatedResponse<Answer>> getAnswersByUserId(
    int userId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      return await _dataSource.getAnswersByUserId(
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
