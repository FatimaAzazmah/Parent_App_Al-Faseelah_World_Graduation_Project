class BehaviorGoal {
  final String id;
  final String childId;
  final String parentId;
  final String title;
  final String description;
  final String zone;
  final String targetBehavior;
  final int targetCount;
  final int currentCount;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;

  BehaviorGoal({
    required this.id,
    required this.childId,
    required this.parentId,
    required this.title,
    required this.description,
    this.zone = '',
    required this.targetBehavior,
    this.targetCount = 1,
    this.currentCount = 0,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
  });

  double get progressPercent {
    if (targetCount <= 0) return 0;
    return (currentCount / targetCount).clamp(0.0, 1.0);
  }

  static DateTime _parseDate(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
    return DateTime.now();
  }

  factory BehaviorGoal.fromSupabase(Map<String, dynamic> row) {
    return BehaviorGoal(
      id: row['id']?.toString() ?? '',
      childId: row['child_id']?.toString() ?? '',
      parentId: row['parent_id']?.toString() ?? '',
      title: row['title']?.toString() ?? '',
      description: row['description']?.toString() ?? '',
      zone: row['zone']?.toString() ?? '',
      targetBehavior: row['target_behavior']?.toString() ?? '',
      targetCount: (row['target_count'] is num)
          ? (row['target_count'] as num).round()
          : int.tryParse('${row['target_count']}') ?? 1,
      currentCount: (row['current_count'] is num)
          ? (row['current_count'] as num).round()
          : int.tryParse('${row['current_count']}') ?? 0,
      isCompleted: row['is_completed'] == true,
      createdAt: _parseDate(row['created_at']),
      completedAt:
          row['completed_at'] != null ? _parseDate(row['completed_at']) : null,
    );
  }

  /// Payload for Supabase insert (no id / timestamps — DB defaults).
  Map<String, dynamic> toSupabaseInsert(String parentId) {
    return {
      'child_id': childId,
      'parent_id': parentId,
      'title': title,
      'description': description,
      'zone': zone,
      'target_behavior': targetBehavior,
      'target_count': targetCount,
      'current_count': currentCount,
      'is_completed': isCompleted,
      'created_at': createdAt.toIso8601String(),
      if (completedAt != null)
        'completed_at': completedAt!.toIso8601String(),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'childId': childId,
      'parentId': parentId,
      'title': title,
      'description': description,
      'zone': zone,
      'targetBehavior': targetBehavior,
      'targetCount': targetCount,
      'currentCount': currentCount,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  BehaviorGoal copyWith({
    String? id,
    String? childId,
    String? parentId,
    String? title,
    String? description,
    String? zone,
    String? targetBehavior,
    int? targetCount,
    int? currentCount,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return BehaviorGoal(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      parentId: parentId ?? this.parentId,
      title: title ?? this.title,
      description: description ?? this.description,
      zone: zone ?? this.zone,
      targetBehavior: targetBehavior ?? this.targetBehavior,
      targetCount: targetCount ?? this.targetCount,
      currentCount: currentCount ?? this.currentCount,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
