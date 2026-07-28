import 'package:flutter/widgets.dart';

import '../app_locale.dart';

/// Lightweight bilingual strings (no intl). Uses [Localizations.localeOf] /
/// [AppLocale]-driven [MaterialApp.locale] so UI follows the selected language.
class AppStrings {
  AppStrings._();

  /// Resolves strings when [context] is null (e.g. auth layer) via [AppLocale].
  static String tr(BuildContext? context, String ar, String en) {
    late final Locale l;
    if (context != null) {
      try {
        l = Localizations.localeOf(context);
      } catch (_) {
        l = AppLocale.notifier.value;
      }
    } else {
      l = AppLocale.notifier.value;
    }
    return l.languageCode == 'ar' ? ar : en;
  }

  static bool _isAr(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'ar';
  }

  /// لاحقة اللغة الحالية كما تظهر في مفاتيح قاعدة البيانات (`_ar` / `_en`).
  static String get langSuffix =>
      AppLocale.notifier.value.languageCode == 'en' ? 'en' : 'ar';

  /// لاحقة اللغة المقابلة، تُستعمل للرجوع إليها عند نقص الترجمة.
  static String get otherLangSuffix => langSuffix == 'en' ? 'ar' : 'en';

  /// يختار بين نسختين من نصّ بيانات (لا نصّ واجهة) حسب اللغة الحالية،
  /// ويرجع للّغة الأخرى إن كانت النسخة المفضّلة فارغة.
  /// يعيد null إن كانت النسختان فارغتين، ليقرّر المستدعي ماذا يعرض.
  static String? localized(String? ar, String? en) {
    final arabic = ar?.trim() ?? '';
    final english = en?.trim() ?? '';
    final wantsEnglish = langSuffix == 'en';

    final preferred = wantsEnglish ? english : arabic;
    if (preferred.isNotEmpty) return preferred;

    final fallback = wantsEnglish ? arabic : english;
    return fallback.isEmpty ? null : fallback;
  }

  static String _t(BuildContext context, String ar, String en) =>
      tr(context, ar, en);

  // —— Home ——
  static String appTitle(BuildContext context) =>
      _t(context, 'عالم الفسيلة', 'Al-Faseelah World');

  static String navHome(BuildContext context) =>
      _t(context, 'الرئيسية', 'Home');

  static String navProgress(BuildContext context) =>
      _t(context, 'التقدم', 'Progress');

  static String navContent(BuildContext context) =>
      _t(context, 'المحتوى', 'Content');

  static String navAccount(BuildContext context) =>
      _t(context, 'الحساب', 'Account');

  static String quickActions(BuildContext context) =>
      _t(context, 'الإجراءات السريعة', 'Quick actions');

  static String actionChildProfile(BuildContext context) =>
      _t(context, 'ملف الطفل', 'Child profile');

  static String actionChildProfileSub(BuildContext context) =>
      _t(context, 'إدارة بيانات الأطفال', 'Manage children');

  static String actionReports(BuildContext context) =>
      _t(context, 'التقارير', 'Reports');

  static String actionReportsSub(BuildContext context) =>
      _t(context, 'تقدم التعلم', 'Learning progress');

  static String actionConnection(BuildContext context) =>
      _t(context, 'الاتصال', 'Connection');

  static String actionConnectionSub(BuildContext context) =>
      _t(context, 'توصيل اللعبة', 'Connect the game');

  static String actionContent(BuildContext context) =>
      _t(context, 'المحتوى', 'Content');

  static String actionContentSub(BuildContext context) =>
      _t(context, 'مكتبة التعليم', 'Learning library');

  static String actionBehaviorGoals(BuildContext context) =>
      _t(context, 'أهداف السلوك', 'Behavior goals');

  static String actionBehaviorGoalsSub(BuildContext context) =>
      _t(context, 'تحديد الأهداف', 'Set goals');

  static String actionAiReports(BuildContext context) =>
      _t(context, 'التقارير الذكية', 'Smart reports');

  static String actionAiReportsSub(BuildContext context) =>
      _t(context, 'تحليل التقدم', 'Progress insights');

  static String defaultUserDisplay(BuildContext context) =>
      defaultUserDisplayName(context);

  static String yourChildPlaceholder(BuildContext context) =>
      _t(context, 'طفلك', 'your child');

  static String welcomeGreeting(BuildContext context, String userName) =>
      _isAr(context)
          ? 'مرحباً $userName!  👋'
          : 'Welcome, $userName!  👋';

  static String welcomeReadyToPlay(BuildContext context, String childName) =>
      _isAr(context)
          ? '$childName مستعد للعب!'
          : '$childName is ready to play!';

  static String welcomeAddChild(BuildContext context) =>
      _t(context, 'أضف طفلك للبدء', 'Add your child to get started');

  static String statMinutesToday(BuildContext context) =>
      _t(context, 'دقيقة اليوم', 'min today');

  static String statActivitiesDone(BuildContext context) =>
      _t(context, 'أنشطة مكتملة', 'activities done');

  static String statNewStar(BuildContext context) =>
      _t(context, 'نجمة جديدة', 'new star');

  static String connectionOnline(BuildContext context) =>
      _t(context, 'اللعبة متصلة', 'Game connected');

  static String connectionDetails(BuildContext context) =>
      _t(context, 'التفاصيل', 'Details');

  static String recentActivities(BuildContext context) =>
      _t(context, 'آخر النشاطات', 'Recent activity');

  static String noActivitiesYet(BuildContext context) =>
      _t(context, 'لا توجد نشاطات بعد', 'No activity yet');

  static String noActivitiesHint(BuildContext context) =>
      _t(
        context,
        'قم بإضافة طفل وابدأ استخدام التطبيق',
        'Add a child and start using the app',
      );

  static String viewAll(BuildContext context) =>
      _t(context, 'عرض الكل', 'View all');

  static String tipOfTheDay(BuildContext context) =>
      _t(context, 'نصيحة اليوم', 'Tip of the day');

  static String tipOfTheDayBody(BuildContext context) =>
      _t(
        context,
        'شجعي طفلك على استكشاف منطقة المزرعة الجديدة!  تحتوي على أنشطة رائعة لتعلم أسماء الحيوانات وأصواتها.',
        'Encourage your child to explore the new farm area! It has great activities to learn animal names and sounds.',
      );

  // —— Settings (main surfaces) ——
  static String settingsTitle(BuildContext context) =>
      _t(context, 'الإعدادات', 'Settings');

  static String accountActive(BuildContext context) =>
      _t(context, 'حساب مفعّل', 'Account active');

  static String registeredChildren(BuildContext context) =>
      _t(context, 'الأطفال المسجلون', 'Registered children');

  static String addShort(BuildContext context) =>
      _t(context, 'إضافة', 'Add');

  static String noChildrenYetSettings(BuildContext context) =>
      _t(context, 'لا يوجد أطفال مسجلون بعد', 'No children registered yet');

  static String yearsOldShort(BuildContext context, int age) =>
      _isAr(context) ? '$age سنوات' : '$age years';

  static String playingNow(BuildContext context) =>
      _t(context, 'يلعب الآن', 'Playing now');

  static String sectionGeneral(BuildContext context) =>
      _t(context, 'الإعدادات العامة', 'General');

  static String darkMode(BuildContext context) =>
      _t(context, 'الوضع الداكن', 'Dark mode');

  static String darkModeSub(BuildContext context) =>
      _t(context, 'تغيير مظهر التطبيق', 'Change app appearance');

  static String sounds(BuildContext context) =>
      _t(context, 'الأصوات', 'Sounds');

  static String soundsSub(BuildContext context) =>
      _t(context, 'أصوات التنبيهات والتفاعل', 'Alert and interaction sounds');

  static String language(BuildContext context) =>
      _t(context, 'اللغة', 'Language');

  static String autoUpdate(BuildContext context) =>
      _t(context, 'التحديث التلقائي', 'Auto update');

  static String autoUpdateSub(BuildContext context) =>
      _t(context, 'تحديث المحتوى تلقائياً', 'Update content automatically');

  static String notificationsSection(BuildContext context) =>
      _t(context, 'الإشعارات', 'Notifications');

  static String enableNotifications(BuildContext context) =>
      _t(context, 'تفعيل الإشعارات', 'Enable notifications');

  static String enableNotificationsSub(BuildContext context) =>
      _t(context, 'استلام إشعارات التطبيق', 'Receive app notifications');

  static String customizeNotifications(BuildContext context) =>
      _t(context, 'تخصيص الإشعارات', 'Customize notifications');

  static String customizeNotificationsSub(BuildContext context) =>
      _t(context, 'اختر أنواع الإشعارات', 'Choose notification types');

  static String parentalControls(BuildContext context) =>
      _t(context, 'الرقابة الأبوية', 'Parental controls');

  static String dailyTimeLimit(BuildContext context) =>
      _t(context, 'الحد الزمني اليومي', 'Daily time limit');

  static String minutesCount(BuildContext context, int n) =>
      _isAr(context) ? '$n دقيقة' : '$n min';

  static String contentFilter(BuildContext context) =>
      _t(context, 'فلترة المحتوى', 'Content filter');

  static String contentFilterSub(BuildContext context) =>
      _t(context, 'التحكم في المحتوى المعروض', 'Control shown content');

  static String usageSchedule(BuildContext context) =>
      _t(context, 'جدول الاستخدام', 'Usage schedule');

  static String usageScheduleSub(BuildContext context) =>
      _t(
        context,
        'تحديد أوقات اللعب المسموحة',
        'Set allowed play times',
      );

  static String pinCode(BuildContext context) =>
      _t(context, 'رمز الحماية', 'PIN');

  static String pinCodeSub(BuildContext context) =>
      _t(context, 'تغيير رمز PIN', 'Change PIN code');

  static String privacyData(BuildContext context) =>
      _t(context, 'الخصوصية والبيانات', 'Privacy & data');

  static String shareAnalytics(BuildContext context) =>
      _t(context, 'مشاركة التحليلات', 'Share analytics');

  static String shareAnalyticsSub(BuildContext context) =>
      _t(context, 'المساعدة في تحسين التطبيق', 'Help improve the app');

  static String downloadData(BuildContext context) =>
      _t(context, 'تحميل البيانات', 'Download data');

  static String downloadDataSub(BuildContext context) =>
      _t(context, 'تحميل نسخة من بياناتك', 'Download a copy of your data');

  static String deleteData(BuildContext context) =>
      _t(context, 'حذف البيانات', 'Delete data');

  static String deleteDataSub(BuildContext context) =>
      _t(context, 'حذف جميع البيانات نهائياً', 'Permanently delete all data');

  static String supportHelp(BuildContext context) =>
      _t(context, 'الدعم والمساعدة', 'Support');

  static String faq(BuildContext context) =>
      _t(context, 'الأسئلة الشائعة', 'FAQ');

  static String faqSub(BuildContext context) =>
      _t(context, 'إجابات على الأسئلة المتكررة', 'Answers to common questions');

  static String contactUs(BuildContext context) =>
      _t(context, 'تواصل معنا', 'Contact us');

  static String contactUsSub(BuildContext context) =>
      _t(context, 'إرسال رسالة للدعم الفني', 'Send a message to support');

  static String rateApp(BuildContext context) =>
      _t(context, 'تقييم التطبيق', 'Rate the app');

  static String rateAppSub(BuildContext context) =>
      _t(context, 'شاركنا رأيك', 'Share your feedback');

  static String privacyPolicy(BuildContext context) =>
      _t(context, 'سياسة الخصوصية', 'Privacy policy');

  static String privacyPolicySub(BuildContext context) =>
      _t(context, 'الشروط والأحكام', 'Terms and conditions');

  static String logout(BuildContext context) =>
      _t(context, 'تسجيل الخروج', 'Log out');

  static String logoutConfirmTitle(BuildContext context) =>
      _t(context, 'تسجيل الخروج', 'Log out');

  static String logoutConfirmBody(BuildContext context) =>
      _t(
        context,
        'هل أنت متأكد من تسجيل الخروج من حسابك؟',
        'Are you sure you want to log out?',
      );

  static String logoutSuccess(BuildContext context) =>
      _t(context, 'تم تسجيل الخروج بنجاح', 'Logged out successfully');

  static String chooseLanguage(BuildContext context) =>
      _t(context, 'اختر اللغة', 'Choose language');

  static String languageChangedAr(BuildContext context) =>
      _t(context, 'تم تغيير اللغة إلى العربية', 'Language changed to Arabic');

  static String languageChangedEn(BuildContext context) =>
      _t(context, 'Language changed to English', 'Language changed to English');

  // —— Child profile ——
  static String childProfileTitle(BuildContext context) =>
      _t(context, 'ملف الطفل', 'Child profile');

  static String noChildrenRegistered(BuildContext context) =>
      _t(context, 'لا يوجد أطفال مسجلين', 'No children registered');

  static String addChild(BuildContext context) =>
      _t(context, 'إضافة طفل', 'Add child');

  static String interests(BuildContext context) =>
      _t(context, 'الاهتمامات', 'Interests');

  static String edit(BuildContext context) => _t(context, 'تعديل', 'Edit');

  static String noInterestsSet(BuildContext context) =>
      _t(context, 'لا توجد اهتمامات محددة', 'No interests selected');

  static String learningProgress(BuildContext context) =>
      _t(context, 'تقدم التعلم', 'Learning progress');

  static String skillLanguage(BuildContext context) =>
      _t(context, 'اللغة', 'Language');

  static String skillMath(BuildContext context) =>
      _t(context, 'الرياضيات', 'Math');

  static String skillSocial(BuildContext context) =>
      _t(context, 'المهارات الاجتماعية', 'Social skills');

