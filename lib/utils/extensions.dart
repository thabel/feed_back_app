import 'package:intl/intl.dart';

extension StringExtensions on String {
  /// Check if string is a valid email
  bool get isValidEmail {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(this);
  }

  /// Check if string is empty or only whitespace
  bool get isEmptyOrBlank {
    return isEmpty || trim().isEmpty;
  }

  /// Capitalize first letter
  String get capitalize {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}

extension DateTimeExtensions on DateTime {
  /// Format as readable date string
  String get formattedDate {
    return DateFormat('dd/MM/yyyy').format(this);
  }

  /// Format as readable time string
  String get formattedTime {
    return DateFormat('HH:mm').format(this);
  }

  /// Format as readable datetime string
  String get formattedDateTime {
    return DateFormat('dd/MM/yyyy HH:mm').format(this);
  }

  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }
}

extension DurationExtensions on Duration {
  /// Format duration as readable string
  String get formattedDuration {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(inSeconds.remainder(60));
    if (inHours > 0) {
      return '${twoDigits(inHours)}:$twoDigitMinutes:$twoDigitSeconds';
    }
    return '$twoDigitMinutes:$twoDigitSeconds';
  }
}

extension IntExtensions on int {
  /// Format as ordinal string (1st, 2nd, 3rd, 4th, etc.)
  String get ordinal {
    if (this == 1) return '1er';
    if (this > 1) return '${this}e';
    return toString();
  }
}
