import 'package:stackit_frontend/core/network/network_exceptions.dart';
import 'package:stackit_frontend/data/datasources/user_datasource.dart';
import 'package:stackit_frontend/data/models/user_model.dart';

class UserRepository {
  final UserDataSource _dataSource;

  UserRepository(this._dataSource);

  Future<List<User>> getUsersByIds(List<String> userIds) async {
    try {
      return await _dataSource.getUsersByIds(userIds);
    } catch (e) {
      if (e is NetworkException) {
        rethrow;
      }
      throw NetworkException(message: e.toString());
    }
  }
}
