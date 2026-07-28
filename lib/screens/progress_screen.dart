import 'package:flutter/material.dart';
import '../services/child_service.dart';
import '../models/child_model.dart';
import '../models/session_model.dart' as models;
import '../utils/app_strings.dart';
import '../utils/app_colors.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final ChildService _childService = ChildService();
  List<Child> _children = [];
  List<models.Session> _sessions = [];
  bool _isLoading = true;
  String _selectedPeriod = _periodKeys[1];
  int _selectedChildIndex = 0;

  static const List<String> _periodKeys = ['يومي', 'أسبوعي', 'شهري', 'فصلي'];

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    final children = await _childService.getChildren();
    if (mounted) {
      setState(() {
        _children = children;
      });
      if (_children.isNotEmpty) {
        await _loadSessions();
      } else {
        setState(() => _isLoading = false);
      }
    }
  }

  DateTime _periodStartDate() {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'يومي':
        return DateTime(now.year, now.month, now.day);
      case 'شهري':
        return now.subtract(const Duration(days: 30));
      case 'فصلي':
        return now.subtract(const Duration(days: 90));
      case 'أسبوعي':
      default:
        return now.subtract(const Duration(days: 7));
    }
  }

  int _periodDayDivisor() {
    switch (_selectedPeriod) {
      case 'يومي':
        return 1;
      case 'شهري':
        return 30;
      case 'فصلي':
        return 90;
      case 'أسبوعي':
      default:
        return 7;
    }
  }

  Future<void> _loadSessions() async {
    final child = _selectedChild;
    if (child == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    setState(() => _isLoading = true);
    final sessions = await _childService.getSessionsForChild(
      child.id,
      from: _periodStartDate(),
    );
    if (!mounted) return;
    setState(() {
      _sessions = sessions;
      _isLoading = false;
    });
  }

  Map<String, dynamic> _getProgressDataForChild(Child? child, List<models.Session> sessions) {
    if (child == null || sessions.isEmpty) {
      return _getEmptyProgressData();
    }

    final totalMinutes =
        sessions.fold<int>(0, (sum, s) => sum + s.totalMinutes);
    final completedActivities =
        sessions.fold<int>(0, (sum, s) => sum + s.activities.length);
    final stars =
        sessions.fold<int>(0, (sum, s) => sum + s.starsEarned);
    final averageDaily = (totalMinutes / _periodDayDivisor()).round();

    final now = DateTime.now();
    final dayBuckets = List<Map<String, dynamic>>.generate(
      7,
      (i) => {'dayIndex': i, 'minutes': 0, 'activities': 0},
    );
    for (final s in sessions) {
      final diff = now.difference(s.startTime).inDays;
      if (diff < 0 || diff > 6) continue;
      final weekdayIndex = (s.startTime.weekday + 1) % 7; // Sat-first for AppStrings map
      dayBuckets[weekdayIndex]['minutes'] =
          (dayBuckets[weekdayIndex]['minutes'] as int) + s.totalMinutes;
      dayBuckets[weekdayIndex]['activities'] =
          (dayBuckets[weekdayIndex]['activities'] as int) + s.activities.length;
    }

    final skillCounts = <String, int>{
      'reading': 0,
      'math': 0,
      'communication': 0,
      'focus': 0,
      'creativity': 0,
    };
    for (final s in sessions) {
      for (final a in s.activities) {
        final t = a.type.toLowerCase();
        final z = a.zone.toLowerCase();
        if (t.contains('قص') || t.contains('story') || t.contains('reading')) {
          skillCounts['reading'] = skillCounts['reading']! + 1;
        } else if (t.contains('حساب') || t.contains('math') || z.contains('رقم')) {
          skillCounts['math'] = skillCounts['math']! + 1;
        } else if (t.contains('social') || t.contains('تفاعل')) {
          skillCounts['communication'] = skillCounts['communication']! + 1;
        } else if (t.contains('focus') || t.contains('تركيز')) {
          skillCounts['focus'] = skillCounts['focus']! + 1;
        } else if (t.contains('إبداع') || t.contains('creative') || z.contains('الإبداع')) {
          skillCounts['creativity'] = skillCounts['creativity']! + 1;
        } else {
          skillCounts['focus'] = skillCounts['focus']! + 1;
        }
      }
    }
    final maxSkill = skillCounts.values.fold<int>(1, (m, v) => v > m ? v : m);
    final skills = skillCounts.entries.map((e) {
      final p = ((e.value / maxSkill) * 100).round();
      return {
        'skillKey': e.key,
        'progress': p,
        'trend': 'stable',
        'change': '0%',
        'icon': e.key == 'reading'
            ? Icons.menu_book
            : e.key == 'math'
                ? Icons.calculate
                : e.key == 'communication'
                    ? Icons.chat
                    : e.key == 'focus'
                        ? Icons.psychology
                        : Icons.brush,
      };
    }).toList();

    final recentSessions = sessions.take(5).map((s) {
      final hh = s.startTime.hour.toString().padLeft(2, '0');
      final mm = s.startTime.minute.toString().padLeft(2, '0');
      final durationLabel = AppStrings.tr(
        context,
        '${s.totalMinutes} دقيقة',
        '${s.totalMinutes} min',
      );
      return {
        'id': s.id,
        'date': '${s.startTime.year}-${s.startTime.month.toString().padLeft(2, '0')}-${s.startTime.day.toString().padLeft(2, '0')} $hh:$mm',
        'duration': durationLabel,
        'activities': s.activities.map((a) => a.title).take(4).toList(),
        'mood': s.mood.isNotEmpty ? s.mood : '-',
        'focus': s.focusLevel.isNotEmpty ? s.focusLevel : '-',
      };
    }).toList();

    final achievements = <Map<String, dynamic>>[];
    for (final s in sessions) {
      if (s.starsEarned >= 5) {
        achievements.add({
          'icon': Icons.star,
          'color': const Color(0xFFFFB74D),
          'title': AppStrings.tr(context, 'جلسة مميزة', 'Great session'),
          'description': AppStrings.tr(
            context,
            'حصد ${s.starsEarned} نجوم في جلسة واحدة',
            'Earned ${s.starsEarned} stars in one session',
          ),
          'date':
              '${s.startTime.year}-${s.startTime.month.toString().padLeft(2, '0')}-${s.startTime.day.toString().padLeft(2, '0')}',
        });
      }
      if (s.activities.length >= 5) {
        achievements.add({
          'icon': Icons.check_circle,
          'color': const Color(0xFF90EE90),
          'title': AppStrings.tr(context, 'نشاطات كثيرة', 'High activity'),
          'description': AppStrings.tr(
            context,
            'أكمل ${s.activities.length} نشاطات',
            'Completed ${s.activities.length} activities',
          ),
          'date':
              '${s.startTime.year}-${s.startTime.month.toString().padLeft(2, '0')}-${s.startTime.day.toString().padLeft(2, '0')}',
        });
      }
    }

    return {
      'totalMinutes': totalMinutes,
      'averageDaily': averageDaily,
      'completedActivities': completedActivities,
      'earnedStars': stars,
      'dailyProgress': dayBuckets,
      'skills': skills,
      'achievements': achievements.take(10).toList(),
      'recentSessions': recentSessions,
    };
  }

  Map<String, dynamic> _getEmptyProgressData() {
    return {
      'totalMinutes': 0,
      'averageDaily': 0,
      'completedActivities': 0,
      'earnedStars': 0,
      'dailyProgress': <Map<String, dynamic>>[],
      'skills': <Map<String, dynamic>>[],
      'achievements': <Map<String, dynamic>>[],
      'recentSessions': <Map<String, dynamic>>[],
    };
  }

  Child? get _selectedChild {
    if (_children.isEmpty || _selectedChildIndex >= _children.length) return null;
    return _children[_selectedChildIndex];
  }

  Map<String, dynamic> get _progressData => _getProgressDataForChild(_selectedChild, _sessions);

  String _progressSkillLabel(BuildContext context, String skillKey) {
    switch (skillKey) {
      case 'reading':
        return AppStrings.progressSkillReading(context);
      case 'math':
        return AppStrings.progressSkillMath(context);
      case 'communication':
        return AppStrings.progressSkillCommunication(context);
      case 'focus':
        return AppStrings.progressSkillFocus(context);
      case 'creativity':
        return AppStrings.progressSkillCreativity(context);
      default:
        return skillKey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(AppStrings.progressReportsTitle(context))),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_children.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(AppStrings.progressReportsTitle(context))),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.child_care, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              Text(AppStrings.aiReportsNoChildren(context),
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text(AppStrings.aiReportsAddChildHint(context),
                  style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  await Navigator.pushNamed(context, '/add-child');
                  _loadChildren();
                },
                icon: const Icon(Icons.add),
                label: Text(AppStrings.addChild(context)),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.progressReportsTitle(context)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _showShareOptions(),
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => _downloadReport(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFilters(),
              const SizedBox(height: 20),
              _buildStatsSummary(),
              const SizedBox(height: 24),
              _buildUsageChart(),
              const SizedBox(height: 24),
              _buildSkillsProgress(),
              const SizedBox(height: 24),
              _buildAchievements(),
              const SizedBox(height: 24),
              _buildRecentSessions(),
              const SizedBox(height: 24),
              _buildAIRecommendations(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.child_care, color: Color(0xFF87CEEB)),
                const SizedBox(width: 12),
                Text(AppStrings.behaviorChildLabel(context),
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: ThemeColors.softFill(context),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _selectedChildIndex,
                        isExpanded: true,
                        items: _children.asMap().entries.map((entry) {
                          return DropdownMenuItem(
                            value: entry.key,
                            child: Row(
                              children: [
                                Text(entry.value.avatar, style: const TextStyle(fontSize: 20)),
                                const SizedBox(width: 8),
                                Text(entry.value.displayName),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedChildIndex = value!;
                          });
                          _loadSessions();
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _periodKeys.map((periodKey) {
                  final isSelected = _selectedPeriod == periodKey;
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: ChoiceChip(
                      label: Text(AppStrings.progressPeriodLabel(context, periodKey)),
                      selected: isSelected,
                      selectedColor: Theme.of(context).colorScheme.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : ThemeColors.subtle(context),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (selected) {
                        setState(() {
                          _selectedPeriod = periodKey;
                        });
                        _loadSessions();
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSummary() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.timer,
            value: '${_progressData['totalMinutes']}',
            label: AppStrings.progressStatTotalMinutes(context),
            color: const Color(0xFF87CEEB),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.check_circle,
            value: '${_progressData['completedActivities']}',
            label: AppStrings.progressStatCompletedActivities(context),
            color: const Color(0xFF90EE90),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.star,
            value: '${_progressData['earnedStars']}',
            label: AppStrings.progressStatStars(context),
            color: const Color(0xFFFFB74D),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: ThemeColors.subtle(context)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageChart() {
    final dailyProgress = _progressData['dailyProgress'] as List;
    
    if (dailyProgress.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.bar_chart, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 12),
                Text(AppStrings.progressNoUsageYet(context),
                    style: TextStyle(color: ThemeColors.subtle(context))),
              ],
            ),
          ),
        ),
      );
    }
    
    final minutes = dailyProgress.map((d) => d['minutes'] as int).toList();
    final maxMinutes = minutes.reduce((a, b) => a > b ? a : b);
    final safeMax = maxMinutes > 0 ? maxMinutes : 1;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.progressWeeklyUsageTitle(context),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF90EE90).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.trending_up, size: 16, color: Color(0xFF90EE90)),
                      const SizedBox(width: 4),
                      Text(
                        AppStrings.progressAvgMinPerDay(
                            context, _progressData['averageDaily'] as int),
                        style: const TextStyle(
                          color: Color(0xFF2E7D32),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 180,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: dailyProgress.map((day) {
                  final percentage = (day['minutes'] as int) / safeMax;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${day['minutes']}',
                        style: TextStyle(
                          fontSize: 11,
                          color: ThemeColors.subtle(context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 32,
                        height: 120 * percentage,
                        decoration:  BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF87CEEB),
                              const Color(0xFF90EE90),
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.progressChartDayShort(
                          context,
                          day['dayIndex'] as int,
                        ),
                        style: TextStyle(fontSize: 11, color: ThemeColors.subtle(context)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsProgress() {
    final skills = _progressData['skills'] as List;
    final skillColors = [
      const Color(0xFF87CEEB),
      const Color(0xFF90EE90),
      const Color(0xFFFFB74D),
      const Color(0xFFBA68C8),
      const Color(0xFF4DD0E1),
    ];

    if (skills.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.school, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 12),
                Text(AppStrings.progressNoSkillsYet(context),
                    style: TextStyle(color: ThemeColors.subtle(context))),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.progressSkillsTitle(context),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...skills.asMap().entries.map((entry) {
              final index = entry.key;
              final skill = entry.value;
              final color = skillColors[index % skillColors.length];

              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(skill['icon'] as IconData, size: 18, color: color),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _progressSkillLabel(
                                context, skill['skillKey'] as String),
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: skill['trend'] == 'up'
                                ? const Color(0xFF90EE90).withValues(alpha: 0.15)
                                : ThemeColors.fill(context),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                skill['trend'] == 'up'
                                    ? Icons.trending_up
                                    : Icons.trending_flat,
                                size: 14,
                                color: skill['trend'] == 'up'
                                    ? const Color(0xFF2E7D32)
                                    : ThemeColors.subtle(context),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                AppStrings.progressChangePercent(
                                    context, skill['change'] as String),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: skill['trend'] == 'up'
                                      ? const Color(0xFF2E7D32)
                                      : ThemeColors.subtle(context),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${skill['progress']}%',
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: skill['progress'] / 100,
                        backgroundColor: ThemeColors.fill(context),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievements() {
    final achievements = _progressData['achievements'] as List;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.progressAchievementsTitle(context),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (achievements.isNotEmpty)
              TextButton(
                onPressed: () => _showAllAchievements(),
                child: Text(AppStrings.progressViewAll(context)),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (achievements.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.emoji_events, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text(AppStrings.progressNoAchievementsYet(context),
                        style: TextStyle(color: ThemeColors.subtle(context))),
                  ],
                ),
              ),
            ),
          )
        else
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: achievements.length,
              itemBuilder: (context, index) {
              final achievement = achievements[index];
              return Container(
                width: 130,
                margin: const EdgeInsets.only(left: 12),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: (achievement['color'] as Color).withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            achievement['icon'] as IconData,
                            color: achievement['color'] as Color,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          achievement['title'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          achievement['date'],
                          style: TextStyle(
                            fontSize: 10,
                            color: ThemeColors.faint(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentSessions() {
    final sessions = _progressData['recentSessions'] as List;

    if (sessions.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.history, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 12),
                Text(AppStrings.progressNoSessionsYet(context),
                    style: TextStyle(color: ThemeColors.subtle(context))),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.progressRecentSessionsTitle(context),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...sessions.map((session) {
              return InkWell(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/activity-detail',
                    arguments: {
                      'sessionId': session['id'],
                      'childId': _selectedChild?.id,
                    },
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ThemeColors.softFill(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ThemeColors.fill(context)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16, color: Color(0xFF87CEEB)),
                              const SizedBox(width: 6),
                              Text(
                                session['date'],
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.timer, size: 16, color: Color(0xFF90EE90)),
                              const SizedBox(width: 4),
                              Text(
                                session['duration'],
                                style: TextStyle(color: ThemeColors.subtle(context), fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: (session['activities'] as List).map((activity) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF87CEEB).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              activity,
                              style: const TextStyle(fontSize: 12, color: Color(0xFF1976D2)),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _buildSessionTag(
                            '${AppStrings.progressMoodPrefix(context)}: ${session['mood']}',
                            Icons.emoji_emotions,
                            const Color(0xFFFFB74D),
                          ),
                          const SizedBox(width: 12),
                          _buildSessionTag(
                            '${AppStrings.progressFocusPrefix(context)}: ${session['focus']}',
                            Icons.psychology,
                            const Color(0xFFBA68C8),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionTag(String text, IconData icon, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(fontSize: 11, color: ThemeColors.subtle(context)),
        ),
      ],
    );
  }

  Widget _buildAIRecommendations() {
    final childName =
        _selectedChild?.displayName ?? AppStrings.yourChildPlaceholder(context);

    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              const Color(0xFF90EE90).withValues(alpha: 0.1),
              const Color(0xFF87CEEB).withValues(alpha: 0.1),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFBA68C8).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.auto_awesome, color: Color(0xFFBA68C8)),
                ),
                const SizedBox(width: 12),
                Text(
                  AppStrings.progressAISuggestionsTitle(context),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildRecommendationItem(
              icon: Icons.trending_up,
              title: AppStrings.progressRecReadingTitle(context),
              description: AppStrings.progressRecReadingBody(context, childName),
              color: const Color(0xFF90EE90),
            ),
            const Divider(height: 24),
            _buildRecommendationItem(
              icon: Icons.lightbulb,
              title: AppStrings.progressRecActivityTitle(context),
              description:
                  AppStrings.progressRecActivityBody(context, childName),
              color: const Color(0xFFFFB74D),
            ),
            const Divider(height: 24),
            _buildRecommendationItem(
              icon: Icons.schedule,
              title: AppStrings.progressRecBestTimeTitle(context),
              description: AppStrings.progressRecBestTimeBody(context, childName),
              color: const Color(0xFF87CEEB),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(fontSize: 13, color: ThemeColors.subtle(context), height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showShareOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ThemeColors.border(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                AppStrings.progressShareReportTitle(context),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF25D366).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.chat, color: Color(0xFF25D366)),
                ),
                title: Text(AppStrings.progressShareWhatsApp(context)),
                onTap: () {
                  Navigator.pop(context);
                  _showShareSuccess();
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1DA1F2).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.email, color: Color(0xFF1DA1F2)),
                ),
                title: Text(AppStrings.progressShareEmail(context)),
                onTap: () {
                  Navigator.pop(context);
                  _showShareSuccess();
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.copy, color: Colors.grey),
                ),
                title: Text(AppStrings.progressShareCopyLink(context)),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppStrings.progressLinkCopied(context))),
                  );
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _showShareSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppStrings.progressShareSuccess(context))),
    );
  }

  void _downloadReport() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.picture_as_pdf, color: Colors.red),
            const SizedBox(width: 8),
            Text(AppStrings.progressDownloadTitle(ctx)),
          ],
        ),
        content: Text(AppStrings.progressDownloadBody(ctx)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.cancel(ctx)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppStrings.progressDownloading(context))),
              );
            },
            child: Text(AppStrings.progressDownloadAction(ctx)),
          ),
        ],
      ),
    );
  }

  void _showAllAchievements() {
    final achievements = _progressData['achievements'] as List;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: ThemeColors.border(context),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppStrings.progressAllAchievementsTitle(context),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: achievements.length,
                      itemBuilder: (context, index) {
                        final achievement = achievements[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: (achievement['color'] as Color).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                achievement['icon'] as IconData,
                                color: achievement['color'] as Color,
                              ),
                            ),
                            title: Text(
                              achievement['title'],
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(achievement['description']),
                            trailing: Text(
                              achievement['date'],
                              style: TextStyle(fontSize: 12, color: ThemeColors.faint(context)),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}