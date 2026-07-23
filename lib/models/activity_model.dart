/// نموذج النشاط
class Activity {
  final String id;
  final String title;
  final String type;
  final String zone;
  final int duration;
  final String result;
  final int starsEarned;
  final DateTime completedAt;

  Activity({
    required this. id,
    required this.title,
    required this.type,
    required this.zone,
    required this.duration,
    required this.result,
    required this.starsEarned,
    required this.completedAt,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      type: json['type'] ??  '',
      zone: json['zone'] ?? '',
      duration: json['duration'] ?? 0,
      result: json['result'] ?? '',
      starsEarned:  json['starsEarned'] ?? 0,
      completedAt: DateTime.parse(json['completedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'zone': zone,
      'duration': duration,
      'result':  result,
      'starsEarned': starsEarned,
      'completedAt':  completedAt.toIso8601String(),
    };
  }
}

/// أنواع الأنشطة
enum ActivityType {
  story,      // قصة
  game,       // لعبة
  learning,   // نشاط تعليمي
  religious,  // محتوى ديني
  skill,      // مهارة يومية
}