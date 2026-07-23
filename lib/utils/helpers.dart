import 'package:flutter/material.dart';

/// دوال مساعدة للتطبيق
class AppHelpers {
  /// تحويل الدقائق إلى صيغة ساعات ودقائق
  static String formatMinutes(int minutes) {
    if (minutes < 60) {
      return '$minutes دقيقة';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) {
      return '$hours ساعة';
    }
    return '$hours ساعة و $remainingMinutes دقيقة';
  }

  /// تنسيق التاريخ بالعربية
  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'اليوم';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inDays == 2) {
      return 'قبل يومين';
    } else if (difference.inDays < 7) {
      return 'قبل ${difference.inDays} أيام';
    } else if (difference.inDays < 30) {
      final weeks = difference.inDays ~/ 7;
      return 'قبل $weeks أسبوع';
    } else {
      final months = difference.inDays ~/ 30;
      return 'قبل $months شهر';
    }
  }

  /// تنسيق الوقت
  static String formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute. toString().padLeft(2, '0');
    final period = hour < 12 ? 'صباحاً' : 'مساءً';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  /// حساب نسبة التقدم
  static double calculateProgress(int current, int total) {
    if (total == 0) return 0;
    return (current / total).clamp(0.0, 1.0);
  }

  /// الح��ول على لون حسب النسبة
  static Color getProgressColor(double progress) {
    if (progress >= 0.8) {
      return const Color(0xFF90EE90); // أخضر
    } else if (progress >= 0.5) {
      return const Color(0xFFFFB74D); // برتقالي
    } else {
      return const Color(0xFFE74C3C); // أحمر
    }
  }

  /// الحصول على إيموجي المزاج
  static String getMoodEmoji(String mood) {
    switch (mood. toLowerCase()) {
      case 'سعيد':
        return '😊';
      case 'متحمس':
        return '🤩';
      case 'هادئ':
        return '😌';
      case 'مركز':
        return '🎯';
      case 'متعب':
        return '😴';
      default:
        return '😊';
    }
  }

  /// التحقق من صحة البريد الإلكتروني
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// التحقق من قوة كلمة المرور
  static bool isStrongPassword(String password) {
    return password.length >= 8 &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[a-z]')) &&
        password.contains(RegExp(r'[0-9]'));
  }
}