import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/zone_model.dart';

/// خدمة إدارة المناطق (البوردات) — تركّز على البوردات المتغيرة
/// التي يختار الأهل أيّها مفعّل على الجهاز حالياً.
class BoardService {
  static final BoardService _instance = BoardService._internal();
  factory BoardService() => _instance;
  BoardService._internal();

  SupabaseClient get _client => Supabase.instance.client;

  /// جلب كل المناطق المتغيرة (is_dynamic = true) مع قطع كل منطقة.
  /// المنطقة المفعّلة حالياً تكون is_active = true.
  Future<List<Zone>> getDynamicBoards() async {
    try {
      final zoneRows = await _client
          .from('zones')
          .select()
          .eq('is_dynamic', true)
          .order('id', ascending: true);

      final zones = <Zone>[];
      for (final row in (zoneRows as List<dynamic>)) {
        final zoneMap = row as Map<String, dynamic>;
        final zoneId = (zoneMap['id'] is num)
            ? (zoneMap['id'] as num).toInt()
            : int.tryParse('${zoneMap['id']}') ?? 0;

        // قطع هذه المنطقة
        final pieceRows = await _client
            .from('pieces')
            .select()
            .eq('zone_id', zoneId)
            .order('id', ascending: true);

        final pieces = (pieceRows as List<dynamic>)
            .map((p) => ZonePiece.fromSupabase(p as Map<String, dynamic>))
            .toList();

        zones.add(Zone.fromSupabase(zoneMap, pieces: pieces));
      }
      return zones;
    } catch (e) {
      print('[BoardService] getDynamicBoards error: $e');
      return [];
    }
  }

  /// المنطقة المتغيرة المفعّلة حالياً (أو null إن لم توجد).
  Future<Zone?> getActiveBoard() async {
    try {
      final row = await _client
          .from('zones')
          .select()
          .eq('is_dynamic', true)
          .eq('is_active', true)
          .maybeSingle();
      if (row == null) return null;
      return Zone.fromSupabase(row as Map<String, dynamic>);
    } catch (e) {
      print('[BoardService] getActiveBoard error: $e');
      return null;
    }
  }

  /// تفعيل بورد معيّن (يُطفئ الباقي تلقائياً عبر دالة قاعدة البيانات).
  /// الرازبيري ستقرأ is_active من Supabase وتتعامل على أساسه.
  Future<BoardResult> setActiveBoard(String zoneKey) async {
    try {
      await _client.rpc(
        'set_active_board',
        params: {'target_zone_key': zoneKey},
      );
      return BoardResult(success: true, message: 'تم تفعيل البورد بنجاح');
    } catch (e) {
      print('[BoardService] setActiveBoard error: $e');
      // خطة بديلة: لو الدالة غير موجودة، نبدّل يدوياً
      try {
        await _client
            .from('zones')
            .update({'is_active': false})
            .eq('is_dynamic', true);
        await _client
            .from('zones')
            .update({'is_active': true})
            .eq('key', zoneKey);
        return BoardResult(success: true, message: 'تم تفعيل البورد بنجاح');
      } catch (e2) {
        print('[BoardService] setActiveBoard fallback error: $e2');
        return BoardResult(
          success: false,
          message: 'تعذّر تفعيل البورد، حاولي مرة أخرى',
        );
      }
    }
  }
}

class BoardResult {
  final bool success;
  final String message;
  BoardResult({required this.success, required this.message});
}
