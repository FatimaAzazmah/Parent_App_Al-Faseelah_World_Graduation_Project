// Copyright © 2026 Fatima Azazmah. All rights reserved.
// Al-Faseelah World — Parent App. Unauthorised reuse is prohibited.
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/app_strings.dart';
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
        return ServiceResult(success: false, message: AppStrings.tr(null, 'يجب تسجيل الدخول أولاً', 'Please sign in first'));
      }

      final insert = goal.copyWith(parentId: uid).toSupabaseInsert(uid);
      final row = await _client
          .from('behavior_goals')
          .insert(insert)
          .select()
          .single();

      return ServiceResult(
        success: true,
        message: AppStrings.tr(null, 'تم إضافة الهدف بنجاح', 'Goal added successfully'),
        data: BehaviorGoal.fromSupabase(Map<String, dynamic>.from(row)),
      );
    } catch (e) {
      return ServiceResult(success: false, message: AppStrings.tr(null, 'حدث خطأ: $e', 'Error: $e'));
    }
  }

  Future<ServiceResult> updateGoalProgress(String goalId, int newCount) async {
    try {
      final uid = _supabaseUserId;
      if (uid == null) {
        return ServiceResult(success: false, message: AppStrings.tr(null, 'يجب تسجيل الدخول أولاً', 'Please sign in first'));
      }

      final existing = await _client
          .from('behavior_goals')
          .select()
          .eq('id', goalId)
          .eq('parent_id', uid)
          .maybeSingle();

      if (existing == null) {
        return ServiceResult(success: false, message: AppStrings.tr(null, 'الهدف غير موجود', 'Goal not found'));
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
        message: isCompleted ? AppStrings.tr(null, 'تم إكمال الهدف!', 'Goal completed!') : AppStrings.tr(null, 'تم تحديث التقدم', 'Progress updated'),
      );
    } catch (e) {
      return ServiceResult(success: false, message: AppStrings.tr(null, 'حدث خطأ: $e', 'Error: $e'));
    }
  }

  Future<ServiceResult> deleteGoal(String goalId) async {
    try {
      final uid = _supabaseUserId;
      if (uid == null) {
        return ServiceResult(success: false, message: AppStrings.tr(null, 'يجب تسجيل الدخول أولاً', 'Please sign in first'));
      }

      await _client
          .from('behavior_goals')
          .delete()
          .eq('id', goalId)
          .eq('parent_id', uid);

      return ServiceResult(success: true, message: AppStrings.tr(null, 'تم حذف الهدف', 'Goal deleted'));
    } catch (e) {
      return ServiceResult(success: false, message: AppStrings.tr(null, 'حدث خطأ: $e', 'Error: $e'));
    }
  }
}
