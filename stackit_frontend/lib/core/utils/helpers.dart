import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'dart:math' as math;

class Helpers {
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength)}...';
  }

  static String getInitials(String name) {
    if (name.isEmpty) return '';
    
    final nameParts = name.split(' ');
    if (nameParts.length == 1) {
      return nameParts[0][0].toUpperCase();
    } else {
      return nameParts[0][0].toUpperCase() + nameParts[1][0].toUpperCase();
    }
  }

  static String formatNumber(int number) {
    if (number < 1000) {
      return number.toString();
    } else if (number < 1000000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    }
  }
  
  // Open URLs in browser or app
  static Future<bool> launchURL(String url) async {
    try {
      final uri = Uri.parse(url);
      return await url_launcher.launchUrl(uri);
    } catch (e) {
      return false;
    }
  }
  
  // Get device type (mobile, tablet, desktop)
  static String getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < 600) {
      return 'mobile';
    } else if (width < 900) {
      return 'tablet';
    } else {
      return 'desktop';
    }
  }
  
  // Generate a random color
  static Color getRandomColor({int? seed}) {
    final random = seed != null ? math.Random(seed) : math.Random();
    return Color.fromRGBO(
      random.nextInt(200), // Not too bright
      random.nextInt(200),
      random.nextInt(200),
      1,
    );
  }
  
  // Get avatar color from username
  static Color getAvatarColorFromUsername(String username) {
    // Generate consistent color based on username
    final hash = username.hashCode;
    return getRandomColor(seed: hash);
  }
  
  // Get file extension from path
  static String? getFileExtension(String path) {
    final lastDot = path.lastIndexOf('.');
    if (lastDot == -1) return null;
    return path.substring(lastDot + 1);
  }
  
  // Check if string is a URL
  static bool isValidUrl(String text) {
    final urlPattern = RegExp(
      r'^(https?:\/\/)?' // protocol
      r'(([a-z\d]([a-z\d-]*[a-z\d])*)\.)+[a-z]{2,}|' // domain name
      r'((\d{1,3}\.){3}\d{1,3})' // OR ip (v4) address
      r'(\:\d+)?(\/[-a-z\d%_.~+]*)*' // port and path
      r'(\?[;&a-z\d%_.~+=-]*)?' // query string
      r'(\#[-a-z\d_]*)?$', // fragment locator
      caseSensitive: false,
    );
    return urlPattern.hasMatch(text);
  }
}
