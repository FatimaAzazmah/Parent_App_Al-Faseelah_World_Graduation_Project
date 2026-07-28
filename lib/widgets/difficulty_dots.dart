import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// ثلاث نقاط تُظهر مستوى صعوبة عنصر المحتوى من ١ إلى ٣،
/// وهو المستوى الذي تُختار على أساسه المعلومات المعروضة للطفل.
class DifficultyDots extends StatelessWidget {
  /// المستوى المعبّأ من النقاط؛ يُقصّ ضمن المدى 0..[totalLevels].
  final int level;

  /// عدد النقاط الكلي، ويطابق مستويات الصعوبة في قاعدة البيانات.
  static const int totalLevels = 3;

  /// لون النقطة المعبّأة، وهو نفس البرتقالي المستعمل لعلامات التمييز.
  static const Color _filled = Color(0xFFFFB74D);

  const DifficultyDots({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final filledCount = level.clamp(0, totalLevels);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < totalLevels; index++)
          Padding(
            padding: const EdgeInsets.only(left: 2),
            child: Icon(
              Icons.circle,
              size: 8,
              color: index < filledCount
                  ? _filled
                  : ThemeColors.border(context),
            ),
          ),
      ],
    );
  }
}
