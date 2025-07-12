import 'package:stackit_frontend/core/network/network_exceptions.dart';
import 'package:stackit_frontend/data/datasources/vote_datasource.dart';
import 'package:stackit_frontend/data/models/vote_model.dart';
import 'package:stackit_frontend/data/models/vote_request.dart';

class VoteRepository {
  final VoteDataSource _dataSource;

  VoteRepository(this._dataSource);

  Future<Vote> vote(String targetType, int targetId, int voteType) async {
    try {
      final request = VoteRequest(
        targetType: targetType,
        targetId: targetId,
        voteType: voteType,
      );
      return await _dataSource.vote(request);
    } catch (e) {
      if (e is NetworkException) {
        rethrow;
      }
      throw NetworkException(message: e.toString());
    }
  }

  Future<List<Vote>> getUserVotes() async {
    try {
      return await _dataSource.getUserVotes();
    } catch (e) {
      if (e is NetworkException) {
        rethrow;
      }
      throw NetworkException(message: e.toString());
    }
  }

  Future<void> deleteVote(int id) async {
    try {
      await _dataSource.deleteVote(id);
    } catch (e) {
      if (e is NetworkException) {
        rethrow;
      }
      throw NetworkException(message: e.toString());
    }
  }
}
