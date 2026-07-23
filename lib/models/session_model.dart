import 'activity_model.dart';

/// نموذج جلسة اللعب
class Session {
  final String id;
  final String childId;
  final DateTime startTime;
  final DateTime?  endTime;
  final int totalMinutes;
  final List<Activity> activities;
  final Map<String, int> zonesVisited;
  final String mood;
  final String focusLevel;
  final int starsEarned;

  Session({
    required this. id,
    required this.childId,
    required this.startTime,
    this.endTime,
    required this.totalMinutes,
    required this.activities,
    required this.zonesVisited,
    required this. mood,
    required this.focusLevel,
    required this. starsEarned,
  });

  factory Session. fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'] ?? '',
      childId:  json['childId'] ?? '',
      startTime: DateTime.parse(json['startTime'] ?? DateTime. now().toIso8601String()),
      endTime: json['endTime'] != null ? DateTime. parse(json['endTime']) : null,
      totalMinutes: json['totalMinutes'] ??  0,
      activities: (json['activities'] as List?)
          ?.map((a) => Activity.fromJson(a))
          .toList() ?? [],
      zonesVisited:  Map<String, int>.from(json['zonesVisited'] ?? {}),
      mood: json['mood'] ?? '',
      focusLevel: json['focusLevel'] ?? '',
      starsEarned: json['starsEarned'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'childId': childId,
      'startTime':  startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'totalMinutes': totalMinutes,
      'activities': activities.map((a) => a.toJson()).toList(),
      'zonesVisited': zonesVisited,
      'mood': mood,
      'focusLevel': focusLevel,
      'starsEarned': starsEarned,
    };
  }

  /// عدد الأنشطة المكتملة
  int get completedActivitiesCount => activities.length;

  /// عدد المناطق التي زارها
  int get visitedZonesCount => zonesVisited. keys.length;
}