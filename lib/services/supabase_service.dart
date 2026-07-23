import 'package:supabase_flutter/supabase_flutter.dart';

/// Minimal Supabase auth wrapper.
/// Keeps auth errors visible to callers via exceptions, which are then
/// transformed into the existing `AuthResult` messages in `auth_service.dart`.
class SupabaseService {
  SupabaseService._internal();
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;

  final SupabaseClient _client = Supabase.instance.client;

  Future<void> login(String email, String password) async {
    try {
      await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
    } catch (e) {
      // Keep error details for debugging (Step 7).
      print('[SupabaseService] login error: $e');
      rethrow;
    }
  }

  Future<void> register({
    required String email,
    required String password,
  }) async {
    try {
      await _client.auth.signUp(
        email: email.trim(),
        password: password,
      );
    } catch (e) {
      print('[SupabaseService] register error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      print('[SupabaseService] logout error: $e');
      rethrow;
    }
  }
}

