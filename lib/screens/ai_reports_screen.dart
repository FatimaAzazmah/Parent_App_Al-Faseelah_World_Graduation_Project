import 'package:flutter/material.dart';

import '../models/child_model.dart';
import '../services/child_service.dart';
import '../utils/app_strings.dart';
import '../utils/app_colors.dart';

class AIReportsScreen extends StatefulWidget {
  const AIReportsScreen({super.key});

  @override
  State<AIReportsScreen> createState() => _AIReportsScreenState();
}

class _AIReportsScreenState extends State<AIReportsScreen> {
  final ChildService _childService = ChildService();
  List<Child> _children = [];
  int _selectedChildIndex = 0;
  bool _isLoading = true;
  ChildStats? _stats;

  static const Color skyBlue = Color(0xFF87CEEB);
  static const Color lightGreen = Color(0xFF90EE90);
  static const Color orange = Color(0xFFFFB74D);
  static const Color purple = Color(0xFFBA68C8);
  static const Color cyan = Color(0xFF4DD0E1);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final children = await _childService.getChildren();
    if (mounted) {
      setState(() {
        _children = children;
      });
      if (children.isNotEmpty) {
        await _loadStats(children[0].id);
      } else {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadStats(String childId) async {
    setState(() => _isLoading = true);
    final stats = await _childService.getChildStats(childId);
    if (mounted) {
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    }
  }

  Child? get _selectedChild {
    if (_children.isEmpty || _selectedChildIndex >= _children.length) return null;
    return _children[_selectedChildIndex];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.aiReportsAppBarTitle(context)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareReport(),
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => _exportReport(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _children.isEmpty
              ? _buildNoChildrenState()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildChildSelector(),
                      const SizedBox(height: 24),
                      _buildWeeklySummary(),
                      const SizedBox(height: 24),
                      _buildSkillsAnalysis(),
                      const SizedBox(height: 24),
                      _buildBehaviorPatterns(),
                      const SizedBox(height: 24),
                      _buildEducationalRecommendations(),
                      const SizedBox(height: 24),
                      _buildOptimalLearningTimes(),
                      const SizedBox(height: 24),
                      _buildProgressComparison(),
                      const SizedBox(height: 24),
                      _buildExportSection(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }

  Widget _buildNoChildrenState() {
    return Center(
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
              _loadData();
            },
            icon: const Icon(Icons.add),
            label: Text(AppStrings.aiReportsAddChildButton(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildChildSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: skyBlue.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _selectedChild?.avatar ?? '👦',
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _selectedChildIndex,
                  isExpanded: true,
                  items: _children.asMap().entries.map((entry) {
                    return DropdownMenuItem(
                      value: entry.key,
                      child: Text(
                        entry.value.displayName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedChildIndex = value!;
                    });
                    _loadStats(_children[value!].id);
                  },
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: lightGreen.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, size: 16, color: lightGreen),
                  const SizedBox(width: 4),
                  Text(
                    _stats != null && _stats!.totalActivities > 0
                        ? AppStrings.aiReportsBadgeNew(context)
                        : AppStrings.aiReportsBadgeNoData(context),
                    style: TextStyle(
                      color: _stats != null && _stats!.totalActivities > 0
                          ? const Color(0xFF2E7D32)
                          : ThemeColors.subtle(context),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklySummary() {
    final totalHours = _stats != null ? (_stats!.totalMinutes / 60).toStringAsFixed(1) : '0.0';
    final totalStars = _stats?.totalStars ?? 0;
    final totalActivities = _stats?.totalActivities ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [skyBlue, lightGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: skyBlue.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.summarize, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                AppStrings.aiReportsWeeklySummaryTitle(context),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            totalActivities > 0
                ? AppStrings.aiReportsSummaryWithData(
                    context,
                    _selectedChild?.displayName ??
                        AppStrings.aiReportsChildFallback(context),
                    totalActivities,
                    totalHours,
                  )
                : AppStrings.aiReportsSummaryNoData(context),
            style: const TextStyle(
                color: Colors.white, fontSize: 15, height: 1.5),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                '⏱️',
                '$totalHours ${AppStrings.aiReportsHoursUnit(context)}',
                AppStrings.aiReportsTotalPlayHours(context),
              ),
              _buildSummaryItem(
                '📈',
                '$totalActivities',
                AppStrings.aiReportsCompletedActivities(context),
              ),
              _buildSummaryItem(
                '🌟',
                '$totalStars',
                AppStrings.aiReportsStarsEarned(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildSkillsAnalysis() {
    final skills = [
      {
        'name': AppStrings.aiReportsSkillReading(context),
        'progress': _stats?.totalActivities ?? 0,
        'color': skyBlue,
        'icon': Icons.menu_book
      },
      {
        'name': AppStrings.aiReportsSkillSocial(context),
        'progress': 0,
        'color': lightGreen,
        'icon': Icons.people
      },
      {
        'name': AppStrings.aiReportsSkillLogic(context),
        'progress': 0,
        'color': orange,
        'icon': Icons.psychology
      },
      {
        'name': AppStrings.aiReportsSkillCreativity(context),
        'progress': 0,
        'color': purple,
        'icon': Icons.brush
      },
      {
        'name': AppStrings.aiReportsSkillMotor(context),
        'progress': 0,
        'color': cyan,
        'icon': Icons.sports_handball
      },
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: purple.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.analytics, color: purple),
                ),
                const SizedBox(width: 12),
                Text(
                  AppStrings.aiReportsSkillsTitle(context),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...skills.map((skill) {
              final maxVal = (_stats?.totalActivities ?? 0) > 0 ? _stats!.totalActivities : 1;
              final progress = ((skill['progress'] as int) / maxVal * 100).clamp(0, 100).toInt();
              return _buildSkillProgressBar(
                skill['name'] as String,
                progress,
                skill['color'] as Color,
                skill['icon'] as IconData,
              );
            }),
            if ((_stats?.totalActivities ?? 0) == 0)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    AppStrings.aiReportsSkillsPlaceholder(context),
                    style: TextStyle(color: ThemeColors.faint(context), fontSize: 13),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillProgressBar(String name, int progress, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
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
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '$progress%',
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress / 100,
              backgroundColor: ThemeColors.fill(context),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBehaviorPatterns() {
    final hasData = (_stats?.totalActivities ?? 0) > 0;

    final patterns = hasData
        ? [
            {
              'emoji': '🎯',
              'title': AppStrings.aiReportsPatternFocusTitle(context),
              'description': AppStrings.aiReportsPatternFocusDesc(context),
              'color': lightGreen
            },
            {
              'emoji': '🎨',
              'title': AppStrings.aiReportsPatternCreativeTitle(context),
              'description': AppStrings.aiReportsPatternCreativeDesc(context),
              'color': purple
            },
            {
              'emoji': '🤝',
              'title': AppStrings.aiReportsPatternSocialTitle(context),
              'description': AppStrings.aiReportsPatternSocialDesc(context),
              'color': skyBlue
            },
          ]
        : <Map<String, dynamic>>[];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cyan.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.psychology, color: cyan),
                ),
                const SizedBox(width: 12),
                Text(
                  AppStrings.aiReportsBehaviorTitle(context),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (patterns.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.psychology_outlined, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Text(
                        AppStrings.aiReportsBehaviorPlaceholder(context),
                        style: TextStyle(color: ThemeColors.faint(context)),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...patterns.map((pattern) => _buildPatternItem(
                    pattern['emoji'] as String,
                    pattern['title'] as String,
                    pattern['description'] as String,
                    pattern['color'] as Color,
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildPatternItem(String emoji, String title, String description, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: ThemeColors.subtle(context)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEducationalRecommendations() {
    final recommendations = [
      {
        'icon': Icons.menu_book,
        'title': AppStrings.aiReportsRecReadingTitle(context),
        'description': AppStrings.aiReportsRecReadingBody(context),
      },
      {
        'icon': Icons.group,
        'title': AppStrings.aiReportsRecGroupTitle(context),
        'description': AppStrings.aiReportsRecGroupBody(context),
      },
      {
        'icon': Icons.schedule,
        'title': AppStrings.aiReportsRecRoutineTitle(context),
        'description': AppStrings.aiReportsRecRoutineBody(context),
      },
    ];

    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [orange.withValues(alpha: 0.1), purple.withValues(alpha: 0.1)],
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
                    color: orange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.lightbulb, color: orange),
                ),
                const SizedBox(width: 12),
                Text(
                  AppStrings.aiReportsRecommendationsTitle(context),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...recommendations.map((rec) => _buildRecommendationItem(
                  rec['icon'] as IconData,
                  rec['title'] as String,
                  rec['description'] as String,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(IconData icon, String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ThemeColors.surface(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: skyBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 13, color: ThemeColors.subtle(context), height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptimalLearningTimes() {
    final times = [
      {
        'emoji': '🌅',
        'period': AppStrings.aiReportsPeriodMorning(context),
        'hours': '9-11',
        'level': AppStrings.aiReportsLevelMedium(context),
        'color': orange
      },
      {
        'emoji': '☀️',
        'period': AppStrings.aiReportsPeriodNoon(context),
        'hours': '1-3',
        'level': AppStrings.aiReportsLevelLow(context),
        'color': Colors.grey
      },
      {
        'emoji': '🌆',
        'period': AppStrings.aiReportsPeriodAfternoon(context),
        'hours': '4-6',
        'level': AppStrings.aiReportsLevelExcellent(context),
        'color': lightGreen
      },
      {
        'emoji': '🌙',
        'period': AppStrings.aiReportsPeriodEvening(context),
        'hours': '7-9',
        'level': AppStrings.aiReportsLevelGood(context),
        'color': skyBlue
      },
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: skyBlue.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.access_time, color: skyBlue),
                ),
                const SizedBox(width: 12),
                Text(
                  AppStrings.aiReportsBestTimesTitle(context),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: times
                  .map((time) => Expanded(
                        child: _buildTimeBlock(
                          time['emoji'] as String,
                          time['period'] as String,
                          time['hours'] as String,
                          time['level'] as String,
                          time['color'] as Color,
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: lightGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, color: lightGreen),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppStrings.aiReportsBestTimeBanner(context),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeBlock(String emoji, String period, String hours, String level, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(period, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          Text(hours, style: TextStyle(fontSize: 9, color: ThemeColors.subtle(context))),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              level,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressComparison() {
    final totalMinutes = _stats?.totalMinutes ?? 0;
    final totalActivities = _stats?.totalActivities ?? 0;
    final totalStars = _stats?.totalStars ?? 0;
    final avgDaily = _stats?.averageDailyMinutes ?? 0;

    final comparisons = [
      {
        'label': AppStrings.aiReportsStatPlayTime(context),
        'current': AppStrings.aiReportsMinutesShort(context, totalMinutes),
        'icon': Icons.timer
      },
      {
        'label': AppStrings.aiReportsStatActivities(context),
        'current': '$totalActivities',
        'icon': Icons.check_circle
      },
      {
        'label': AppStrings.aiReportsStatDailyAvg(context),
        'current': AppStrings.aiReportsPerDayShort(context, avgDaily),
        'icon': Icons.trending_up
      },
      {
        'label': AppStrings.aiReportsStatStars(context),
        'current': '$totalStars',
        'icon': Icons.star
      },
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: lightGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.compare_arrows, color: lightGreen),
                ),
                const SizedBox(width: 12),
                Text(
                  AppStrings.aiReportsStatsSummaryTitle(context),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...comparisons.map((comp) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ThemeColors.softFill(context),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(comp['icon'] as IconData, color: skyBlue, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(comp['label'] as String),
                      ),
                      Text(
                        comp['current'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildExportSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: orange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.file_download, color: orange),
                ),
                const SizedBox(width: 12),
                Text(
                  AppStrings.aiReportsExportTitle(context),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.aiReportsExportSubtitle(context),
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _exportReport(),
                    icon: const Icon(Icons.picture_as_pdf),
                    label: Text(AppStrings.aiReportsExportPdf(context)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _shareReport(),
                    icon: const Icon(Icons.share),
                    label: Text(AppStrings.aiReportsShare(context)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _exportReport() {
    if (_selectedChild == null || _stats == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.aiReportsNoDataExport(context))),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.picture_as_pdf, color: orange),
            const SizedBox(width: 8),
            Text(AppStrings.aiReportsExportDialogTitle(context)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.aiReportsExportReportLine(
                context, _selectedChild!.displayName)),
            const SizedBox(height: 8),
            Text(AppStrings.aiReportsExportIncludes(context)),
            const SizedBox(height: 8),
            _buildExportItem(
                AppStrings.aiReportsExportItemSummary(context)),
            _buildExportItem(AppStrings.aiReportsExportItemSkills(context)),
            _buildExportItem(
                AppStrings.aiReportsExportItemBehavior(context)),
            _buildExportItem(AppStrings.aiReportsExportItemRecs(context)),
            _buildExportItem(AppStrings.aiReportsExportItemStats(context)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.cancel(context)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _generateReport();
            },
            icon: const Icon(Icons.download),
            label: Text(AppStrings.aiReportsExportAction(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildExportItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.check, size: 16, color: lightGreen),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  void _generateReport() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(const Duration(seconds: 2), () {
          // السياق هنا سياق الحوار، ففحصه هو الصحيح لا فحص الشاشة.
          if (context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(AppStrings.aiReportsExportSuccess(
                        context, _selectedChild!.displayName)),
                  ],
                ),
                backgroundColor: lightGreen,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        });

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(AppStrings.aiReportsGenerating(context)),
            ],
          ),
        );
      },
    );
  }

  void _shareReport() {
    if (_selectedChild == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.aiReportsNoDataShare(context))),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.aiReportsSharing(context, _selectedChild!.displayName)),
        backgroundColor: skyBlue,
      ),
    );
  }
}
