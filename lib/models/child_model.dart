import '../app_locale.dart';

/// نموذج بيانات الطفل
class Child {
  final String id;
  final String name;

  /// الاسم بالإنجليزية (اختياري) — يُعرض عندما تكون لغة التطبيق إنجليزية.
  final String? nameEn;
  final int age;
  final String gender;
  final String avatar;
  final List<String> interests;
  final DateTime createdAt;
  final String? parentId;
  /// Parent-written focus areas / suggestions; persisted in Supabase `parent_notes`.
  final String? parentNotes;
  /// معرّف قطعة الـ RFID الخاصة بالطفل؛ تُستخدم من الراسبيري باي للتعرف على الطفل.
  /// يُخزَّن بعمود `rfid_id` بجدول `children` على Supabase.
  final String? rfidId;

  Child({
    required this.id,
    required this.name,
    this.nameEn,
    required this.age,
    required this.gender,
    required this.avatar,
    required this.interests,
    required this.createdAt,
    this.parentId,
    this.parentNotes,
    this.rfidId,
  });

  /// الاسم المعروض حسب لغة التطبيق:
  /// إنجليزي إن توفّر عند اختيار الإنجليزية، وإلا الاسم الأساسي.
  String get displayName {
    final isEn = AppLocale.notifier.value.languageCode == 'en';
    if (isEn && nameEn != null && nameEn!.trim().isNotEmpty) {
      return nameEn!.trim();
    }
    return name;
  }

  static DateTime _parseCreatedAt(dynamic raw) {
    if (raw is String) {
      return DateTime.tryParse(raw) ?? DateTime.now();
    }
    return DateTime.now();
  }

  /// إنشاء من JSON
  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      nameEn: json['nameEn'] as String?,
      age: json['age'] ?? 5,
      gender: json['gender'] ?? 'ذكر',
      avatar: json['avatar'] ?? '👦',
      interests: List<String>.from(json['interests'] ?? []),
      createdAt: _parseCreatedAt(json['createdAt']),
      parentId: json['parentId'] as String?,
      parentNotes: json['parentNotes'] as String?,
      rfidId: json['rfidId'] as String?,
    );
  }

  /// تحويل إلى JSON (عميل / تخزين مؤقت)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'nameEn': nameEn,
      'age': age,
      'gender': gender,
      'avatar': avatar,
      'interests': interests,
      'createdAt': createdAt.toIso8601String(),
      'parentId': parentId,
      'parentNotes': parentNotes,
      'rfidId': rfidId,
    };
  }

  /// نسخة معدلة
  Child copyWith({
    String? id,
    String? name,
    String? nameEn,
    bool clearNameEn = false,
    int? age,
    String? gender,
    String? avatar,
    List<String>? interests,
    DateTime? createdAt,
    String? parentId,
    String? parentNotes,
    bool clearParentNotes = false,
    String? rfidId,
    bool clearRfidId = false,
  }) {
    return Child(
      id: id ?? this.id,
      name: name ?? this.name,
      nameEn: clearNameEn ? null : (nameEn ?? this.nameEn),
      age: age ?? this.age,
      gender: gender ?? this.gender,
      avatar: avatar ?? this.avatar,
      interests: interests ?? this.interests,
      createdAt: createdAt ?? this.createdAt,
      parentId: parentId ?? this.parentId,
      parentNotes:
          clearParentNotes ? null : (parentNotes ?? this.parentNotes),
      rfidId: clearRfidId ? null : (rfidId ?? this.rfidId),
    );
  }
}
