import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/zone_model.dart';
import '../utils/app_strings.dart';

/// خدمة البوردات المتغيّرة: اللوح الذي يركّبه الأهل على اللعبة.
/// يقرأ جهاز الرازبيري اللوح المفعّل من قاعدة البيانات قبل كل جلسة،
/// فالتطبيق يكتب الاختيار ولا يتصل بالجهاز مباشرة.
class BoardService {
  // Singleton pattern
  static final BoardService _instance = BoardService._internal();
  factory BoardService() => _instance;
  BoardService._internal();

  SupabaseClient get _client => Supabase.instance.client;

  /// اسم دالة قاعدة البيانات التي تنقل التفعيل من لوح لآخر في عملية واحدة.
  static const String _activateFunction = 'set_active_board';

  /// المنطقة مع قطعها في استعلام واحد عبر العلاقة بينهما، بدل استعلام
  /// منفصل لقطع كل منطقة.
  static const String _boardColumns = '*, pieces(*)';

  /// يجلب البوردات المتغيّرة التي يستطيع الأهل تبديلها، مع قطع كل لوح.
  /// المفعّل حالياً هو الذي [Zone.isActive] فيه صحيحة.
  Future<List<Zone>> getDynamicBoards() async {
    try {
      final rows = await _client
          .from('zones')
          .select(_boardColumns)
          .eq('is_dynamic', true)
          .order('id', ascending: true);

      return [
        for (final row in rows as List<dynamic>)
          if (row is Map) _boardFromSupabaseRow(Map<String, dynamic>.from(row)),
      ];
    } catch (e) {
      debugPrint('[BoardService] getDynamicBoards error: $e');
      return [];
    }
  }

  /// يفعّل اللوح المطابق لـ [zoneKey] ويُطفئ ما عداه.
  ///
  /// يتم عبر دالة في قاعدة البيانات لتصير العملية ذرّية: إمّا ينتقل
  /// التفعيل كاملاً أو لا يتغيّر شيء، فلا يبقى الجهاز بلا لوح مفعّل.
  Future<BoardResult> setActiveBoard(String zoneKey) async {
    try {
      await _client.rpc(
        _activateFunction,
        params: {'target_zone_key': zoneKey},
      );
      return BoardResult(
        success: true,
        message: AppStrings.tr(
          null,
          'تم تفعيل البورد بنجاح',
          'Board activated successfully',
        ),
      );
    } catch (e) {
      debugPrint('[BoardService] setActiveBoard error: $e');
      return BoardResult(
        success: false,
        message: AppStrings.tr(
          null,
          'تعذّر تفعيل البورد، حاولي مرة أخرى',
          'Could not activate the board, please try again',
        ),
      );
    }
  }

  // ── قراءة صفوف Supabase ──

  /// قراءة رقم صحيح قد يصل كعدد أو كنص.
  static int _readInt(dynamic value, {int fallback = 0}) {
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? fallback;
  }

  /// مثل [_readInt] لكنها تُبقي القيمة فارغة إن لم تكن رقماً صالحاً.
  static int? _readOptionalInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    return int.tryParse('$value');
  }

  /// قراءة نص، مع اعتبار القيمة الفارغة نصاً فارغاً.
  static String _readText(dynamic value) => value?.toString() ?? '';

  /// تحويل صف من جدول zones، مع قطعه المضمّنة في العلاقة، إلى [Zone].
  Zone _boardFromSupabaseRow(Map<String, dynamic> row) {
    final embedded = row['pieces'];
    final pieces = <ZonePiece>[];

    if (embedded is List) {
      for (final piece in embedded) {
        if (piece is Map) {
          pieces.add(_pieceFromSupabaseRow(Map<String, dynamic>.from(piece)));
        }
      }
      // العلاقة لا تضمن ترتيباً، ونرتّب هنا ليظهر اللوح بترتيب ثابت.
      pieces.sort((a, b) => a.id.compareTo(b.id));
    }

    return Zone(
      id: _readInt(row['id']),
      key: _readText(row['key']),
      nameAr: _readText(row['name_ar']),
      nameEn: _readText(row['name_en']),
      isDynamic: row['is_dynamic'] == true,
      isActive: row['is_active'] == true,
      pieces: pieces,
    );
  }

  /// تحويل صف من جدول pieces إلى [ZonePiece].
  ZonePiece _pieceFromSupabaseRow(Map<String, dynamic> row) {
    return ZonePiece(
      id: _readInt(row['id']),
      zoneId: _readOptionalInt(row['zone_id']),
      key: _readText(row['key']),
      nameAr: _readText(row['name_ar']),
      nameEn: _readText(row['name_en']),
      sensorPin: _readOptionalInt(row['sensor_pin']),
    );
  }
}

/// نتيجة محاولة تفعيل لوح، برسالة جاهزة للعرض بلغة التطبيق.
class BoardResult {
  final bool success;
  final String message;

  BoardResult({required this.success, required this.message});
}
