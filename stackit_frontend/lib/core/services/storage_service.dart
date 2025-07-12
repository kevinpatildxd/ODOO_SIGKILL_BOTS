import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// A service that handles local storage operations.
///
/// This service provides methods for storing and retrieving data
/// from SharedPreferences. It follows the singleton pattern to
/// ensure only one instance exists throughout the app.
class StorageService {
  // Singleton instance
  static final StorageService _instance = StorageService._internal();
  
  // SharedPreferences instance
  late SharedPreferences _prefs;
  
  // Keys for stored data
  static const String authTokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'dark_theme';
  
  // Private constructor for singleton pattern
  StorageService._internal();
  
  // Factory constructor to return the singleton instance
  factory StorageService() {
    return _instance;
  }
  
  /// Initializes the storage service.
  ///
  /// This must be called before using the service, typically in app startup.
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  /// Stores the authentication token.
  ///
  /// [token] is the JWT token to store.
  Future<bool> setAuthToken(String token) async {
    return await _prefs.setString(authTokenKey, token);
  }
  
  /// Retrieves the stored authentication token.
  ///
  /// Returns null if no token is stored.
  String? getAuthToken() {
    return _prefs.getString(authTokenKey);
  }
  
  /// Checks if an authentication token exists.
  ///
  /// Returns true if a token is stored.
  bool hasAuthToken() {
    return _prefs.containsKey(authTokenKey);
  }
  
  /// Removes the stored authentication token.
  ///
  /// Used for logout operations.
  Future<bool> removeAuthToken() async {
    return await _prefs.remove(authTokenKey);
  }
  
  /// Stores the user ID.
  ///
  /// [userId] is the ID of the logged-in user.
  Future<bool> setUserId(String userId) async {
    return await _prefs.setString(userIdKey, userId);
  }
  
  /// Retrieves the stored user ID.
  ///
  /// Returns null if no user ID is stored.
  String? getUserId() {
    return _prefs.getString(userIdKey);
  }
  
  /// Stores user data.
  ///
  /// [userData] is a map containing user information.
  Future<bool> setUserData(Map<String, dynamic> userData) async {
    return await _prefs.setString(userDataKey, json.encode(userData));
  }
  
  /// Retrieves stored user data.
  ///
  /// Returns null if no user data is stored.
  Map<String, dynamic>? getUserData() {
    final String? userDataString = _prefs.getString(userDataKey);
    if (userDataString == null) {
      return null;
    }
    
    try {
      return json.decode(userDataString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }
  
  /// Sets the theme preference.
  ///
  /// [isDarkMode] determines if dark mode is enabled.
  Future<bool> setDarkMode(bool isDarkMode) async {
    return await _prefs.setBool(themeKey, isDarkMode);
  }
  
  /// Gets the theme preference.
  ///
  /// Returns the stored theme preference, or false if none is set.
  bool getDarkMode() {
    return _prefs.getBool(themeKey) ?? false;
  }
  
  /// Stores a generic value with a custom key.
  ///
  /// [key] is the storage key.
  /// [value] is the value to store.
  Future<bool> setValue(String key, dynamic value) async {
    if (value is String) {
      return await _prefs.setString(key, value);
    } else if (value is int) {
      return await _prefs.setInt(key, value);
    } else if (value is double) {
      return await _prefs.setDouble(key, value);
    } else if (value is bool) {
      return await _prefs.setBool(key, value);
    } else if (value is List<String>) {
      return await _prefs.setStringList(key, value);
    } else {
      // For complex objects, convert to JSON string
      return await _prefs.setString(key, json.encode(value));
    }
  }
  
  /// Retrieves a generic value by key.
  ///
  /// [key] is the storage key.
  /// [defaultValue] is returned if the key doesn't exist.
  dynamic getValue(String key, dynamic defaultValue) {
    if (!_prefs.containsKey(key)) {
      return defaultValue;
    }
    
    try {
      return _prefs.get(key);
    } catch (e) {
      return defaultValue;
    }
  }
  
  /// Removes a value by key.
  ///
  /// [key] is the storage key to remove.
  Future<bool> removeValue(String key) async {
    return await _prefs.remove(key);
  }
  
  /// Clears all stored data.
  ///
  /// Used when logging out or resetting the app.
  Future<bool> clearAll() async {
    return await _prefs.clear();
  }
}
