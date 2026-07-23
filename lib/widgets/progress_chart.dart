import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// رسم بياني للتقدم الأسبوعي
class WeeklyProgressChart extends StatelessWidget {
  final List<DayProgress> data;
  final double maxHeight;

  const WeeklyProgressChart({
    super.key,
    required this.data,
    this.maxHeight = 120,
  });

  @override
  Widget build(BuildContext context) {
    final maxMinutes = data.map((d) => d.minutes).reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: maxHeight + 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.map((day) {
          final percentage = maxMinutes > 0 ? day.minutes / maxMinutes : 0.0;
          return _buildBar(day, percentage);
        }).toList(),
      ),
    );
  }

  Widget _buildBar(DayProgress day, double percentage) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '${day.minutes}',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 32,
          height: maxHeight * percentage,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.skyBlue, AppColors.lightGreen],
              begin: Alignment.bottomCenter,
              end: Alignment. topCenter,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day.dayName. substring(0, 3),
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
        ),
      ],
    );
  }
}

/// بيانات يوم واحد
class DayProgress {
  final String dayName;
  final int minutes;
  final int activities;

  DayProgress({
    required this.dayName,
    required this.minutes,
    this.activities = 0,
  });
}

/// شريط تقدم مهارة
class SkillProgressBar extends StatelessWidget {
  final String skillName;
  final int progress;
  final String?  trend;
  final Color color;
  final IconData?  icon;

  const SkillProgressBar({
    super.key,
    required this. skillName,
    required this. progress,
    this.trend,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration:  BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  skillName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              if (trend != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical:  4),
                  decoration: BoxDecoration(
                    color: AppColors.lightGreen.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        trend! . startsWith('+') ? Icons.trending_up : Icons.trending_flat,
                        size: 14,
                        color: trend! .startsWith('+')
                            ? const Color(0xFF2E7D32)
                            : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        trend!,
                        style: TextStyle(
                          fontSize: 11,
                          color: trend!.startsWith('+')
                              ? const Color(0xFF2E7D32)
                              : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Text(
                '$progress%',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

/// دائرة تقدم
class CircularProgress extends StatelessWidget {
  final double progress;
  final String label;
  final Color color;
  final double size;

  const CircularProgress({
    super.key,
    required this.progress,
    required this.label,
    required this.color,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value:  progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
              strokeWidth: 8,
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: size * 0.2,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: size * 0.1,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}