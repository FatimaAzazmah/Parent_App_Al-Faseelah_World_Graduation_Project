import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// عرض صورة الطفل الرمزية
class ChildAvatar extends StatelessWidget {
  final String avatar;
  final double size;
  final Color?  backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final VoidCallback?  onTap;

  const ChildAvatar({
    super.key,
    required this.avatar,
    this.size = 50,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 2,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.skyBlue. withOpacity(0.15),
          shape: BoxShape.circle,
          border: borderColor != null
              ? Border.all(color: borderColor!, width:  borderWidth)
              : null,
        ),
        child: Center(
          child: Text(
            avatar,
            style: TextStyle(fontSize: size * 0.5),
          ),
        ),
      ),
    );
  }
}

/// اختيار الصورة الرمزية
class AvatarPicker extends StatelessWidget {
  final String selectedAvatar;
  final Function(String) onAvatarSelected;
  final List<String> avatars;

  const AvatarPicker({
    super.key,
    required this. selectedAvatar,
    required this.onAvatarSelected,
    this.avatars = const ['👦', '👧', '🧒', '👶', '🧒🏻', '👦🏻', '👧🏻', '👦🏽', '👧🏽'],
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // الصورة المختارة
        ChildAvatar(
          avatar: selectedAvatar,
          size: 100,
          borderColor: AppColors.skyBlue,
          borderWidth: 3,
        ),
        const SizedBox(height: 16),
        const Text(
          'اختر صورة رمزية',
          style:  TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
        ),
        const SizedBox(height: 12),
        // قائمة الصور الرمزية
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: avatars.map((avatar) {
            final isSelected = avatar == selectedAvatar;
            return GestureDetector(
              onTap: () => onAvatarSelected(avatar),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.skyBlue.withOpacity(0.2)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? Border.all(color: AppColors.skyBlue, width: 2)
                      : null,
                ),
                child: Text(avatar, style: const TextStyle(fontSize: 28)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// بطاقة الطفل مع الصورة الرمزية
class ChildCard extends StatelessWidget {
  final String name;
  final String avatar;
  final int age;
  final String?  subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const ChildCard({
    super. key,
    required this.name,
    required this.avatar,
    required this.age,
    this. subtitle,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child:  Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ChildAvatar(
                avatar: avatar,
                size: 60,
                backgroundColor: AppColors.skyBlue. withOpacity(0.15),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle ?? '$age سنوات',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
              if (trailing == null)
                Icon(Icons.chevron_left, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}