  static String skillCreativity(BuildContext context) =>
      _t(context, 'الإبداع', 'Creativity');

  static String educationalSettings(BuildContext context) =>
      _t(context, 'الإعدادات التربوية', 'Learning settings');

  static String dailyUsageTitle(BuildContext context) =>
      _t(context, 'وقت الاستخدام اليومي', 'Daily screen time');

  static String dailyUsageSubtitle(BuildContext context) =>
      _t(context, '45 دقيقة', '45 minutes');

  static String allowedContentTitle(BuildContext context) =>
      _t(context, 'المحتوى المسموح', 'Allowed content');

  static String allowedContentSubtitle(BuildContext context) =>
      _t(
        context,
        'قصص، أنشطة، ألعاب تعليمية',
        'Stories, activities, educational games',
      );

  static String learningPathTitle(BuildContext context) =>
      _t(context, 'المسار التعليمي', 'Learning path');

  static String learningPathSubtitle(BuildContext context) =>
      _t(
        context,
        'متوازن - تركيز على اللغة',
        'Balanced — focus on language',
      );

  static String reportsButton(BuildContext context) =>
      _t(context, 'التقارير', 'Reports');

  static String contentButton(BuildContext context) =>
      _t(context, 'المحتوى', 'Content');

  static String deleteChildProfile(BuildContext context) =>
      _t(context, 'حذف ملف الطفل', 'Delete child profile');

  static String deleteChildSuccess(BuildContext context, String name) =>
      _isAr(context) ? 'تم حذف $name بنجاح' : '$name was deleted successfully';

  static String confirmDelete(BuildContext context) =>
      _t(context, 'تأكيد الحذف', 'Confirm delete');

  static String confirmDeleteChildBody(
    BuildContext context,
    String childName,
  ) =>
      _isAr(context)
          ? 'هل أنت متأكد من حذف ملف "$childName"؟\nلا يمكن التراجع عن هذا الإجراء.'
          : 'Are you sure you want to delete profile "$childName"?\nThis cannot be undone.';

  static String cancel(BuildContext context) =>
      _t(context, 'إلغاء', 'Cancel');

  static String delete(BuildContext context) =>
      _t(context, 'حذف', 'Delete');

  static String editChildTitle(BuildContext context) =>
      _t(context, 'تعديل بيانات الطفل', 'Edit child');

  static String childNameLabel(BuildContext context) =>
      _t(context, 'اسم الطفل', 'Child name');

  static String childAgeLabel(BuildContext context) =>
      _t(context, 'العمر', 'Age');

  static String rfidLabel(BuildContext context) =>
      _t(context, 'رقم قطعة RFID', 'RFID Tag ID');

  static String rfidHint(BuildContext context) =>
      _t(context, 'مثال: A1B2C3D4', 'e.g. A1B2C3D4');

  static String rfidHelperText(BuildContext context) =>
      _t(
        context,
        'الرقم المكتوب على قطعة الـ RFID الخاصة بالطفل، عشان الراسبيري باي يتعرف عليه تلقائياً',
        'The ID printed on the child\'s RFID tag, so the Raspberry Pi can recognize them automatically',
      );

  static String rfidSectionTitle(BuildContext context) =>
      _t(context, 'قطعة الـ RFID', 'RFID Tag');

  static String rfidNotAssigned(BuildContext context) =>
      _t(context, 'لم يتم تعيين قطعة بعد', 'No tag assigned yet');

  static String save(BuildContext context) => _t(context, 'حفظ', 'Save');

  static String changesSaved(BuildContext context) =>
      _t(context, 'تم حفظ التغييرات', 'Changes saved');

  static String selectInterestsTitle(BuildContext context) =>
      _t(context, 'اختر اهتمامات الطفل', 'Choose interests');

  static String yearsUnit(BuildContext context) =>
      _t(context, 'سنوات', 'years');

  static String minutesPerDayStat(BuildContext context) =>
      _t(context, 'دقيقة/يوم', 'min/day');

  static String achievementStat(BuildContext context) =>
      _t(context, 'إنجاز', 'Achievement');

  static String dayStat(BuildContext context) =>
      _t(context, 'يوم', 'Days');

  static String appVersion(BuildContext context) =>
      _t(context, 'الإصدار 1.0.0', 'Version 1.0.0');

  static String copyright(BuildContext context) =>
      _t(context, '© 2024 جميع الحقوق محفوظة', '© 2024 All rights reserved');

  // —— Splash ——
  static String splashTagline(BuildContext context) =>
      _t(context, 'تعلم • العب • انمُ', 'Learn • Play • Grow');

  // —— Login ——
  static String loginParentAppSubtitle(BuildContext context) =>
      _t(context, 'تطبيق الأهل', 'Parent app');

  static String loginTitle(BuildContext context) =>
      _t(context, 'تسجيل الدخول', 'Log in');

  static String loginSubtitle(BuildContext context) =>
      _t(context, 'أدخل بياناتك للمتابعة', 'Enter your details to continue');

  static String emailLabel(BuildContext context) =>
      _t(context, 'البريد الإلكتروني', 'Email');

  static String emailHintSample(BuildContext context) =>
      'example@email.com';

  static String passwordLabel(BuildContext context) =>
      _t(context, 'كلمة المرور', 'Password');

  static String passwordHintDots(BuildContext context) => '••••••••';

  static String validationEmailRequired(BuildContext context) =>
      _t(context, 'الرجاء إدخال البريد الإلكتروني', 'Please enter your email');

  static String validationEmailInvalid(BuildContext context) => _t(
        context,
        'الرجاء إدخال بريد إلكتروني صحيح',
        'Please enter a valid email',
      );

  static String validationPasswordRequired(BuildContext context) => _t(
        context,
        'الرجاء إدخال كلمة المرور',
        'Please enter your password',
      );

  static String validationPasswordMinLength(BuildContext context) => _t(
        context,
        'كلمة المرور يجب أن تكون 6 أحرف على الأقل',
        'Password must be at least 6 characters',
      );

  static String rememberMe(BuildContext context) =>
      _t(context, 'تذكرني', 'Remember me');

  static String forgotPasswordLink(BuildContext context) =>
      _t(context, 'نسيت كلمة المرور؟', 'Forgot password?');

  static String loginButton(BuildContext context) =>
      _t(context, 'تسجيل الدخول', 'Log in');

  static String orDivider(BuildContext context) =>
      _t(context, 'أو', 'or');

  static String continueWithGoogle(BuildContext context) =>
      _t(context, 'المتابعة مع Google', 'Continue with Google');

  static String continueWithApple(BuildContext context) =>
      _t(context, 'المتابعة مع Apple', 'Continue with Apple');

  static String googleLoginUnavailable(BuildContext context) => _t(
        context,
        'تسجيل الدخول بـ Google غير متاح حالياً',
        'Google sign-in is not available yet',
      );

  static String appleLoginUnavailable(BuildContext context) => _t(
        context,
        'تسجيل الدخول بـ Apple غير متاح حالياً',
        'Apple sign-in is not available yet',
      );

  static String noAccountPrompt(BuildContext context) =>
      _t(context, 'ليس لديك حساب؟', 'Don’t have an account?');

  static String createAccountLink(BuildContext context) =>
      _t(context, 'إنشاء حساب', 'Create account');

  // —— Forgot password ——
  static String forgotPasswordTitle(BuildContext context) =>
      _t(context, 'نسيت كلمة المرور؟', 'Forgot password?');

  static String forgotPasswordDescription(BuildContext context) => _t(
        context,
        'لا تقلق! أدخل بريدك الإلكتروني وسنرسل لك رابط لإعادة تعيين كلمة المرور',
        'No worries! Enter your email and we’ll send a link to reset your password',
      );

  static String sendResetLink(BuildContext context) =>
      _t(context, 'إرسال رابط الاستعادة', 'Send reset link');

  static String backToLogin(BuildContext context) =>
      _t(context, 'العودة لتسجيل الدخول', 'Back to log in');

  static String emailSentTitle(BuildContext context) =>
      _t(context, 'تم إرسال البريد!', 'Email sent!');

  static String emailSentSubtitle(BuildContext context) => _t(
        context,
        'تم إرسال رابط استعادة كلمة المرور إلى:',
        'A password reset link was sent to:',
      );

  static String forgotStepCheckInbox(BuildContext context) => _t(
        context,
        'تحقق من صندوق الوارد في بريدك الإلكتروني',
        'Check your email inbox',
      );

  static String forgotStepClickLink(BuildContext context) => _t(
        context,
        'اضغط على رابط استعادة كلمة المرور',
        'Tap the password reset link',
      );

  static String forgotStepNewPassword(BuildContext context) => _t(
        context,
        'أدخل كلمة المرور الجديدة',
        'Enter your new password',
      );

  static String forgotSpamHint(BuildContext context) => _t(
        context,
        'إذا لم تجد البريد، تحقق من مجلد الرسائل غير المرغوب فيها (Spam)',
        'If you don’t see the email, check your spam folder',
      );

  static String emailNotReceived(BuildContext context) =>
      _t(context, 'لم يصلك البريد؟', 'Didn’t get the email?');

  static String resend(BuildContext context) =>
      _t(context, 'إعادة الإرسال', 'Resend');

  static String resendWithSeconds(BuildContext context, int s) =>
      _isAr(context) ? 'إعادة الإرسال ($s)' : 'Resend ($s)';

  static String emailResentSnack(BuildContext context) => _t(
        context,
        'تم إعادة إرسال البريد الإلكتروني',
        'Email resent',
      );

  // —— Register ——
  static String registerAppBarTitle(BuildContext context) =>
      _t(context, 'إنشاء حساب جديد', 'Create account');

  static String agreeTermsRequiredSnack(BuildContext context) => _t(
        context,
        'يجب الموافقة على الشروط والأحكام',
        'You must accept the terms and conditions',
      );

  static String registerSuccessTitle(BuildContext context) => _t(
        context,
        'تم إنشاء الحساب بنجاح!',
        'Account created successfully!',
      );

  static String registerWelcomeBody(BuildContext context, String name) =>
      _isAr(context)
          ? 'مرحباً $name، يمكنك الآن استخدام التطبيق'
          : 'Welcome, $name. You can start using the app.';

  static String getStarted(BuildContext context) =>
      _t(context, 'البدء', 'Get started');

  static String regStepData(BuildContext context) =>
      _t(context, 'البيانات', 'Details');

  static String regStepSecurity(BuildContext context) =>
      _t(context, 'الأمان', 'Security');

  static String regStepConfirm(BuildContext context) =>
      _t(context, 'التأكيد', 'Confirm');

  static String regPersonalTitle(BuildContext context) =>
      _t(context, 'البيانات الشخصية', 'Personal details');

  static String regPersonalSubtitle(BuildContext context) => _t(
        context,
        'أدخل بياناتك الشخصية لإنشاء حسابك',
        'Enter your details to create your account',
      );

  static String fullNameLabel(BuildContext context) =>
      _t(context, 'الاسم الكامل', 'Full name');

  static String fullNameHint(BuildContext context) =>
      _t(context, 'أدخل اسمك الكامل', 'Enter your full name');

  static String validationNameRequired(BuildContext context) =>
      _t(context, 'الرجاء إدخال الاسم', 'Please enter your name');

  static String validationNameMinLength(BuildContext context) => _t(
        context,
        'الاسم يجب أن يكون 3 أحرف على الأقل',
        'Name must be at least 3 characters',
      );

  static String phoneOptionalLabel(BuildContext context) => _t(
        context,
        'رقم الهاتف (اختياري)',
        'Phone (optional)',
      );

  static String phoneHint(BuildContext context) =>
      _t(context, '+966 5X XXX XXXX', '+966 5X XXX XXXX');

  static String regSecurityTitle(BuildContext context) =>
      _t(context, 'إعدادات الأمان', 'Security');

  static String regSecuritySubtitle(BuildContext context) => _t(
        context,
        'أنشئ كلمة مرور قوية لحماية حسابك',
        'Create a strong password to protect your account',
      );

  static String confirmPasswordLabel(BuildContext context) =>
      _t(context, 'تأكيد كلمة المرور', 'Confirm password');

  static String validationConfirmPasswordRequired(BuildContext context) => _t(
        context,
        'الرجاء تأكيد كلمة المرور',
        'Please confirm your password',
      );

  static String validationPasswordMismatch(BuildContext context) => _t(
        context,
        'كلمة المرور غير متطابقة',
        'Passwords do not match',
      );

  static String passwordStrengthLabel(BuildContext context) =>
      _t(context, 'قوة كلمة المرور', 'Password strength');

  static String passwordWeak(BuildContext context) =>
      _t(context, 'ضعيفة', 'Weak');

  static String passwordMedium(BuildContext context) =>
      _t(context, 'متوسطة', 'Fair');

  static String passwordGood(BuildContext context) =>
      _t(context, 'جيدة', 'Good');

  static String passwordStrong(BuildContext context) =>
      _t(context, 'قوية', 'Strong');

  static String pwdHint6Chars(BuildContext context) =>
      _t(context, '6 أحرف', '6+ chars');

  static String pwdHintUpper(BuildContext context) =>
      _t(context, 'حرف كبير', 'Uppercase');

  static String pwdHintDigit(BuildContext context) =>
      _t(context, 'رقم', 'Number');

  static String regConfirmTitle(BuildContext context) =>
      _t(context, 'تأكيد البيانات', 'Review details');

  static String regConfirmSubtitle(BuildContext context) => _t(
        context,
        'راجع بياناتك قبل إنشاء الحساب',
        'Review your information before signing up',
      );

  static String summaryName(BuildContext context) =>
      _t(context, 'الاسم', 'Name');

