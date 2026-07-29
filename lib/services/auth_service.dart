import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/app_strings.dart';
import 'supabase_service.dart';

String? _firstNonEmptyField(List<dynamic> values) {
  for (final v in values) {
    if (v == null) continue;
    final s = v.toString().trim();
    if (s.isNotEmpty) return s;
  }
  return null;
}

String? _nameFromUserMetadata(User user) {
  final meta = user.userMetadata;
  if (meta == null) return null;
  return _firstNonEmptyField([meta['full_name'], meta['name']]);
}

String? _emailLocalDisplayName(User user) {
  final email = user.email;
  if (email == null || email.isEmpty) return null;
  final local = email.split('@').first.trim();
  if (local.isEmpty) return null;
  return '${local[0].toUpperCase()}${local.length > 1 ? local.substring(1) : ''}';
}

/// خدمة المصادقة مع Supabase
class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final SupabaseClient _client = Supabase.instance.client;
  final SupabaseService _supabaseService = SupabaseService();

  // حالة تسجيل الدخول
  bool get isLoggedIn => _client.auth.currentUser != null;

  /// الحصول على بيانات المستخدم من جدول `profiles` في Supabase
  Future<UserData?> getCurrentUserData() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final response = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      final data = response is Map<String, dynamic> ? response : null;
      if (data != null) {
        final profileName = _firstNonEmptyField([
          data['name'],
          data['full_name'],
          data['display_name'],
        ]);
        if (profileName != null) {
          return UserData.fromProfileRow({...data, 'name': profileName});
        }
        final u = UserData.fromProfileRow(data);
        if (u.name.isNotEmpty) return u;
        final fromMeta = _nameFromUserMetadata(user);
        final fromEmail = _emailLocalDisplayName(user);
        final resolved =
            fromMeta ?? fromEmail ?? AppStrings.defaultUserDisplayName(null);
        return u.copyWith(name: resolved);
      }

      return _userDataFromAuthUser(user);
    } catch (e) {
      debugPrint('[AuthService] getCurrentUserData error: $e');
      final user = _client.auth.currentUser;
      if (user == null) return null;
      return _userDataFromAuthUser(user);
    }
  }

  UserData _userDataFromAuthUser(User user) {
    String name = _nameFromUserMetadata(user) ??
        _emailLocalDisplayName(user) ??
        AppStrings.defaultUserDisplayName(null);

    return UserData(
      id: user.id,
      email: user.email ?? '',
      name: name,
      phone: null,
      avatarUrl: null,
      createdAt: DateTime.now(),
    );
  }

  /// تسجيل الدخول
  Future<AuthResult> login(String email, String password) async {
    try {
      await _supabaseService.login(email, password);

      final userData = await getCurrentUserData();
      return AuthResult(
        success: true,
        message: AppStrings.tr(null, 'تم تسجيل الدخول بنجاح', 'Signed in successfully'),
        user: userData,
      );
    } catch (e) {
      debugPrint('[AuthService] login error: $e');
      return AuthResult(
        success: false,
        message: _mapSupabaseAuthError(
          e,
          fallback: AppStrings.tr(null, 'حدث خطأ غير متوقع', 'Something went wrong'),
        ),
      );
    }
  }

  /// إنشاء حساب جديد
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      // التحقق من البيانات
      if (name.isEmpty) {
        return AuthResult(
          success: false,
          message: AppStrings.tr(null, 'الرجاء إدخال الاسم', 'Please enter your name'),
        );
      }
      if (!_isValidEmail(email)) {
        return AuthResult(
          success: false,
          message: AppStrings.tr(null, 'البريد الإلكتروني غير صحيح', 'Invalid email address'),
        );
      }
      if (password.length < 6) {
        return AuthResult(
          success: false,
          message: AppStrings.tr(
            null,
            'كلمة المرور يجب أن تكون 6 أحرف على الأقل',
            'Password must be at least 6 characters',
          ),
        );
      }

      final authResponse = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'full_name': name.trim(),
          'name': name.trim(),
        },
      );

      final userId = authResponse.user?.id ?? _client.auth.currentUser?.id;
      if (userId == null) {
        return AuthResult(
          success: false,
          message: AppStrings.tr(null, 'حدث خطأ غير متوقع', 'Something went wrong'),
        );
      }

      // Save/Upsert profile in `profiles` table.
      await _client.from('profiles').upsert(
        {
          'id': userId,
          'email': email.trim(),
          'name': name.trim(),
          'phone': phone,
          'created_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'id',
      );

      final userData = await getCurrentUserData();
      return AuthResult(
        success: true,
        message: AppStrings.tr(null, 'تم إنشاء الحساب بنجاح', 'Account created successfully'),
        user: userData,
      );
    } catch (e) {
      debugPrint('[AuthService] register error: $e');
      return AuthResult(
        success: false,
        message: _mapSupabaseAuthError(
          e,
          fallback: AppStrings.tr(null, 'حدث خطأ: $e', 'Error: $e'),
        ),
      );
    }
  }

  /// استعادة كلمة المرور
  Future<AuthResult> forgotPassword(String email) async {
    try {
      if (!_isValidEmail(email)) {
        return AuthResult(
          success: false,
          message: AppStrings.tr(null, 'البريد الإلكتروني غير صحيح', 'Invalid email address'),
        );
      }

      await _client.auth.resetPasswordForEmail(email.trim());

      return AuthResult(
        success: true,
        message: AppStrings.tr(
          null,
          'تم إرسال رابط استعادة كلمة المرور إلى بريدك الإلكتروني',
          'Password reset link sent to your email',
        ),
      );
    } catch (e) {
      debugPrint('[AuthService] forgotPassword error: $e');
      return AuthResult(
        success: false,
        message: _mapSupabaseAuthError(
          e,
          fallback: AppStrings.tr(null, 'حدث خطأ: $e', 'Error: $e'),
        ),
      );
    }
  }

  /// تسجيل الخروج
  Future<void> logout() async {
    await _supabaseService.logout();
  }

  /// تحديث بيانات المستخدم
  Future<AuthResult> updateProfile({
    String? name,
    String? phone,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return AuthResult(
          success: false,
          message: AppStrings.tr(null, 'يجب تسجيل الدخول أولاً', 'Please sign in first'),
        );
      }

      final updates = <String, dynamic>{};
      if (name != null && name.isNotEmpty) {
        updates['name'] = name.trim();
      }
      if (phone != null) {
        updates['phone'] = phone;
      }

      if (updates.isNotEmpty) {
        await _client.from('profiles').update(updates).eq('id', user.id);
      }

      if (name != null && name.trim().isNotEmpty) {
        final trimmed = name.trim();
        await _client.auth.updateUser(
          UserAttributes(
            data: {
              'full_name': trimmed,
              'name': trimmed,
            },
          ),
        );
      }

      final updatedUserData = await getCurrentUserData();

      return AuthResult(
        success: true,
        message: AppStrings.tr(null, 'تم تحديث البيانات بنجاح', 'Profile updated successfully'),
        user: updatedUserData,
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: AppStrings.tr(null, 'حدث خطأ: $e', 'Error: $e'),
      );
    }
  }

  /// التحقق من صحة البريد الإلكتروني
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  String _mapSupabaseAuthError(Object e, {required String fallback}) {
    final msg = e.toString();

    // Map Supabase auth error text to the existing Arabic/English copy.
    if (msg.contains('Invalid login credentials') ||
        msg.contains('invalid login credentials') ||
        msg.contains('Invalid password')) {
      return AppStrings.tr(
        null,
        'البريد الإلكتروني أو كلمة المرور غير صحيحة',
        'Invalid email or password',
      );
    }
    if (msg.contains('Email not confirmed') ||
        msg.contains('email not confirmed')) {
      return AppStrings.tr(
        null,
        'يرجى تأكيد البريد الإلكتروني أولاً',
        'Please confirm your email first',
      );
    }
    if (msg.contains('already registered') ||
        msg.contains('User already registered')) {
      return AppStrings.tr(
        null,
        'هذا البريد الإلكتروني مستخدم بالفعل',
        'This email is already registered',
      );
    }
    if (msg.contains('Invalid email') ||
        msg.contains('invalid email')) {
      return AppStrings.tr(null, 'البريد الإلكتروني غير صحيح', 'Invalid email address');
    }

    return fallback;
  }
}

