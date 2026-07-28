import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/app_strings.dart';
import '../utils/app_colors.dart';
import '../services/child_service.dart';
import '../models/session_model.dart' as models;

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _childService = ChildService();

  List<_AppNotification> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  // ── بناء الإشعارات من الجلسات الحقيقية ──
  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);

    final client = Supabase.instance.client;
    final user   = client.auth.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    final children = await _childService.getChildren();
    final List<_AppNotification> notifs = [];

    for (final child in children) {
      final sessions = await _childService.getSessionsForChild(
        child.id,
        from: DateTime.now().subtract(const Duration(days: 7)),
        limit: 5,
      );

      for (final session in sessions) {
        // إشعار لكل جلسة
        notifs.add(_AppNotification(
          id: 'session_${session.id}',
          childName: child.displayName,
          childAvatar: child.avatar,
          icon: Icons.play_circle,
          color: const Color(0xFF87CEEB),
          title: child.displayName,
          body: _sessionSummary(session),
          time: session.startTime,
          isRead: _isOlderThan(session.startTime, hours: 1),
          type: _NotifType.session,
          sessionId: session.id,
          childId: child.id,
        ));

        // إشعار إذا كسب نجوم
        if (session.starsEarned >= 3) {
          notifs.add(_AppNotification(
            id: 'stars_${session.id}',
            childName: child.displayName,
            childAvatar: child.avatar,
            icon: Icons.star,
            color: const Color(0xFFFFB74D),
            title: child.displayName,
            body: _starsMessage(child.displayName, session.starsEarned),
            time: session.startTime,
            isRead: _isOlderThan(session.startTime, hours: 2),
            type: _NotifType.achievement,
            sessionId: session.id,
            childId: child.id,
          ));
        }
      }
    }

    // ترتيب من الأحدث للأقدم
    notifs.sort((a, b) => b.time.compareTo(a.time));

    if (mounted) {
      setState(() {
        _notifications = notifs;
        _isLoading = false;
      });
    }
  }

  String _sessionSummary(models.Session s) {
    final mins  = s.totalMinutes;
    final acts  = s.activities.length;
    final stars = s.starsEarned;
    return '$mins min • $acts activities • $stars ⭐';
  }

  String _starsMessage(String name, int stars) {
    return '$name earned $stars stars! Great job 🎉';
  }

  bool _isOlderThan(DateTime time, {required int hours}) {
    return DateTime.now().difference(time).inHours > hours;
  }

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24)   return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  void _markAllAsRead() {
    setState(() {
      for (final n in _notifications) {
        n.isRead = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppStrings.notificationsMarkAllDone(context))),
    );
  }

  void _markAsRead(String id) {
    setState(() {
      final n = _notifications.firstWhere((n) => n.id == id,
          orElse: () => _notifications.first);
      n.isRead = true;
    });
  }

  void _deleteNotification(String id) {
    setState(() => _notifications.removeWhere((n) => n.id == id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppStrings.notificationsDeletedOne(context))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.notificationsTitleWithUnread(
            context, _unreadCount)),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                AppStrings.notificationsReadAll(context),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'clear_all') _showClearAllDialog();
              if (value == 'refresh')   _loadNotifications();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'refresh',
                child: Row(children: [
                  const Icon(Icons.refresh),
                  const SizedBox(width: 8),
                  Text(AppStrings.tr(context, 'تحديث', 'Refresh')),
                ]),
              ),
              PopupMenuItem(
                value: 'clear_all',
                child: Row(children: [
                  const Icon(Icons.delete_sweep, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(AppStrings.notificationsMenuClear(context)),
                ]),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
          ? _buildEmptyState()
          : _buildList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: ThemeColors.fill(context),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications_off,
                size: 60, color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),
          Text(
            AppStrings.notificationsEmptyTitle(context),
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: ThemeColors.subtle(context)),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.tr(context,
                'لا توجد جلسات في آخر 7 أيام',
                'No sessions in the last 7 days'),
            style: TextStyle(fontSize: 14, color: ThemeColors.faint(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final n = _notifications[index];
          return Dismissible(
            key: Key(n.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 20),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (_) => _deleteNotification(n.id),
            child: _buildCard(n),
          );
        },
      ),
    );
  }

  Widget _buildCard(_AppNotification n) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: n.isRead ? null : const Color(0xFF87CEEB).withValues(alpha: 0.05),
      child: InkWell(
        onTap: () {
          _markAsRead(n.id);
          if (n.sessionId != null) {
            Navigator.pushNamed(context, '/activity-detail',
                arguments: {
                  'sessionId': n.sessionId,
                  'childId':   n.childId,
                });
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar + icon
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: n.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(n.icon, color: n.color, size: 24),
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: Text(n.childAvatar,
                        style: const TextStyle(fontSize: 14)),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                        child: Text(n.title,
                            style: TextStyle(
                                fontWeight: n.isRead
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                                fontSize: 15)),
                      ),
                      if (!n.isRead)
                        Container(
                          width: 10, height: 10,
                          decoration: const BoxDecoration(
                            color: Color(0xFF87CEEB),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ]),
                    const SizedBox(height: 4),
                    Text(n.body,
                        style: TextStyle(
                            fontSize: 13, color: ThemeColors.subtle(context)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Text(_timeAgo(n.time),
                        style: TextStyle(
                            fontSize: 11, color: ThemeColors.faint(context))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(AppStrings.notificationsClearAllTitle(context)),
        content: Text(AppStrings.notificationsClearAllBody(context)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.cancel(context)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _notifications.clear());
              Navigator.pop(context);
            },
            style:
            ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
                AppStrings.notificationsClearAllConfirm(context)),
          ),
        ],
      ),
    );
  }
}

// ── Data model ──
enum _NotifType { session, achievement }

class _AppNotification {
  final String       id;
  final String       childName;
  final String       childAvatar;
  final IconData     icon;
  final Color        color;
  final String       title;
  final String       body;
  final DateTime     time;
  bool               isRead;
  final _NotifType   type;
  final String?      sessionId;
  final String?      childId;

  _AppNotification({
    required this.id,
    required this.childName,
    required this.childAvatar,
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    required this.time,
    required this.isRead,
    required this.type,
    this.sessionId,
    this.childId,
  });
}