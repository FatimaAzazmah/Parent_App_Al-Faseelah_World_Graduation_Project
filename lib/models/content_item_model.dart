import '../app_locale.dart';

/// يمثّل صفاً من جدول content الحقيقي في Supabase.
/// المحتوى الفعلي مخزّن في knowledge_card (jsonb).
/// Getters are locale-aware: they prefer the `_en` variants of
/// knowledge_card fields when the app language is English, and fall
/// back to Arabic when the English text is not available yet.
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
  final String? zoneNameEn;
  final String? pieceNameAr;
  final String? pieceNameEn;

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
    this.zoneNameEn,
    this.pieceNameAr,
    this.pieceNameEn,
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
    String? zoneAr;
    String? zoneEn;
    String? pieceAr;
    String? pieceEn;
    final zoneObj = row['zones'];
    if (zoneObj is Map) {
      zoneAr = zoneObj['name_ar']?.toString();
      zoneEn = zoneObj['name_en']?.toString();
    }
    final pieceObj = row['pieces'];
    if (pieceObj is Map) {
      pieceAr = pieceObj['name_ar']?.toString();
      pieceEn = pieceObj['name_en']?.toString();
    }

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
      zoneNameAr: zoneAr,
      zoneNameEn: zoneEn,
      pieceNameAr: pieceAr,
      pieceNameEn: pieceEn,
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
      zoneNameEn: zoneNameEn,
      pieceNameAr: pieceNameAr,
      pieceNameEn: pieceNameEn,
      isSavedForChild: isSavedForChild ?? this.isSavedForChild,
    );
  }

  // ── قراءات مساعدة من knowledge_card (حسب لغة التطبيق) ──

  static bool get _isEn => AppLocale.notifier.value.languageCode == 'en';

  String? _first(List<String> keys) {
    for (final k in keys) {
      final v = knowledgeCard[k];
      if (v != null && v.toString().trim().isNotEmpty) return v.toString();
    }
    return null;
  }

  /// اسم المنطقة حسب لغة التطبيق.
  String? get zoneName =>
      _isEn ? (zoneNameEn ?? zoneNameAr) : (zoneNameAr ?? zoneNameEn);

  /// اسم القطعة حسب لغة التطبيق.
  String? get pieceName =>
      _isEn ? (pieceNameEn ?? pieceNameAr) : (pieceNameAr ?? pieceNameEn);

  /// العنوان: النسخة المطابقة للغة أولاً، ثم العناوين العامة، ثم اسم القطعة.
  String get title {
    final localized = _isEn
        ? _first(['title_en', 'name_en'])
        : _first(['title_ar', 'name_ar', 'العنوان']);
    return localized ??
        _first(['title', 'name']) ??
        _first(['title_ar', 'name_ar', 'title_en', 'name_en']) ??
        pieceName ??
        typeLabel;
  }

  /// وصف مختصر إن وُجد.
  String get summary {
    final localized = _isEn
        ? _first(['summary_en', 'description_en'])
        : _first(['summary_ar', 'الوصف', 'ملخص']);
    return localized ?? _first(['summary', 'description']) ?? '';
  }

  /// النص الكامل (قصة/شرح) حسب اللغة، مع الرجوع للغة الأخرى إن لم يتوفر.
  String get storyText {
    final localized = _isEn
        ? _first(['story_en', 'text_en', 'body_en'])
        : _first(['story_ar', 'text_ar', 'النص', 'القصة']);
    return localized ??
        _first(['story', 'text', 'body']) ??
        (_isEn
                ? _first(['story_ar', 'text_ar'])
                : _first(['story_en', 'text_en'])) ??
        summary;
  }

  /// قائمة ثنائية اللغة: عناصرها إمّا نصوص أو خرائط {ar, en}.
  List<String> _biList(String key) {
    final v = knowledgeCard[key];
    if (v is! List) return const [];
    final out = <String>[];
    for (final e in v) {
      if (e is Map) {
        final s = _isEn ? (e['en'] ?? e['ar']) : (e['ar'] ?? e['en']);
        if (s != null && s.toString().trim().isNotEmpty) {
          out.add(s.toString());
        }
      } else if (e != null && e.toString().trim().isNotEmpty) {
        out.add(e.toString());
      }
    }
    return out;
  }

  List<String> get vocabulary => [
        ..._biList('vocab'),
        ..._biList('vocabulary'),
        ..._biList('مفردات'),
      ];

  List<String> get facts => [
        ..._biList('facts'),
        ..._biList('facts_l1'),
        ..._biList('حقائق'),
      ];

  List<String> get values => [
        ..._biList('values'),
        ..._biList('قيم'),
      ];

  /// تسمية النوع حسب لغة التطبيق.
  String get typeLabel {
    switch (type) {
      case 'story':
        return _isEn ? 'Story' : 'قصة';
      case 'play':
        return _isEn ? 'Game' : 'لعبة';
      case 'learn':
        return _isEn ? 'Educational' : 'تعليمي';
      case 'values':
        return _isEn ? 'Values' : 'قيم';
      case 'challenge':
        return _isEn ? 'Challenge' : 'تحدي';
      default:
        return type;
    }
  }

  /// (متروكة للتوافق مع كود أقدم)
  String get typeLabelAr => typeLabel;

  /// هل هذا النوع "مهمة" قابلة للإنجاز (تظهر خانة "تمت")؟
  /// الألعاب (play) تُلعب ولا "تُنجز".
  bool get isTask => type != 'play';
}