  static String summaryEmail(BuildContext context) =>
      _t(context, 'البريد', 'Email');

  static String summaryPhone(BuildContext context) =>
      _t(context, 'الهاتف', 'Phone');

  static String iAgreePrefix(BuildContext context) =>
      _t(context, 'أوافق على ', 'I agree to the ');

  static String termsLink(BuildContext context) =>
      _t(context, 'الشروط والأحكام', 'Terms & conditions');

  static String andWord(BuildContext context) =>
      _t(context, ' و', ' and ');

  static String privacyLink(BuildContext context) =>
      _t(context, 'سياسة الخصوصية', 'Privacy policy');

  static String previous(BuildContext context) =>
      _t(context, 'السابق', 'Back');

  static String next(BuildContext context) =>
      _t(context, 'التالي', 'Next');

  static String createAccountButton(BuildContext context) =>
      _t(context, 'إنشاء حساب', 'Create account');

  static String haveAccountPrompt(BuildContext context) =>
      _t(context, 'لديك حساب بالفعل؟', 'Already have an account?');

  static String termsDialogTitle(BuildContext context) =>
      _t(context, 'الشروط والأحكام', 'Terms & conditions');

  static String termsDialogBody(BuildContext context) => _t(
        context,
        'شروط وأحكام استخدام تطبيق عالم الفسيلة:\n\n'
        '1. يجب أن يكون المستخدم ولي أمر الطفل أو وصيه القانوني.\n\n'
        '2. يتحمل ولي الأمر مسؤولية استخدام التطبيق ومراقبة تفاعل الطفل.\n\n'
        '3. نحافظ على خصوصية بيانات الأطفال ولا نشاركها مع أطراف ثالثة.\n\n'
        '4. المحتوى التعليمي مصمم للأطفال من 3-12 سنة.\n\n'
        '5. يحق لنا تحديث الشروط والأحكام مع إشعار المستخدمين.',
        'Terms of use for Al-Faseelah World:\n\n'
        '1. You must be the child’s parent or legal guardian.\n\n'
        '2. The parent is responsible for app use and supervising the child.\n\n'
        '3. We protect children’s data and do not share it with third parties.\n\n'
        '4. Educational content is designed for ages 3–12.\n\n'
        '5. We may update these terms with notice to users.',
      );

  static String privacyDialogTitleReg(BuildContext context) =>
      _t(context, 'سياسة الخصوصية', 'Privacy policy');

  static String privacyDialogBodyReg(BuildContext context) => _t(
        context,
        'سياسة الخصوصية لتطبيق عالم الفسيلة:\n\n'
        '1. نجمع البيانات الضرورية فقط لتشغيل التطبيق.\n\n'
        '2. بيانات الأطفال محمية ولا يتم مشاركتها.\n\n'
        '3. نستخدم التشفير لحماية جميع البيانات.\n\n'
        '4. يمكنك طلب حذف بياناتك في أي وقت.\n\n'
        '5. لا نستخدم البيانات لأغراض إعلانية.',
        'Privacy policy for Al-Faseelah World:\n\n'
        '1. We only collect data needed to run the app.\n\n'
        '2. Children’s data is protected and not shared.\n\n'
        '3. We use encryption to protect data.\n\n'
        '4. You can request deletion of your data at any time.\n\n'
        '5. We do not use data for advertising.',
      );

  static String close(BuildContext context) =>
      _t(context, 'إغلاق', 'Close');

  // —— Add child ——
  static String addChildAppBar(BuildContext context) =>
      _t(context, 'إضافة طفل جديد', 'Add a child');

  static String selectAvatarTitle(BuildContext context) =>
      _t(context, 'اختر صورة رمزية', 'Choose an avatar');

  static String childNameFieldTitle(BuildContext context) =>
      _t(context, 'اسم الطفل', 'Child’s name');

  static String childNameHint(BuildContext context) =>
      _t(context, 'أدخل اسم الطفل', 'Enter the child’s name');

  static String validationChildNameRequired(BuildContext context) => _t(
        context,
        'الرجاء إدخال اسم الطفل',
        'Please enter the child’s name',
      );

  static String validationChildNameMin(BuildContext context) => _t(
        context,
        'الاسم يجب أن يكون حرفين على الأقل',
        'Name must be at least 2 characters',
      );

  static String ageSectionTitle(BuildContext context) =>
      _t(context, 'العمر', 'Age');

  static String ageRangeHint(BuildContext context) =>
      _t(context, 'العمر المناسب: 3-9 سنوات', 'Recommended age: 3–9 years');

  static String genderSectionTitle(BuildContext context) =>
      _t(context, 'الجنس', 'Gender');

  static String genderMale(BuildContext context) =>
      _t(context, 'ذكر', 'Boy');

  static String genderFemale(BuildContext context) =>
      _t(context, 'أنثى', 'Girl');

  /// Map stored gender (Arabic or simple English) to localized label for display.
  static String genderLabelFromStored(BuildContext context, String stored) {
    final s = stored.trim();
    if (s == 'ذكر' ||
        s.toLowerCase() == 'boy' ||
        s.toLowerCase() == 'male') {
      return genderMale(context);
    }
    if (s == 'أنثى' ||
        s == 'انثى' ||
        s.toLowerCase() == 'girl' ||
        s.toLowerCase() == 'female') {
      return genderFemale(context);
    }
    return stored;
  }

  /// All interest values that may appear in storage (Arabic canonical + profile extras).
  static List<String> interestStorageOptions() => [
        'القصص',
        'قصص الحيوانات',
        'الأرقام',
        'الحروف',
        'الألوان',
        'الحيوانات',
        'الطبيعة',
        'الفضاء',
        'القرآن',
        'الرسم',
        'الفن',
        'الرياضة',
        'العلوم',
        'الطبخ',
      ];



  /// Safe display for stored interest strings (Arabic canonical, legacy English, or custom).
  static String interestDisplayLabel(BuildContext context, String raw) {
    final s = raw.trim();
    switch (s) {
      case 'القصص':
      case 'Stories':
        return _t(context, 'القصص', 'Stories');
      case 'قصص الحيوانات':
      case 'Animal stories':
        return _t(context, 'قصص الحيوانات', 'Animal stories');
      case 'الأرقام':
      case 'Numbers':
        return _t(context, 'الأرقام', 'Numbers');
      case 'الحروف':
      case 'Letters':
        return _t(context, 'الحروف', 'Letters');
      case 'الألوان':
      case 'Colors':
      case 'Colours':
        return _t(context, 'الألوان', 'Colors');
      case 'الحيوانات':
      case 'Animals':
        return _t(context, 'الحيوانات', 'Animals');
      case 'الطبيعة':
      case 'Nature':
        return _t(context, 'الطبيعة', 'Nature');
      case 'الفضاء':
      case 'Space':
        return _t(context, 'الفضاء', 'Space');
      case 'القرآن':
      case 'Quran':
        return _t(context, 'القرآن', 'Quran');
      case 'الرسم':
      case 'Drawing':
        return _t(context, 'الرسم', 'Drawing');
      case 'الفن':
      case 'Art':
        return _t(context, 'الفن', 'Art');
      case 'الرياضة':
      case 'Sports':
        return _t(context, 'الرياضة', 'Sports');
      case 'العلوم':
      case 'Science':
        return _t(context, 'العلوم', 'Science');
      case 'الطبخ':
      case 'Cooking':
        return _t(context, 'الطبخ', 'Cooking');
      default:
        return raw;
    }
  }

  /// Display only; keep DB values as Arabic ذكر/أنثى when selecting.
  static String interestsSelectedCount(BuildContext context, int n) =>
      _isAr(context) ? '$n مختار' : '$n selected';

  static String interestsPickHint(BuildContext context) => _t(
        context,
        'اختر اهتمامات طفلك لتخصيص المحتوى',
        'Pick interests to personalize content',
      );

  static String validationPickOneInterest(BuildContext context) => _t(
        context,
        'الرجاء اختيار اهتمام واحد على الأقل',
        'Please select at least one interest',
      );

  static String childAddedSuccess(BuildContext context, String name) =>
      _isAr(context)
          ? 'تم إضافة $name بنجاح! 🎉'
          : '$name was added successfully! 🎉';

  // —— Settings (dialogs & extras) ——
  static String editProfileSheetTitle(BuildContext context) =>
      _t(context, 'تعديل الملف الشخصي', 'Edit profile');

  static String nameFieldShort(BuildContext context) =>
      _t(context, 'الاسم', 'Name');

  static String newPasswordOptionalLabel(BuildContext context) => _t(
        context,
        'كلمة المرور الجديدة (اختياري)',
        'New password (optional)',
      );

  static String childSettingsTitle(BuildContext context, String name) =>
      _isAr(context) ? 'إعدادات $name' : '$name’s settings';

  static String childSettingsEditProfile(BuildContext context) =>
      _t(context, 'تعديل الملف', 'Edit profile');

  static String childSettingsTimeLimit(BuildContext context) =>
      _t(context, 'الحد الزمني', 'Time limit');

  static String childSettingsReports(BuildContext context) =>
      _t(context, 'التقارير', 'Reports');

  static String childSettingsDeleteProfile(BuildContext context) =>
      _t(context, 'حذف الملف', 'Delete profile');

  static String deleteChildFileTitle(BuildContext context) =>
      _t(context, 'حذف ملف الطفل', 'Delete child profile');

  static String deleteChildFileBody(BuildContext context, String childName) =>
      _isAr(context)
          ? 'هل أنت متأكد من حذف ملف $childName؟\n\nسيتم حذف جميع البيانات والتقارير المتعلقة بهذا الملف. لا يمكن التراجع عن هذا الإجراء.'
          : 'Delete $childName’s profile?\n\nAll related data and reports will be removed. This cannot be undone.';

  static String childFileDeletedSnack(BuildContext context, String name) =>
      _isAr(context) ? 'تم حذف ملف $name' : 'Deleted $name’s profile';

  static String languageArabicTitle(BuildContext context) =>
      _t(context, 'العربية', 'Arabic');

  static String languageArabicSubtitle(BuildContext context) =>
      _t(context, 'Arabic', 'Arabic');

  static String languageEnglishTitle(BuildContext context) =>
      _t(context, 'English', 'English');

  static String languageEnglishSubtitle(BuildContext context) =>
      _t(context, 'الإنجليزية', 'English');

  static String notifCustomizeSheetTitle(BuildContext context) =>
      _t(context, 'تخصيص الإشعارات', 'Notification preferences');

  static String notifChildActivityTitle(BuildContext context) =>
      _t(context, 'نشاطات الطفل', 'Child activities');

  static String notifChildActivitySub(BuildContext context) => _t(
        context,
        'إشعارات عند بدء أو انتهاء اللعب',
        'Alerts when play starts or ends',
      );

  static String notifProgressReportsTitle(BuildContext context) => _t(
        context,
        'تقارير التقدم',
        'Progress reports',
      );

  static String notifProgressReportsSub(BuildContext context) => _t(
        context,
        'ملخص أسبوعي لتقدم الطفل',
        'Weekly summary of your child’s progress',
      );

  static String notifTipsTitle(BuildContext context) =>
      _t(context, 'نصائح تربوية', 'Parenting tips');

  static String notifTipsSub(BuildContext context) => _t(
        context,
        'نصائح وتوصيات من الذكاء الاصطناعي',
        'Tips and suggestions powered by AI',
      );

  static String notifUpdatesTitle(BuildContext context) =>
      _t(context, 'التحديثات', 'Updates');

  static String notifUpdatesSub(BuildContext context) =>
      _t(context, 'محتوى وميزات جديدة', 'New content and features');

  static String notifSettingsSavedSnack(BuildContext context) => _t(
        context,
        'تم حفظ إعدادات الإشعارات',
        'Notification settings saved',
      );

  static String contentFilterSheetTitle(BuildContext context) =>
      _t(context, 'فلترة المحتوى', 'Content filter');

  static String contentFilterSheetSubtitle(BuildContext context) => _t(
        context,
        'اختر أنواع المحتوى المسموح بها للطفل',
        'Choose allowed content types for your child',
      );

  static String contentFilterSavedSnack(BuildContext context) => _t(
        context,
        'تم حفظ إعدادات المحتوى',
        'Content settings saved',
      );

  static String scheduleSheetTitle(BuildContext context) =>
      _t(context, 'جدول الاستخدام', 'Usage schedule');

  static String startTimeLabel(BuildContext context) =>
      _t(context, 'وقت البدء', 'Start time');

  static String endTimeLabel(BuildContext context) =>
      _t(context, 'وقت الانتهاء', 'End time');

  static String usageDaysLabel(BuildContext context) =>
      _t(context, 'أيام الاستخدام', 'Usage days');

  static String scheduleSavedSnack(BuildContext context) => _t(
        context,
        'تم حفظ جدول الاستخدام',
        'Schedule saved',
      );

  static List<String> weekDayShortLetters(BuildContext context) =>
      _isAr(context)
          ? ['س', 'أ', 'إ', 'ث', 'أ', 'خ', 'ج']
          : ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  static String changePinSheetTitle(BuildContext context) =>
      _t(context, 'تغيير رمز الحماية', 'Change PIN');

  static String pinCurrentLabel(BuildContext context) =>
      _t(context, 'رمز PIN الحالي', 'Current PIN');

  static String pinNewLabel(BuildContext context) =>
      _t(context, 'رمز PIN الجديد', 'New PIN');

  static String pinConfirmLabel(BuildContext context) =>
      _t(context, 'تأكيد رمز PIN الجديد', 'Confirm new PIN');

  static String pinChangedSnack(BuildContext context) => _t(
        context,
        'تم تغيير رمز الحماية بنجاح',
        'PIN updated successfully',
      );

