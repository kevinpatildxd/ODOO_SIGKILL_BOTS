import 'package:stackit_frontend/core/network/network_exceptions.dart';
import 'package:stackit_frontend/data/datasources/tag_datasource.dart';
import 'package:stackit_frontend/data/models/paginated_response.dart';
import 'package:stackit_frontend/data/models/tag_model.dart';

class TagRepository {
  final TagDataSource _dataSource;

  TagRepository(this._dataSource);

  Future<PaginatedResponse<Tag>> getTags({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    try {
      return await _dataSource.getTags(
        page: page,
        limit: limit,
        search: search,
      );
    } catch (e) {
      if (e is NetworkException) {
        rethrow;
      }
      throw NetworkException(message: e.toString());
    }
  }

  Future<List<Tag>> getAllTags() async {
    try {
      return await _dataSource.getAllTags();
    } catch (e) {
      if (e is NetworkException) {
        rethrow;
      }
      throw NetworkException(message: e.toString());
    }
  }

  Future<Tag> getTagById(int id) async {
    try {
      return await _dataSource.getTagById(id);
    } catch (e) {
      if (e is NetworkException) {
        rethrow;
      }
      throw NetworkException(message: e.toString());
    }
  }
}
