import 'package:flutter/material.dart';
import '../utils/app_strings.dart';
import '../utils/app_colors.dart';
import '../services/child_service.dart';
import '../models/child_model.dart';

class ChildProfileScreen extends StatefulWidget {
  const ChildProfileScreen({super.key});

  @override
  State<ChildProfileScreen> createState() => _ChildProfileScreenState();
}

class _ChildProfileScreenState extends State<ChildProfileScreen> {
  final ChildService _childService = ChildService();
  final TextEditingController _parentNotesController = TextEditingController();
  List<Child> _children = [];
  bool _isLoading = true;
  bool _savingParentNotes = false;
  int selectedChildIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  @override
  void dispose() {
    _parentNotesController.dispose();
    super.dispose();
  }

  void _syncParentNotesField() {
    if (_children.isEmpty) {
      _parentNotesController.text = '';
      return;
    }
    final idx = selectedChildIndex.clamp(0, _children.length - 1);
    _parentNotesController.text = _children[idx].parentNotes ?? '';
  }

  Future<void> _loadChildren() async {
    final children = await _childService.getChildren();
    if (mounted) {
      setState(() {
        _children = children;
        _isLoading = false;
        if (selectedChildIndex >= _children.length) {
          selectedChildIndex = 0;
        }
      });
      _syncParentNotesField();
    }
  }