  static String pinMismatchSnack(BuildContext context) => _t(
        context,
        'رمز PIN غير متطابق أو غير صحيح',
        'PIN does not match or is invalid',
      );

  static String downloadDataTitle(BuildContext context) =>
      _t(context, 'تحميل البيانات', 'Download data');

  static String downloadDataBody(BuildContext context) => _t(
        context,
        'سيتم إرسال نسخة من بياناتك إلى بريدك الإلكتروني.\n\nتتضمن البيانات:\n• معلومات الحساب\n• ملفات الأطفال\n• تقارير التقدم\n• الإعدادات',
        'A copy of your data will be sent to your email.\n\nIt includes:\n• Account information\n• Child profiles\n• Progress reports\n• Settings',
      );

  static String downloadConfirmSnack(BuildContext context) => _t(
        context,
        'سيتم إرسال البيانات إلى بريدك الإلكتروني',
        'Your data will be sent to your email',
      );

  static String downloadAction(BuildContext context) =>
      _t(context, 'تحميل', 'Download');

  static String deleteAllDataTitle(BuildContext context) =>
      _t(context, 'حذف جميع البيانات', 'Delete all data');

  static String deleteAllDataBody(BuildContext context) => _t(
        context,
        'هل أنت متأكد من حذف جميع بياناتك؟\n\n⚠️ تحذير: سيتم حذف:\n• حسابك الشخصي\n• جميع ملفات الأطفال\n• جميع التقارير والإنجازات\n• جميع الإعدادات\n\nهذا الإجراء لا يمكن التراجع عنه! ',
        'Delete all your data?\n\n⚠️ This will remove:\n• Your account\n• All child profiles\n• Reports and achievements\n• All settings\n\nThis cannot be undone!',
      );

  static String finalDeleteTitle(BuildContext context) =>
      _t(context, 'تأكيد الحذف النهائي', 'Confirm permanent deletion');

  static String typeDeleteToConfirm(BuildContext context) => _t(
        context,
        'اكتب "حذف" للتأكيد: ',
        'Type the word to confirm: ',
      );

  static String hintTypeDelete(BuildContext context) =>
      _t(context, 'اكتب حذف', 'Type DELETE');

  static String deleteConfirmKeyword(BuildContext context) =>
      _t(context, 'حذف', 'DELETE');

  static String allDataDeletedSnack(BuildContext context) =>
      _t(context, 'تم حذف جميع البيانات', 'All data deleted');

  static String confirmDeleteAction(BuildContext context) =>
      _t(context, 'تأكيد الحذف', 'Confirm delete');

  static String faqSheetTitle(BuildContext context) =>
      _t(context, 'الأسئلة الشائعة', 'FAQ');

  static String contactSheetTitle(BuildContext context) =>
      _t(context, 'تواصل معنا', 'Contact us');

  static String contactSubjectLabel(BuildContext context) =>
      _t(context, 'الموضوع', 'Subject');

  static String contactMessageLabel(BuildContext context) =>
      _t(context, 'الرسالة', 'Message');

  static String send(BuildContext context) =>
      _t(context, 'إرسال', 'Send');

  static String contactSentSnack(BuildContext context) => _t(
        context,
        'تم إرسال رسالتك، سنرد عليك قريباً',
        'Your message was sent. We’ll reply soon.',
      );

  static String rateAppDialogTitle(BuildContext context) =>
      _t(context, 'تقييم التطبيق', 'Rate the app');

  static String rateAppQuestion(BuildContext context) => _t(
        context,
        'كيف تقيّم تجربتك مع عالم الفسيلة؟',
        'How would you rate your experience with Al-Faseelah World?',
      );

  static String rateTapStars(BuildContext context) =>
      _t(context, 'اضغط على النجوم للتقييم', 'Tap the stars to rate');

  static String rateSorry(BuildContext context) =>
      _t(context, 'نأسف لعدم رضاك 😔', 'Sorry you’re not satisfied 😔');

  static String rateThanks(BuildContext context) =>
      _t(context, 'شكراً لتقييمك!  😊', 'Thanks for your feedback! 😊');

  static String rateGreat(BuildContext context) =>
      _t(context, 'رائع! نسعد بذلك!  🎉', 'Great! We’re glad! 🎉');

  static String later(BuildContext context) =>
      _t(context, 'لاحقاً', 'Later');

  static String thanksForRatingSnack(BuildContext context) =>
      _t(context, 'شكراً لتقييمك!  ❤️', 'Thanks for your rating! ❤️');

  static String privacyPolicySheetTitle(BuildContext context) =>
      _t(context, 'سياسة الخصوصية', 'Privacy policy');

  static String policyUpdatedLine(BuildContext context) =>
      _t(context, 'آخر تحديث: يناير 2024', 'Last updated: January 2024');

  static String policyVersionLine(BuildContext context) =>
      _t(context, 'الإصدار 1.0', 'Version 1.0');

  // Policy sections (sheet)
  static String policyCollectTitle(BuildContext context) =>
      _t(context, 'جمع البيانات', 'Data collection');

  static String policyCollectBody(BuildContext context) => _t(
        context,
        'نقوم بجمع البيانات الضرورية فقط لتقديم تجربة تعليمية مخصصة لطفلك. تشمل هذه البيانات: اسم الطفل، العمر، تفضيلات التعلم، وبيانات استخدام اللعبة.',
        'We collect only what we need for a personalized learning experience: your child’s name, age, learning preferences, and gameplay usage.',
      );

  static String policyUseTitle(BuildContext context) =>
      _t(context, 'استخدام البيانات', 'How we use data');

  static String policyUseBody(BuildContext context) => _t(
        context,
        'نستخدم البيانات المجمعة لـ:\n• تخصيص المحتوى التعليمي\n• إنشاء تقارير التقدم\n• تحسين تجربة المستخدم\n• تطوير ميزات جديدة',
        'We use data to:\n• Personalize educational content\n• Build progress reports\n• Improve the experience\n• Develop new features',
      );

  static String policyProtectTitle(BuildContext context) =>
      _t(context, 'حماية البيانات', 'Data protection');

  static String policyProtectBody(BuildContext context) => _t(
        context,
        'جميع البيانات مشفرة ومحمية بأحدث تقنيات الأمان. نستخدم بروتوكولات SSL/TLS لتأمين نقل البيانات. لا نشارك بيانات الأطفال مع أي طرف ثالث تحت أي ظرف.',
        'Data is encrypted and protected with modern security practices. We use SSL/TLS for transfers. We do not share children’s data with third parties.',
      );

  static String policyRightsTitle(BuildContext context) =>
      _t(context, 'حقوق المستخدم', 'Your rights');

  static String policyRightsBody(BuildContext context) => _t(
        context,
        'يحق لك في أي وقت:\n• الوصول إلى بياناتك ومراجعتها\n• تعديل بياناتك الشخصية\n• حذف بياناتك بشكل كامل\n• طلب نسخة من بياناتك\n• إيقاف جمع البيانات التحليلية',
        'You may at any time:\n• Access and review your data\n• Update your personal information\n• Delete your data completely\n• Request a copy of your data\n• Opt out of analytics collection',
      );

  static String policyChildrenTitle(BuildContext context) =>
      _t(context, 'بيانات الأطفال', 'Children’s data');

  static String policyChildrenBody(BuildContext context) => _t(
        context,
        'نولي اهتماماً خاصاً بحماية بيانات الأطفال:\n• لا نجمع بيانات شخصية حساسة\n• لا نعرض إعلانات للأطفال\n• لا نسمح بالتواصل مع الغرباء\n• جميع المحتوى مراجع ومناسب للأطفال',
        'We take extra care with children’s data:\n• We avoid collecting sensitive personal data\n• No ads shown to children\n• No contact with strangers\n• Content is reviewed and child-appropriate',
      );

  static String policyCookiesTitle(BuildContext context) =>
      _t(context, 'ملفات تعريف الارتباط', 'Cookies');

  static String policyCookiesBody(BuildContext context) => _t(
        context,
        'نستخدم ملفات تعريف الارتباط لتحسين تجربة الاستخدام وتذكر تفضيلاتك. يمكنك التحكم في إعدادات ملفات تعريف الارتباط من إعدادات جهازك.',
        'We use cookies to improve the experience and remember preferences. You can control cookies in your device settings.',
      );

  static String policyUpdatesTitle(BuildContext context) =>
      _t(context, 'التحديثات على السياسة', 'Policy updates');

  static String policyUpdatesBody(BuildContext context) => _t(
        context,
        'قد نقوم بتحديث سياسة الخصوصية من وقت لآخر. سنقوم بإشعارك بأي تغييرات جوهرية عبر التطبيق أو البريد الإلكتروني.',
        'We may update this policy from time to time. We’ll notify you of important changes via the app or email.',
      );

  static String policyContactTitle(BuildContext context) =>
      _t(context, 'التواصل', 'Contact');

  static String policyContactBody(BuildContext context) => _t(
        context,
        'للأسئلة أو الاستفسارات المتعلقة بالخصوصية:\n\nالبريد الإلكتروني: privacy@alfaseelah.com\nالهاتف: +966-XX-XXX-XXXX\nالعنوان: المملكة العربية السعودية',
        'Privacy questions:\n\nEmail: privacy@alfaseelah.com\nPhone: +966-XX-XXX-XXXX\nLocation: Saudi Arabia',
      );

  /// Stable keys for content-filter dialog state (not persisted).
  static String contentFilterOptionLabel(BuildContext context, String key) {
    switch (key) {
      case 'stories':
        return _t(context, 'قصص', 'Stories');
      case 'educational':
        return _t(context, 'أنشطة تعليمية', 'Educational activities');
      case 'games':
        return _t(context, 'ألعاب', 'Games');
      case 'religious':
        return _t(context, 'محتوى ديني', 'Religious content');
      case 'parenting':
        return _t(context, 'محتوى تربوي', 'Parenting content');
      case 'songs':
        return _t(context, 'أناشيد', 'Songs');
      default:
        return key;
    }
  }

  static List<MapEntry<String, bool>> initialContentFilterEntries() => [
        MapEntry('stories', true),
        MapEntry('educational', true),
        MapEntry('games', true),
        MapEntry('religious', true),
        MapEntry('parenting', true),
        MapEntry('songs', true),
      ];

  // FAQ entries (localized by index in UI)
  static String faqQ(BuildContext context, int i) {
    final ar = [
      'كيف أضيف طفل جديد؟',
      'كيف أتحكم في وقت استخدام الطفل؟',
      'كيف أربط اللعبة بالتطبيق؟',
      'هل بيانات طفلي آمنة؟',
      'كيف أحصل على تقارير تقدم طفلي؟',
      'هل يمكنني إضافة أكثر من طفل؟',
    ];
    final en = [
      'How do I add a child?',
      'How do I control screen time?',
      'How do I connect the game to the app?',
      'Is my child’s data safe?',
      'How do I get progress reports?',
      'Can I add more than one child?',
    ];
    return _t(context, ar[i], en[i]);
  }

  static String faqA(BuildContext context, int i) {
    final ar = [
      'اذهب إلى الإعدادات > الأطفال المسجلون > إضافة طفل جديد، ثم أدخل بيانات الطفل.',
      'من الإعدادات > الرقابة الأبوية > الحد الزمني اليومي، يمكنك تحديد عدد الدقائق المسموحة يومياً.',
      'تأكد من تشغيل الجهاز وتفعيل البلوتوث، ثم اذهب إلى صفحة الاتصال واضغط على البحث عن الأجهزة.',
      'نعم، جميع البيانات مشفرة ومحمية. نحن لا نشارك بيانات الأطفال مع أي طرف ثالث.',
      'من الشاشة الرئيسية، اضغط على "التقارير" أو من القائمة السفلية اختر "التقدم" لعرض تقارير مفصلة.',
      'نعم، يمكنك إضافة عدة أطفال ولكل طفل ملف خاص به مع إعدادات وتقارير منفصلة.',
    ];
    final en = [
      'Go to Settings > Registered children > Add child, then enter the child’s details.',
      'From Settings > Parental controls > Daily time limit, set allowed minutes per day.',
      'Turn on the device and Bluetooth, then open Connection and search for devices.',
      'Yes. Data is encrypted and protected. We do not share children’s data with third parties.',
      'From Home tap Reports, or use the bottom tab Progress for detailed reports.',
      'Yes. You can add multiple children; each has their own profile, settings, and reports.',
    ];
    return _t(context, ar[i], en[i]);
  }

  static int get faqCount => 6;

  // —— Settings: language row matches MaterialApp locale ——
  static String activeLanguageDisplayForSettings(BuildContext context) =>
      _isAr(context)
          ? languageArabicTitle(context)
          : languageEnglishTitle(context);

  // —— Onboarding ——
  static String onboardingSkip(BuildContext context) =>
      _t(context, 'تخطي', 'Skip');

  static String onboardingPrev(BuildContext context) =>
      _t(context, 'السابق', 'Previous');

  static String onboardingNext(BuildContext context) =>
      _t(context, 'التالي', 'Next');

  static String onboardingStart(BuildContext context) =>
      _t(context, 'ابدأ الآن', 'Get started');

  static String onboardingTitle0(BuildContext context) =>
      _t(context, 'مرحباً بك في عالم الفسيلة', 'Welcome to Al-Faseelah World');

  static String onboardingDesc0(BuildContext context) => _t(
        context,
        'تجربة تعليمية فريدة تجمع بين اللعب الملموس والذكاء الاصطناعي لتنمية مهارات طفلك',
        'A unique learning experience blending hands-on play and AI to grow your child’s skills',
      );

