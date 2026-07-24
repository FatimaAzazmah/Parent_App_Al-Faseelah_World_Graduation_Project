import 'package:flutter/material.dart';

import '../models/behavior_goal_model.dart';
import '../models/child_model.dart';
import '../services/behavior_goal_service.dart';
import '../services/child_service.dart';
import '../utils/app_strings.dart';
import '../utils/app_colors.dart';

class BehaviorGoalsScreen extends StatefulWidget {
  const BehaviorGoalsScreen({super.key});

  @override
  State<BehaviorGoalsScreen> createState() => _BehaviorGoalsScreenState();
}

class _BehaviorGoalsScreenState extends State<BehaviorGoalsScreen> {
  final BehaviorGoalService _goalService = BehaviorGoalService();
  final ChildService _childService = ChildService();

  List<Child> _children = [];
  List<BehaviorGoal> _goals = [];
  int _selectedChildIndex = 0;
  bool _isLoading = true;

  static const Color skyBlue = Color(0xFF87CEEB);
  static const Color lightGreen = Color(0xFF90EE90);
  static const Color orange = Color(0xFFFFB74D);
  static const Color purple = Color(0xFFBA68C8);
  static const Color cyan = Color(0xFF4DD0E1);

  final List<Map<String, dynamic>> _zones = [
    {'key': 'منطقة القصص', 'icon': Icons.auto_stories, 'color': skyBlue},
    {'key': 'منطقة الأرقام', 'icon': Icons.calculate, 'color': lightGreen},
    {'key': 'منطقة المزرعة', 'icon': Icons.agriculture, 'color': orange},
    {'key': 'منطقة القيم', 'icon': Icons.volunteer_activism, 'color': purple},
    {'key': 'منطقة الإبداع', 'icon': Icons.brush, 'color': cyan},
    {
      'key': 'المنطقة الدينية',
      'icon': Icons.menu_book,
      'color': const Color(0xFF81C784)
    },
    {
      'key': 'منطقة الحيوانات',
      'icon': Icons.pets,
      'color': const Color(0xFFFF8A65)
    },
  ];

