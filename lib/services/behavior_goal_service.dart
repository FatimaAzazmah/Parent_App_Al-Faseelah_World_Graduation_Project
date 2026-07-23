import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/behavior_goal_model.dart';
import 'child_service.dart';

class BehaviorGoalService {
  static final BehaviorGoalService _instance = BehaviorGoalService._internal();
  factory BehaviorGoalService() => _instance;
  BehaviorGoalService._internal();

  SupabaseClient get _client => Supabase.instance.client;

  String? get _supabaseUserId => _client.auth.currentUser?.id;

  Future<List<BehaviorGoal>> getGoalsForChild(String childId) async {
    try {
      final uid = _supabaseUserId;
      if (uid == null) return [];

      final rows = await _client
          .from('behavior_goals')
          .select()
          .eq('child_id', childId)
          .eq('parent_id', uid)
          .order('created_at', ascending: false);

      return (rows as List<dynamic>)
          .map((row) => BehaviorGoal.fromSupabase(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('[BehaviorGoalService] getGoalsForChild error: $e');
      return [];
    }
  }

  Stream<List<BehaviorGoal>> getGoalsStream(String childId) {
    return Stream.value([]);
  }

  Future<ServiceResult> addGoal(BehaviorGoal goal) async {
    try {
      final uid = _supabaseUserId;
      if (uid == null) {
        return ServiceResult(success: false, message: 'يجب تسجيل الدخول أولاً');
      }

      final insert = goal.copyWith(parentId: uid).toSupabaseInsert(uid);
      final row = await _client
          .from('behavior_goals')
          .insert(insert)
          .select()
          .single();

      return ServiceResult(
        success: true,
        message: 'تم إضافة الهدف بنجاح',
        data: BehaviorGoal.fromSupabase(Map<String, dynamic>.from(row)),
      );
    } catch (e) {
      return ServiceResult(success: false, message: 'حدث خطأ: $e');
    }
  }

  Future<ServiceResult> updateGoalProgress(String goalId, int newCount) async {
    try {
      final uid = _supabaseUserId;
      if (uid == null) {
        return ServiceResult(success: false, message: 'يجب تسجيل الدخول أولاً');
      }

      final existing = await _client
          .from('behavior_goals')
          .select()
          .eq('id', goalId)
          .eq('parent_id', uid)
          .maybeSingle();

      if (existing == null) {
        return ServiceResult(success: false, message: 'الهدف غير موجود');
      }

      final data = Map<String, dynamic>.from(existing);
      final targetCount = (data['target_count'] is num)
          ? (data['target_count'] as num).round()
          : int.tryParse('${data['target_count']}') ?? 1;
      final isCompleted = newCount >= targetCount;

      await _client.from('behavior_goals').update({
        'current_count': newCount,
        'is_completed': isCompleted,
        if (isCompleted) 'completed_at': DateTime.now().toIso8601String(),
      }).eq('id', goalId).eq('parent_id', uid);

      return ServiceResult(
        success: true,
        message: isCompleted ? 'تم إكمال الهدف!' : 'تم تحديث التقدم',
      );
    } catch (e) {
      return ServiceResult(success: false, message: 'حدث خطأ: $e');
    }
  }

  Future<ServiceResult> deleteGoal(String goalId) async {
    try {
      final uid = _supabaseUserId;
      if (uid == null) {
        return ServiceResult(success: false, message: 'يجب تسجيل الدخول أولاً');
      }

      await _client
          .from('behavior_goals')
          .delete()
          .eq('id', goalId)
          .eq('parent_id', uid);

      return ServiceResult(success: true, message: 'تم حذف الهدف');
    } catch (e) {
      return ServiceResult(success: false, message: 'حدث خطأ: $e');
    }
  }
}
