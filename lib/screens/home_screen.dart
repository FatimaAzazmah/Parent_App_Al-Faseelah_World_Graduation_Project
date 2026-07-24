import 'package:flutter/material.dart';
import '../utils/app_strings.dart';
import '../utils/app_colors.dart';
import '../services/auth_service.dart';
import '../services/child_service.dart';
import '../models/child_model.dart';
import '../models/session_model.dart' as models;
import '../services/ble_service.dart';
import 'content_library_screen.dart';
import 'progress_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeContent(),
    const ProgressScreen(),
    const ContentLibraryScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex == 0
          ? AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.spa, color: Colors.white),
            const SizedBox(width: 8),
            Text(AppStrings.appTitle(context)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
        ],
      )
          : null,
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: ThemeColors.surface(context),
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(
            fontFamily: 'Tajawal',
            fontWeight: FontWeight.bold,
          ),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home),
              label: AppStrings.navHome(context),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.trending_up_outlined),
              activeIcon: const Icon(Icons.trending_up),
              label: AppStrings.navProgress(context),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.library_books_outlined),
              activeIcon: const Icon(Icons.library_books),
              label: AppStrings.navContent(context),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              activeIcon: const Icon(Icons.person),
              label: AppStrings.navAccount(context),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  HomeContent
