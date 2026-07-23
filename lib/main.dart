import 'package:flutter/material.dart';
import 'package:pearant_app/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_locale.dart';
import 'config/supabase_config.dart';

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

  // Initialize Supabase for authentication/profile handling.
  // Credentials live in lib/config/supabase_config.dart (gitignored).
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  await AppLocale.loadSavedLocale();
  runApp(const AlFaseelahParentApp());
}

class AlFaseelahParentApp extends StatelessWidget {
  const AlFaseelahParentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: AppLocale.notifier,
      builder: (context, locale, _) {
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

          // استخدام الثيم الفاتح فقط
          theme: _buildLightTheme(),
          darkTheme: _buildLightTheme(),
          themeMode: ThemeMode.light,

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
        shadowColor: const Color(0xFF87CEEB).withOpacity(0.3),
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
