import 'package:stackit_frontend/core/network/network_exceptions.dart';
import 'package:stackit_frontend/data/datasources/auth_datasource.dart';
import 'package:stackit_frontend/data/models/auth_request.dart';
import 'package:stackit_frontend/data/models/auth_response.dart';
import 'package:stackit_frontend/data/models/user_model.dart';

class AuthRepository {
  final AuthDataSource _dataSource;

  AuthRepository(this._dataSource);

  Future<User> login(String email, String password) async {
    try {
      final request = LoginRequest(email: email, password: password);
      final response = await _dataSource.login(request);
      
      if (!response.success || response.data == null) {
        throw NetworkException(message: response.message);
      }
      
      return response.data!.user;
    } catch (e) {
      if (e is NetworkException) {
        rethrow;
      }
      throw NetworkException(message: e.toString());
    }
  }

  Future<User> register(String username, String email, String password) async {
    try {
      final request = RegisterRequest(
        username: username,
        email: email,
        password: password,
      );
      final response = await _dataSource.register(request);
      
      if (!response.success || response.data == null) {
        throw NetworkException(message: response.message);
      }
      
      return response.data!.user;
    } catch (e) {
      if (e is NetworkException) {
        rethrow;
      }
      throw NetworkException(message: e.toString());
    }
  }

  Future<bool> forgotPassword(String email) async {
    try {
      final request = ForgotPasswordRequest(email: email);
      final response = await _dataSource.forgotPassword(request);
      
      return response.success;
    } catch (e) {
      if (e is NetworkException) {
        rethrow;
      }
      throw NetworkException(message: e.toString());
    }
  }
}