/// نتيجة المصادقة
class AuthResult {
  final bool success;
  final String message;
  final UserData? user;

  AuthResult({
    required this.success,
    required this.message,
    this.user,
  });
}

/// بيانات المستخدم
class UserData {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? avatarUrl;
  final DateTime createdAt;

  UserData({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.avatarUrl,
    required this.createdAt,
  });

  /// إنشاء من صف `profiles` في Supabase
  factory UserData.fromProfileRow(Map<String, dynamic> row) {
    final rawCreatedAt = row['created_at'] ?? row['createdAt'];
    final createdAt = rawCreatedAt is String
        ? (DateTime.tryParse(rawCreatedAt) ?? DateTime.now())
        : (rawCreatedAt is DateTime ? rawCreatedAt : DateTime.now());

    return UserData(
      id: (row['id'] ?? '') as String,
      email: (row['email'] ?? '') as String,
      name: _firstNonEmptyField([
            row['name'],
            row['full_name'],
            row['display_name'],
          ]) ??
          '',
      phone: row['phone'] as String?,
      avatarUrl: (row['avatar_url'] ?? row['avatarUrl']) as String?,
      createdAt: createdAt,
    );
  }

  /// تحويل إلى JSON (مناسب للـ client-side مؤقتاً)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  UserData copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? avatarUrl,
    DateTime? createdAt,
  }) {
    return UserData(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
