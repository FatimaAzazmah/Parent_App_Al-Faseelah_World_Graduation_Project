import 'package:flutter/material.dart';

import '../models/session_model.dart' as models;
import '../services/child_service.dart';
import '../utils/app_strings.dart';

/// شاشة تفاصيل نشاط الطفل
class ChildActivityDetailScreen extends StatefulWidget {
  final String? sessionId;

  const ChildActivityDetailScreen({super.key, this.sessionId});

  @override
  State<ChildActivityDetailScreen> createState() => _ChildActivityDetailScreenState();
}

class _ChildActivityDetailScreenState extends State<ChildActivityDetailScreen> {
  final ChildService _childService = ChildService();
  models.Session? _session;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSession();
    });
  }

  Future<void> _loadSession() async {
    final args = ModalRoute.of(context)?.settings.arguments;
    String? sessionId = widget.sessionId;
    String? childId;
    if (args is Map) {
      sessionId = (args['sessionId'] as String?) ?? sessionId;
      childId = args['childId'] as String?;
    }

    models.Session? s;
    if (sessionId != null && sessionId.isNotEmpty) {
      s = await _childService.getSessionById(sessionId);
    } else if (childId != null && childId.isNotEmpty) {
      final sessions = await _childService.getChildSessions(childId);
      if (sessions.isNotEmpty) s = sessions.first;
    }

    if (!mounted) return;
    setState(() {
      _session = s;
      _isLoading = false;
    });
  }

  String _dateLabel(DateTime dt) {
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} $hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.tr(context, 'تفاصيل الجلسة', 'Session details')),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppStrings.tr(
                      context,
                      'جاري مشاركة التقرير...',
                      'Sharing report...',
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _session == null
              ? Center(
                  child: Text(
                    AppStrings.tr(
                      context,
                      'لا توجد بيانات جلسة متاحة',
                      'No session data available',
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSessionHeader(context),
                      const SizedBox(height: 24),
                      _buildZonesVisited(context),
                      const SizedBox(height: 24),
                      _buildCompletedActivities(context),
                      const SizedBox(height: 24),
                      _buildBehaviorAnalysis(context),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSessionHeader(BuildContext context) {
    final s = _session!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF87CEEB), Color(0xFF90EE90)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white24,
                child: Icon(Icons.history, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _dateLabel(s.startTime),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      AppStrings.tr(context, 'سجل جلسة حقيقي', 'Real session record'),
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  AppStrings.tr(context, '${s.totalMinutes} دقيقة', '${s.totalMinutes} min'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildHeaderStat(
                '🎯',
                '${s.activities.length}',
                AppStrings.tr(context, 'أنشطة', 'Activities'),
              ),
              _buildHeaderStat(
                '⭐',
                '${s.starsEarned}',
                AppStrings.tr(context, 'نجوم', 'Stars'),
              ),
              _buildHeaderStat(
                '📍',
                '${s.zonesVisited.length}',
                AppStrings.tr(context, 'مناطق', 'Zones'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          value,
          style:  const TextStyle(
            fontSize:  20,
            fontWeight:  FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildZonesVisited(BuildContext context) {
    final zones = _session!.zonesVisited.entries.toList();
    if (zones.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(AppStrings.tr(context, 'لا توجد مناطق مسجلة', 'No visited zones')),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.tr(context, 'المناطق التي زارها', 'Visited zones'),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...zones.map((zone) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.place, color: Color(0xFF87CEEB)),
              title: Text(zone.key),
              trailing: Text(
                AppStrings.tr(context, '${zone.value} نشاط', '${zone.value} activities'),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCompletedActivities(BuildContext context) {
    final activities = _session!.activities;
    if (activities.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(AppStrings.tr(context, 'لا توجد أنشطة في هذه الجلسة', 'No activities in this session')),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.tr(context, 'الأنشطة المكتملة', 'Completed activities'),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...activities.map((activity) {
          final stars = activity.starsEarned > 0
              ? AppStrings.tr(context, '${activity.starsEarned} نجوم', '${activity.starsEarned} stars')
              : AppStrings.tr(context, 'مكتمل', 'Done');
          return Card(
            child: ListTile(
              leading: const Icon(Icons.task_alt, color: Color(0xFF87CEEB)),
              title: Text(activity.title),
              subtitle: Text(activity.type),
              trailing: Text(stars),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBehaviorAnalysis(BuildContext context) {
    final s = _session!;
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
                    color: const Color(0xFFBA68C8).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.psychology, color: Color(0xFFBA68C8)),
                ),
                const SizedBox(width: 12),
                Text(
                  AppStrings.tr(context, 'تحليل السلوك', 'Behavior analysis'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildBehaviorItem(
              AppStrings.tr(context, 'المزاج العام', 'Mood'),
              s.mood.isNotEmpty ? s.mood : '-',
              '😊',
              const Color(0xFFFFB74D),
            ),
            _buildBehaviorItem(
              AppStrings.tr(context, 'مستوى التركيز', 'Focus level'),
              s.focusLevel.isNotEmpty ? s.focusLevel : '-',
              '🎯',
              const Color(0xFF90EE90),
            ),
            _buildBehaviorItem(
              AppStrings.tr(context, 'الوقت الكلي', 'Total time'),
              AppStrings.tr(context, '${s.totalMinutes} دقيقة', '${s.totalMinutes} min'),
              '⏱️',
              const Color(0xFF87CEEB),
            ),
            _buildBehaviorItem(
              AppStrings.tr(context, 'إجمالي النجوم', 'Total stars'),
              '${s.starsEarned}',
              '⭐',
              const Color(0xFFBA68C8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBehaviorItem(String title, String value, String emoji, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child:  Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Removed hardcoded AI demo insights to keep session details truthful.
}