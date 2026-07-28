import '../utils/app_strings.dart';

/// يوحّد اختيار الاسم المعروض في كل نموذج يحمل اسماً بلغتين.
/// الصنف المستعمِل يوفّر [nameAr] و [nameEn] فقط، ويرث بقية المنطق.
mixin BilingualName {
  /// الاسم العربي كما هو مخزّن في قاعدة البيانات.
  String get nameAr;

  /// الاسم الإنجليزي كما هو مخزّن في قاعدة البيانات.
  String get nameEn;

  /// الاسم حسب لغة التطبيق الحالية.
  /// إن كان اسم اللغة المختارة فارغاً يُعرض اسم اللغة الأخرى بدل فراغ.
  String get displayName => AppStrings.localized(nameAr, nameEn) ?? '';
}

/// منطقة لعب (بورد) من جدول zones.
/// بيانات صرفة؛ قراءة صفوف Supabase مسؤولية BoardService.
class Zone with BilingualName {
  final int id;

  /// المفتاح النصي الثابت للمنطقة (home / mosque / zoo ...).
  final String key;

  @override
  final String nameAr;

  @override
  final String nameEn;

  /// المناطق المتغيّرة وحدها يمكن للأهل تبديلها من التطبيق.
  final bool isDynamic;

  /// المنطقة الموضوعة حالياً على الجهاز.
  final bool isActive;

  /// قطع هذه المنطقة؛ تبقى فارغة ما لم تُحمَّل معها.
  final List<ZonePiece> pieces;

  const Zone({
    required this.id,
    required this.key,
    required this.nameAr,
    required this.nameEn,
    this.isDynamic = false,
    this.isActive = false,
    this.pieces = const [],
  });

  /// نسخة محدَّثة تُستعمل لتبديل حالة التفعيل محلياً بعد نجاح العملية،
  /// بدل إعادة تحميل القائمة كاملة من الخادم.
  Zone copyWith({bool? isActive, List<ZonePiece>? pieces}) {
    return Zone(
      id: id,
      key: key,
      nameAr: nameAr,
      nameEn: nameEn,
      isDynamic: isDynamic,
      isActive: isActive ?? this.isActive,
      pieces: pieces ?? this.pieces,
    );
  }
}

/// قطعة لعب تتبع منطقة، من جدول pieces.
class ZonePiece with BilingualName {
  final int id;

  /// المنطقة التي تتبع لها القطعة؛ قد تكون غير محدّدة.
  final int? zoneId;

  /// المفتاح النصي الثابت للقطعة.
  final String key;

  @override
  final String nameAr;

  @override
  final String nameEn;

  /// منفذ الحسّاس الذي يلتقط القطعة على اللوح؛ يقرأه جهاز الرازبيري.
  final int? sensorPin;

  const ZonePiece({
    required this.id,
    this.zoneId,
    required this.key,
    required this.nameAr,
    required this.nameEn,
    this.sensorPin,
  });
}
