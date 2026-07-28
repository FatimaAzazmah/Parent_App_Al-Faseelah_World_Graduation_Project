import 'local_config.dart';

/// إعدادات الاتصال بـ Supabase.
///
/// لا تُخزَّن أي قيمة خاصة بمشروع بعينه في الشيفرة المرفوعة. تُقرأ القيم
/// من مصدرين بالترتيب:
///
/// 1. ما يُمرَّر وقت البناء عبر `--dart-define`، ويُستعمل في بناء الإصدار
///    وخطوط النشر حيث لا وجود لملفات محلية.
/// 2. `local_config.dart` المستثنى من Git، وهو الأسهل للتطوير اليومي
///    لأنه يجعل `flutter run` يعمل بلا وسائط إضافية.
///
/// المفتاح المستعمَل هو المفتاح العام (anon / publishable) المخصَّص أصلاً
/// لتطبيقات العملاء؛ فهو يُشحن داخل كل نسخة من التطبيق ولا يُعدّ سرّاً،
/// وحماية البيانات تأتي من سياسات RLS في قاعدة البيانات. أمّا المفتاح
/// السرّي (service_role) فلا يُستعمل في التطبيق إطلاقاً.
class SupabaseConfig {
  const SupabaseConfig._();

  static const String _definedUrl = String.fromEnvironment('SUPABASE_URL');
  static const String _definedAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');

  /// رابط مشروع Supabase.
  static String get url =>
      _definedUrl.isNotEmpty ? _definedUrl : LocalConfig.supabaseUrl;

  /// المفتاح العام للمشروع.
  static String get anonKey =>
      _definedAnonKey.isNotEmpty ? _definedAnonKey : LocalConfig.supabaseAnonKey;

  /// هل توفّرت الإعدادات من أيّ من المصدرين؟
  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
