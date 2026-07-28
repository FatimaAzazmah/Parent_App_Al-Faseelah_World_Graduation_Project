import 'package:flutter/material.dart';

import '../utils/app_strings.dart';
import '../utils/app_colors.dart';

class ParentalControlsScreen extends StatefulWidget {
  const ParentalControlsScreen({super. key});

  @override
  State<ParentalControlsScreen> createState() => _ParentalControlsScreenState();
}

class _ParentalControlsScreenState extends State<ParentalControlsScreen> {
  // إعدادات الوقت
  double _dailyTimeLimit = 45;
  bool _weekendExtraTime = true;
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 20, minute: 0);
  List<bool> _activeDays = [true, true, true, true, true, true, true];

  final Map<String, bool> _contentCategories = Map<String, bool>.fromEntries(
    AppStrings.parentalInitialContentEntries(),
  );

  final Map<String, bool> _skillsFocus = Map<String, bool>.fromEntries(
    AppStrings.parentalInitialSkillEntries(),
  );

  // إعدادات الأمان
  bool _requirePinForSettings = true;
  bool _requirePinForPurchases = true;
  bool _allowNotifications = true;
  bool _allowSoundEffects = true;
  bool _allowBackgroundMusic = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.parentalTitle(context)),
        actions: [
          TextButton.icon(
            onPressed: _saveSettings,
            icon: const Icon(Icons.save, color: Colors.white),
            label: Text(
              AppStrings.parentalSaveAppBar(context),
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTimeLimitSection(),
            const SizedBox(height: 24),
            _buildScheduleSection(),
            const SizedBox(height: 24),
            _buildContentFilterSection(),
            const SizedBox(height: 24),
            _buildSkillsFocusSection(),
            const SizedBox(height: 24),
            _buildSecuritySection(),
            const SizedBox(height: 24),
            _buildNotificationSection(),
            const SizedBox(height: 24),
            _buildSoundSection(),
            const SizedBox(height: 24),
            _buildResetSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors. grey[600],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeLimitSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              title: AppStrings.parentalDailyLimitTitle(context),
              icon: Icons.timer,
              color: const Color(0xFF87CEEB),
              subtitle: AppStrings.parentalDailyLimitSubtitle(context),
            ),
            const SizedBox(height:  24),

            // عرض الوقت المحدد
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:  [
                Column(
                  crossAxisAlignment:  CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.minutesCount(
                          context, _dailyTimeLimit.round()),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF87CEEB),
                      ),
                    ),
                    Text(
                      AppStrings.parentalHoursPerDayLine(
                        context,
                        (_dailyTimeLimit / 60).toStringAsFixed(1),
                      ),
                      style: TextStyle(
                        color: ThemeColors.subtle(context),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF90EE90).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFF90EE90),
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        AppStrings.parentalLimitEnabledBadge(context),
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // شريط التحكم
            SliderTheme(
              data:  SliderTheme.of(context).copyWith(
                activeTrackColor: const Color(0xFF87CEEB),
                inactiveTrackColor: const Color(0xFF87CEEB).withValues(alpha: 0.2),
                thumbColor: const Color(0xFF87CEEB),
                overlayColor: const Color(0xFF87CEEB).withValues(alpha: 0.1),
                trackHeight: 8,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
              ),
              child: Slider(
                value: _dailyTimeLimit,
                min: 15,
                max: 180,
                divisions: 33,
                onChanged: (value) {
                  setState(() {
                    _dailyTimeLimit = value;
                  });
                },
              ),
            ),

            // تسميات الشريط
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppStrings.parentalSlider15m(context),
                      style: TextStyle(color: ThemeColors.faint(context), fontSize: 12)),
                  Text(AppStrings.parentalSlider1h(context),
                      style: TextStyle(color: ThemeColors.faint(context), fontSize: 12)),
                  Text(AppStrings.parentalSlider2h(context),
                      style: TextStyle(color: ThemeColors.faint(context), fontSize: 12)),
                  Text(AppStrings.parentalSlider3h(context),
                      style: TextStyle(color: ThemeColors.faint(context), fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // وقت إضافي في العطلة
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ThemeColors.softFill(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child:  SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  AppStrings.parentalWeekendExtraTitle(context),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  AppStrings.parentalWeekendExtraSubtitle(context),
                  style: TextStyle(color: ThemeColors.subtle(context), fontSize: 12),
                ),
                value: _weekendExtraTime,
                activeThumbColor: const Color(0xFF87CEEB),
                onChanged: (value) {
                  setState(() {
                    _weekendExtraTime = value;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              title: AppStrings.parentalScheduleTitle(context),
              icon: Icons.schedule,
              color: const Color(0xFF90EE90),
              subtitle: AppStrings.parentalScheduleSubtitle(context),
            ),
            const SizedBox(height: 24),

            // أوقات الاستخدام
            Row(
              children: [
                Expanded(
                  child: _buildTimeSelector(
                    AppStrings.parentalStartTime(context),
                    _startTime,
                    Icons.play_circle_outline,
                    (time) => setState(() => _startTime = time),
                  ),
                ),
                const SizedBox(width:  16),
                Container(
                  padding: const EdgeInsets.all(8),
                  child: const Icon(Icons.arrow_forward, color: Colors.grey),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTimeSelector(
                    AppStrings.parentalEndTime(context),
                    _endTime,
                    Icons.stop_circle_outlined,
                    (time) => setState(() => _endTime = time),
                  ),
                ),
              ],
            ),

            const SizedBox(height:  24),

            // أيام الاستخدام
            Text(
              AppStrings.parentalAllowedDays(context),
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children:  List.generate(7, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _activeDays[index] = !_activeDays[index];
                    });
                  },
                  child: Tooltip(
                    message:
                        AppStrings.parentalWeekDayTooltip(context, index),
                    child: AnimatedContainer(
                      duration:  const Duration(milliseconds: 200),
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: _activeDays[index]
                            ? const Color(0xFF90EE90)
                            : ThemeColors.fill(context),
                        shape: BoxShape.circle,
                        boxShadow: _activeDays[index]
                            ? [
                          BoxShadow(
                            color: const Color(0xFF90EE90).withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          AppStrings.parentalWeekDayLetters(context)[index],
                          style: TextStyle(
                            color: _activeDays[index] ? Colors.white : ThemeColors.subtle(context),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                AppStrings.parentalDaysEnabledCount(
                  context,
                  _activeDays.where((d) => d).length,
                ),
                style: TextStyle(color: ThemeColors.faint(context), fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector(
      String label,
      TimeOfDay time,
      IconData icon,
      Function(TimeOfDay) onChanged,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: ThemeColors.subtle(context), fontSize: 12),
        ),
        const SizedBox(height:  8),
        InkWell(
          onTap: () async {
            final selectedTime = await showTimePicker(
              context: context,
              initialTime: time,
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme. light(
                      primary: Color(0xFF87CEEB),
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (selectedTime != null) {
              onChanged(selectedTime);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets. all(14),
            decoration: BoxDecoration(
              color: ThemeColors.softFill(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ThemeColors.border(context)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 20, color: const Color(0xFF90EE90)),
                const SizedBox(width: 8),
                Text(
                  time.format(context),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentFilterSection() {
    return Card(
      child:  Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment. start,
          children: [
            _buildSectionHeader(
              title: AppStrings.parentalContentFilterTitle(context),
              icon: Icons.filter_list,
              color: const Color(0xFFFFB74D),
              subtitle: AppStrings.parentalContentFilterSubtitle(context),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _contentCategories.entries.map((entry) {
                return FilterChip(
                  selected: entry.value,
                  label: Text(
                      AppStrings.parentalContentLabel(context, entry.key)),
                  onSelected: (selected) {
                    setState(() {
                      _contentCategories[entry.key] = selected;
                    });
                  },
                  selectedColor: const Color(0xFFFFB74D).withValues(alpha: 0.2),
                  checkmarkColor: const Color(0xFFFFB74D),
                  avatar: entry.value
                      ? null
                      : const Icon(Icons.block, size: 16, color: Colors.grey),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed:  () {
                    setState(() {
                      _contentCategories. updateAll((key, value) => true);
                    });
                  },
                  child: Text(AppStrings.parentalSelectAll(context)),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _contentCategories.updateAll((key, value) => false);
                    });
                  },
                  child: Text(AppStrings.parentalDeselectAll(context)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsFocusSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              title: AppStrings.parentalSkillsTitle(context),
              icon: Icons.psychology,
              color: const Color(0xFFBA68C8),
              subtitle: AppStrings.parentalSkillsSubtitle(context),
            ),
            const SizedBox(height: 20),
            ..._skillsFocus.entries.map((entry) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: entry.value
                      ? const Color(0xFFBA68C8).withValues(alpha: 0.05)
                      : ThemeColors.softFill(context),
                  borderRadius: BorderRadius.circular(10),
                ),
                child:  CheckboxListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  title: Text(
                    AppStrings.parentalSkillLabel(context, entry.key),
                    style: TextStyle(
                      fontWeight:
                          entry.value ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                  value: entry.value,
                  activeColor: const Color(0xFFBA68C8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _skillsFocus[entry.key] = value!;
                    });
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets. all(16),
        child: Column(
          crossAxisAlignment:  CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              title: AppStrings.parentalSecurityTitle(context),
              icon: Icons.security,
              color: Colors.red,
              subtitle: AppStrings.parentalSecuritySubtitle(context),
            ),
            const SizedBox(height:  20),

            // رمز PIN للإعدادات
            _buildSecuritySwitch(
              title: AppStrings.parentalPinSettingsTitle(context),
              subtitle: AppStrings.parentalPinSettingsSubtitle(context),
              value: _requirePinForSettings,
              icon: Icons.lock,
              onChanged: (value) {
                setState(() {
                  _requirePinForSettings = value;
                });
              },
            ),
            const Divider(),

            // رمز PIN للمشتريات
            _buildSecuritySwitch(
              title: AppStrings.parentalPinPurchasesTitle(context),
              subtitle: AppStrings.parentalPinPurchasesSubtitle(context),
              value: _requirePinForPurchases,
              icon: Icons. shopping_cart,
              onChanged: (value) {
                setState(() {
                  _requirePinForPurchases = value;
                });
              },
            ),
            const Divider(),

            // تغيير رمز PIN
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius. circular(8),
                ),
                child: const Icon(Icons. pin, color: Colors.red),
              ),
              title: Text(AppStrings.parentalChangePinTitle(context)),
              subtitle: Text(AppStrings.parentalChangePinSubtitle(context)),
              trailing: const Icon(Icons.chevron_left),
              onTap: () => _showChangePinDialog(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySwitch({
    required String title,
    required String subtitle,
    required bool value,
    required IconData icon,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      contentPadding: EdgeInsets. zero,
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: value
              ? const Color(0xFF90EE90).withValues(alpha: 0.15)
              : ThemeColors.fill(context),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: value ? const Color(0xFF90EE90) : Colors.grey,
        ),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight. w500)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors. grey[600])),
      value: value,
      activeThumbColor: const Color(0xFF90EE90),
      onChanged: onChanged,
    );
  }

  Widget _buildNotificationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets. all(16),
        child: Column(
          crossAxisAlignment:  CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              title: AppStrings.parentalNotificationsSectionTitle(context),
              icon: Icons.notifications,
              color: const Color(0xFF4DD0E1),
              subtitle:
                  AppStrings.parentalNotificationsSectionSubtitle(context),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets. zero,
              title: Text(AppStrings.parentalAllowNotificationsTitle(context)),
              subtitle:
                  Text(AppStrings.parentalAllowNotificationsSubtitle(context)),
              value: _allowNotifications,
              activeThumbColor: const Color(0xFF4DD0E1),
              onChanged: (value) {
                setState(() {
                  _allowNotifications = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoundSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets. all(16),
        child: Column(
          crossAxisAlignment:  CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              title: AppStrings.parentalSoundTitle(context),
              icon: Icons.volume_up,
              color: const Color(0xFF9575CD),
              subtitle: AppStrings.parentalSoundSubtitle(context),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets. zero,
              title: Text(AppStrings.parentalSoundEffectsTitle(context)),
              subtitle: Text(AppStrings.parentalSoundEffectsSubtitle(context)),
              value:  _allowSoundEffects,
              activeThumbColor:  const Color(0xFF9575CD),
              onChanged: (value) {
                setState(() {
                  _allowSoundEffects = value;
                });
              },
            ),
            const Divider(),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(AppStrings.parentalBgMusicTitle(context)),
              subtitle: Text(AppStrings.parentalBgMusicSubtitle(context)),
              value: _allowBackgroundMusic,
              activeThumbColor: const Color(0xFF9575CD),
              onChanged: (value) {
                setState(() {
                  _allowBackgroundMusic = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResetSection() {
    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              title: AppStrings.parentalResetTitle(context),
              icon: Icons.restore,
              color: Colors.red,
              subtitle: AppStrings.parentalResetSubtitle(context),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double. infinity,
              child: OutlinedButton. icon(
                onPressed: _showResetConfirmDialog,
                icon: const Icon(Icons.restore, color: Colors.red),
                label: Text(
                  AppStrings.parentalResetButton(context),
                  style: const TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors. red),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePinDialog() {
    final currentPinController = TextEditingController();
    final newPinController = TextEditingController();
    final confirmPinController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.lock, color: Color(0xFF87CEEB)),
            const SizedBox(width: 8),
            Text(AppStrings.parentalPinDialogTitle(dialogContext)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPinController,
              obscureText: true,
              maxLength: 4,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: AppStrings.parentalPinCurrentLabel(dialogContext),
                counterText: '',
                prefixIcon: const Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPinController,
              obscureText: true,
              maxLength: 4,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: AppStrings.parentalPinNewLabel(dialogContext),
                counterText: '',
                prefixIcon: const Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPinController,
              obscureText: true,
              maxLength: 4,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: AppStrings.parentalPinConfirmLabel(dialogContext),
                counterText: '',
                prefixIcon: const Icon(Icons.lock),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppStrings.cancel(dialogContext)),
          ),
          ElevatedButton(
            onPressed: () {
              if (newPinController.text == confirmPinController.text &&
                  newPinController.text.length == 4) {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppStrings.parentalPinChangedOk(context)),
                    backgroundColor: const Color(0xFF90EE90),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppStrings.parentalPinMismatch(context)),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(AppStrings.save(dialogContext)),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red),
            const SizedBox(width: 8),
            Text(AppStrings.parentalResetConfirmTitle(dialogContext)),
          ],
        ),
        content: Text(AppStrings.parentalResetConfirmBody(dialogContext)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppStrings.cancel(dialogContext)),
          ),
          ElevatedButton(
            onPressed: () {
              _resetToDefaults();
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppStrings.parentalResetDone(context)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(AppStrings.parentalResetAction(dialogContext)),
          ),
        ],
      ),
    );
  }

  void _resetToDefaults() {
    setState(() {
      _dailyTimeLimit = 45;
      _weekendExtraTime = true;
      _startTime = const TimeOfDay(hour: 8, minute: 0);
      _endTime = const TimeOfDay(hour: 20, minute: 0);
      _activeDays = [true, true, true, true, true, true, true];
      _contentCategories
        ..clear()
        ..addAll(
            Map.fromEntries(AppStrings.parentalInitialContentEntries()));
      _skillsFocus
        ..clear()
        ..addAll(Map.fromEntries(AppStrings.parentalInitialSkillEntries()));
      _requirePinForSettings = true;
      _requirePinForPurchases = true;
      _allowNotifications = true;
      _allowSoundEffects = true;
      _allowBackgroundMusic = true;
    });
  }

  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(AppStrings.parentalSavedOk(context)),
          ],
        ),
        backgroundColor: const Color(0xFF90EE90),
      ),
    );
    Navigator.pop(context);
  }
}