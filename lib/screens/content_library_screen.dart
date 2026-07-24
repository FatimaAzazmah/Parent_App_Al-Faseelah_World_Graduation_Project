import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_strings.dart';

import '../models/child_model.dart';
import '../models/content_item_model.dart';
import '../services/child_service.dart';
import '../services/content_library_service.dart';

/// شاشة المحتوى المطوّرة:
///  • تصفّح المحتوى الحقيقي من جدول content
///  • اختيار طفل نشط
///  • تفضيلات عامة (أنواع مفضّلة) تُحفظ في parent_preferences
///  • حفظ محتوى خاص لكل طفل (child_saved_content)
///  • تبويب "المحفوظ" لكل طفل
class ContentLibraryScreen extends StatefulWidget {
  const ContentLibraryScreen({super.key});

  @override
  State<ContentLibraryScreen> createState() => _ContentLibraryScreenState();
}

class _ContentLibraryScreenState extends State<ContentLibraryScreen>
    with SingleTickerProviderStateMixin {
  final ContentLibraryService _service = ContentLibraryService();
  final ChildService _childService = ChildService();
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  List<Child> _children = [];
  Child? _selectedChild;

  List<ContentItem> _allContent = [];
  List<ContentItem> _savedContent = [];
  List<String> _preferredTypes = [];

  String _selectedType = 'all';
  bool _isLoading = true;

  // الأنواع (مطابقة لقيود جدول content)
  static const List<_TypeInfo> _types = [
    _TypeInfo('all', 'الكل', 'All', Icons.apps, Color(0xFF87CEEB)),
    _TypeInfo('story', 'قصص', 'Stories', Icons.auto_stories, Color(0xFF87CEEB)),
    _TypeInfo('learn', 'تعليمي', 'Educational', Icons.school, Color(0xFF90EE90)),
    _TypeInfo('values', 'قيم', 'Values', Icons.volunteer_activism, Color(0xFF81C784)),
    _TypeInfo('challenge', 'تحديات', 'Challenges', Icons.emoji_events, Color(0xFFFFB74D)),
    _TypeInfo('play', 'ألعاب', 'Games', Icons.sports_esports, Color(0xFFBA68C8)),
  ];

  static _TypeInfo _typeInfo(String key) =>
      _types.firstWhere((t) => t.key == key,
          orElse: () => _types.first);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _init();
  }

  Future<void> _init() async {
    final children = await _childService.getChildren();
    Child? first = children.isNotEmpty ? children.first : null;
    setState(() {
      _children = children;
      _selectedChild = first;
    });
    await _loadForChild();
  }

  Future<void> _loadForChild() async {
    setState(() => _isLoading = true);
    final childId = _selectedChild?.id;

    final content = await _service.getContent(childId: childId);
    List<ContentItem> saved = [];
    List<String> prefs = [];
    if (childId != null) {
      saved = await _service.getSavedContent(childId);
      prefs = await _service.getPreferredTypes(childId);
    }

    if (mounted) {
      setState(() {
        _allContent = content;
        _savedContent = saved;
        _preferredTypes = prefs;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<ContentItem> get _filtered {
    var items = _allContent;
    if (_selectedType != 'all') {
      items = items.where((c) => c.type == _selectedType).toList();
    }
    final q = _searchController.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      items = items
          .where((c) => c.title.toLowerCase().contains(q))
          .toList();
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.tr(context, 'مكتبة المحتوى', 'Content Library')),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: [
            Tab(text: AppStrings.tr(context, 'استكشاف', 'Explore')),
            Tab(text: AppStrings.tr(context, 'المحفوظ', 'Saved')),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildChildSelector(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildExploreTab(),
                      _buildSavedTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // ── اختيار الطفل ──
  Widget _buildChildSelector() {
    if (_children.isEmpty) {
      return Container(
        width: double.infinity,
        color: const Color(0xFFFFF3E0),
        padding: const EdgeInsets.all(12),
        child: Text(
          AppStrings.tr(context, 'أضيفي طفلاً أولاً لتخصيص المحتوى وحفظه',
              'Add a child first to personalize and save content'),
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFFE65100)),
        ),
      );
    }

    return Container(
      color: ThemeColors.surface(context),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.child_care, size: 20, color: Color(0xFF87CEEB)),
          const SizedBox(width: 8),
          Text(AppStrings.tr(context, 'الطفل:', 'Child:'),
              style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _children.length,
                itemBuilder: (context, i) {
                  final child = _children[i];
                  final selected = child.id == _selectedChild?.id;
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: ChoiceChip(
                      selected: selected,
                      label: Text('${child.avatar} ${child.displayName}'),
                      onSelected: (_) async {
                        setState(() => _selectedChild = child);
                        await _loadForChild();
                      },
                      selectedColor:
                          const Color(0xFF87CEEB).withOpacity(0.25),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── تبويب الاستكشاف ──
  Widget _buildExploreTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: AppStrings.tr(context, 'ابحثي عن محتوى...', 'Search content...'),
              prefixIcon: const Icon(Icons.search),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        _buildTypeChips(),
        if (_selectedChild != null) _buildPreferenceHint(),
        Expanded(
          child: _filtered.isEmpty
              ? _buildEmpty(AppStrings.tr(context,
                  'لا يوجد محتوى في هذا التصنيف', 'No content in this category'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _filtered.length,
                  itemBuilder: (context, i) => _buildContentCard(_filtered[i]),
                ),
        ),
      ],
    );
  }

  Widget _buildTypeChips() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _types.length,
        itemBuilder: (context, i) {
          final t = _types[i];
          final selected = t.key == _selectedType;
          final isPreferred =
              t.key != 'all' && _preferredTypes.contains(t.key);
          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: FilterChip(
              selected: selected,
              avatar: Icon(t.icon,
                  size: 18,
                  color: selected ? t.color : ThemeColors.subtle(context)),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(t.label(context)),
                  if (isPreferred) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.star, size: 14, color: Color(0xFFFFB74D)),
                  ],
                ],
              ),
              onSelected: (_) => setState(() => _selectedType = t.key),
              selectedColor: t.color.withOpacity(0.2),
            ),
          );
        },
      ),
    );
  }

  // تلميح + زر لضبط التفضيلات العامة
  Widget _buildPreferenceHint() {
    return InkWell(
      onTap: _showPreferencesSheet,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF90EE90).withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.tune, size: 18, color: Color(0xFF2E7D32)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _preferredTypes.isEmpty
                    ? AppStrings.tr(
                        context,
                        'اختاري الأنواع المفضّلة لـ ${_selectedChild!.displayName}',
                        'Pick preferred types for ${_selectedChild!.displayName}')
                    : '${AppStrings.tr(context, 'التفضيلات', 'Preferences')}: '
                        '${_preferredTypes.map((t) => _typeInfo(t).label(context)).join(AppStrings.tr(context, '، ', ', '))}',
                style: const TextStyle(fontSize: 13, color: Color(0xFF2E7D32)),
              ),
            ),
            const Icon(Icons.chevron_left, color: Color(0xFF2E7D32)),
          ],
        ),
      ),
    );
  }

  void _showPreferencesSheet() {
    final child = _selectedChild;
    if (child == null) return;
    final selected = Set<String>.from(_preferredTypes);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheet) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      AppStrings.tr(
                          context,
                          'الأنواع المفضّلة لـ ${child.displayName}',
                          'Preferred types for ${child.displayName}'),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                      AppStrings.tr(
                          context,
                          'توجيه عام: الفسيلة ستميل لهذه الأنواع في جلساتها',
                          'General guidance: Faseelah will lean toward these types during sessions'),
                      style:
                          TextStyle(fontSize: 13, color: ThemeColors.subtle(context))),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _types
                        .where((t) => t.key != 'all')
                        .map((t) {
                      final on = selected.contains(t.key);
                      return FilterChip(
                        selected: on,
                        avatar: Icon(t.icon, size: 18),
                        label: Text(t.label(context)),
                        onSelected: (v) => setSheet(() {
                          if (v) {
                            selected.add(t.key);
                          } else {
                            selected.remove(t.key);
                          }
                        }),
                        selectedColor: t.color.withOpacity(0.25),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: Text(AppStrings.tr(
                          context, 'حفظ التفضيلات', 'Save preferences')),
                      onPressed: () async {
                        final ok = await _service.setPreferredTypes(
                            child.id, selected.toList());
                        if (!mounted) return;
                        Navigator.pop(context);
                        setState(() => _preferredTypes = selected.toList());
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(ok
                                ? AppStrings.tr(context, 'تم حفظ التفضيلات',
                                    'Preferences saved')
                                : AppStrings.tr(context, 'تعذّر الحفظ، حاولي مجدداً',
                                    'Could not save, please try again')),
                            backgroundColor:
                                ok ? const Color(0xFF81C784) : Colors.red,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ── تبويب المحفوظ ──
  Widget _buildSavedTab() {
    if (_selectedChild == null) {
      return _buildEmpty(AppStrings.tr(context, 'اختاري طفلاً لعرض محتواه المحفوظ',
          'Select a child to view their saved content'));
    }
    if (_savedContent.isEmpty) {
      return _buildEmpty(AppStrings.tr(
          context,
          'لا يوجد محتوى محفوظ لـ ${_selectedChild!.displayName} بعد',
          'No saved content for ${_selectedChild!.displayName} yet'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _savedContent.length,
      itemBuilder: (context, i) =>
          _buildContentCard(_savedContent[i], inSavedTab: true),
    );
  }

  // ── كارت المحتوى ──
  Widget _buildContentCard(ContentItem item, {bool inSavedTab = false}) {
    final t = _typeInfo(item.type);
    final canSave = _selectedChild != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showContentDetails(item),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: t.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(t.icon, color: t.color, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _pill(t.label(context), t.color),
                        const SizedBox(width: 6),
                        if (item.zoneName != null)
                          _pill(item.zoneName!, Colors.grey.shade500),
                        const SizedBox(width: 6),
                        _difficultyDots(item.difficulty),
                      ],
                    ),
                  ],
                ),
              ),
              if (canSave)
                IconButton(
                  icon: Icon(
                    item.isSavedForChild
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                    color: item.isSavedForChild
                        ? const Color(0xFFFFB74D)
                        : Colors.grey,
                  ),
                  onPressed: () => _toggleSave(item),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleSave(ContentItem item) async {
    final child = _selectedChild;
    if (child == null) return;

    final nowSaved = !item.isSavedForChild;
    // تحديث فوري للواجهة
    setState(() {
      _allContent = _allContent
          .map((c) =>
              c.id == item.id ? c.copyWith(isSavedForChild: nowSaved) : c)
          .toList();
    });

    bool ok;
    if (nowSaved) {
      ok = await _service.saveContentForChild(child.id, item.id);
    } else {
      ok = await _service.unsaveContentForChild(child.id, item.id);
    }

    if (!mounted) return;
    if (ok) {
      // حدّث قائمة المحفوظ
      final saved = await _service.getSavedContent(child.id);
      if (mounted) setState(() => _savedContent = saved);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(nowSaved
              ? AppStrings.tr(context, 'تم حفظ "${item.title}" لـ ${child.displayName}',
                  '"${item.title}" saved for ${child.displayName}')
              : AppStrings.tr(context, 'تم إزالة "${item.title}"',
                  '"${item.title}" removed')),
          backgroundColor: const Color(0xFF81C784),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      // تراجع عند الفشل
      setState(() {
        _allContent = _allContent
            .map((c) => c.id == item.id
                ? c.copyWith(isSavedForChild: !nowSaved)
                : c)
            .toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.tr(context, 'تعذّر تنفيذ العملية، حاولي مجدداً',
              'Operation failed, please try again')),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ── تفاصيل المحتوى ──
  void _showContentDetails(ContentItem item) {
    final t = _typeInfo(item.type);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scroll) {
            return SingleChildScrollView(
              controller: scroll,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: ThemeColors.border(context),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    height: 130,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [t.color.withOpacity(0.7), t.color],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(t.icon, size: 64, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(item.title,
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                      ),
                      _pill(t.label(context), t.color),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (item.zoneName != null) ...[
                        const Icon(Icons.place, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(item.zoneName!,
                            style: TextStyle(color: ThemeColors.subtle(context))),
                        const SizedBox(width: 12),
                      ],
                      Text(AppStrings.tr(context, 'الصعوبة: ', 'Difficulty: ')),
                      _difficultyDots(item.difficulty),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (item.storyText.isNotEmpty) ...[
                    Text(AppStrings.tr(context, 'المحتوى', 'Content'),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(item.storyText,
                        style: TextStyle(
                            fontSize: 15,
                            height: 1.6,
                            color: ThemeColors.text(context))),
                    const SizedBox(height: 16),
                  ],
                  if (item.vocabulary.isNotEmpty)
                    _chipSection(AppStrings.tr(context, 'المفردات', 'Vocabulary'),
                        item.vocabulary, t.color),
                  if (item.facts.isNotEmpty)
                    _chipSection(AppStrings.tr(context, 'حقائق', 'Facts'),
                        item.facts, const Color(0xFF4DD0E1)),
                  if (item.values.isNotEmpty)
                    _chipSection(AppStrings.tr(context, 'القيم', 'Values'),
                        item.values, const Color(0xFF81C784)),
                  const SizedBox(height: 8),
                  if (_selectedChild != null)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: Icon(item.isSavedForChild
                            ? Icons.bookmark_remove
                            : Icons.bookmark_add),
                        label: Text(item.isSavedForChild
                            ? AppStrings.tr(
                                context,
                                'إزالة من محفوظات ${_selectedChild!.displayName}',
                                "Remove from ${_selectedChild!.displayName}'s saved")
                            : AppStrings.tr(context,
                                'حفظ لـ ${_selectedChild!.displayName}',
                                'Save for ${_selectedChild!.displayName}')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: item.isSavedForChild
                              ? Colors.grey
                              : const Color(0xFFFFB74D),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _toggleSave(item);
                        },
                      ),
                    ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ── عناصر مساعدة للواجهة ──
  Widget _pill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }

  Widget _difficultyDots(int difficulty) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return Padding(
          padding: const EdgeInsets.only(left: 2),
          child: Icon(
            Icons.circle,
            size: 8,
            color: i < difficulty
                ? const Color(0xFFFFB74D)
                : Colors.grey.shade300,
          ),
        );
      }),
    );
  }

  Widget _chipSection(String title, List<String> items, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: items
              .map((s) => Chip(
                    label: Text(s, style: const TextStyle(fontSize: 12)),
                    backgroundColor: color.withOpacity(0.12),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ))
              .toList(),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _buildEmpty(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 72, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: ThemeColors.subtle(context))),
        ],
      ),
    );
  }
}

class _TypeInfo {
  final String key;
  final String labelAr;
  final String labelEn;
  final IconData icon;
  final Color color;
  const _TypeInfo(this.key, this.labelAr, this.labelEn, this.icon, this.color);

  String label(BuildContext context) =>
      AppStrings.tr(context, labelAr, labelEn);
}
