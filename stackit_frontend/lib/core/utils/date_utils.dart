class DateUtils {
  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  static String formatDateTime(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }

  static String formatDateOnly(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }
  
  // Alias for formatDate to match the import in question_card.dart
  static String formatTimeAgo(DateTime date) {
    return formatDate(date);
  }
  
  // Format to ISO 8601 string
  static String toIso8601String(DateTime date) {
    return date.toIso8601String();
  }
  
  // Parse ISO 8601 string
  static DateTime? parseIso8601String(String isoString) {
    try {
      return DateTime.parse(isoString);
    } catch (e) {
      return null;
    }
  }
  
  // Format with custom pattern
  static String formatCustom(DateTime date, {bool includeTime = true}) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    final day = date.day;
    final month = months[date.month - 1];
    final year = date.year;
    
    if (includeTime) {
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '$month $day, $year at $hour:$minute';
    }
    
    return '$month $day, $year';
  }
  
  // Get difference between two dates in days
  static int daysBetween(DateTime from, DateTime to) {
    final difference = to.difference(from);
    return difference.inDays;
  }
  
  // Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }
}
