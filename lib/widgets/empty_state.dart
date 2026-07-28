import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// حالة فراغ موحّدة: أيقونة باهتة ورسالة تشرح للأهل سبب خلوّ الشاشة.
///
/// الرسالة تصل مترجَمة من الشاشة المستدعية، فلا يحتوي هذا المكوّن أي نصّ.
class EmptyState extends StatelessWidget {
  /// أيقونة تعبّر عن نوع المحتوى الغائب.
  final IconData icon;

  /// الرسالة المعروضة تحت الأيقونة.
  final String message;

  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 72, color: ThemeColors.faint(context)),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: ThemeColors.subtle(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
