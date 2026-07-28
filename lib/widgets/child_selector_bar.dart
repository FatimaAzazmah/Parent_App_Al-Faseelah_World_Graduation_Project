import 'package:flutter/material.dart';
import '../models/child_model.dart';
import '../utils/app_colors.dart';

/// شريط أفقي لاختيار الطفل النشط في الشاشة.
///
/// تشترك فيه الشاشات التي تعرض بيانات طفل واحد في كل مرّة، فيبقى شكل
/// الاختيار وسلوكه واحداً في التطبيق كلّه بدل تكرار الصف في كل شاشة.
class ChildSelectorBar extends StatelessWidget {
  /// الأطفال المعروضون؛ لا يظهر الشريط إن كانت القائمة فارغة.
  final List<Child> children;

  /// معرّف الطفل المختار حالياً.
  final String? selectedChildId;

  /// يُستدعى عند اختيار طفل آخر.
  final ValueChanged<Child> onChildSelected;

  /// نصّ اختياري يسبق الأسماء، مثل «الطفل:».
  final String? label;

  const ChildSelectorBar({
    super.key,
    required this.children,
    required this.selectedChildId,
    required this.onChildSelected,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    final accent = Theme.of(context).colorScheme.primary;

    return Container(
      color: ThemeColors.surface(context),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.child_care, size: 20, color: accent),
          const SizedBox(width: 8),
          if (label != null) ...[
            Text(label!, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: children.length,
                itemBuilder: (context, index) {
                  final child = children[index];
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: ChoiceChip(
                      selected: child.id == selectedChildId,
                      label: Text('${child.avatar} ${child.displayName}'),
                      selectedColor: accent.withValues(alpha: 0.25),
                      onSelected: (_) => onChildSelected(child),
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
}
