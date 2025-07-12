import 'package:dio/dio.dart';
import 'package:stackit_frontend/core/network/api_client.dart';
import 'package:stackit_frontend/core/network/api_endpoints.dart';
import 'package:stackit_frontend/core/network/network_exceptions.dart';
import 'package:stackit_frontend/data/models/vote_model.dart';
import 'package:stackit_frontend/data/models/vote_request.dart';

class VoteDataSource {
  final Dio _dio = ApiClient.dio;

  Future<Vote> vote(VoteRequest request) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.votes,
        data: request.toJson(),
      );
      return Vote.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    } catch (e) {
      throw NetworkException(message: e.toString());
    }
  }

  Future<List<Vote>> getUserVotes() async {
    try {
      final response = await _dio.get(
        ApiEndpoints.votes,
        queryParameters: {
          'userId': 'current', // Backend should handle this to get current user votes
        },
      );
      
      final data = response.data['data'] as List;
      return data.map((json) => Vote.fromJson(json)).toList();
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    } catch (e) {
      throw NetworkException(message: e.toString());
    }
  }

  Future<void> deleteVote(int id) async {
    try {
      await _dio.delete('${ApiEndpoints.votes}/$id');
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    } catch (e) {
      throw NetworkException(message: e.toString());
    }
  }
}
