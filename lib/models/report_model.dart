/// نموذج تقرير الذكاء الاصطناعي
class AIReport {
  final String id;
  final String childId;
  final String period;
  final Map<String, int> skillsProgress;
  final List<String> behaviorPatterns;
  final List<String> recommendations;
  final Map<String, String> optimalTimes;
  final WeeklyComparison?  comparison;
  final DateTime generatedAt;

  AIReport({
    required this.id,
    required this.childId,
    required this.period,
    required this.skillsProgress,
    required this.behaviorPatterns,
    required this. recommendations,
    required this.optimalTimes,
    this. comparison,
    required this.generatedAt,
  });

  factory AIReport.fromJson(Map<String, dynamic> json) {
    return AIReport(
      id: json['id'] ?? '',
      childId: json['childId'] ?? '',
      period: json['period'] ?? 'أسبوعي',
      skillsProgress:  Map<String, int>.from(json['skillsProgress'] ?? {}),
      behaviorPatterns:  List<String>.from(json['behaviorPatterns'] ?? []),
      recommendations: List<String>. from(json['recommendations'] ?? []),
      optimalTimes:  Map<String, String>.from(json['optimalTimes'] ??  {}),
      comparison: json['comparison'] != null
          ? WeeklyComparison.fromJson(json['comparison'])
          : null,
      generatedAt: DateTime.parse(json['generatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'childId': childId,
      'period': period,
      'skillsProgress':  skillsProgress,
      'behaviorPatterns': behaviorPatterns,
      'recommendations': recommendations,
      'optimalTimes': optimalTimes,
      'comparison': comparison?.toJson(),
      'generatedAt': generatedAt.toIso8601String(),
    };
  }
}

/// مقارنة أسبوعية
class WeeklyComparison {
  final int currentWeekMinutes;
  final int previousWeekMinutes;
  final int currentActivities;
  final int previousActivities;
  final int currentStars;
  final int previousStars;

  WeeklyComparison({
    required this.currentWeekMinutes,
    required this. previousWeekMinutes,
    required this.currentActivities,
    required this.previousActivities,
    required this.currentStars,
    required this.previousStars,
  });

  factory WeeklyComparison.fromJson(Map<String, dynamic> json) {
    return WeeklyComparison(
      currentWeekMinutes: json['currentWeekMinutes'] ??  0,
      previousWeekMinutes: json['previousWeekMinutes'] ?? 0,
      currentActivities: json['currentActivities'] ?? 0,
      previousActivities: json['previousActivities'] ?? 0,
      currentStars: json['currentStars'] ?? 0,
      previousStars: json['previousStars'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentWeekMinutes':  currentWeekMinutes,
      'previousWeekMinutes': previousWeekMinutes,
      'currentActivities': currentActivities,
      'previousActivities': previousActivities,
      'currentStars': currentStars,
      'previousStars': previousStars,
    };
  }

  /// نسبة التغيير في الوقت
  double get timeChangePercent {
    if (previousWeekMinutes == 0) return 0;
    return ((currentWeekMinutes - previousWeekMinutes) / previousWeekMinutes) * 100;
  }
}