// ─────────────────────────────────────────────────────────────
class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final _authService  = AuthService();
  final _childService = ChildService();

  UserData?      _userData;
  List<Child>    _children   = [];
  bool           _isLoading  = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final userData = await _authService.getCurrentUserData();
    final children = await _childService.getChildren();
    if (mounted) {
      setState(() {
        _userData   = userData;
        _children   = children;
        _isLoading  = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeHeader(context),
              const SizedBox(height: 24),
              _buildConnectionStatus(context),
              const SizedBox(height: 24),

              // ── Quick Actions أولاً ──
              _buildQuickActions(context),
              const SizedBox(height: 24),

              // ── بطاقة لكل طفل ──
              if (_children.isEmpty)
                _buildNoChildCard(context)
              else ...[
                Text(
                  AppStrings.recentActivities(context),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ..._children.map((child) => _ChildStatsCard(
                  child: child,
                  childService: _childService,
                )),
              ],

              const SizedBox(height: 24),
              _buildTipsSection(context),
            ],
          ),
        ),
      ),
    );
  }

  // ── رأس الترحيب البسيط ──
  Widget _buildWelcomeHeader(BuildContext context) {
    final userName = _userData?.name ?? AppStrings.defaultUserDisplay(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF87CEEB), Color(0xFF90EE90)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF87CEEB).withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.waving_hand, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.welcomeGreeting(context, userName),
                  style: const TextStyle(
                      color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _children.isEmpty
                      ? AppStrings.welcomeAddChild(context)
                      : '${_children.length} ${AppStrings.tr(context, "أطفال مسجلين", "children registered")}',
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── حالة الاتصال ──
  Widget _buildConnectionStatus(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: BleService.instance.isConnected,
      builder: (context, isConnected, _) {
        return ValueListenableBuilder<String?>(
          valueListenable: BleService.instance.connectedName,
          builder: (context, deviceName, _) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isConnected
                            ? const Color(0xFF90EE90).withOpacity(0.2)
                            : Colors.grey.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isConnected ? Icons.check_circle : Icons.wifi_off,
                        color: isConnected
                            ? const Color(0xFF90EE90)
                            : Colors.grey,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isConnected
                                ? AppStrings.connectionOnline(context)
                                : AppStrings.connectionStatusDisconnected(context),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isConnected ? null : ThemeColors.subtle(context),
                            ),
                          ),
                          Text(
                            isConnected
                                ? (deviceName ?? 'Al-Faseelah-001')
                                : AppStrings.tr(context,
                                'اضغط للاتصال باللعبة',
                                'Tap to connect to the game'),
                            style: TextStyle(
                                color: ThemeColors.subtle(context), fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/connection'),
                      child: Text(AppStrings.connectionDetails(context)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ── لا يوجد أطفال ──
  Widget _buildNoChildCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.child_care, size: 60, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(AppStrings.welcomeAddChild(context),
                  style: TextStyle(fontSize: 16, color: ThemeColors.subtle(context))),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/add-child'),
                icon: const Icon(Icons.add),
                label: Text(AppStrings.addChildAppBar(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Quick Actions ──
  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.quickActions(context),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
          children: [
            _buildActionCard(context,
              icon: Icons.child_care,
              title: AppStrings.actionChildProfile(context),
              subtitle: AppStrings.actionChildProfileSub(context),
              color: const Color(0xFF87CEEB),
              onTap: () => Navigator.pushNamed(context, '/child-profile'),
            ),
            _buildActionCard(context,
              icon: Icons.assessment,
              title: AppStrings.actionReports(context),
              subtitle: AppStrings.actionReportsSub(context),
              color: const Color(0xFF90EE90),
              onTap: () => Navigator.pushNamed(context, '/progress'),
            ),
            _buildActionCard(context,
              icon: Icons.wifi,
              title: AppStrings.actionConnection(context),
              subtitle: AppStrings.actionConnectionSub(context),
              color: const Color(0xFF98D8AA),
              onTap: () => Navigator.pushNamed(context, '/connection'),
            ),
            _buildActionCard(context,
              icon: Icons.library_books,
              title: AppStrings.actionContent(context),
              subtitle: AppStrings.actionContentSub(context),
              color: const Color(0xFFFFB74D),
              onTap: () => Navigator.pushNamed(context, '/library'),
            ),
            _buildActionCard(context,
              icon: Icons.flag,
              title: AppStrings.actionBehaviorGoals(context),
              subtitle: AppStrings.actionBehaviorGoalsSub(context),
              color: const Color(0xFFBA68C8),
              onTap: () => Navigator.pushNamed(context, '/behavior-goals'),
            ),
            _buildActionCard(context,
              icon: Icons.analytics,
              title: AppStrings.actionAiReports(context),
              subtitle: AppStrings.actionAiReportsSub(context),
              color: const Color(0xFF4DD0E1),
              onTap: () => Navigator.pushNamed(context, '/ai-reports'),
            ),
            _buildActionCard(context,
              icon: Icons.dashboard_customize,
              title: _t(context, 'اختيار البورد', 'Select Board'),
              subtitle: _t(context, 'البورد المفعّل الآن', 'Active board'),
              color: const Color(0xFF7986CB),
              onTap: () => Navigator.pushNamed(context, '/board-selection'),
            ),
            _buildActionCard(context,
              icon: Icons.emoji_events,
              title: _t(context, 'الإنجازات', 'Achievements'),
              subtitle: _t(context, 'ماذا أنجز طفلك', "Child's progress"),
              color: const Color(0xFFFF8A65),
              onTap: () => Navigator.pushNamed(context, '/achievements'),
            ),
          ],
        ),
      ],
    );
  }

  // ترجمة سريعة عربي/إنجليزي حسب لغة التطبيق
  String _t(BuildContext context, String ar, String en) {
    return Localizations.localeOf(context).languageCode == 'en' ? en : ar;
  }

  Widget _buildActionCard(BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(height: 8),
              Text(title,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(subtitle,
                style: TextStyle(fontSize: 10, color: ThemeColors.subtle(context)),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── نصيحة اليوم ──
  Widget _buildTipsSection(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(colors: [
            const Color(0xFF90EE90).withOpacity(0.1),
            const Color(0xFF87CEEB).withOpacity(0.1),
          ]),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.lightbulb_outline, color: Color(0xFFFFB74D)),
              const SizedBox(width: 8),
              Text(AppStrings.tipOfTheDay(context),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 12),
            Text(AppStrings.tipOfTheDayBody(context),
                style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  ChildStatsCard — بطاقة مستقلة لكل طفل مع إحصائياته
// ─────────────────────────────────────────────────────────────
class _ChildStatsCard extends StatefulWidget {
  final Child        child;
  final ChildService childService;

  const _ChildStatsCard({required this.child, required this.childService});

  @override
  State<_ChildStatsCard> createState() => _ChildStatsCardState();
}

class _ChildStatsCardState extends State<_ChildStatsCard> {
  int  _todayMinutes    = 0;
  int  _todayActivities = 0;
  int  _todayStars      = 0;
  List<models.Session> _recentSessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final today = DateTime.now().subtract(const Duration(hours: 24));
    final sessions = await widget.childService.getSessionsForChild(
      widget.child.id,
      from: today,
      limit: 20,
    );

    int mins = 0, acts = 0, stars = 0;
    for (final s in sessions) {
      mins  += s.totalMinutes;
      acts  += s.activities.length;
      stars += s.starsEarned;
    }

    if (mounted) {
      setState(() {
        _todayMinutes    = mins;
        _todayActivities = acts;
        _todayStars      = stars;
        _recentSessions  = sessions;
        _isLoading       = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── رأس البطاقة: avatar + اسم + زر التفاصيل ──
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor:
                  const Color(0xFF87CEEB).withOpacity(0.2),
                  child: Text(widget.child.avatar,
                      style: const TextStyle(fontSize: 28)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.child.displayName,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(
                        '${widget.child.age} ${AppStrings.tr(context, "سنوات", "years old")}',
                        style: TextStyle(fontSize: 13, color: ThemeColors.subtle(context)),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    '/progress',
                  ),
                  child: Text(AppStrings.viewAll(context)),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // ── إحصائيات اليوم ──
            if (_isLoading)
              const Center(
                child: SizedBox(
                  height: 40,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat(
                    context,
                    icon: Icons.timer_outlined,
                    color: const Color(0xFF87CEEB),
                    value: _todayMinutes > 0 ? '$_todayMinutes' : '—',
                    label: AppStrings.statMinutesToday(context),
                  ),
                  _buildStatDivider(),
                  _buildStat(
                    context,
                    icon: Icons.task_alt,
                    color: const Color(0xFF90EE90),
                    value: _todayActivities > 0 ? '$_todayActivities' : '—',
                    label: AppStrings.statActivitiesDone(context),
                  ),
                  _buildStatDivider(),
                  _buildStat(
                    context,
                    icon: Icons.star_outlined,
                    color: const Color(0xFFFFB74D),
                    value: _todayStars > 0 ? '$_todayStars' : '—',
                    label: AppStrings.statNewStar(context),
                  ),
                ],
              ),

              // ── آخر الجلسات ──
              if (_recentSessions.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Text(
                  AppStrings.tr(context, 'آخر الجلسات', 'Recent sessions'),
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: ThemeColors.subtle(context)),
                ),
                const SizedBox(height: 8),
                ..._recentSessions.map((s) => _buildSessionRow(context, s)),
              ] else ...[
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    AppStrings.noActivitiesYet(context),
                    style: TextStyle(fontSize: 13, color: ThemeColors.faint(context)),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStat(BuildContext context, {
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 6),
        Text(value,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label,
            style: TextStyle(fontSize: 11, color: ThemeColors.subtle(context))),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(width: 1, height: 50, color: ThemeColors.fill(context));
  }

  Widget _buildSessionRow(BuildContext context, models.Session session) {
    final diff = DateTime.now().difference(session.startTime);
    String timeAgo;
    if (diff.inMinutes < 60) {
      timeAgo = AppStrings.tr(
          context, 'منذ ${diff.inMinutes} دقيقة', '${diff.inMinutes}m ago');
    } else if (diff.inHours < 24) {
      timeAgo = AppStrings.tr(
          context, 'منذ ${diff.inHours} ساعة', '${diff.inHours}h ago');
    } else {
      timeAgo = AppStrings.tr(
          context, 'منذ ${diff.inDays} يوم', '${diff.inDays}d ago');
    }

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => Navigator.pushNamed(
        context,
        '/activity-detail',
        arguments: {
          'sessionId': session.id,
          'childId':   session.childId,
        },
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFF87CEEB).withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.play_circle_outline,
                  color: Color(0xFF87CEEB), size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${session.totalMinutes} ${AppStrings.tr(context, "دقيقة", "min")} • '
                    '${session.activities.length} ${AppStrings.tr(context, "نشاط", "activities")}',
                style: const TextStyle(fontSize: 13),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.star, color: Color(0xFFFFB74D), size: 14),
                const SizedBox(width: 2),
                Text('${session.starsEarned}',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                Text(timeAgo,
                    style: TextStyle(fontSize: 11, color: ThemeColors.faint(context))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}