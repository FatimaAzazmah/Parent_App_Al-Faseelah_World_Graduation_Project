import '../utils/app_strings.dart';

/// عنصر تعليمي واحد من جدول content.
///
/// مادة العنصر نفسها مخزّنة في العمود knowledge_card (jsonb) بمفاتيح
/// ثنائية اللغة تتبع اصطلاح `<اسم>_ar` و `<اسم>_en`. كل القراءات هنا
/// تحترم لغة التطبيق الحالية وترجع للّغة الأخرى إن نقصت الترجمة، حتى لا
/// تظهر بطاقة فارغة للأهل.
///
/// بيانات صرفة؛ قراءة صفوف Supabase مسؤولية ContentLibraryService.
class ContentItem {
  final int id;

  /// نوع العنصر: learn أو play أو story أو values أو challenge.
  final String type;

  /// مستوى الصعوبة 1..3، ويحدّد أي مستوى معلومات يُعرض.
  final int difficulty;

  /// مادة العنصر كما وصلت من العمود jsonb.
  final Map<String, dynamic> knowledgeCard;

  /// المفتاح الذي يربط العنصر بشاشة الإنجازات، إن كان قابلاً للتتبع.
  final String? trackableKey;

  // أسماء تصل عبر join مع جدولي zones و pieces
  final String? zoneNameAr;
  final String? zoneNameEn;
  final String? pieceNameAr;
  final String? pieceNameEn;

  /// تُحسب في طبقة الخدمة حسب الطفل المختار حالياً.
  final bool isSavedForChild;

  const ContentItem({
    required this.id,
    required this.type,
    this.difficulty = 1,
    this.knowledgeCard = const {},
    this.trackableKey,
    this.zoneNameAr,
    this.zoneNameEn,
    this.pieceNameAr,
    this.pieceNameEn,
    this.isSavedForChild = false,
  });

  /// نسخة محدَّثة بحالة حفظ جديدة، تُستعمل لتحديث الواجهة فور ضغط الأهل
  /// قبل وصول تأكيد الخادم. حالة الحفظ هي الحقل الوحيد المتغيّر بعد الجلب.
  ContentItem withSavedState(bool saved) {
    return ContentItem(
      id: id,
      type: type,
      difficulty: difficulty,
      knowledgeCard: knowledgeCard,
      trackableKey: trackableKey,
      zoneNameAr: zoneNameAr,
      zoneNameEn: zoneNameEn,
      pieceNameAr: pieceNameAr,
      pieceNameEn: pieceNameEn,
      isSavedForChild: saved,
    );
  }

  // ── الأسماء المرتبطة (من الـ join) ──

  /// اسم المنطقة التي ينتمي لها العنصر، بلغة التطبيق.
  String? get zoneName => AppStrings.localized(zoneNameAr, zoneNameEn);

  /// اسم القطعة التي يشرحها العنصر، بلغة التطبيق.
  String? get pieceName => AppStrings.localized(pieceNameAr, pieceNameEn);

  // ── قراءة knowledge_card ──

  /// قيمة مفتاح واحد كنصّ منظّف، أو null إن كان غائباً أو فارغاً.
  String? _rawText(String key) {
    final value = knowledgeCard[key];
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  /// يبحث عن نصّ حسب اصطلاح التسمية: لكل اسم أساسي يجرّب نسخة اللغة
  /// الحالية، ثم المفتاح المجرّد، ثم نسخة اللغة المقابلة، قبل الانتقال
  /// للاسم التالي. هكذا يُكتب منطق البحث مرة واحدة بدل تكراره في كل حقل.
  String? _localizedText(List<String> baseKeys) {
    for (final base in baseKeys) {
      final text = _rawText('${base}_${AppStrings.langSuffix}') ??
          _rawText(base) ??
          _rawText('${base}_${AppStrings.otherLangSuffix}');
      if (text != null) return text;
    }
    return null;
  }

  /// نصّ عنصر داخل قائمة: إمّا نصّ مباشر أو خريطة {ar, en}.
  String? _entryText(dynamic entry) {
    if (entry is Map) {
      return AppStrings.localized(
        entry['ar']?.toString(),
        entry['en']?.toString(),
      );
    }
    final text = entry?.toString().trim();
    return (text == null || text.isEmpty) ? null : text;
  }

  /// يجمع قائمة نصوص من knowledge_card بنفس اصطلاح [_localizedText]،
  /// ويضمّ ما يجده تحت كل اسم أساسي في قائمة واحدة.
  List<String> _localizedList(List<String> baseKeys) {
    final collected = <String>[];
    for (final base in baseKeys) {
      final raw = knowledgeCard['${base}_${AppStrings.langSuffix}'] ??
          knowledgeCard[base] ??
          knowledgeCard['${base}_${AppStrings.otherLangSuffix}'];
      if (raw is! List) continue;
      for (final entry in raw) {
        final text = _entryText(entry);
        if (text != null) collected.add(text);
      }
    }
    return collected;
  }

  // ── الحقول المعروضة ──

  /// عنوان العنصر، ويسقط على اسم القطعة إن لم يُسجَّل له عنوان.
  /// النصّ الفارغ متروك للشاشة لتعرض بديلاً مترجَماً.
  String get title =>
      _localizedText(const ['title', 'name', 'العنوان']) ?? pieceName ?? '';

  /// وصف مختصر للعنصر إن وُجد.
  String get summary =>
      _localizedText(const ['summary', 'description', 'الوصف', 'ملخص']) ?? '';

  /// النصّ الكامل للقصة أو الشرح، ويسقط على الوصف المختصر.
  String get storyText =>
      _localizedText(const ['story', 'text', 'body', 'النص', 'القصة']) ??
      summary;

  /// المفردات التي يعلّمها العنصر.
  List<String> get vocabulary =>
      _localizedList(const ['vocab', 'vocabulary', 'مفردات']);

  /// المعلومات المعروضة، مأخوذة من المستوى المطابق لصعوبة العنصر أولاً
  /// حتى يتلقّى الطفل معلومات بمستواه، مع التدرّج للأبسط عند غيابه.
  List<String> get facts =>
      _localizedList(['facts_l$difficulty', 'facts_l1', 'facts', 'حقائق']);

  /// القيم التربوية المرتبطة بالعنصر.
  List<String> get values => _localizedList(const ['values', 'قيم']);
}
