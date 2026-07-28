import 'package:flutter/material.dart';

/// عنوان صغير تحته مجموعة رقائق، لعرض قوائم قصيرة مثل المفردات
/// والمعلومات والقيم داخل تفاصيل عنصر المحتوى.
/// لا يظهر شيء إن كانت [items] فارغة، فيختصر الشرط على المستدعي.
class LabelledChipGroup extends StatelessWidget {
  final String title;
  final List<String> items;

  /// لون خلفية الرقائق، ويميّز نوع القائمة عن غيرها.
  final Color color;

  const LabelledChipGroup({
    super.key,
    required this.title,
    required this.items,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final item in items)
              Chip(
                label: Text(item, style: const TextStyle(fontSize: 12)),
                backgroundColor: color.withValues(alpha: 0.12),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
          ],
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}