  static String onboardingTitle1(BuildContext context) =>
      _t(context, 'تعلم من خلال اللعب', 'Learn through play');

  static String onboardingDesc1(BuildContext context) => _t(
        context,
        'أربع مناطق تعليمية: المنزل، المدرسة، المسجد، ومنطقة متغيرة تتيح لطفلك استكشاف عوالم جديدة',
        'Four learning zones: home, school, mosque, and a changing area to explore new worlds',
      );

  static String onboardingTitle2(BuildContext context) =>
      _t(context, 'ذكاء اصطناعي متطور', 'Advanced AI');

  static String onboardingDesc2(BuildContext context) => _t(
        context,
        'يتعرف على طفلك ويتكيف مع احتياجاته، يقدم محتوى مخصص ويتابع تقدمه بشكل مستمر',
        'Adapts to your child with personalized content and ongoing progress tracking',
      );

  static String onboardingTitle3(BuildContext context) =>
      _t(context, 'تقارير ذكية للأهل', 'Smart reports for parents');

  static String onboardingDesc3(BuildContext context) => _t(
        context,
        'تابعي تقدم طفلك واحصلي على تقارير مفصلة وتوصيات مخصصة من الذكاء الاصطناعي',
        'Track progress with detailed reports and tailored AI recommendations',
      );

  static String onboardingTitle4(BuildContext context) =>
      _t(context, 'تحكم أبوي كامل', 'Full parental control');

  static String onboardingDesc4(BuildContext context) => _t(
        context,
        'تحكمي في المحتوى، حددي وقت الاستخدام، واختاري المسار التعليمي المناسب لطفلك',
        'Manage content, screen time, and the learning path that fits your child',
      );

  // —— Notifications ——
  static String notificationsTitle(BuildContext context) =>
      _t(context, 'الإشعارات', 'Notifications');

  static String notificationsMarkAllRead(BuildContext context) =>
      _t(context, 'تحديد الكل كمقروء', 'Mark all read');

  static String notificationsClearAll(BuildContext context) =>
      _t(context, 'مسح الكل', 'Clear all');

  static String notificationsEmptyTitle(BuildContext context) =>
      _t(context, 'لا توجد إشعارات', 'No notifications');

  static String notificationsEmptySubtitle(BuildContext context) => _t(
        context,
        'ستظهر هنا إشعارات نشاط طفلك',
        'Your child’s activity alerts will appear here',
      );

  static String notificationsTitleWithUnread(
          BuildContext context, int unread) =>
      unread > 0
          ? _isAr(context)
              ? 'الإشعارات ($unread)'
              : 'Notifications ($unread)'
          : notificationsTitle(context);

  static String notificationsReadAll(BuildContext context) =>
      _t(context, 'قراءة الكل', 'Read all');

  static String notificationsMenuClear(BuildContext context) =>
      _t(context, 'حذف الكل', 'Clear all');

  static String notificationsMenuSettings(BuildContext context) => _t(
        context,
        'إعدادات الإشعارات',
        'Notification settings',
      );

  static String notificationsEmptySubtitleAlt(BuildContext context) => _t(
        context,
        'ستظهر هنا جميع الإشعارات والتنبيهات',
        'Alerts and updates will appear here',
      );

  static String notificationsDelete(BuildContext context) =>
      _t(context, 'حذف', 'Delete');

  static String notificationsClose(BuildContext context) =>
      _t(context, 'إغلاق', 'Close');

  static String notificationsDeletedOne(BuildContext context) =>
      _t(context, 'تم حذف الإشعار', 'Notification removed');

  static String notificationsClearAllConfirm(BuildContext context) =>
      _t(context, 'حذف الكل', 'Delete all');

  static String notificationTitleById(BuildContext context, String id) {
    switch (id) {
      case '1':
        return _t(context, 'سارة أكملت قصة جديدة!', 'Sarah finished a new story!');
      case '2':
        return _t(context, 'إنجاز جديد!', 'New achievement!');
      case '3':
        return _t(context, 'تقرير أسبوعي جاهز', 'Weekly report ready');
      case '4':
        return _t(context, 'محتوى جديد متاح', 'New content available');
      case '5':
        return _t(context, 'تذكير باللعب', 'Play reminder');
      default:
        return '';
    }
  }

  static String notificationBodyById(BuildContext context, String id) {
    switch (id) {
      case '1':
        return _t(
          context,
          'أكملت سارة قصة "الأرنب الصغير" بنجاح',
          'Sarah completed the story “The Little Rabbit”',
        );
      case '2':
        return _t(
          context,
          'حصلت سارة على شارة "القارئ الصغير"',
          'Sarah earned the “Little Reader” badge',
        );
      case '3':
        return _t(
          context,
          'تقرير تقدم سارة للأسبوع متاح الآن',
          'Sarah’s weekly progress report is available',
        );
      case '4':
        return _t(
          context,
          'تم إضافة 5 قصص جديدة لمكتبة المحتوى',
          '5 new stories were added to the library',
        );
      case '5':
        return _t(
          context,
          'لم يلعب طفلك منذ 3 أيام، شجعيه على اللعب!',
          'Your child hasn’t played in 3 days — encourage a session!',
        );
      default:
        return '';
    }
  }

  static String notificationTimeById(BuildContext context, String id) {
    switch (id) {
      case '1':
        return _t(context, 'منذ 30 دقيقة', '30 minutes ago');
      case '2':
        return _t(context, 'منذ ساعة', '1 hour ago');
      case '3':
        return _t(context, 'منذ يوم', '1 day ago');
      case '4':
        return _t(context, 'منذ يومين', '2 days ago');
      case '5':
        return _t(context, 'منذ 3 أيام', '3 days ago');
      default:
        return '';
    }
  }

  static String notificationsClearAllTitle(BuildContext context) =>
      _t(context, 'حذف جميع الإشعارات', 'Delete all notifications');

  static String notificationsClearAllBody(BuildContext context) => _t(
        context,
        'هل أنت متأكد من حذف جميع الإشعارات؟',
        'Are you sure you want to delete all notifications?',
      );

  static String notificationsCleared(BuildContext context) =>
      _t(context, 'تم مسح جميع الإشعارات', 'All notifications cleared');

  static String notificationsMarkAllDone(BuildContext context) =>
      _t(context, 'تم تحديد الكل كمقروء', 'All marked as read');

  // —— Connection ——
  static String connectionTitle(BuildContext context) =>
      _t(context, 'الاتصال باللعبة', 'Connect to the game');

  static String connectionSearching(BuildContext context) =>
      _t(context, 'جاري البحث عن الأجهزة...', 'Searching for devices...');

  static String connectionSearchDevices(BuildContext context) =>
      _t(context, 'البحث عن الأجهزة', 'Search for devices');

  static String connectionHowToTitle(BuildContext context) =>
      _t(context, 'كيفية الاتصال', 'How to connect');

  static String connectionHowTo1(BuildContext context) => _t(
        context,
        'تأكد من تشغيل جهاز اللعبة',
        'Make sure the game device is on',
      );

  static String connectionHowTo2(BuildContext context) => _t(
        context,
        'فعّل البلوتوث على هاتفك',
        'Turn on Bluetooth on your phone',
      );

  static String connectionHowTo3(BuildContext context) => _t(
        context,
        'اضغط على "البحث عن الأجهزة"',
        'Tap “Search for devices”',
      );

  static String connectionHowTo4(BuildContext context) => _t(
        context,
        'اختر جهازك من القائمة',
        'Pick your device from the list',
      );

  static String connectionDeviceFaseelah(BuildContext context) =>
      _t(context, 'جهاز الفسيلة', 'Al-Faseelah device');

  static String connectionDeviceTablet(BuildContext context) =>
      _t(context, 'جهاز اللوحي', 'Tablet device');

  static String connectionSignalStrong(BuildContext context) =>
      _t(context, 'إشارة قوية', 'Strong signal');

  static String connectionSignalMedium(BuildContext context) =>
      _t(context, 'إشارة متوسطة', 'Medium signal');

  static String connectionLastToday(BuildContext context) =>
      _t(context, 'آخر اتصال: اليوم', 'Last connected: today');

  static String connectionLastYesterday(BuildContext context) =>
      _t(context, 'آخر اتصال: أمس', 'Last connected: yesterday');

  static String connectionConnect(BuildContext context) =>
      _t(context, 'اتصال', 'Connect');

  static String connectionDisconnect(BuildContext context) =>
      _t(context, 'قطع الاتصال', 'Disconnect');

  static String connectionConnectedTo(BuildContext context, String name) =>
      _isAr(context) ? 'متصل بـ $name' : 'Connected to $name';

  static String connectionDisconnectedFrom(BuildContext context, String name) =>
      _isAr(context) ? 'تم قطع الاتصال بـ $name' : 'Disconnected from $name';

  static String connectionPairTitle(BuildContext context) =>
      _t(context, 'إقران الجهاز', 'Pair device');

  static String connectionPairBody(BuildContext context, String name) {
    return _isAr(context)
        ? 'أدخل رمز الإقران المعروض على $name'
        : 'Enter the pairing code shown on $name';
  }

  static String connectionPairHint(BuildContext context) =>
      _t(context, 'رمز الإقران', 'Pairing code');

  static String connectionPairInvalid(BuildContext context) =>
      _t(context, 'الرمز غير صحيح', 'Invalid code');

  static String connectionPairSuccess(BuildContext context) =>
      _t(context, 'تم الاتصال بنجاح!', 'Connected successfully!');

  static String connectionHelpTitle(BuildContext context) =>
      _t(context, 'المساعدة في الاتصال', 'Connection help');

  static String connectionHelpBody(BuildContext context) => _t(
        context,
        '• تأكد أن الجهازين قريبان\n• أعد تشغيل البلوتوث\n• أعد تشغيل جهاز اللعبة',
        '• Keep devices close\n• Restart Bluetooth\n• Restart the game device',
      );

  static String connectionTroubleshootTitle(BuildContext context) =>
      _t(context, 'استكشاف الأخطاء', 'Troubleshooting');

  static String connectionTroubleshootBody(BuildContext context) => _t(
        context,
        'إذا استمرت المشكلة، جرّب إعادة تشغيل التطبيق والجهاز.',
        'If issues persist, try restarting the app and the device.',
      );

  static String connectionAppBarTitle(BuildContext context) =>
      _t(context, 'توصيل الجهاز', 'Connect device');

  static String connectionStatusConnected(BuildContext context) =>
      _t(context, 'متصل', 'Connected');

  static String connectionStatusScanning(BuildContext context) =>
      _t(context, 'جاري البحث...', 'Searching...');

  static String connectionStatusDisconnected(BuildContext context) =>
      _t(context, 'غير متصل', 'Disconnected');

  static String connectionSubtitleScanning(BuildContext context) => _t(
        context,
        'يتم البحث عن أجهزة قريبة',
        'Looking for nearby devices',
      );

  static String connectionSubtitleIdle(BuildContext context) => _t(
        context,
        'ابحث عن جهاز الفسيلة',
        'Search for your Al-Faseelah device',
      );

  static String connectionConnectedSnack(BuildContext context, String name) =>
      _isAr(context) ? 'تم الاتصال بـ $name' : 'Connected to $name';

  static String connectionDisconnectTitle(BuildContext context) =>
      _t(context, 'قطع الاتصال', 'Disconnect');

  static String connectionDisconnectBody(BuildContext context) => _t(
        context,
        'هل تريد قطع الاتصال بالجهاز؟',
        'Do you want to disconnect from this device?',
      );

  static String connectionDeviceInfoTitle(BuildContext context) =>
      _t(context, 'معلومات الجهاز', 'Device information');

  static String connectionLabelDeviceName(BuildContext context) =>
      _t(context, 'اسم الجهاز', 'Device name');

  static String connectionLabelSignalStrength(BuildContext context) =>
      _t(context, 'قوة الإشارة', 'Signal strength');

  static String connectionSignalExcellent(BuildContext context) =>
      _t(context, 'ممتازة', 'Excellent');

  static String connectionLabelBattery(BuildContext context) =>
      _t(context, 'البطارية', 'Battery');

  static String connectionLabelFirmware(BuildContext context) =>
      _t(context, 'إصدار البرنامج', 'Firmware');

  static String connectionLabelStorage(BuildContext context) =>
      _t(context, 'المساحة المتاحة', 'Available storage');

  static String connectionRefresh(BuildContext context) =>
      _t(context, 'تحديث', 'Refresh');

  static String connectionSettingsButton(BuildContext context) =>
      _t(context, 'إعدادات', 'Settings');

  static String connectionAvailableDevices(BuildContext context) =>
      _t(context, 'الأجهزة المتاحة', 'Available devices');

  static String connectionNoDevices(BuildContext context) =>
      _t(context, 'لا توجد أجهزة متاحة', 'No devices found');

  static String connectionNoDevicesHint(BuildContext context) => _t(
        context,
        'تأكد من تشغيل جهاز الفسيلة',
        'Make sure your Al-Faseelah device is on',
      );

  static String connectionSignalRow(BuildContext context, String label) =>
      _isAr(context) ? 'إشارة $label' : '$label signal';

  static String connectionConnectedBadge(BuildContext context) =>
      _t(context, 'متصل', 'Connected');

  static String connectionInstructionsCardTitle(BuildContext context) =>
      _t(context, 'تعليمات الاتصال', 'Connection steps');

  static String connectionStep1Title(BuildContext context) =>
      _t(context, 'تشغيل الجهاز', 'Power on');

  static String connectionStep1Desc(BuildContext context) => _t(
        context,
        'تأكد من تشغيل جهاز عالم الفسيلة',
        'Turn on your Al-Faseelah device',
      );

