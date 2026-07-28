// Copyright © 2026 Fatima Azazmah. All rights reserved.
// Al-Faseelah World — Parent App. Unauthorised reuse is prohibited.
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/content_item_model.dart';

/// خدمة مكتبة المحتوى: عناصر التعلّم التي يستطيع الأهل تصفّحها،
/// ما يعلّمونه كمفضّل لكل طفل، تفضيلات الأنواع، وإنجازات الطفل.
class ContentLibraryService {
  // Singleton pattern
  static final ContentLibraryService _instance =
      ContentLibraryService._internal();
  factory ContentLibraryService() => _instance;
  ContentLibraryService._internal();

  SupabaseClient get _client => Supabase.instance.client;

  /// الأعمدة اللازمة لبناء [ContentItem] كاملاً، وفيها اسما المنطقة
  /// والقطعة عبر العلاقات حتى لا نحتاج استعلامات إضافية لكل عنصر.
  static const String _contentColumns =
      '*, zones(name_ar,name_en), pieces(name_ar,name_en)';

  // ── المحتوى ──

  /// يجلب مكتبة المحتوى الفعّالة كاملة، ويعلّم فيها ما حفظه الأهل
  /// للطفل المحدّد. تمرير [childId] فارغاً يعيد المكتبة بلا تعليم.
  ///
  /// تُشتقّ قائمة «المحفوظ» من هذه النتيجة بالترشيح محلياً، فيكفي
  /// استعلامان لكل الشاشة بدل أربعة، ويستحيل أن يختلف التبويبان.
  Future<List<ContentItem>> getLibraryForChild(String? childId) async {
    try {
      final rows = await _client
          .from('content')
          .select(_contentColumns)
          .eq('is_active', true)
          .order('id', ascending: true);

      final savedIds = await _savedContentIds(childId);

      return [
        for (final row in rows as List<dynamic>)
          if (row is Map)
            _contentFromSupabaseRow(
              Map<String, dynamic>.from(row),
              isSavedForChild: savedIds.contains(_readInt(row['id'])),
            ),
      ];
    } catch (e) {
      debugPrint('[ContentLibraryService] getLibraryForChild error: $e');
      return [];
    }
  }

  // ── المحفوظات لكل طفل ──

  /// معرّفات المحتوى الذي علّمه الأهل كمفضّل لهذا الطفل.
  /// يعيد مجموعة فارغة إن لم يكن هناك طفل مختار.
  Future<Set<int>> _savedContentIds(String? childId) async {
    if (childId == null || childId.isEmpty) return <int>{};

    try {
      final rows = await _client
          .from('child_saved_content')
          .select('content_id')
          .eq('child_id', childId);

      final ids = <int>{};
      for (final row in rows as List<dynamic>) {
        if (row is Map) ids.add(_readInt(row['content_id']));
      }
      return ids;
    } catch (e) {
      debugPrint('[ContentLibraryService] _savedContentIds error: $e');
      return <int>{};
    }
  }

  /// يعلّم عنصراً كمفضّل لطفل، فتميل الفسيلة لتقديمه له أثناء اللعب.
  Future<bool> saveContentForChild(String childId, int contentId) async {
    try {
      await _client.from('child_saved_content').insert({
        'child_id': childId,
        'content_id': contentId,
      });
      return true;
    } catch (e) {
      debugPrint('[ContentLibraryService] saveContentForChild error: $e');
      return false;
    }
  }

  /// يزيل تعليم المفضّل عن عنصر لطفل.
  Future<bool> unsaveContentForChild(String childId, int contentId) async {
    try {
      await _client
          .from('child_saved_content')
          .delete()
          .eq('child_id', childId)
          .eq('content_id', contentId);
      return true;
    } catch (e) {
      debugPrint('[ContentLibraryService] unsaveContentForChild error: $e');
      return false;
    }
  }

  // ── تفضيلات الأنواع ──

  /// أنواع المحتوى التي يفضّل الأهل أن تميل إليها جلسات الطفل.
  Future<List<String>> getPreferredTypes(String childId) async {
    try {
      final row = await _client
          .from('parent_preferences')
          .select('preferred_types')
          .eq('child_id', childId)
          .maybeSingle();

      final stored = row?['preferred_types'];
      if (stored is! List) return [];

      return [
        for (final type in stored)
          if (type != null) type.toString(),
      ];
    } catch (e) {
      debugPrint('[ContentLibraryService] getPreferredTypes error: $e');
      return [];
    }
  }

  /// يحفظ الأنواع المفضّلة لطفل، ويستبدل ما كان محفوظاً له سابقاً.
  Future<bool> setPreferredTypes(String childId, List<String> types) async {
    try {
      await _client.from('parent_preferences').upsert({
        'child_id': childId,
        'preferred_types': types,
        'updated_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      debugPrint('[ContentLibraryService] setPreferredTypes error: $e');
      return false;
    }
  }

  // ── الإنجازات ──

  /// إنجازات الطفل: مفتاح كل عنصر أتقنه مقابل تاريخ إتقانه.
  /// مفاتيح الخريطة وحدها تكفي لمعرفة ما تحقّق دون تواريخه.
  Future<Map<String, DateTime>> getAchievementsWithDates(
      String childId) async {
    try {
      final rows = await _client
          .from('achievements')
          .select('item_key, achieved_at')
          .eq('child_id', childId);

      final achieved = <String, DateTime>{};
      for (final row in rows as List<dynamic>) {
        if (row is! Map) continue;
        final key = row['item_key']?.toString() ?? '';
        if (key.isEmpty) continue;
        achieved[key] = _readDate(row['achieved_at']);
      }
      return achieved;
    } catch (e) {
      debugPrint('[ContentLibraryService] getAchievementsWithDates error: $e');
      return {};
    }
  }

  // ── قراءة صفوف Supabase ──

  /// قراءة رقم صحيح قد يصل كعدد أو كنص.
  static int _readInt(dynamic value, {int fallback = 0}) {
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? fallback;
  }

  /// قراءة تاريخ نصّي، مع اعتبار غير الصالح تاريخ اليوم.
  static DateTime _readDate(dynamic value) {
    if (value is DateTime) return value;
    return DateTime.tryParse('$value') ?? DateTime.now();
  }

  /// قراءة اسم من كائن العلاقة القادم عبر join، إن وُجد.
  static String? _readJoinedName(dynamic relation, String column) {
    if (relation is! Map) return null;
    return relation[column]?.toString();
  }

  /// تحويل صف من جدول content إلى [ContentItem].
  /// [isSavedForChild] تُحسب خارج هذه الدالة لأنها تخصّ الطفل المختار
  /// وليست جزءاً من الصف نفسه.
  ContentItem _contentFromSupabaseRow(
    Map<String, dynamic> row, {
    bool isSavedForChild = false,
  }) {
    final rawCard = row['knowledge_card'];
    final zone = row['zones'];
    final piece = row['pieces'];

    return ContentItem(
      id: _readInt(row['id']),
      type: row['type']?.toString() ?? 'learn',
      difficulty: _readInt(row['difficulty'], fallback: 1),
      knowledgeCard:
          rawCard is Map ? Map<String, dynamic>.from(rawCard) : const {},
      trackableKey: row['trackable_key']?.toString(),
      zoneNameAr: _readJoinedName(zone, 'name_ar'),
      zoneNameEn: _readJoinedName(zone, 'name_en'),
      pieceNameAr: _readJoinedName(piece, 'name_ar'),
      pieceNameEn: _readJoinedName(piece, 'name_en'),
      isSavedForChild: isSavedForChild,
    );
  }
}
