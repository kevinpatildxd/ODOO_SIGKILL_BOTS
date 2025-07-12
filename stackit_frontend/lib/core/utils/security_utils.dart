import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityUtils {
  // Secure storage keys
  static const String _authTokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';
  
  // Save auth token securely
  static Future<bool> saveAuthToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_authTokenKey, token);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving auth token: $e');
      }
      return false;
    }
  }
  
  // Get auth token
  static Future<String?> getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_authTokenKey);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting auth token: $e');
      }
      return null;
    }
  }
  
  // Save refresh token securely
  static Future<bool> saveRefreshToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_refreshTokenKey, token);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving refresh token: $e');
      }
      return false;
    }
  }
  
  // Get refresh token
  static Future<String?> getRefreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_refreshTokenKey);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting refresh token: $e');
      }
      return null;
    }
  }
  
  // Save user data securely
  static Future<bool> saveUserData(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_userKey, jsonEncode(userData));
    } catch (e) {
      if (kDebugMode) {
        print('Error saving user data: $e');
      }
      return false;
    }
  }
  
  // Get user data
  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString(_userKey);
      if (userDataString == null) return null;
      return jsonDecode(userDataString) as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user data: $e');
      }
      return null;
    }
  }
  
  // Clear all secure storage
  static Future<bool> clearSecureStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_authTokenKey);
      await prefs.remove(_refreshTokenKey);
      await prefs.remove(_userKey);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing secure storage: $e');
      }
      return false;
    }
  }
  
  // Sanitize input text to prevent XSS
  static String sanitizeInput(String input) {
    // Basic HTML sanitization
    return input
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;')
        .replaceAll('/', '&#x2F;');
  }
  
  // Check if token is expired
  static bool isTokenExpired(String token) {
    try {
      // JWT token structure: header.payload.signature
      final parts = token.split('.');
      if (parts.length != 3) return true;
      
      // Decode the payload
      final payload = parts[1];
      final normalized = base64.normalize(payload);
      final decodedPayload = utf8.decode(base64.decode(normalized));
      final payloadMap = jsonDecode(decodedPayload) as Map<String, dynamic>;
      
      // Check expiration
      if (payloadMap.containsKey('exp')) {
        final expiry = DateTime.fromMillisecondsSinceEpoch(payloadMap['exp'] * 1000);
        return DateTime.now().isAfter(expiry);
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking token expiry: $e');
      }
      return true;
    }
  }
} 