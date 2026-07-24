import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/app_strings.dart';
import '../models/child_model.dart';
import '../models/session_model.dart' as models;
import '../models/activity_model.dart';

/// خدمة إدارة الأطفال والجلسات عبر Supabase
class ChildService {
  // Singleton pattern
  static final ChildService _instance = ChildService._internal();
  factory ChildService() => _instance;
  ChildService._internal();

  SupabaseClient get _client => Supabase.instance.client;

  /// الحصول على قائمة الأطفال للمستخدم الحالي
  Future<List<Child>> getChildren() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return [];

      final rows = await _client
          .from('children')
          .select()
          .eq('parent_id', user.id)
          .order('created_at', ascending: false);

      return (rows as List<dynamic>)
          .map((row) => _childFromSupabaseRow(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('[ChildService] getChildren error: $e');
      return [];
    }
  }

  /// Stream للاستماع لتغييرات قائمة الأطفال
  Stream<List<Child>> getChildrenStream() {
    return Stream.value([]);
  }

  /// الحصول على طفل بالـ ID
  Future<Child?> getChildById(String id) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final row = await _client
          .from('children')
          .select()
          .eq('id', id)
          .eq('parent_id', user.id)
          .maybeSingle();

      if (row == null) return null;
      return _childFromSupabaseRow(row as Map<String, dynamic>);
    } catch (e) {
      print('[ChildService] getChildById error: $e');
      return null;
    }
  }

  /// الحصول على طفل بواسطة معرّف قطعة الـ RFID الخاصة به
  Future<Child?> getChildByRfid(String rfidId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final row = await _client
          .from('children')
          .select()
          .eq('rfid_id', rfidId)
          .eq('parent_id', user.id)
          .maybeSingle();

      if (row == null) return null;
      return _childFromSupabaseRow(row as Map<String, dynamic>);
    } catch (e) {
      print('[ChildService] getChildByRfid error: $e');
      return null;
    }
  }

  /// إضافة طفل جديد
  Future<ServiceResult> addChild(Child child) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return ServiceResult(
          success: false,
          message: AppStrings.tr(null, 'يجب تسجيل الدخول أولاً', 'Please sign in first'),
        );
      }

      final now = DateTime.now();
      final payload = _toSupabasePayload(
        child.copyWith(createdAt: now),
        parentId: user.id,
      );

      final inserted = await _client
          .from('children')
          .insert(payload)
          .select()
          .single();

      final addedChild = _childFromSupabaseRow(inserted as Map<String, dynamic>);

      return ServiceResult(
        success: true,
        message: AppStrings.tr(null, 'تم إضافة ${child.name} بنجاح', '${child.name} added successfully'),
        data: addedChild,
      );
    } catch (e) {
      print('[ChildService] addChild error: $e');
      return ServiceResult(
        success: false,
        message: AppStrings.tr(null, 'حدث خطأ: $e', 'Error: $e'),
      );
    }
  }

  /// تحديث بيانات طفل
  Future<ServiceResult> updateChild(Child child) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return ServiceResult(
          success: false,
          message: AppStrings.tr(null, 'يجب تسجيل الدخول أولاً', 'Please sign in first'),
        );
      }

      final payload = _toSupabasePayload(child, parentId: user.id);
      await _client
          .from('children')
          .update(payload)
          .eq('id', child.id)
          .eq('parent_id', user.id);

      return ServiceResult(
        success: true,
        message: AppStrings.tr(null, 'تم تحديث البيانات بنجاح', 'Updated successfully'),
        data: child,
      );
    } catch (e) {
      print('[ChildService] updateChild error: $e');
      return ServiceResult(
        success: false,
        message: AppStrings.tr(null, 'حدث خطأ: $e', 'Error: $e'),
      );
    }
  }

  /// حذف طفل
  Future<ServiceResult> deleteChild(String id) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return ServiceResult(
          success: false,
          message: AppStrings.tr(null, 'يجب تسجيل الدخول أولاً', 'Please sign in first'),
        );
      }

      await _client
          .from('children')
          .delete()
          .eq('id', id)
          .eq('parent_id', user.id);

      return ServiceResult(
        success: true,
        message: AppStrings.tr(null, 'تم الحذف بنجاح', 'Deleted successfully'),
      );
    } catch (e) {
      print('[ChildService] deleteChild error: $e');
      return ServiceResult(
        success: false,
        message: AppStrings.tr(null, 'حدث خطأ: $e', 'Error: $e'),
      );
    }
  }

  static int _parseAge(dynamic raw) {
    if (raw == null) return 5;
    if (raw is int) return raw;
    if (raw is num) return raw.round();
    if (raw is String) return int.tryParse(raw) ?? 5;
    return 5;
  }

  Child _childFromSupabaseRow(Map<String, dynamic> row) {
    final createdAtRaw = row['created_at'];
    final createdAt = createdAtRaw is String
        ? (DateTime.tryParse(createdAtRaw) ?? DateTime.now())
        : DateTime.now();

    return Child(
      id: (row['id'] ?? '') as String,
      name: (row['name'] ?? '') as String,
      nameEn: row['name_en'] as String?,
      age: _parseAge(row['age']),
      gender: (row['gender'] ?? 'ذكر') as String,
      avatar: (row['avatar'] ?? '👦') as String,
      interests: List<String>.from(row['interests'] ?? const []),
      createdAt: createdAt,
      parentId: row['parent_id'] as String?,
      parentNotes: row['parent_notes'] as String?,
      rfidId: row['rfid_id'] as String?,
    );
  }

  Map<String, dynamic> _toSupabasePayload(Child child, {required String parentId}) {
    return {
      'name': child.name,
      'name_en': child.nameEn,
      'age': child.age,
      'gender': child.gender,
      'avatar': child.avatar,
      'interests': child.interests,
      'created_at': child.createdAt.toIso8601String(),
      'parent_id': parentId,
      'parent_notes': child.parentNotes,
      'rfid_id': child.rfidId,
    };
  }

  static DateTime _parseDate(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
    return DateTime.now();
  }

  static Map<String, int> _zonesVisitedFromJson(dynamic raw) {
    if (raw is Map) {
      return raw.map(
        (k, v) => MapEntry(
          k.toString(),
          (v is num) ? v.round() : int.tryParse('$v') ?? 0,
        ),
      );
    }
    return {};
  }

  static List<Activity> _activitiesFromJson(dynamic raw) {
    if (raw is! List) return [];
    final out = <Activity>[];
    for (final a in raw) {
      if (a is Map) {
        out.add(Activity.fromJson(Map<String, dynamic>.from(a)));
      }
    }
    return out;
  }

  models.Session _sessionFromSupabaseRow(Map<String, dynamic> data) {
    return models.Session(
      id: data['id']?.toString() ?? '',
      childId: data['child_id']?.toString() ?? '',
      startTime: _parseDate(data['start_time']),
      endTime: data['end_time'] != null ? _parseDate(data['end_time']) : null,
      totalMinutes: (data['total_minutes'] is num)
          ? (data['total_minutes'] as num).round()
          : int.tryParse('${data['total_minutes']}') ?? 0,
      activities: _activitiesFromJson(data['activities']),
      zonesVisited: _zonesVisitedFromJson(data['zones_visited']),
      mood: data['mood']?.toString() ?? '',
      focusLevel: data['focus_level']?.toString() ?? '',
      starsEarned: (data['stars_earned'] is num)
          ? (data['stars_earned'] as num).round()
          : int.tryParse('${data['stars_earned']}') ?? 0,
    );
  }

  /// الحصول على جلسات طفل
  Future<List<models.Session>> getChildSessions(String childId) async {
    return getSessionsForChild(childId, limit: 10);
  }

  /// الحصول على جلسات طفل مع فلاتر زمنية
  Future<List<models.Session>> getSessionsForChild(
    String childId, {
    DateTime? from,
    DateTime? to,
    int? limit,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return [];

      dynamic query = _client
          .from('sessions')
          .select()
          .eq('child_id', childId)
          .eq('parent_id', user.id);

      if (from != null) {
        query = query.gte('start_time', from.toIso8601String());
      }
      if (to != null) {
        query = query.lte('start_time', to.toIso8601String());
      }
      query = query.order('start_time', ascending: false);
      if (limit != null) {
        query = query.limit(limit);
      }

      final rows = await query;

      return (rows as List<dynamic>)
          .map((row) => _sessionFromSupabaseRow(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('[ChildService] getSessionsForChild error: $e');
      return [];
    }
  }

  /// الحصول على جلسة واحدة بالمعرف
  Future<models.Session?> getSessionById(String sessionId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;
      final row = await _client
          .from('sessions')
          .select()
          .eq('id', sessionId)
          .eq('parent_id', user.id)
          .maybeSingle();
      if (row == null) return null;
      return _sessionFromSupabaseRow(row as Map<String, dynamic>);
    } catch (e) {
      print('[ChildService] getSessionById error: $e');
      return null;
    }
  }

  /// الحصول على إحصائيات طفل
  Future<ChildStats> getChildStats(String childId) async {
    final empty = ChildStats(
      totalMinutes: 0,
      totalActivities: 0,
      totalStars: 0,
      averageDailyMinutes: 0,
      favoriteZone: AppStrings.tr(null, 'غير محدد', 'Not set'),
      topSkill: AppStrings.tr(null, 'التعلم', 'Learning'),
    );
    try {
      final user = _client.auth.currentUser;
      if (user == null) return empty;

      final rows = await _client
          .from('sessions')
          .select()
          .eq('child_id', childId)
          .eq('parent_id', user.id);

      int totalMinutes = 0;
      int totalActivities = 0;
      int totalStars = 0;
      final Map<String, int> zonesCounts = {};

      final weekAgo = DateTime.now().subtract(const Duration(days: 7));
      int weeklyMinutes = 0;

      for (final r in rows as List<dynamic>) {
        final data = r as Map<String, dynamic>;
        final mins = (data['total_minutes'] is num)
            ? (data['total_minutes'] as num).round()
            : int.tryParse('${data['total_minutes']}') ?? 0;
        totalMinutes += mins;
        totalStars += (data['stars_earned'] is num)
            ? (data['stars_earned'] as num).round()
            : int.tryParse('${data['stars_earned']}') ?? 0;

        final acts = data['activities'];
        if (acts is List) {
          totalActivities += acts.length;
        }

        _zonesVisitedFromJson(data['zones_visited'])
            .forEach((zone, count) {
          zonesCounts[zone] = (zonesCounts[zone] ?? 0) + count;
        });

        final st = _parseDate(data['start_time']);
        if (st.isAfter(weekAgo)) {
          weeklyMinutes += mins;
        }
      }

      final averageDailyMinutes = (weeklyMinutes / 7).round();

      String favoriteZone = AppStrings.tr(null, 'غير محدد', 'Not set');
      if (zonesCounts.isNotEmpty) {
        favoriteZone = zonesCounts.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key;
      }

      return ChildStats(
        totalMinutes: totalMinutes,
        totalActivities: totalActivities,
        totalStars: totalStars,
        averageDailyMinutes: averageDailyMinutes,
        favoriteZone: favoriteZone,
        topSkill: AppStrings.tr(null, 'التعلم', 'Learning'),
      );
    } catch (e) {
      print('[ChildService] getChildStats error: $e');
      return empty;
    }
  }

  /// حفظ جلسة جديدة
  Future<ServiceResult> saveSession(models.Session session) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return ServiceResult(
          success: false,
          message: AppStrings.tr(null, 'يجب تسجيل الدخول أولاً', 'Please sign in first'),
        );
      }

      await _client.from('sessions').insert({
        'child_id': session.childId,
        'parent_id': user.id,
        'start_time': session.startTime.toIso8601String(),
        'end_time': session.endTime?.toIso8601String(),
        'total_minutes': session.totalMinutes,
        'activities': session.activities.map((a) => a.toJson()).toList(),
        'zones_visited': session.zonesVisited,
        'mood': session.mood,
        'focus_level': session.focusLevel,
        'stars_earned': session.starsEarned,
      });

      return ServiceResult(
        success: true,
        message: AppStrings.tr(null, 'تم حفظ الجلسة بنجاح', 'Session saved successfully'),
      );
    } catch (e) {
      return ServiceResult(
        success: false,
        message: AppStrings.tr(null, 'حدث خطأ: $e', 'Error: $e'),
      );
    }
  }
}

/// نتيجة الخدمة
class ServiceResult {
  final bool success;
  final String message;
  final dynamic data;

  ServiceResult({
    required this.success,
    required this.message,
    this.data,
  });
}

/// إحصائيات الطفل
class ChildStats {
  final int totalMinutes;
  final int totalActivities;
  final int totalStars;
  final int averageDailyMinutes;
  final String favoriteZone;
  final String topSkill;

  ChildStats({
    required this.totalMinutes,
    required this.totalActivities,
    required this.totalStars,
    required this.averageDailyMinutes,
    required this.favoriteZone,
    required this.topSkill,
  });
}