  static String connectionStep2Title(BuildContext context) =>
      _t(context, 'تفعيل البلوتوث', 'Enable Bluetooth');

  static String connectionStep2Desc(BuildContext context) => _t(
        context,
        'قم بتفعيل البلوتوث على هاتفك',
        'Enable Bluetooth on your phone',
      );

  static String connectionStep3Title(BuildContext context) =>
      _t(context, 'البحث والاتصال', 'Search and connect');

  static String connectionStep3Desc(BuildContext context) => _t(
        context,
        'اضغط على "البحث عن الأجهزة" واختر جهازك',
        'Tap “Search for devices” and pick your device',
      );

  static String connectionStep4Title(BuildContext context) =>
      _t(context, 'بدء اللعب', 'Start playing');

  static String connectionStep4Desc(BuildContext context) => _t(
        context,
        'بعد الاتصال، يمكن لطفلك بدء اللعب!',
        'After connecting, your child can start playing!',
      );

  static String connectionUpdateDialogTitle(BuildContext context) =>
      _t(context, 'تحديث الجهاز', 'Device update');

  static String connectionUpdateCurrent(BuildContext context) =>
      _t(context, 'الإصدار الحالي: v2.1.0', 'Current version: v2.1.0');

  static String connectionUpdateLatest(BuildContext context) =>
      _t(context, 'أحدث إصدار: v2.2.0', 'Latest version: v2.2.0');

  static String connectionUpdateChangelog(BuildContext context) => _t(
        context,
        'التحديث الجديد يتضمن:\n• تحسينات في الأداء\n• محتوى تعليمي جديد\n• إصلاح بعض الأخطاء',
        'This update includes:\n• Performance improvements\n• New learning content\n• Bug fixes',
      );

  static String connectionLater(BuildContext context) =>
      _t(context, 'لاحقاً', 'Later');

  static String connectionUpdateNow(BuildContext context) =>
      _t(context, 'تحديث الآن', 'Update now');

  static String connectionUpdateDownloading(BuildContext context) =>
      _t(context, 'جاري تحميل التحديث...', 'Downloading update...');

  static String connectionDeviceSettingsTitle(BuildContext context) =>
      _t(context, 'إعدادات الجهاز', 'Device settings');

  static String connectionVolumeLevel(BuildContext context) =>
      _t(context, 'مستوى الصوت', 'Volume');

  static String connectionBrightness(BuildContext context) =>
      _t(context, 'سطوع الشاشة', 'Screen brightness');

  static String connectionDeviceLanguage(BuildContext context) =>
      _t(context, 'لغة الجهاز', 'Device language');

  static String connectionDeviceLanguageValueAr(BuildContext context) =>
      _t(context, 'العربية', 'Arabic');

  // —— Parental controls ——
  static String parentalTitle(BuildContext context) =>
      _t(context, 'الرقابة الأبوية', 'Parental controls');

  static String parentalSave(BuildContext context) =>
      _t(context, 'حفظ الإعدادات', 'Save settings');

  static String parentalSaveAppBar(BuildContext context) =>
      _t(context, 'حفظ', 'Save');

  static String parentalDailyLimitTitle(BuildContext context) =>
      _t(context, 'الحد الزمني اليومي', 'Daily time limit');

  static String parentalDailyLimitSubtitle(BuildContext context) => _t(
        context,
        'تحديد وقت الاستخدام اليومي',
        'Set daily usage time',
      );

  static String parentalLimitEnabledBadge(BuildContext context) =>
      _t(context, 'مفعّل', 'On');

  static String parentalHoursPerDayLine(
          BuildContext context, String hoursStr) =>
      _isAr(context) ? '$hoursStr ساعة يومياً' : '$hoursStr h per day';

  static String parentalSlider15m(BuildContext context) =>
      _t(context, '15 د', '15m');

  static String parentalSlider1h(BuildContext context) =>
      _t(context, '1 س', '1h');

  static String parentalSlider2h(BuildContext context) =>
      _t(context, '2 س', '2h');

  static String parentalSlider3h(BuildContext context) =>
      _t(context, '3 س', '3h');

  static String parentalCurrentLimit(BuildContext context) =>
      _t(context, 'الحد الحالي', 'Current limit');

  static String parentalPerDay(BuildContext context) =>
      _t(context, 'يومياً', 'per day');

  static String parentalWeekendExtraTitle(BuildContext context) => _t(
        context,
        'وقت إضافي في عطلة نهاية الأسبوع',
        'Extra time on weekends',
      );

  static String parentalWeekendExtraSubtitle(BuildContext context) => _t(
        context,
        '+30 دقيقة يومي الجمعة والسبت',
        '+30 minutes on Friday and Saturday',
      );

  static String parentalScheduleTitle(BuildContext context) =>
      _t(context, 'جدول الاستخدام', 'Usage schedule');

  static String parentalScheduleSubtitle(BuildContext context) => _t(
        context,
        'تحديد أوقات وأيام اللعب',
        'Set allowed play times and days',
      );

  static String parentalStartTime(BuildContext context) =>
      _t(context, 'وقت البدء', 'Start time');

  static String parentalEndTime(BuildContext context) =>
      _t(context, 'وقت الانتهاء', 'End time');

  static String parentalAllowedDays(BuildContext context) =>
      _t(context, 'أيام الاستخدام المسموحة', 'Allowed days');

  static String parentalDaysEnabledCount(BuildContext context, int n) =>
      _isAr(context) ? '$n أيام مفعّلة' : '$n days enabled';

  static String parentalContentFilterTitle(BuildContext context) =>
      _t(context, 'فلترة المحتوى', 'Content filter');

  static String parentalContentFilterSubtitle(BuildContext context) => _t(
        context,
        'اختر أنواع المحتوى المسموح بها',
        'Choose allowed content types',
      );

  static String parentalSelectAll(BuildContext context) =>
      _t(context, 'تحديد الكل', 'Select all');

  static String parentalDeselectAll(BuildContext context) =>
      _t(context, 'إلغاء الكل', 'Clear all');

  static String parentalSkillsTitle(BuildContext context) =>
      _t(context, 'التركيز على المهارات', 'Skills focus');

  static String parentalSkillsSubtitle(BuildContext context) => _t(
        context,
        'حدد المهارات التي تريد تطويرها',
        'Pick skills you want to develop',
      );

  static String parentalSecurityTitle(BuildContext context) =>
      _t(context, 'الأمان', 'Security');

  static String parentalSecuritySubtitle(BuildContext context) => _t(
        context,
        'إعدادات الحماية والأمان',
        'Protection and safety settings',
      );

  static String parentalPinSettingsTitle(BuildContext context) =>
      _t(context, 'رمز PIN للإعدادات', 'PIN for settings');

  static String parentalPinSettingsSubtitle(BuildContext context) => _t(
        context,
        'طلب رمز PIN للدخول للإعدادات',
        'Require a PIN to open settings',
      );

  static String parentalPinPurchasesTitle(BuildContext context) =>
      _t(context, 'رمز PIN للمشتريات', 'PIN for purchases');

  static String parentalPinPurchasesSubtitle(BuildContext context) => _t(
        context,
        'طلب رمز PIN لأي عملية شراء',
        'Require a PIN for purchases',
      );

  static String parentalChangePinTitle(BuildContext context) =>
      _t(context, 'تغيير رمز PIN', 'Change PIN');

  static String parentalChangePinSubtitle(BuildContext context) =>
      _t(context, 'تحديث رمز الحماية', 'Update your security code');

  static String parentalNotificationsSectionTitle(BuildContext context) =>
      _t(context, 'الإشعارات', 'Notifications');

  static String parentalNotificationsSectionSubtitle(BuildContext context) =>
      _t(context, 'التحكم في إشعارات التطبيق', 'Control app notifications');

  static String parentalAllowNotificationsTitle(BuildContext context) =>
      _t(context, 'السماح بالإشعارات', 'Allow notifications');

  static String parentalAllowNotificationsSubtitle(BuildContext context) => _t(
        context,
        'إرسال إشعارات عن نشاط الطفل',
        'Alerts about your child’s activity',
      );

  static String parentalSoundTitle(BuildContext context) =>
      _t(context, 'الصوت', 'Sound');

  static String parentalSoundSubtitle(BuildContext context) => _t(
        context,
        'إعدادات الأصوات والموسيقى',
        'Sounds and music settings',
      );

  static String parentalSoundEffectsTitle(BuildContext context) =>
      _t(context, 'المؤثرات الصوتية', 'Sound effects');

  static String parentalSoundEffectsSubtitle(BuildContext context) => _t(
        context,
        'أصوات التفاعل واللعب',
        'Interaction and play sounds',
      );

  static String parentalBgMusicTitle(BuildContext context) =>
      _t(context, 'الموسيقى الخلفية', 'Background music');

  static String parentalBgMusicSubtitle(BuildContext context) => _t(
        context,
        'موسيقى هادئة أثناء اللعب',
        'Calm music during play',
      );

  static String parentalResetTitle(BuildContext context) =>
      _t(context, 'إعادة الضبط', 'Reset');

  static String parentalResetSubtitle(BuildContext context) => _t(
        context,
        'استعادة الإعدادات الافتراضية',
        'Restore default settings',
      );

  static String parentalResetButton(BuildContext context) => _t(
        context,
        'إعادة ضبط جميع الإعدادات',
        'Reset all settings',
      );

  static String parentalPinDialogTitle(BuildContext context) =>
      _t(context, 'تغيير رمز PIN', 'Change PIN');

  static String parentalPinCurrentLabel(BuildContext context) =>
      _t(context, 'الرمز الحالي', 'Current code');

  static String parentalPinNewLabel(BuildContext context) =>
      _t(context, 'الرمز الجديد', 'New code');

  static String parentalPinConfirmLabel(BuildContext context) =>
      _t(context, 'تأكيد الرمز الجديد', 'Confirm new code');

  static String parentalPinChangedOk(BuildContext context) =>
      _t(context, 'تم تغيير رمز PIN بنجاح', 'PIN changed successfully');

  static String parentalPinMismatch(BuildContext context) => _t(
        context,
        'الرمز غير متطابق أو غير صحيح',
        'Codes do not match or are invalid',
      );

  static String parentalResetConfirmTitle(BuildContext context) =>
      _t(context, 'تأكيد إعادة الضبط', 'Confirm reset');

  static String parentalResetConfirmBody(BuildContext context) => _t(
        context,
        'هل أنت متأكد من إعادة ضبط جميع إعدادات الرقابة الأبوية إلى الإعدادات الافتراضية؟\n\nهذا الإجراء لا يمكن التراجع عنه.',
        'Reset all parental control settings to defaults?\n\nThis cannot be undone.',
      );

  static String parentalResetDone(BuildContext context) =>
      _t(context, 'تم إعادة ضبط الإعدادات', 'Settings reset');

  static String parentalResetAction(BuildContext context) =>
      _t(context, 'إعادة الضبط', 'Reset');

  static String parentalSavedOk(BuildContext context) => _t(
        context,
        'تم حفظ إعدادات الرقابة الأبوية بنجاح',
        'Parental control settings saved',
      );

  static String parentalContentLabel(BuildContext context, String key) {
    switch (key) {
      case 'pc_stories':
        return _t(context, 'قصص تفاعلية', 'Interactive stories');
      case 'pc_edu_games':
        return _t(context, 'ألعاب تعليمية', 'Educational games');
      case 'pc_activities':
        return _t(context, 'أنشطة', 'Activities');
      case 'pc_religious':
        return _t(context, 'محتوى ديني', 'Religious content');
      case 'pc_parenting':
        return _t(context, 'محتوى تربوي', 'Parenting content');
      case 'pc_songs':
        return _t(context, 'أناشيد وأغاني', 'Songs and chants');
      case 'pc_videos':
        return _t(context, 'فيديوهات', 'Videos');
      default:
        return key;
    }
  }

  static List<MapEntry<String, bool>> parentalInitialContentEntries() => [
        const MapEntry('pc_stories', true),
        const MapEntry('pc_edu_games', true),
        const MapEntry('pc_activities', true),
        const MapEntry('pc_religious', true),
        const MapEntry('pc_parenting', true),
        const MapEntry('pc_songs', true),
        const MapEntry('pc_videos', false),
      ];

  static String parentalSkillLabel(BuildContext context, String key) {
    switch (key) {
      case 'sk_reading':
        return _t(context, 'القراءة', 'Reading');
      case 'sk_writing':
        return _t(context, 'الكتابة', 'Writing');
      case 'sk_math':
        return _t(context, 'الحساب', 'Math');
      case 'sk_social':
        return _t(context, 'المهارات الاجتماعية', 'Social skills');
      case 'sk_creativity':
        return _t(context, 'الإبداع', 'Creativity');
      case 'sk_focus':
        return _t(context, 'التركيز', 'Focus');
      default:
        return key;
    }
  }

  static List<MapEntry<String, bool>> parentalInitialSkillEntries() => [
        const MapEntry('sk_reading', true),
        const MapEntry('sk_writing', true),
        const MapEntry('sk_math', true),
        const MapEntry('sk_social', true),
        const MapEntry('sk_creativity', false),
        const MapEntry('sk_focus', true),
      ];

  /// Weekday initials (same order as existing Arabic screen: Sat..Fri).
  static List<String> parentalWeekDayLetters(BuildContext context) {
    if (_isAr(context)) {
      return ['س', 'أ', 'إ', 'ث', 'أ', 'خ', 'ج'];
    }
    return ['Sa', 'Su', 'Mo', 'Tu', 'We', 'Th', 'Fr'];
  }

  static String parentalWeekDayTooltip(BuildContext context, int index) {
    final ar = [
      'السبت',
      'الأحد',
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
    ];
    final en = [
      'Saturday',
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
    ];
    return _t(context, ar[index], en[index]);
  }

