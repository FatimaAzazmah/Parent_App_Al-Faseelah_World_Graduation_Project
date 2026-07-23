/// يمثّل صفاً من جدول content الحقيقي في Supabase.
/// المحتوى الفعلي مخزّن في knowledge_card (jsonb).
class ContentItem {
  final int id;
  final int? zoneId;
  final int? pieceId;
  final String type; // learn | play | story | values | challenge
  final int difficulty; // 1..3
  final Map<String, dynamic> knowledgeCard;
  final String? trackableKey;
  final bool isActive;

  // أسماء مُحمّلة عبر join (اختياري)
  final String? zoneNameAr;
  final String? pieceNameAr;

  // هل هذا المحتوى محفوظ للطفل المحدد حالياً؟ (يُحسب في الطبقة الأعلى)
  final bool isSavedForChild;

  const ContentItem({
    required this.id,
    this.zoneId,
    this.pieceId,
    required this.type,
    this.difficulty = 1,
    this.knowledgeCard = const {},
    this.trackableKey,
    this.isActive = true,
    this.zoneNameAr,
    this.pieceNameAr,
    this.isSavedForChild = false,
  });

  factory ContentItem.fromSupabase(
    Map<String, dynamic> row, {
    bool isSavedForChild = false,
  }) {
    // knowledge_card قد يأتي كـ Map مباشرة (jsonb) أو كنص JSON
    final rawCard = row['knowledge_card'];
    Map<String, dynamic> card = {};
    if (rawCard is Map) {
      card = Map<String, dynamic>.from(rawCard);
    }

    // zone/piece قد تأتي كـ nested object من join
    String? zoneName;
    String? pieceName;
    final zoneObj = row['zones'];
    if (zoneObj is Map) zoneName = zoneObj['name_ar']?.toString();
    final pieceObj = row['pieces'];
    if (pieceObj is Map) pieceName = pieceObj['name_ar']?.toString();

    return ContentItem(
      id: (row['id'] is num)
          ? (row['id'] as num).toInt()
          : int.tryParse('${row['id']}') ?? 0,
      zoneId: (row['zone_id'] is num)
          ? (row['zone_id'] as num).toInt()
          : int.tryParse('${row['zone_id']}'),
      pieceId: (row['piece_id'] is num)
          ? (row['piece_id'] as num).toInt()
          : int.tryParse('${row['piece_id']}'),
      type: row['type']?.toString() ?? 'learn',
      difficulty: (row['difficulty'] is num)
          ? (row['difficulty'] as num).toInt()
          : int.tryParse('${row['difficulty']}') ?? 1,
      knowledgeCard: card,
      trackableKey: row['trackable_key']?.toString(),
      isActive: row['is_active'] != false,
      zoneNameAr: zoneName,
      pieceNameAr: pieceName,
      isSavedForChild: isSavedForChild,
    );
  }

  ContentItem copyWith({bool? isSavedForChild}) {
    return ContentItem(
      id: id,
      zoneId: zoneId,
      pieceId: pieceId,
      type: type,
      difficulty: difficulty,
      knowledgeCard: knowledgeCard,
      trackableKey: trackableKey,
      isActive: isActive,
      zoneNameAr: zoneNameAr,
      pieceNameAr: pieceNameAr,
      isSavedForChild: isSavedForChild ?? this.isSavedForChild,
    );
  }

  // ── قراءات مساعدة من knowledge_card ──

  /// العنوان: يجرّب عدة مفاتيح شائعة، ثم يسقط على اسم القطعة.
  String get title {
    for (final k in ['title', 'title_ar', 'name', 'العنوان']) {
      final v = knowledgeCard[k];
      if (v != null && v.toString().trim().isNotEmpty) return v.toString();
    }
    return pieceNameAr ?? typeLabelAr;
  }

  /// وصف مختصر إن وُجد.
  String get summary {
    for (final k in ['summary', 'description', 'الوصف', 'ملخص']) {
      final v = knowledgeCard[k];
      if (v != null && v.toString().trim().isNotEmpty) return v.toString();
    }
    return '';
  }

  /// نص القصة الكامل إن وُجد (لنوع story).
  String get storyText {
    for (final k in ['story', 'text', 'body', 'النص', 'القصة']) {
      final v = knowledgeCard[k];
      if (v != null && v.toString().trim().isNotEmpty) return v.toString();
    }
    return summary;
  }

  List<String> _stringList(String key) {
    final v = knowledgeCard[key];
    if (v is List) {
      return v.map((e) => e.toString()).toList();
    }
    return const [];
  }

  List<String> get vocabulary =>
      _stringList('vocabulary') + _stringList('مفردات');
  List<String> get facts => _stringList('facts') + _stringList('حقائق');
  List<String> get values => _stringList('values') + _stringList('قيم');

  String get typeLabelAr {
    switch (type) {
      case 'story':
        return 'قصة';
      case 'play':
        return 'لعبة';
      case 'learn':
        return 'تعليمي';
      case 'values':
        return 'قيم';
      case 'challenge':
        return 'تحدي';
      default:
        return type;
    }
  }

  /// هل هذا النوع "مهمة" قابلة للإنجاز (تظهر خانة "تمت")؟
  /// الألعاب (play) تُلعب ولا "تُنجز".
  bool get isTask => type != 'play';
}
