import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/content_item_model.dart';

/// خدمة المحتوى الحقيقي (جدول content) + التفضيلات + المحفوظات + الإنجازات.
class ContentLibraryService {
  static final ContentLibraryService _instance =
      ContentLibraryService._internal();
  factory ContentLibraryService() => _instance;
  ContentLibraryService._internal();

  SupabaseClient get _client => Supabase.instance.client;

  // ── المحتوى ──

  /// جلب كل المحتوى الفعّال، مع أسماء المنطقة/القطعة (join).
  /// إن مُرّر childId، تُعلّم العناصر المحفوظة لهذا الطفل.
  Future<List<ContentItem>> getContent({
    String? type,
    String? childId,
  }) async {
    try {
      var query = _client
          .from('content')
          .select('*, zones(name_ar), pieces(name_ar)')
          .eq('is_active', true);

      if (type != null && type.isNotEmpty) {
        query = query.eq('type', type);
      }

      final rows = await query.order('id', ascending: true);

      // مجموعة المحتوى المحفوظ لهذا الطفل
      Set<int> savedIds = {};
      if (childId != null && childId.isNotEmpty) {
        savedIds = await _getSavedContentIds(childId);
      }

      return (rows as List<dynamic>).map((row) {
        final map = row as Map<String, dynamic>;
        final id = (map['id'] is num)
            ? (map['id'] as num).toInt()
            : int.tryParse('${map['id']}') ?? 0;
        return ContentItem.fromSupabase(
          map,
          isSavedForChild: savedIds.contains(id),
        );
      }).toList();
    } catch (e) {
      print('[ContentLibraryService] getContent error: $e');
      return [];
    }
  }

  // ── المحتوى المحفوظ الخاص لكل طفل ──

  Future<Set<int>> _getSavedContentIds(String childId) async {
    try {
      final rows = await _client
          .from('child_saved_content')
          .select('content_id')
          .eq('child_id', childId);
      return (rows as List<dynamic>)
          .map((r) => (r as Map<String, dynamic>)['content_id'])
          .map((v) => (v is num) ? v.toInt() : int.tryParse('$v') ?? 0)
          .toSet();
    } catch (e) {
      print('[ContentLibraryService] _getSavedContentIds error: $e');
      return {};
    }
  }

  /// جلب المحتوى المحفوظ لطفل (العناصر الكاملة).
  Future<List<ContentItem>> getSavedContent(String childId) async {
    try {
      // 1) معرّفات المحتوى المحفوظ لهذا الطفل
      final savedIds = await _getSavedContentIds(childId);
      if (savedIds.isEmpty) return [];

      // 2) جلب صفوف المحتوى المطابقة مع أسماء المنطقة/القطعة
      final rows = await _client
          .from('content')
          .select('*, zones(name_ar), pieces(name_ar)')
          .inFilter('id', savedIds.toList());

      return (rows as List<dynamic>)
          .map((r) => ContentItem.fromSupabase(
                Map<String, dynamic>.from(r as Map),
                isSavedForChild: true,
              ))
          .toList();
    } catch (e) {
      print('[ContentLibraryService] getSavedContent error: $e');
      return [];
    }
  }

  /// حفظ محتوى لطفل.
  Future<bool> saveContentForChild(String childId, int contentId) async {
    try {
      await _client.from('child_saved_content').insert({
        'child_id': childId,
        'content_id': contentId,
      });
      return true;
    } catch (e) {
      print('[ContentLibraryService] saveContentForChild error: $e');
      return false;
    }
  }

  /// إلغاء حفظ محتوى لطفل.
  Future<bool> unsaveContentForChild(String childId, int contentId) async {
    try {
      await _client
          .from('child_saved_content')
          .delete()
          .eq('child_id', childId)
          .eq('content_id', contentId);
      return true;
    } catch (e) {
      print('[ContentLibraryService] unsaveContentForChild error: $e');
      return false;
    }
  }

  // ── التفضيلات العامة (parent_preferences) ──

  /// جلب الأنواع المفضّلة العامة لطفل.
  Future<List<String>> getPreferredTypes(String childId) async {
    try {
      final row = await _client
          .from('parent_preferences')
          .select('preferred_types')
          .eq('child_id', childId)
          .maybeSingle();
      if (row == null) return [];
      final v = (row as Map<String, dynamic>)['preferred_types'];
      if (v is List) return v.map((e) => e.toString()).toList();
      return [];
    } catch (e) {
      print('[ContentLibraryService] getPreferredTypes error: $e');
      return [];
    }
  }

  /// حفظ الأنواع المفضّلة العامة لطفل (upsert).
  Future<bool> setPreferredTypes(
      String childId, List<String> types) async {
    try {
      await _client.from('parent_preferences').upsert({
        'child_id': childId,
        'preferred_types': types,
        'updated_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('[ContentLibraryService] setPreferredTypes error: $e');
      return false;
    }
  }

  // ── الإنجازات (achievements) ──

  /// جلب مفاتيح الإنجازات المحقّقة لطفل (item_key المحقّقة).
  Future<Set<String>> getAchievedKeys(String childId) async {
    try {
      final rows = await _client
          .from('achievements')
          .select('item_key')
          .eq('child_id', childId);
      return (rows as List<dynamic>)
          .map((r) => (r as Map<String, dynamic>)['item_key']?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toSet();
    } catch (e) {
      print('[ContentLibraryService] getAchievedKeys error: $e');
      return {};
    }
  }

  /// جلب الإنجازات مع تواريخها لطفل: item_key -> achieved_at.
  Future<Map<String, DateTime>> getAchievementsWithDates(
      String childId) async {
    try {
      final rows = await _client
          .from('achievements')
          .select('item_key, achieved_at')
          .eq('child_id', childId);
      final map = <String, DateTime>{};
      for (final r in (rows as List<dynamic>)) {
        final m = r as Map<String, dynamic>;
        final key = m['item_key']?.toString();
        if (key == null || key.isEmpty) continue;
        final raw = m['achieved_at'];
        final date = raw is String
            ? (DateTime.tryParse(raw) ?? DateTime.now())
            : DateTime.now();
        map[key] = date;
      }
      return map;
    } catch (e) {
      print('[ContentLibraryService] getAchievementsWithDates error: $e');
      return {};
    }
  }
}
