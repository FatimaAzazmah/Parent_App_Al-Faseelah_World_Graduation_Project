// Template for Supabase credentials.
//
// Copy this file to `supabase_config.dart` (same folder) and fill in your own
// Project URL and publishable/anon key from the Supabase dashboard
// (Settings -> API). The real `supabase_config.dart` is gitignored and is
// never committed.
//
// `anonKey` is the PUBLIC publishable/anon key and is safe for client apps;
// database access is protected by Row Level Security (RLS). Never put the
// secret (service_role) key here.
class SupabaseConfig {
  static const String url = 'https://YOUR-PROJECT-ref.supabase.co';
  static const String anonKey = 'YOUR-SUPABASE-PUBLISHABLE-OR-ANON-KEY';
}