  final List<String> _behaviorTypes = [
    'إكمال الأنشطة',
    'التفاعل الاجتماعي',
    'الالتزام بالوقت',
    'حل المشكلات',
    'التعاون',
    'الصبر والمثابرة',
    'الإبداع',
    'الاستماع الجيد',
  ];

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
        await _loadGoals(children[0].id);
      } else {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadGoals(String childId) async {
    setState(() => _isLoading = true);
    final goals = await _goalService.getGoalsForChild(childId);
    if (mounted) {
      setState(() {
        _goals = goals;
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
        title: Text(AppStrings.behaviorGoalsTitle(context)),
      ),
      floatingActionButton: _children.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _showAddGoalDialog(),
              icon: const Icon(Icons.add),
              label: Text(AppStrings.behaviorNewGoal(context)),
              backgroundColor: skyBlue,
            )
          : null,
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
                      const SizedBox(height: 20),
                      _buildGoalsSummary(),
                      const SizedBox(height: 24),
                      _buildGoalsList(),
                      const SizedBox(height: 80),
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
          Text(AppStrings.behaviorNoChildrenTitle(context),
              style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Text(AppStrings.behaviorNoChildrenSubtitle(context),
              style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () async {
              await Navigator.pushNamed(context, '/add-child');
              _loadData();
            },
            icon: const Icon(Icons.add),
            label: Text(AppStrings.behaviorAddChild(context)),
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
            const Icon(Icons.child_care, color: skyBlue),
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
                      _loadGoals(_children[value!].id);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsSummary() {
    final completedGoals = _goals.where((g) => g.isCompleted).length;
    final activeGoals = _goals.where((g) => !g.isCompleted).length;
    final totalGoals = _goals.length;

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            icon: Icons.flag,
            value: '$totalGoals',
            label: AppStrings.behaviorStatTotal(context),
            color: skyBlue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            icon: Icons.pending_actions,
            value: '$activeGoals',
            label: AppStrings.behaviorStatActive(context),
            color: orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            icon: Icons.check_circle,
            value: '$completedGoals',
            label: AppStrings.behaviorStatCompleted(context),
            color: lightGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
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
                color: color.withOpacity(0.15),
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
              style: TextStyle(fontSize: 11, color: ThemeColors.subtle(context)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsList() {
    if (_goals.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.flag_outlined, size: 60, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  AppStrings.behaviorEmptyTitle(context),
                  style: TextStyle(fontSize: 18, color: ThemeColors.subtle(context)),
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.behaviorEmptyHint(context),
                  style: TextStyle(fontSize: 14, color: ThemeColors.faint(context)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final activeGoals = _goals.where((g) => !g.isCompleted).toList();
    final completedGoals = _goals.where((g) => g.isCompleted).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (activeGoals.isNotEmpty) ...[
          Text(
            AppStrings.behaviorActiveSection(context),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...activeGoals.map((goal) => _buildGoalCard(goal)),
          const SizedBox(height: 24),
        ],
        if (completedGoals.isNotEmpty) ...[
          Row(
            children: [
              const Icon(Icons.check_circle, color: lightGreen, size: 20),
              const SizedBox(width: 8),
              Text(
                AppStrings.behaviorCompletedSection(context),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...completedGoals.map((goal) => _buildGoalCard(goal)),
        ],
      ],
    );
  }

  Widget _buildGoalCard(BehaviorGoal goal) {
    final zoneData = _zones.firstWhere(
      (z) => z['key'] == goal.zone,
      orElse: () => {'key': goal.zone, 'icon': Icons.flag, 'color': skyBlue},
    );
    final color = zoneData['color'] as Color;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: goal.isCompleted
            ? const BorderSide(color: lightGreen, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(zoneData['icon'] as IconData, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppStrings.behaviorZoneLabel(context, goal.zone),
                        style: TextStyle(fontSize: 12, color: ThemeColors.subtle(context)),
                      ),
                    ],
                  ),
                ),
                if (!goal.isCompleted)
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'delete') {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title:
                                Text(AppStrings.behaviorDeleteGoalTitle(ctx)),
                            content:
                                Text(AppStrings.behaviorDeleteGoalBody(ctx)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: Text(AppStrings.cancel(ctx)),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red),
                                child: Text(AppStrings.delete(ctx)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await _goalService.deleteGoal(goal.id);
                          _loadGoals(_selectedChild!.id);
                        }
                      } else if (value == 'increment') {
                        await _goalService.updateGoalProgress(
                            goal.id, goal.currentCount + 1);
                        _loadGoals(_selectedChild!.id);
                      }
                    },
                    itemBuilder: (ctx) => [
                      PopupMenuItem(
                        value: 'increment',
                        child: Row(
                          children: [
                            const Icon(Icons.add_circle, color: lightGreen),
                            const SizedBox(width: 8),
                            Text(AppStrings.behaviorProgressPlusOne(ctx)),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(Icons.delete, color: Colors.red),
                            const SizedBox(width: 8),
                            Text(AppStrings.delete(ctx)),
                          ],
                        ),
                      ),
                    ],
                  )
                else
                  const Icon(Icons.check_circle, color: lightGreen, size: 28),
              ],
            ),
            if (goal.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                goal.description,
                style: TextStyle(fontSize: 13, color: ThemeColors.subtle(context)),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    AppStrings.behaviorTypeLabel(context, goal.targetBehavior),
                    style: const TextStyle(fontSize: 11, color: purple),
                  ),
                ),
                const Spacer(),
                Text(
                  '${goal.currentCount} / ${goal.targetCount}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: goal.progressPercent,
                backgroundColor: ThemeColors.fill(context),
                valueColor: AlwaysStoppedAnimation<Color>(
                  goal.isCompleted ? lightGreen : color,
                ),
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddGoalDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final targetController = TextEditingController(text: '5');
    String selectedZone = _zones[0]['key'] as String;
    String selectedBehavior = _behaviorTypes[0];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                    const SizedBox(height: 20),
                    Text(
                      AppStrings.behaviorAddGoalTitle(context),
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: AppStrings.behaviorFieldGoalTitle(context),
                        hintText:
                            AppStrings.behaviorFieldGoalTitleHint(context),
                        prefixIcon: const Icon(Icons.flag),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descController,
                      decoration: InputDecoration(
                        labelText: AppStrings.behaviorFieldDescription(context),
                        hintText:
                            AppStrings.behaviorFieldDescriptionHint(context),
                        prefixIcon: const Icon(Icons.description),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    Text(AppStrings.behaviorZoneSection(context),
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _zones.map((zone) {
                        final key = zone['key'] as String;
                        final isSelected = selectedZone == key;
                        return FilterChip(
                          selected: isSelected,
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(zone['icon'] as IconData, size: 16,
                                  color: isSelected ? Colors.white : zone['color'] as Color),
                              const SizedBox(width: 4),
                              Text(
                                AppStrings.behaviorZoneLabel(context, key),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isSelected ? Colors.white : null,
                                ),
                              ),
                            ],
                          ),
                          selectedColor: zone['color'] as Color,
                          onSelected: (selected) {
                            setModalState(() {
                              selectedZone = key;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Text(AppStrings.behaviorTypeSection(context),
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: ThemeColors.softFill(context),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedBehavior,
                          isExpanded: true,
                          items: _behaviorTypes.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(
                                  AppStrings.behaviorTypeLabel(context, type)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setModalState(() {
                              selectedBehavior = value!;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: targetController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: AppStrings.behaviorFieldTargetCount(context),
                        hintText:
                            AppStrings.behaviorFieldTargetCountHint(context),
                        prefixIcon: const Icon(Icons.numbers),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          if (titleController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(AppStrings.behaviorTitleRequired(
                                      context))),
                            );
                            return;
                          }

                          final goal = BehaviorGoal(
                            id: '',
                            childId: _selectedChild!.id,
                            parentId: '',
                            title: titleController.text.trim(),
                            description: descController.text.trim(),
                            zone: selectedZone,
                            targetBehavior: selectedBehavior,
                            targetCount: int.tryParse(targetController.text) ?? 5,
                            createdAt: DateTime.now(),
                          );

                          final result = await _goalService.addGoal(goal);
                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(result.message),
                                backgroundColor: result.success ? lightGreen : Colors.red,
                              ),
                            );
                            if (result.success) {
                              _loadGoals(_selectedChild!.id);
                            }
                          }
                        },
                        icon: const Icon(Icons.save),
                        label: Text(AppStrings.behaviorSaveGoal(context)),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
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
}
