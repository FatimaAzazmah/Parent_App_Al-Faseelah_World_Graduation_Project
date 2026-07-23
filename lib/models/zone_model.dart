/// يمثّل منطقة (بورد) من جدول zones في Supabase.
class Zone {
  final int id;
  final String key;
  final String nameAr;
  final String nameEn;
  final String goalsAr;
  final bool isDynamic;
  final bool isActive;

  /// القطع التابعة لهذه المنطقة (تُحمّل اختيارياً من جدول pieces).
  final List<ZonePiece> pieces;

  const Zone({
    required this.id,
    required this.key,
    required this.nameAr,
    required this.nameEn,
    this.goalsAr = '',
    this.isDynamic = false,
    this.isActive = false,
    this.pieces = const [],
  });

  factory Zone.fromSupabase(
    Map<String, dynamic> row, {
    List<ZonePiece> pieces = const [],
  }) {
    return Zone(
      id: (row['id'] is num)
          ? (row['id'] as num).toInt()
          : int.tryParse('${row['id']}') ?? 0,
      key: row['key']?.toString() ?? '',
      nameAr: row['name_ar']?.toString() ?? '',
      nameEn: row['name_en']?.toString() ?? '',
      goalsAr: row['goals_ar']?.toString() ?? '',
      isDynamic: row['is_dynamic'] == true,
      isActive: row['is_active'] == true,
      pieces: pieces,
    );
  }

  Zone copyWith({bool? isActive, List<ZonePiece>? pieces}) {
    return Zone(
      id: id,
      key: key,
      nameAr: nameAr,
      nameEn: nameEn,
      goalsAr: goalsAr,
      isDynamic: isDynamic,
      isActive: isActive ?? this.isActive,
      pieces: pieces ?? this.pieces,
    );
  }

  /// أهداف المنطقة كقائمة (goals_ar مفصولة بفواصل عربية).
  List<String> get goalsList => goalsAr
      .split(RegExp(r'[،,]'))
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
}

/// قطعة داخل منطقة (من جدول pieces).
class ZonePiece {
  final int id;
  final int? zoneId;
  final String key;
  final String nameAr;
  final String nameEn;
  final int? sensorPin;

  const ZonePiece({
    required this.id,
    this.zoneId,
    required this.key,
    required this.nameAr,
    required this.nameEn,
    this.sensorPin,
  });

  factory ZonePiece.fromSupabase(Map<String, dynamic> row) {
    return ZonePiece(
      id: (row['id'] is num)
          ? (row['id'] as num).toInt()
          : int.tryParse('${row['id']}') ?? 0,
      zoneId: (row['zone_id'] is num)
          ? (row['zone_id'] as num).toInt()
          : int.tryParse('${row['zone_id']}'),
      key: row['key']?.toString() ?? '',
      nameAr: row['name_ar']?.toString() ?? '',
      nameEn: row['name_en']?.toString() ?? '',
      sensorPin: (row['sensor_pin'] is num)
          ? (row['sensor_pin'] as num).toInt()
          : int.tryParse('${row['sensor_pin']}'),
    );
  }
}
