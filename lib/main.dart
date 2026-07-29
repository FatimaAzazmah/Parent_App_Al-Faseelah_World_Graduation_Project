import 'package:flutter/material.dart';
import 'package:pearant_app/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_locale.dart';
import 'app_theme.dart';
import 'config/supabase_config.dart';
import 'utils/app_strings.dart';

// استيراد جميع الشاشات
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/home_screen.dart';
import 'screens/child_profile_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/connection_screen.dart';
import 'screens/content_library_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/add_child_screen.dart';
import 'screens/parental_controls_screen.dart';
import 'screens/ai_reports_screen.dart';
import 'screens/child_activity_detail_screen.dart';
import 'screens/behavior_goals_screen.dart';
import 'screens/board_selection_screen.dart';
import 'screens/achievements_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppLocale.loadSavedLocale();
  await AppTheme.loadSavedTheme();

  // بدون إعدادات الاتصال لا يمكن تشغيل أي شاشة، فنشرح الخطوة الناقصة
  // لمن يشغّل المشروع أول مرة بدل تعطّل التطبيق برسالة غامضة.
  if (!SupabaseConfig.isConfigured) {
    runApp(const _MissingConfigApp());
    return;
  }

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(const AlFaseelahParentApp());
}

/// شاشة بديلة تظهر حين يُبنى التطبيق بلا إعدادات Supabase،
/// وتدلّ على الأمر الصحيح لتشغيله.
class _MissingConfigApp extends StatelessWidget {
  const _MissingConfigApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.settings_ethernet, size: 64),
              const SizedBox(height: 16),
              Text(
                AppStrings.tr(
                  null,
                  'إعدادات Supabase غير مضبوطة',
                  'Supabase configuration is missing',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                AppStrings.tr(
                  null,
                  'انسخي القالب التالي إلى local_config.dart واملئي قيمك:',
                  'Copy this template to local_config.dart and fill in your values:',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const SelectableText(
                'lib/config/local_config.example.dart',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'monospace'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AlFaseelahParentApp extends StatelessWidget {
  const AlFaseelahParentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: AppLocale.notifier,
      builder: (context, locale, _) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: AppTheme.notifier,
          builder: (context, themeMode, _) {
            return MaterialApp(
          onGenerateTitle: (context) => AppLocalizations.of(context)!.app_title,
          debugShowCheckedModeBanner: false,

          // دعم اللغة العربية والإنجليزية
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (deviceLocale, supportedLocales) {
            for (var supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == deviceLocale?.languageCode) {
                return supportedLocale;
              }
            }
            return supportedLocales.first;
          },

          // الثيم الفاتح والداكن حسب اختيار المستخدم
          theme: _buildLightTheme(),
          darkTheme: _buildDarkTheme(),
          themeMode: themeMode,

          // ✅ رجّعنا التطبيق يفتح على SplashScreen
          home: const SplashScreen(),

          // جميع المسارات
          routes: {
            '/splash': (context) => const SplashScreen(),
            '/onboarding': (context) => const OnboardingScreen(),
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/forgot-password': (context) => const ForgotPasswordScreen(),
            '/home': (context) => const HomeScreen(),
            '/child-profile': (context) => const ChildProfileScreen(),
            '/progress': (context) => const ProgressScreen(),
            '/connection': (context) => const ConnectionScreen(),
            '/library': (context) => const ContentLibraryScreen(),
            '/settings': (context) => const SettingsScreen(),
            '/notifications': (context) => const NotificationsScreen(),
            '/add-child': (context) => const AddChildScreen(),
            '/parental-controls': (context) => const ParentalControlsScreen(),
            '/ai-reports': (context) => const AIReportsScreen(),
            '/activity-detail': (context) => const ChildActivityDetailScreen(),
            '/behavior-goals': (context) => const BehaviorGoalsScreen(),
            '/board-selection': (context) => const BoardSelectionScreen(),
            '/achievements': (context) => const AchievementsScreen(),
          },
            );
          },
        );
      },
    );
  }

  // الثيم الداكن - أسطح داكنة ونصوص فاتحة بتباين واضح
  ThemeData _buildDarkTheme() {
    final base = ThemeData(brightness: Brightness.dark);
    final textTheme = GoogleFonts.tajawalTextTheme(base.textTheme);

    const Color background = Color(0xFF121218);
    const Color surface = Color(0xFF1E1E26);
    const Color fill = Color(0xFF2A2A34);
    const Color primary = Color(0xFF87CEEB);
    const Color onPrimary = Color(0xFF0F2230);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: GoogleFonts.tajawal().fontFamily,
      textTheme: textTheme,

      colorScheme: const ColorScheme.dark(
        primary: primary,
        onPrimary: onPrimary,
        secondary: Color(0xFF90EE90),
        onSecondary: Color(0xFF10240F),
        tertiary: Color(0xFF98D8AA),
        surface: surface,
        onSurface: Colors.white,
        error: Color(0xFFFF8A80),
      ),

      scaffoldBackgroundColor: background,

      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        iconTheme: IconThemeData(color: primary),
      ),

      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black45,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: surface,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primary),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: fill,
        hintStyle: TextStyle(color: Colors.grey[500]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF8A80), width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        prefixIconColor: primary,
      ),

      dialogTheme: const DialogThemeData(backgroundColor: surface),
      bottomSheetTheme: const BottomSheetThemeData(backgroundColor: surface),
      dividerTheme: DividerThemeData(color: Colors.grey[800]),
      listTileTheme: const ListTileThemeData(
        iconColor: primary,
        textColor: Colors.white,
      ),
    );
  }

  // الثيم الفاتح - الألوان الأصلية
  ThemeData _buildLightTheme() {
    final textTheme = GoogleFonts.tajawalTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: GoogleFonts.tajawal().fontFamily,
      textTheme: textTheme,

      colorScheme: const ColorScheme.light(
        primary: Color(0xFF87CEEB),
        secondary: Color(0xFF90EE90),
        tertiary: Color(0xFF98D8AA),
        surface: Colors.white,
        error: Color(0xFFE74C3C),
      ),

      scaffoldBackgroundColor: Colors.white,

      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF87CEEB),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),

      cardTheme: CardThemeData(
        elevation: 4,
        shadowColor: const Color(0xFF87CEEB).withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF87CEEB),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF87CEEB),
          side: const BorderSide(color: Color(0xFF87CEEB)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: const Color(0xFF87CEEB)),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF87CEEB), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE74C3C), width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        prefixIconColor: const Color(0xFF87CEEB),
      ),
    );
  }
}
