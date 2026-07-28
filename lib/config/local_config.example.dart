/// قالب الإعدادات المحلية.
///
/// انسخي هذا الملف إلى `local_config.dart` في المجلد نفسه، واملئي قيمك
/// من لوحة Supabase (Settings ← API). الملف المحلي مستثنى من Git فلا
/// يُرفع أبداً، وهذا القالب وحده هو المرفوع.
///
/// ```
/// cp lib/config/local_config.example.dart lib/config/local_config.dart
/// ```
class LocalConfig {
  const LocalConfig._();

  /// رابط مشروع Supabase، مثل https://xxxx.supabase.co
  static const String supabaseUrl = '';

  /// المفتاح العام (publishable / anon) الخاص بالمشروع.
  static const String supabaseAnonKey = '';
}
