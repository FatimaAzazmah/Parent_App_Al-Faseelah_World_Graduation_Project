import 'package:flutter/material.dart';

/// شارة صغيرة ملوّنة تُعرض بجانب العنوان لبيان تصنيف أو منطقة.
/// الخلفية مشتقّة من [color] بشفافية خفيفة لتبقى مقروءة في الوضعين.
class TagPill extends StatelessWidget {
  final String text;
  final Color color;

  const TagPill({
    super.key,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