  // —— AI reports ——
  static String aiReportsTitle(BuildContext context) =>
      _t(context, 'تقارير الذكاء الاصطناعي', 'AI reports');

  static String aiReportsAppBarTitle(BuildContext context) =>
      _t(context, 'التقارير الذكية', 'Smart reports');

  static String aiReportsWeeklySummaryTitle(BuildContext context) =>
      _t(context, 'ملخص التقدم', 'Progress summary');

  static String aiReportsBadgeNew(BuildContext context) =>
      _t(context, 'تحليل جديد', 'New insights');

  static String aiReportsBadgeNoData(BuildContext context) =>
      _t(context, 'لا بيانات', 'No data');

  static String aiReportsAddChildHint(BuildContext context) => _t(
        context,
        'قم بإضافة طفل أولاً لعرض التقارير',
        'Add a child first to view reports',
      );

  static String aiReportsAddChildButton(BuildContext context) =>
      _t(context, 'إضافة طفل', 'Add child');

  static String aiReportsSelectChildHint(BuildContext context) => _t(
        context,
        'اختر طفلاً لعرض التقرير',
        'Select a child to view the report',
      );

  static String aiReportsNoChildren(BuildContext context) => _t(
        context,
        'لا يوجد أطفال مسجلون',
        'No registered children',
      );

  static String aiReportsSummaryTitle(BuildContext context, String name) =>
      _isAr(context) ? 'ملخص تقدم $name' : 'Progress summary for $name';

  static String aiReportsSummaryWithData(
    BuildContext context,
    String childName,
    int activities,
    String hoursDisplay,
  ) =>
      _isAr(context)
          ? 'أظهر $childName تقدماً في الأنشطة التعليمية. تم إكمال $activities نشاط بإجمالي $hoursDisplay ساعة.'
          : '$childName is making progress in learning activities. Completed $activities activities, $hoursDisplay hours total.';

  static String aiReportsSummaryNoData(BuildContext context) => _t(
        context,
        'لا توجد بيانات نشاطات بعد. ابدأ باستخدام اللعبة لعرض التقارير.',
        'No activity data yet. Use the game to see reports.',
      );

  static String aiReportsTotalPlayHours(BuildContext context) =>
      _t(context, 'إجمالي اللعب', 'Total play');

  static String aiReportsCompletedActivities(BuildContext context) =>
      _t(context, 'أنشطة مكتملة', 'Completed activities');

  static String aiReportsStarsEarned(BuildContext context) =>
      _t(context, 'نجوم مكتسبة', 'Stars earned');

  static String aiReportsHoursUnit(BuildContext context) =>
      _t(context, 'ساعة', 'hours');

  static String aiReportsSkillsTitle(BuildContext context) =>
      _t(context, 'تحليل المهارات', 'Skills analysis');

  static String aiReportsSkillReading(BuildContext context) =>
      _t(context, 'القراءة والاستماع', 'Reading & listening');

  static String aiReportsSkillSocial(BuildContext context) =>
      _t(context, 'المهارات الاجتماعية', 'Social skills');

  static String aiReportsSkillLogic(BuildContext context) =>
      _t(context, 'التفكير المنطقي', 'Logical thinking');

  static String aiReportsSkillCreativity(BuildContext context) =>
      _t(context, 'الإبداع والخيال', 'Creativity & imagination');

  static String aiReportsSkillMotor(BuildContext context) =>
      _t(context, 'المهارات الحركية', 'Motor skills');

  static String aiReportsSkillsPlaceholder(BuildContext context) => _t(
        context,
        'ستظهر بيانات المهارات بعد استخدام اللعبة',
        'Skill data will appear after using the game',
      );

  static String aiReportsBehaviorTitle(BuildContext context) => _t(
        context,
        'أنماط السلوك المكتشفة',
        'Observed behavior patterns',
      );

  static String aiReportsBehaviorPlaceholder(BuildContext context) => _t(
        context,
        'ستظهر أنماط السلوك بعد استخدام اللعبة',
        'Behavior patterns will appear after using the game',
      );

  static String aiReportsPatternFocusTitle(BuildContext context) =>
      _t(context, 'التركيز', 'Focus');

  static String aiReportsPatternFocusDesc(BuildContext context) => _t(
        context,
        'يظهر الطفل تركيزاً أثناء الأنشطة',
        'Shows focus during activities',
      );

  static String aiReportsPatternCreativeTitle(BuildContext context) =>
      _t(context, 'الميل للإبداع', 'Creative interest');

  static String aiReportsPatternCreativeDesc(BuildContext context) => _t(
        context,
        'يفضل الأنشطة التي تتيح له التعبير',
        'Prefers activities that allow expression',
      );

  static String aiReportsPatternSocialTitle(BuildContext context) =>
      _t(context, 'التفاعل الاجتماعي', 'Social interaction');

  static String aiReportsPatternSocialDesc(BuildContext context) => _t(
        context,
        'يستمتع بالأنشطة التفاعلية',
        'Enjoys interactive activities',
      );

  static String aiReportsRecommendationsTitle(BuildContext context) =>
      _t(context, 'توصيات تربوية', 'Educational tips');

  static String aiReportsRecReadingTitle(BuildContext context) =>
      _t(context, 'القراءة التفاعلية', 'Interactive reading');

  static String aiReportsRecReadingBody(BuildContext context) => _t(
        context,
        'جرب قراءة القصص مع طفلك وطرح أسئلة عن الشخصيات. هذا يعزز مهارات التفكير النقدي.',
        'Read stories together and ask about characters to build critical thinking.',
      );

  static String aiReportsRecGroupTitle(BuildContext context) =>
      _t(context, 'اللعب الجماعي', 'Group play');

  static String aiReportsRecGroupBody(BuildContext context) => _t(
        context,
        'شجع طفلك على اللعب مع أطفال آخرين لتطوير مهاراته الاجتماعية.',
        'Encourage play with peers to grow social skills.',
      );

  static String aiReportsRecRoutineTitle(BuildContext context) =>
      _t(context, 'روتين ثابت', 'Consistent routine');

  static String aiReportsRecRoutineBody(BuildContext context) => _t(
        context,
        'حافظ على وقت لعب ثابت يومياً حيث يظهر الطفل أفضل تركيز.',
        'Keep a steady daily play time for best focus.',
      );

  static String aiReportsBestTimesTitle(BuildContext context) =>
      _t(context, 'أفضل أوقات التعلم', 'Best learning times');

  static String aiReportsPeriodMorning(BuildContext context) =>
      _t(context, 'صباحاً', 'Morning');

  static String aiReportsPeriodNoon(BuildContext context) =>
      _t(context, 'ظهراً', 'Midday');

  static String aiReportsPeriodAfternoon(BuildContext context) =>
      _t(context, 'عصراً', 'Afternoon');

  static String aiReportsPeriodEvening(BuildContext context) =>
      _t(context, 'مساءً', 'Evening');

  static String aiReportsLevelMedium(BuildContext context) =>
      _t(context, 'متوسط', 'Medium');

  static String aiReportsLevelLow(BuildContext context) =>
      _t(context, 'منخفض', 'Low');

  static String aiReportsLevelExcellent(BuildContext context) =>
      _t(context, 'ممتاز', 'Excellent');

  static String aiReportsLevelGood(BuildContext context) =>
      _t(context, 'جيد', 'Good');

  static String aiReportsBestTimeBanner(BuildContext context) => _t(
        context,
        'أفضل وقت للتعلم: 4:00 - 6:00 مساءً',
        'Best learning time: 4:00–6:00 PM',
      );

  static String aiReportsStatsSummaryTitle(BuildContext context) =>
      _t(context, 'ملخص الإحصائيات', 'Statistics summary');

  static String aiReportsStatPlayTime(BuildContext context) =>
      _t(context, 'وقت اللعب', 'Play time');

  static String aiReportsStatActivities(BuildContext context) =>
      _t(context, 'الأنشطة المكتملة', 'Completed activities');

  static String aiReportsStatDailyAvg(BuildContext context) =>
      _t(context, 'المعدل اليومي', 'Daily average');

  static String aiReportsStatStars(BuildContext context) =>
      _t(context, 'النجوم المكتسبة', 'Stars earned');

  static String aiReportsMinutesShort(BuildContext context, int m) =>
      _isAr(context) ? '$m دقيقة' : '$m min';

  static String aiReportsPerDayShort(BuildContext context, int d) =>
      _isAr(context) ? '$d د/يوم' : '$d min/day';

  static String aiReportsExportTitle(BuildContext context) =>
      _t(context, 'تصدير التقرير', 'Export report');

  static String aiReportsExportSubtitle(BuildContext context) => _t(
        context,
        'قم بتصدير تقرير شامل عن تقدم طفلك ومشاركته مع المعلم أو الأخصائي.',
        'Export a full progress report to share with a teacher or specialist.',
      );

  static String aiReportsExportPdf(BuildContext context) =>
      _t(context, 'تصدير PDF', 'Export PDF');

  static String aiReportsShare(BuildContext context) =>
      _t(context, 'مشاركة', 'Share');

  static String aiReportsNoDataExport(BuildContext context) =>
      _t(context, 'لا توجد بيانات لتصديرها', 'Nothing to export');

  static String aiReportsExportDialogTitle(BuildContext context) =>
      _t(context, 'تصدير التقرير', 'Export report');

  static String aiReportsExportReportLine(BuildContext context, String name) =>
      _isAr(context) ? 'تقرير: $name' : 'Report: $name';

  static String aiReportsExportIncludes(BuildContext context) =>
      _t(context, 'التقرير سيتضمن:', 'The report will include:');

  static String aiReportsExportItemSummary(BuildContext context) =>
      _t(context, 'ملخص التقدم العام', 'Overall progress summary');

  static String aiReportsExportItemSkills(BuildContext context) =>
      _t(context, 'تحليل المهارات', 'Skills analysis');

  static String aiReportsExportItemBehavior(BuildContext context) =>
      _t(context, 'أنماط السلوك', 'Behavior patterns');

  static String aiReportsExportItemRecs(BuildContext context) =>
      _t(context, 'التوصيات التربوية', 'Educational recommendations');

  static String aiReportsExportItemStats(BuildContext context) =>
      _t(context, 'إحصائيات الاستخدام', 'Usage statistics');

  static String aiReportsExportAction(BuildContext context) =>
      _t(context, 'تصدير', 'Export');

  static String aiReportsExportSuccess(BuildContext context, String name) =>
      _isAr(context)
          ? 'تم تصدير تقرير $name بنجاح'
          : 'Report for $name exported successfully';

  static String aiReportsGenerating(BuildContext context) =>
      _t(context, 'جاري إنشاء التقرير...', 'Generating report...');

  static String aiReportsNoDataShare(BuildContext context) =>
      _t(context, 'لا توجد بيانات لمشاركتها', 'Nothing to share');

  static String aiReportsSharing(BuildContext context, String name) =>
      _isAr(context) ? 'جاري مشاركة تقرير $name...' : 'Sharing report for $name...';

  static String aiReportsChildFallback(BuildContext context) =>
      _t(context, 'الطفل', 'Child');

  // —— Content library (canonical category keys stay Arabic for DB filter) ——
  static String contentLibraryTitle(BuildContext context) =>
      _t(context, 'مكتبة المحتوى', 'Content library');

  static String contentTabExplore(BuildContext context) =>
      _t(context, 'استكشاف', 'Discover');

  static String contentTabSaved(BuildContext context) =>
      _t(context, 'المحفوظات', 'Saved');

  static String contentSearchHint(BuildContext context) =>
      _t(context, 'ابحث في المحتوى...', 'Search content...');

  static String contentEmptySavedTitle(BuildContext context) =>
      _t(context, 'لا يوجد محتوى محفوظ', 'No saved content');

  static String contentEmptySavedSubtitle(BuildContext context) => _t(
        context,
        'قم بتحميل المحتوى للوصول إليه بدون إنترنت',
        'Download content for offline access',
      );

  static String contentEmptySearchTitle(BuildContext context) =>
      _t(context, 'لا توجد نتائج', 'No results');

  static String contentEmptySearchSubtitle(BuildContext context) =>
      _t(context, 'جرب البحث بكلمات مختلفة', 'Try different search words');

  static String contentBadgeNew(BuildContext context) =>
      _t(context, 'جديد', 'New');

  static String contentCategoryLabel(BuildContext context, String key) {
    switch (key) {
      case 'الكل':
        return _t(context, 'الكل', 'All');
      case 'قصص':
        return _t(context, 'قصص', 'Stories');
      case 'أنشطة':
        return _t(context, 'أنشطة', 'Activities');
      case 'ألعاب':
        return _t(context, 'ألعاب', 'Games');
      case 'تعليمي':
        return _t(context, 'تعليمي', 'Educational');
      case 'تربوي':
        return _t(context, 'تربوي', 'Parenting');
      case 'ديني':
        return _t(context, 'ديني', 'Religious');
      default:
        return key;
    }
  }

  static String contentMinutesShort(BuildContext context, int minutes) =>
      _isAr(context) ? '$minutes دقيقة' : '$minutes min';

  static String contentAgeRangeDisplay(BuildContext context, String raw) {
    if (raw.contains('سنوات')) {
      final inner = raw.replaceAll('سنوات', '').trim();
      return _isAr(context) ? raw : '$inner years';
    }
    return raw;
  }

  static String contentDescriptionHeading(BuildContext context) =>
      _t(context, 'الوصف', 'Description');

  static String contentZoneLabel(BuildContext context) =>
      _t(context, 'المنطقة', 'Zone');

