import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stackit_frontend/core/network/network_exceptions.dart';
import 'package:stackit_frontend/data/models/user_model.dart';
import 'package:stackit_frontend/data/repositories/auth_repository.dart';
import 'dart:convert';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  final SharedPreferences _preferences;
  
  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _token;
  String _errorMessage = '';

  AuthProvider(this._authRepository, this._preferences) {
    _checkAuthStatus();
  }

  // Getters
  AuthStatus get status => _status;
  User? get user => _user;
  String? get token => _token;
  String get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  // Methods
  Future<void> _checkAuthStatus() async {
    final token = _preferences.getString('auth_token');
    final userJson = _preferences.getString('user_data');
    
    if (token != null && userJson != null) {
      try {
        _token = token;
        // We would ideally verify the token with the backend here
        _user = User.fromJson(jsonDecode(userJson));
        _status = AuthStatus.authenticated;
      } catch (e) {
        _status = AuthStatus.unauthenticated;
        _clearAuthData();
      }
    } else {
      _status = AuthStatus.unauthenticated;
    }
    
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final user = await _authRepository.login(email, password);
      _user = user;
      _token = user.token;
      _status = AuthStatus.authenticated;
      
      // Save auth data
      await _saveAuthData();
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e is NetworkException 
          ? e.message 
          : 'Failed to login. Please try again.';
    }
    
    notifyListeners();
  }

  Future<void> register(String username, String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final user = await _authRepository.register(username, email, password);
      _user = user;
      _token = user.token;
      _status = AuthStatus.authenticated;
      
      // Save auth data
      await _saveAuthData();
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e is NetworkException 
          ? e.message 
          : 'Failed to register. Please try again.';
    }
    
    notifyListeners();
  }

  Future<void> forgotPassword(String email) async {
    _status = AuthStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final success = await _authRepository.forgotPassword(email);
      _status = success 
          ? AuthStatus.unauthenticated 
          : AuthStatus.error;
      
      if (!success) {
        _errorMessage = 'Failed to process your request. Please try again.';
      }
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e is NetworkException 
          ? e.message 
          : 'Failed to process your request. Please try again.';
    }
    
    notifyListeners();
  }

  Future<void> logout() async {
    _status = AuthStatus.loading;
    notifyListeners();
    
    await _clearAuthData();
    _status = AuthStatus.unauthenticated;
    
    notifyListeners();
  }

  Future<void> _saveAuthData() async {
    if (_user != null && _token != null) {
      await _preferences.setString('auth_token', _token!);
      await _preferences.setString('user_data', jsonEncode(_user!.toJson()));
    }
  }

  Future<void> _clearAuthData() async {
    _user = null;
    _token = null;
    await _preferences.remove('auth_token');
    await _preferences.remove('user_data');
  }

  void clearError() {
    _errorMessage = '';
    if (_status == AuthStatus.error) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }
}