  Future<void> _saveParentNotes(Child child) async {
    final text = _parentNotesController.text.trim();
    final updated = text.isEmpty
        ? child.copyWith(clearParentNotes: true)
        : child.copyWith(parentNotes: text);

    setState(() => _savingParentNotes = true);
    final result = await _childService.updateChild(updated);
    if (!mounted) return;
    setState(() => _savingParentNotes = false);

    if (result.success) {
      setState(() {
        final i = _children.indexWhere((c) => c.id == child.id);
        if (i != -1) {
          _children[i] = updated;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.parentNotesSaved(context))),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message)),
      );
    }
  }

  Map<String, dynamic> _childToMap(Child child) {
    return {
      'id': child.id,
      'name': child.displayName,
      'age': child.age,
      'avatar': child.avatar,
      'gender': child.gender,
      'rfidId': child.rfidId,
      'interests': child.interests,
      'learningProgress': {
        'language': 50,
        'math': 50,
        'social': 50,
        'creativity': 50,
      },
      'dailyUsage': 0,
      'totalDays': 0,
      'achievements': 0,
      'isActive': true,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(AppStrings.childProfileTitle(context))),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_children.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(AppStrings.childProfileTitle(context))),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.child_care, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              Text(AppStrings.noChildrenRegistered(context),
                  style: const TextStyle(fontSize: 18)),
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

    if (selectedChildIndex >= _children.length) {
      selectedChildIndex = 0;
    }

    final child = _childToMap(_children[selectedChildIndex]);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.childProfileTitle(context)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              _showEditChildDialog(context, _children[selectedChildIndex]);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_children.length > 1) _buildChildSelector(),
              const SizedBox(height: 16),
              _buildProfileCard(child),
              const SizedBox(height: 24),
              _buildInterestsSection(child),
              const SizedBox(height: 24),
              _buildParentNotesSection(context, _children[selectedChildIndex]),
              const SizedBox(height: 24),
              _buildLearningProgressSection(child),
              const SizedBox(height: 24),
              _buildEducationalSettings(context),
              const SizedBox(height: 24),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(context, '/add-child');
          _loadChildren();
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        icon: const Icon(Icons.add),
        label: Text(AppStrings.addChild(context)),
      ),
    );
  }

  String _skillLabel(BuildContext context, String key) {
    switch (key) {
      case 'language':
        return AppStrings.skillLanguage(context);
      case 'math':
        return AppStrings.skillMath(context);
      case 'social':
        return AppStrings.skillSocial(context);
      case 'creativity':
        return AppStrings.skillCreativity(context);
      default:
        return key;
    }
  }

  Widget _buildChildSelector() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        reverse: true,
        itemCount: _children.length,
        itemBuilder: (context, index) {
          final child = _children[index];
          final isSelected = index == selectedChildIndex;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedChildIndex = index;
              });
              _parentNotesController.text = child.parentNotes ?? '';
            },
            child: Container(
              width: 80,
              margin: const EdgeInsets.only(left: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    child.avatar,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    child.displayName,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : ThemeColors.subtle(context),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF90EE90),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileCard(Map<String, dynamic> child) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  backgroundColor:
                      Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                  radius: 50,
                  child: Text(
                    child['avatar'],
                    style: const TextStyle(fontSize: 50),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF90EE90),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              child['name'],
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${child['age']} ${AppStrings.yearsUnit(context)} • ${AppStrings.genderLabelFromStored(context, child['gender'].toString())}',
              style: TextStyle(
                fontSize: 16,
                color: ThemeColors.subtle(context),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFBA68C8).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.nfc, size: 16, color: Color(0xFFBA68C8)),
                  const SizedBox(width: 6),
                  Text(
                    AppStrings.rfidSectionTitle(context),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFBA68C8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    (child['rfidId'] as String?)?.isNotEmpty == true
                        ? child['rfidId']
                        : AppStrings.rfidNotAssigned(context),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: (child['rfidId'] as String?)?.isNotEmpty == true
                          ? const Color(0xFFBA68C8)
                          : ThemeColors.faint(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(
                  context: context,
                  icon: Icons.timer,
                  value: '${child['dailyUsage']}',
                  label: AppStrings.minutesPerDayStat(context),
                  color: const Color(0xFF87CEEB),
                ),
                _buildStatItem(
                  context: context,
                  icon: Icons.emoji_events,
                  value: '${child['achievements']}',
                  label: AppStrings.achievementStat(context),
                  color: const Color(0xFFFFB74D),
                ),
                _buildStatItem(
                  context: context,
                  icon: Icons.calendar_today,
                  value: '${child['totalDays']}',
                  label: AppStrings.dayStat(context),
                  color: const Color(0xFF90EE90),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required BuildContext context,
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: ThemeColors.subtle(context),
          ),
        ),
      ],
    );
  }

  Widget _buildInterestsSection(Map<String, dynamic> child) {
    final interests = child['interests'] as List<dynamic>;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.interests(context),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                _showEditInterestsDialog(context, child);
              },
              icon: const Icon(Icons.edit, size: 16),
              label: Text(AppStrings.edit(context)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        interests.isEmpty
            ? Text(AppStrings.noInterestsSet(context),
                style: const TextStyle(color: Colors.grey))
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: interests.map((interest) {
                  return Chip(
                    backgroundColor:
                        Theme.of(context).colorScheme.secondary.withValues(alpha: 0.15),
                    label: Text(
                      AppStrings.interestDisplayLabel(
                          context, interest.toString()),
                    ),
                    avatar: const Icon(
                      Icons.favorite,
                      size: 16,
                      color: Color(0xFF90EE90),
                    ),
                  );
                }).toList(),
              ),
      ],
    );
  }

  Widget _buildParentNotesSection(BuildContext context, Child child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.parentNotesSectionTitle(context),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.parentNotesSectionHelper(context),
          style: TextStyle(fontSize: 13, color: ThemeColors.subtle(context)),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _parentNotesController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: AppStrings.parentNotesHint(context),
            border: const OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed:
                _savingParentNotes ? null : () => _saveParentNotes(child),
            child: _savingParentNotes
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(AppStrings.parentNotesSave(context)),
          ),
        ),
      ],
    );
  }

  Widget _buildLearningProgressSection(Map<String, dynamic> child) {
    final progress = child['learningProgress'] as Map<String, int>;
    final skillColors = {
      'language': const Color(0xFF87CEEB),
      'math': const Color(0xFFFFB74D),
      'social': const Color(0xFF90EE90),
      'creativity': const Color(0xFFBA68C8),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.learningProgress(context),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: progress.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _skillLabel(context, entry.key),
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            '${entry.value}%',
                            style: TextStyle(
                              color: skillColors[entry.key],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: entry.value / 100,
                          backgroundColor: ThemeColors.fill(context),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            skillColors[entry.key] ?? Colors.blue,
                          ),
                          minHeight: 10,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEducationalSettings(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.educationalSettings(context),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF87CEEB).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.timer, color: Color(0xFF87CEEB)),
                ),
                title: Text(AppStrings.dailyUsageTitle(context)),
                subtitle: Text(AppStrings.dailyUsageSubtitle(context)),
                trailing: const Icon(Icons.chevron_left),
                onTap: () {},
              ),
              const Divider(height: 1),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF90EE90).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.content_copy, color: Color(0xFF90EE90)),
                ),
                title: Text(AppStrings.allowedContentTitle(context)),
                subtitle: Text(AppStrings.allowedContentSubtitle(context)),
                trailing: const Icon(Icons.chevron_left),
                onTap: () {},
              ),
              const Divider(height: 1),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB74D).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.school, color: Color(0xFFFFB74D)),
                ),
                title: Text(AppStrings.learningPathTitle(context)),
                subtitle: Text(AppStrings.learningPathSubtitle(context)),
                trailing: const Icon(Icons.chevron_left),
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/progress');
                },
                icon: const Icon(Icons.assessment),
                label: Text(AppStrings.reportsButton(context)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/library');
                },
                icon: const Icon(Icons.library_books),
                label: Text(AppStrings.contentButton(context)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showDeleteConfirmDialog(context),
            icon: const Icon(Icons.delete, color: Colors.red),
            label: Text(AppStrings.deleteChildProfile(context),
                style: const TextStyle(color: Colors.red)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _deleteChild() async {
    if (_children.isEmpty || selectedChildIndex >= _children.length) return;
    
    final childToDelete = _children[selectedChildIndex];
    final result = await _childService.deleteChild(childToDelete.id);
    
    if (mounted) {
      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                AppStrings.deleteChildSuccess(context, childToDelete.displayName)),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          selectedChildIndex = 0;
        });
        _loadChildren();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeleteConfirmDialog(BuildContext context) {
    if (_children.isEmpty || selectedChildIndex >= _children.length) return;
    
    final childName = _children[selectedChildIndex].displayName;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.confirmDelete(context)),
        content:
            Text(AppStrings.confirmDeleteChildBody(context, childName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.cancel(context)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteChild();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(AppStrings.delete(context),
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditChildDialog(BuildContext context, Child currentChild) {
    final nameController = TextEditingController(text: currentChild.name);
    final nameEnController =
        TextEditingController(text: currentChild.nameEn ?? '');
    final ageController =
        TextEditingController(text: currentChild.age.toString());
    final rfidController =
        TextEditingController(text: currentChild.rfidId ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
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
                AppStrings.editChildTitle(context),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: AppStrings.childNameLabel(context),
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameEnController,
                textDirection: TextDirection.ltr,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: AppStrings.tr(context, 'الاسم بالإنجليزية',
                      'Name in English'),
                  hintText: AppStrings.tr(
                      context, 'اختياري', 'Optional'),
                  prefixIcon: const Icon(Icons.translate),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: AppStrings.childAgeLabel(context),
                  prefixIcon: const Icon(Icons.cake),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: rfidController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: AppStrings.rfidLabel(context),
                  hintText: AppStrings.rfidHint(context),
                  prefixIcon: const Icon(Icons.nfc),
                  helperText: AppStrings.rfidHelperText(context),
                  helperMaxLines: 2,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(AppStrings.cancel(context)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final name = nameController.text.trim();
                        final nameEnText = nameEnController.text.trim();
                        final ageParsed =
                            int.tryParse(ageController.text.trim()) ??
                                currentChild.age;
                        final rfidText = rfidController.text.trim();
                        final updated = currentChild.copyWith(
                          name:
                              name.isEmpty ? currentChild.name : name,
                          nameEn: nameEnText.isEmpty ? null : nameEnText,
                          clearNameEn: nameEnText.isEmpty,
                          age: ageParsed,
                          rfidId: rfidText.isEmpty ? null : rfidText,
                          clearRfidId: rfidText.isEmpty,
                        );
                        final result =
                            await _childService.updateChild(updated);
                        if (!context.mounted) return;
                        Navigator.pop(context);
                        if (result.success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    AppStrings.changesSaved(context))),
                          );
                          _loadChildren();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(result.message)),
                          );
                        }
                      },
                      child: Text(AppStrings.save(context)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    ).whenComplete(() {
      nameController.dispose();
      ageController.dispose();
      rfidController.dispose();
    });
  }

  void _showEditInterestsDialog(BuildContext context, Map<String, dynamic> child) {
    final allInterests = [
      'قصص الحيوانات',
      'الألوان',
      'القرآن',
      'الأرقام',
      'الحروف',
      'الفضاء',
      'الطبيعة',
      'الرياضة',
      'الفن',
      'العلوم',
    ];

    List<String> selectedInterests = List<String>.from(
      (child['interests'] as List<dynamic>).map((e) => e.toString()),
    );

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppStrings.selectInterestsTitle(context),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: allInterests.map((interest) {
                      final isSelected = selectedInterests.contains(interest);
                      return FilterChip(
                        selected: isSelected,
                        label: Text(
                            AppStrings.interestDisplayLabel(context, interest)),
                        onSelected: (selected) {
                          setModalState(() {
                            if (selected) {
                              selectedInterests.add(interest);
                            } else {
                              selectedInterests.remove(interest);
                            }
                          });
                        },
                        selectedColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.3),
                        checkmarkColor: Theme.of(context).colorScheme.primary,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        child['interests'] = selectedInterests;
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: Text(AppStrings.save(context)),
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