  static String contentVersionLabel(BuildContext context) =>
      _t(context, 'الإصدار', 'Version');

  static String contentTopicsHeading(BuildContext context) =>
      _t(context, 'المواضيع', 'Topics');

  static String contentSkillsHeading(BuildContext context) =>
      _t(context, 'المهارات المستهدفة', 'Target skills');

  static String contentPlayButton(BuildContext context) =>
      _t(context, 'تشغيل المحتوى', 'Play content');

  static String contentPlayingSnack(BuildContext context, String title) =>
      _isAr(context)
          ? 'جاري تشغيل "$title"'
          : 'Starting "$title"…';

  // —— Behavior goals (stored zone/type strings remain Arabic) ——
  static String behaviorGoalsTitle(BuildContext context) =>
      _t(context, 'أهداف السلوك', 'Behavior goals');

  static String behaviorNewGoal(BuildContext context) =>
      _t(context, 'هدف جديد', 'New goal');

  static String behaviorNoChildrenTitle(BuildContext context) =>
      _t(context, 'لا يوجد أطفال مسجلين', 'No registered children');

  static String behaviorNoChildrenSubtitle(BuildContext context) =>
      _t(context, 'قم بإضافة طفل أولاً', 'Add a child first');

  static String behaviorAddChild(BuildContext context) =>
      _t(context, 'إضافة طفل', 'Add child');

  static String behaviorChildLabel(BuildContext context) =>
      _t(context, 'الطفل:', 'Child:');

  static String behaviorStatTotal(BuildContext context) =>
      _t(context, 'إجمالي الأهداف', 'Total goals');

  static String behaviorStatActive(BuildContext context) =>
      _t(context, 'أهداف نشطة', 'Active');

  static String behaviorStatCompleted(BuildContext context) =>
      _t(context, 'مكتملة', 'Completed');

  static String behaviorEmptyTitle(BuildContext context) =>
      _t(context, 'لا توجد أهداف بعد', 'No goals yet');

  static String behaviorEmptyHint(BuildContext context) => _t(
        context,
        'اضغط "هدف جديد" لإضافة أهداف سلوكية لطفلك',
        'Tap “New goal” to add a behavior goal',
      );

  static String behaviorActiveSection(BuildContext context) =>
      _t(context, 'الأهداف النشطة', 'Active goals');

  static String behaviorCompletedSection(BuildContext context) =>
      _t(context, 'الأهداف المكتملة', 'Completed goals');

  static String behaviorDeleteGoalTitle(BuildContext context) =>
      _t(context, 'حذف الهدف', 'Delete goal');

  static String behaviorDeleteGoalBody(BuildContext context) =>
      _t(context, 'هل تريد حذف هذا الهدف؟', 'Delete this goal?');

  static String behaviorProgressPlusOne(BuildContext context) =>
      _t(context, 'تقدم +1', 'Progress +1');

  static String behaviorAddGoalTitle(BuildContext context) => _t(
        context,
        'إضافة هدف سلوكي جديد',
        'Add behavior goal',
      );

  static String behaviorFieldGoalTitle(BuildContext context) =>
      _t(context, 'عنوان الهدف', 'Goal title');

  static String behaviorFieldGoalTitleHint(BuildContext context) => _t(
        context,
        'مثال: إكمال 5 قصص هذا الأسبوع',
        'e.g. Complete 5 stories this week',
      );

  static String behaviorFieldDescription(BuildContext context) =>
      _t(context, 'الوصف (اختياري)', 'Description (optional)');

  static String behaviorFieldDescriptionHint(BuildContext context) =>
      _t(context, 'وصف إضافي للهدف', 'Optional details');

  static String behaviorZoneSection(BuildContext context) =>
      _t(context, 'المنطقة المرتبطة', 'Related zone');

  static String behaviorTypeSection(BuildContext context) => _t(
        context,
        'نوع السلوك المستهدف',
        'Target behavior type',
      );

  static String behaviorFieldTargetCount(BuildContext context) =>
      _t(context, 'العدد المستهدف', 'Target count');

  static String behaviorFieldTargetCountHint(BuildContext context) =>
      _t(context, 'مثال: 5', 'e.g. 5');

  static String behaviorSaveGoal(BuildContext context) =>
      _t(context, 'حفظ الهدف', 'Save goal');

  static String behaviorTitleRequired(BuildContext context) => _t(
        context,
        'يرجى إدخال عنوان الهدف',
        'Please enter a goal title',
      );

  static String behaviorZoneLabel(BuildContext context, String stored) {
    switch (stored.trim()) {
      case 'منطقة القصص':
        return _t(context, 'منطقة القصص', 'Stories zone');
      case 'منطقة الأرقام':
        return _t(context, 'منطقة الأرقام', 'Numbers zone');
      case 'منطقة المزرعة':
        return _t(context, 'منطقة المزرعة', 'Farm zone');
      case 'منطقة القيم':
        return _t(context, 'منطقة القيم', 'Values zone');
      case 'منطقة الإبداع':
        return _t(context, 'منطقة الإبداع', 'Creativity zone');
      case 'المنطقة الدينية':
        return _t(context, 'المنطقة الدينية', 'Religious zone');
      case 'منطقة الحيوانات':
        return _t(context, 'منطقة الحيوانات', 'Animals zone');
      default:
        return stored;
    }
  }

  static String behaviorTypeLabel(BuildContext context, String stored) {
    switch (stored.trim()) {
      case 'إكمال الأنشطة':
        return _t(context, 'إكمال الأنشطة', 'Completing activities');
      case 'التفاعل الاجتماعي':
        return _t(context, 'التفاعل الاجتماعي', 'Social interaction');
      case 'الالتزام بالوقت':
        return _t(context, 'الالتزام بالوقت', 'Time discipline');
      case 'حل المشكلات':
        return _t(context, 'حل المشكلات', 'Problem solving');
      case 'التعاون':
        return _t(context, 'التعاون', 'Cooperation');
      case 'الصبر والمثابرة':
        return _t(context, 'الصبر والمثابرة', 'Patience & persistence');
      case 'الإبداع':
        return _t(context, 'الإبداع', 'Creativity');
      case 'الاستماع الجيد':
        return _t(context, 'الاستماع الجيد', 'Active listening');
      default:
        return stored;
    }
  }

  /// Fallback display label when no name is available (auth layer may use context null).
  static String defaultUserDisplayName(BuildContext? context) =>
      tr(context, 'مستخدم', 'User');

  // —— Progress reports ——
  static String progressReportsTitle(BuildContext context) =>
      _t(context, 'تقارير التقدم', 'Progress reports');

  static String progressStatTotalMinutes(BuildContext context) =>
      _t(context, 'دقيقة إجمالي', 'Total minutes');

  static String progressStatCompletedActivities(BuildContext context) =>
      _t(context, 'نشاط مكتمل', 'Activities done');

  static String progressStatStars(BuildContext context) =>
      _t(context, 'نجوم', 'Stars');

  static String progressPeriodLabel(BuildContext context, String key) {
    switch (key) {
      case 'يومي':
        return _t(context, 'يومي', 'Daily');
      case 'أسبوعي':
        return _t(context, 'أسبوعي', 'Weekly');
      case 'شهري':
        return _t(context, 'شهري', 'Monthly');
      case 'فصلي':
        return _t(context, 'فصلي', 'Seasonal');
      default:
        return key;
    }
  }

  /// Chart x-axis labels, Saturday-first (7 days), index 0..6.
  static String progressChartDayShort(BuildContext context, int dayIndex) {
    if (_isAr(context)) {
      const ar = ['سبت', 'أحد', 'إثن', 'ثلا', 'أرب', 'خمس', 'جمع'];
      return ar[dayIndex.clamp(0, 6)];
    }
    const en = ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
    return en[dayIndex.clamp(0, 6)];
  }

  static String progressWeeklyUsageTitle(BuildContext context) =>
      _t(context, 'الاستخدام الأسبوعي', 'Weekly usage');

  static String progressAvgMinPerDay(BuildContext context, int avg) =>
      _isAr(context) ? 'معدل $avg د/يوم' : 'Avg $avg min/day';

  static String progressNoUsageYet(BuildContext context) =>
      _t(context, 'لا توجد بيانات استخدام بعد', 'No usage data yet');

  static String progressSkillsTitle(BuildContext context) =>
      _t(context, 'تقدم المهارات', 'Skills progress');

  static String progressNoSkillsYet(BuildContext context) =>
      _t(context, 'لا توجد بيانات مهارات بعد', 'No skills data yet');

  static String progressSkillReading(BuildContext context) =>
      _t(context, 'القراءة', 'Reading');

  static String progressSkillMath(BuildContext context) =>
      _t(context, 'الحساب', 'Math');

  static String progressSkillCommunication(BuildContext context) =>
      _t(context, 'التواصل', 'Communication');

  static String progressSkillFocus(BuildContext context) =>
      _t(context, 'التركيز', 'Focus');

  static String progressSkillCreativity(BuildContext context) =>
      _t(context, 'الإبداع', 'Creativity');

  static String progressAchievementsTitle(BuildContext context) =>
      _t(context, 'الإنجازات', 'Achievements');

  static String progressViewAll(BuildContext context) =>
      _t(context, 'عرض الكل', 'View all');

  static String progressNoAchievementsYet(BuildContext context) =>
      _t(context, 'لا توجد إنجازات بعد', 'No achievements yet');

  static String progressRecentSessionsTitle(BuildContext context) =>
      _t(context, 'الجلسات الأخيرة', 'Recent sessions');

  static String progressNoSessionsYet(BuildContext context) =>
      _t(context, 'لا توجد جلسات سابقة', 'No past sessions');

  static String progressMoodPrefix(BuildContext context) =>
      _t(context, 'المزاج', 'Mood');

  static String progressFocusPrefix(BuildContext context) =>
      _t(context, 'التركيز', 'Focus');

  static String progressAISuggestionsTitle(BuildContext context) =>
      _t(context, 'توصيات الذكاء الاصطناعي', 'AI suggestions');

  static String progressRecReadingTitle(BuildContext context) =>
      _t(context, 'تحسن في القراءة', 'Reading progress');

  static String progressRecReadingBody(BuildContext context, String childName) =>
      _isAr(context)
          ? 'يُلاحظ تحسن في مهارات القراءة لـ $childName. زيدي مستوى صعوبة القصص تدريجياً.'
          : '$childName is making reading progress. Gradually increase story difficulty.';

  static String progressRecActivityTitle(BuildContext context) =>
      _t(context, 'اقتراح نشاط', 'Activity idea');

  static String progressRecActivityBody(BuildContext context, String childName) =>
      _isAr(context)
          ? 'جرّب أنشطة جديدة تناسب اهتمامات $childName.'
          : 'Try new activities that match $childName’s interests.';

  static String progressRecBestTimeTitle(BuildContext context) =>
      _t(context, 'أفضل وقت للعب', 'Best play time');

  static String progressRecBestTimeBody(BuildContext context, String childName) =>
      _isAr(context)
          ? 'غالباً يكون التركيز أعلى لدى $childName بين 4–6 مساءً.'
          : '$childName often focuses best between 4:00–6:00 PM.';

  static String progressShareReportTitle(BuildContext context) =>
      _t(context, 'مشاركة التقرير', 'Share report');

  static String progressShareWhatsApp(BuildContext context) =>
      _t(context, 'واتساب', 'WhatsApp');

  static String progressShareEmail(BuildContext context) =>
      _t(context, 'البريد الإلكتروني', 'Email');

  static String progressShareCopyLink(BuildContext context) =>
      _t(context, 'نسخ الرابط', 'Copy link');

  static String progressLinkCopied(BuildContext context) =>
      _t(context, 'تم نسخ الرابط', 'Link copied');

  static String progressShareSuccess(BuildContext context) =>
      _t(context, 'تم مشاركة التقرير بنجاح', 'Report shared');

  static String progressDownloadTitle(BuildContext context) =>
      _t(context, 'تحميل التقرير', 'Download report');

  static String progressDownloadBody(BuildContext context) => _t(
        context,
        'سيتم تحميل تقرير مفصل بصيغة PDF يحتوي على:\n\n• ملخص الاستخدام\n• تقدم المهارات\n• الإنجازات\n• التوصيات',
        'A detailed PDF will include:\n\n• Usage summary\n• Skills progress\n• Achievements\n• Recommendations',
      );

  static String progressDownloading(BuildContext context) =>
      _t(context, 'جاري تحميل التقرير...', 'Downloading report…');

  static String progressDownloadAction(BuildContext context) =>
      _t(context, 'تحميل', 'Download');

  static String progressAllAchievementsTitle(BuildContext context) =>
      _t(context, 'جميع الإنجازات', 'All achievements');

  static String progressChangePercent(BuildContext context, String pct) => pct;

  // —— Parent notes per child ——
  static String parentNotesSectionTitle(BuildContext context) => _t(
        context,
        'ملاحظاتك واقتراحاتك',
        'Your notes & suggestions',
      );

  static String parentNotesSectionHelper(BuildContext context) => _t(
        context,
        'اكتبي ما يحتاج طفلك لتطويره (مثل: العد، النطق، الألوان، التفاعل الاجتماعي) لمساعدة تخصيص الأنشطة لاحقاً.',
        'Note focus areas (e.g. counting, speech, colors, social skills) to help personalize activities later.',
      );

  static String parentNotesHint(BuildContext context) =>
      _t(context, 'ملاحظات لطفلك…', 'Notes for your child…');

  static String parentNotesSave(BuildContext context) =>
      _t(context, 'حفظ الملاحظات', 'Save notes');

  static String parentNotesSaved(BuildContext context) =>
      _t(context, 'تم حفظ الملاحظات', 'Notes saved');
}
