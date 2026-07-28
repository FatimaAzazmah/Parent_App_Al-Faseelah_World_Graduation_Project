import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_strings.dart';

import '../models/child_model.dart';
import '../services/child_service.dart';
import '../services/content_library_service.dart';
import '../widgets/child_selector_bar.dart';
import '../widgets/empty_state.dart';

/// شاشة الإنجازات: تعرض لكل طفل ما تحقّق (achievements) مقابل ما هو متاح
/// للتتبع (content.trackable_key)، مجمّعاً حسب الفئة.
class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final ChildService _childService = ChildService();
  final ContentLibraryService _service = ContentLibraryService();

  List<Child> _children = [];
  Child? _selectedChild;

  // كل مفاتيح التتبع المتاحة، مجمّعة حسب الفئة
  Map<String, List<_Trackable>> _byCategory = {};
  Map<String, DateTime> _achieved = {};
  bool _isLoading = true;

  // ترجمة الفئات (تطابق قيود achievements.category)
  static const Map<String, _CatInfo> _categories = {
    'surahs': _CatInfo('السور', 'Surahs', '📿', Color(0xFF81C784)),
    'duas': _CatInfo('الأدعية', 'Duas', '🤲', Color(0xFF4DD0E1)),
    'letters': _CatInfo('الحروف', 'Letters', '🔤', Color(0xFF87CEEB)),
    'numbers': _CatInfo('الأرقام', 'Numbers', '🔢', Color(0xFFFFB74D)),
    'names': _CatInfo("الأسماء الحسنى", "Allah's Names", '🌟', Color(0xFFBA68C8)),
    'behaviors': _CatInfo('السلوكيات', 'Behaviors', '💪', Color(0xFFFF8A65)),
    'words_ar': _CatInfo('كلمات عربية', 'Arabic Words', '🇵🇸', Color(0xFF90EE90)),
    'words_en': _CatInfo('كلمات إنجليزية', 'English Words', '🔡', Color(0xFF9575CD)),
  };

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final children = await _childService.getChildren();
    setState(() {
      _children = children;
      _selectedChild = children.isNotEmpty ? children.first : null;
    });
    await _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);

    // مفاتيح التتبع من المحتوى (نجمعها من كل المحتوى الفعّال)
    final content = await _service.getLibraryForChild(null);
    final byCat = <String, List<_Trackable>>{};
    final seen = <String>{};
    for (final c in content) {
      final key = c.trackableKey;
      if (key == null || key.isEmpty) continue;
      if (seen.contains(key)) continue;
      seen.add(key);
      final cat = _categoryOf(key);
      byCat.putIfAbsent(cat, () => []).add(_Trackable(key, c.title));
    }

    Map<String, DateTime> achieved = {};
    if (_selectedChild != null) {
      achieved = await _service.getAchievementsWithDates(_selectedChild!.id);
    }

    if (mounted) {
      setState(() {
        _byCategory = byCat;
        _achieved = achieved;
        _isLoading = false;
      });
    }
  }

  /// يستنتج الفئة من مفتاح التتبع (مثل surah_fatiha → surahs).
  String _categoryOf(String key) {
    final k = key.toLowerCase();
    if (k.startsWith('surah')) return 'surahs';
    if (k.startsWith('dua') || k.startsWith('thikr') || k.startsWith('athkar')) {
      return 'duas';
    }
    if (k.startsWith('letter') || k.startsWith('harf')) return 'letters';
    if (k.startsWith('number') || k.startsWith('num') || k.startsWith('raqam')) {
      return 'numbers';
    }
    if (k.startsWith('name') || k.contains('asma')) return 'names';
    if (k.startsWith('behavior') || k.startsWith('suluk')) return 'behaviors';
    if (k.startsWith('word_en') || k.startsWith('en_')) return 'words_en';
    if (k.startsWith('word_ar') || k.startsWith('ar_')) return 'words_ar';
    return 'behaviors'; // افتراضي
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(AppStrings.tr(context, 'الإنجازات', 'Achievements'))),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildChildSelector(),
                if (_selectedChild != null) _buildSummary(),
                Expanded(child: _buildBody()),
              ],
            ),
    );
  }

  Widget _buildChildSelector() {
    return ChildSelectorBar(
      children: _children,
      selectedChildId: _selectedChild?.id,
      onChildSelected: (child) async {
        setState(() => _selectedChild = child);
        await _load();
      },
    );
  }

  Widget _buildSummary() {
    int total = 0;
    for (final list in _byCategory.values) {
      total += list.length;
    }
    final done = _achieved.length;
    final pct = total == 0 ? 0.0 : (done / total).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF87CEEB), Color(0xFF90EE90)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  AppStrings.tr(context, 'إنجازات ${_selectedChild!.displayName}',
                      "${_selectedChild!.displayName}'s Achievements"),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              Text('$done / $total',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 10,
              backgroundColor: ThemeColors.surface(context).withOpacity(0.3),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_selectedChild == null) {
      return _empty(AppStrings.tr(context, 'اختاري طفلاً لعرض إنجازاته',
          'Select a child to view their achievements'));
    }
    if (_byCategory.isEmpty) {
      return _empty(AppStrings.tr(context, 'لا توجد عناصر قابلة للتتبع بعد',
          'No trackable items yet'));
    }

    // رتّب الفئات حسب ترتيب _categories المعروف
    final orderedKeys = _categories.keys
        .where((k) => _byCategory.containsKey(k))
        .toList();
    // أضف أي فئات غير متوقّعة في النهاية
    for (final k in _byCategory.keys) {
      if (!orderedKeys.contains(k)) orderedKeys.add(k);
    }

    return ListView(
      padding: const EdgeInsets.all(12),
      children: orderedKeys.map((cat) {
        final items = _byCategory[cat]!;
        return _buildCategoryCard(cat, items);
      }).toList(),
    );
  }

  Widget _buildCategoryCard(String cat, List<_Trackable> items) {
    final info = _categories[cat] ??
        const _CatInfo('أخرى', 'Other', '📌', Color(0xFF90A4AE));
    final doneCount =
        items.where((it) => _achieved.containsKey(it.key)).length;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        leading: CircleAvatar(
          backgroundColor: info.color.withOpacity(0.2),
          child: Text(info.emoji, style: const TextStyle(fontSize: 20)),
        ),
        title: Text(info.label(context),
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(AppStrings.tr(context,
            '$doneCount / ${items.length} مكتمل',
            '$doneCount / ${items.length} completed')),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: info.color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${items.isEmpty ? 0 : ((doneCount / items.length) * 100).round()}%',
            style: TextStyle(
                color: info.color, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        children: items.map((it) {
          final done = _achieved.containsKey(it.key);
          final date = _achieved[it.key];
          return ListTile(
            dense: true,
            leading: Icon(
              done ? Icons.check_circle : Icons.circle_outlined,
              color: done ? const Color(0xFF81C784) : Colors.grey.shade400,
            ),
            title: Text(it.label),
            subtitle: (done && date != null)
                ? Text(
                    AppStrings.tr(context, 'تحقّق في ${_fmtDate(date)}',
                        'Achieved on ${_fmtDate(date)}'),
                    style: const TextStyle(fontSize: 11))
                : null,
          );
        }).toList(),
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.day}/${d.month}/${d.year}';

  Widget _empty(String msg) {
    return EmptyState(icon: Icons.emoji_events_outlined, message: msg);
  }
}

class _Trackable {
  final String key;
  final String label;
  _Trackable(this.key, this.label);
}

class _CatInfo {
  final String labelAr;
  final String labelEn;
  final String emoji;
  final Color color;
  const _CatInfo(this.labelAr, this.labelEn, this.emoji, this.color);

  String label(BuildContext context) =>
      AppStrings.tr(context, labelAr, labelEn);
}
