import 'package:flutter/material.dart';

/// ألوان التطبيق الرئيسية
class AppColors {
  // الألوان الأساسية
  static const Color skyBlue = Color(0xFF87CEEB);
  static const Color lightGreen = Color(0xFF90EE90);
  static const Color mintGreen = Color(0xFF98D8AA);
  static const Color white = Colors.white;

  // ألوان إضافية
  static const Color orange = Color(0xFFFFB74D);
  static const Color purple = Color(0xFFBA68C8);
  static const Color cyan = Color(0xFF4DD0E1);
  static const Color darkText = Color(0xFF2D3436);
  static const Color lightText = Color(0xFF636E72);
  static const Color error = Color(0xFFE74C3C);
  static const Color success = Color(0xFF2E7D32);

  // التدرجات اللونية
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [skyBlue, lightGreen],
    begin: Alignment.topLeft,
    end: Alignment. bottomRight,
  );
}

/// نصوص التطبيق
class AppStrings {
  static const String appName = 'عالم الفسيلة';
  static const String appSlogan = 'تعلم • العب • انمُ';
  static const String parentApp = 'تطبيق الأهل';

  static String get(BuildContext context, String ar, String en) {
    return Localizations.localeOf(context).languageCode == 'en' ? en : ar;
  }

  // المناطق الأربع في اللعبة
  static List<String> getZones(BuildContext context) => [
    get(context, 'المنزل', 'Home'),
    get(context, 'المدرسة', 'School'),
    get(context, 'المسجد', 'Mosque'),
    get(context, 'المنطقة المتغيرة', 'Changeable Area'),
  ];

  // أيام الأسبوع
  static List<String> getWeekDays(BuildContext context) => [
    get(context, 'السبت', 'Saturday'),
    get(context, 'الأحد', 'Sunday'),
    get(context, 'الإثنين', 'Monday'),
    get(context, 'الثلاثاء', 'Tuesday'),
    get(context, 'الأربعاء', 'Wednesday'),
    get(context, 'الخميس', 'Thursday'),
    get(context, 'الجمعة', 'Friday'),
  ];

  // أنواع المحتوى
  static List<String> getContentTypes(BuildContext context) => [
    get(context, 'قصص', 'Stories'),
    get(context, 'ألعاب تعليمية', 'Educational Games'),
    get(context, 'أنشطة', 'Activities'),
    get(context, 'محتوى ديني', 'Religious Content'),
    get(context, 'محتوى تربوي', 'Educational Content'),
    get(context, 'أناشيد', 'Nasheeds'),
  ];
}

/// أيقونات المناطق
class ZoneIcons {
  static const IconData home = Icons.home;
  static const IconData school = Icons.school;
  static const IconData mosque = Icons.mosque;
  static const IconData dynamic = Icons.park;
}