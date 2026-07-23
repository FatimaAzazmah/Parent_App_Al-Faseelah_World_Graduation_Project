import 'package:flutter/material.dart';
import '../app_locale.dart';
import '../utils/app_strings.dart';
import '../services/auth_service.dart';
import '../services/child_service.dart';
import '../models/child_model.dart';
import '../services/ble_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _authService = AuthService();
  final _childService = ChildService();

  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _darkModeEnabled = false;
  bool _autoUpdateEnabled = true;
  bool _analyticsEnabled = true;
  double _dailyTimeLimit = 45;

  UserData? _userData;
  List<Child> _children = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userData = await _authService.getCurrentUserData();
    final children = await _childService.getChildren();

    if (mounted) {
      setState(() {
        _userData = userData;
        _children = children;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.settingsTitle(context)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileSection(),
          const SizedBox(height: 24),
          _buildChildrenSection(),
          const SizedBox(height: 24),
          _buildGeneralSettings(),
          const SizedBox(height: 24),
          _buildNotificationSettings(),
          const SizedBox(height: 24),
          _buildParentalControlSettings(),
          const SizedBox(height: 24),
          _buildPrivacySettings(),
          const SizedBox(height: 24),
          _buildSupportSection(),
          const SizedBox(height: 24),
          _buildLogoutButton(),
          const SizedBox(height: 40),
          _buildAppInfo(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Theme
                      .of(context)
                      .colorScheme
                      .primary
                      .withOpacity(0.2),
                  child: const Icon(
                      Icons.person, size: 40, color: Color(0xFF87CEEB)),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme
                          .of(context)
                          .colorScheme
                          .primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                        Icons.edit, size: 14, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _userData?.name ??
                        AppStrings.defaultUserDisplay(context),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _userData?.email ?? '',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF90EE90).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      AppStrings.accountActive(context),
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF2E7D32)),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => _showEditProfileDialog(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildrenSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.registeredChildren(context),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () async {
                    await Navigator.pushNamed(context, '/add-child');
                    _loadData();
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(AppStrings.addShort(context)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_children.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(AppStrings.noChildrenYetSettings(context)),
                ),
              )
            else
              ..._children.asMap().entries.map((entry) {
                final index = entry.key;
                final child = entry.value;
                return Column(
                  children: [
                    _buildChildTile(
                      child.name,
                      AppStrings.yearsOldShort(context, child.age),
                      child.avatar,
                      false, // Will be true when RFID identifies the child
                    ),
                    if (index < _children.length - 1) const Divider(),
                  ],
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildChildTile(String name, String age, String avatar,
      bool isActive) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .primary
            .withOpacity(0.2),
        child: Text(avatar, style: const TextStyle(fontSize: 24)),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(age),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF90EE90).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.play_circle,
                      size: 14, color: Color(0xFF2E7D32)),
                  const SizedBox(width: 4),
                  Text(
                    AppStrings.playingNow(context),
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF2E7D32)),
                  ),
                ],
              ),
            ),
          IconButton(
            icon: const Icon(Icons.settings, size: 20),
            onPressed: () => _showChildSettingsDialog(name),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralSettings() {
    return _buildSettingsSection(
      title: AppStrings.sectionGeneral(context),
      icon: Icons.settings,
      children: [
        _buildSwitchTile(
          icon: Icons.dark_mode,
          title: AppStrings.darkMode(context),
          subtitle: AppStrings.darkModeSub(context),
          value: _darkModeEnabled,
          onChanged: (value) {
            setState(() {
              _darkModeEnabled = value;
            });
          },
        ),
        _buildSwitchTile(
          icon: Icons.volume_up,
          title: AppStrings.sounds(context),
          subtitle: AppStrings.soundsSub(context),
          value: _soundEnabled,
          onChanged: (value) {
            setState(() {
              _soundEnabled = value;
            });
          },
        ),
        _buildNavigationTile(
          icon: Icons.language,
          title: AppStrings.language(context),
          subtitle: AppStrings.activeLanguageDisplayForSettings(context),
          onTap: () => _showLanguageDialog(),
        ),
        _buildSwitchTile(
          icon: Icons.system_update,
          title: AppStrings.autoUpdate(context),
          subtitle: AppStrings.autoUpdateSub(context),
          value: _autoUpdateEnabled,
          onChanged: (value) {
            setState(() {
              _autoUpdateEnabled = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildNotificationSettings() {
    return _buildSettingsSection(
      title: AppStrings.notificationsSection(context),
      icon: Icons.notifications,
      children: [
        _buildSwitchTile(
          icon: Icons.notifications_active,
          title: AppStrings.enableNotifications(context),
          subtitle: AppStrings.enableNotificationsSub(context),
          value: _notificationsEnabled,
          onChanged: (value) {
            setState(() {
              _notificationsEnabled = value;
            });
          },
        ),
        _buildNavigationTile(
          icon: Icons.tune,
          title: AppStrings.customizeNotifications(context),
          subtitle: AppStrings.customizeNotificationsSub(context),
          onTap: () => _showNotificationTypesDialog(),
          enabled: _notificationsEnabled,
        ),
      ],
    );
  }

  Widget _buildParentalControlSettings() {
    return _buildSettingsSection(
      title: AppStrings.parentalControls(context),
      icon: Icons.shield,
      children: [
        _buildSliderTile(
          icon: Icons.timer,
          title: AppStrings.dailyTimeLimit(context),
          value: _dailyTimeLimit,
          min: 15,
          max: 120,
          divisions: 21,
          label: AppStrings.minutesCount(
              context, _dailyTimeLimit.round()),
          onChanged: (value) {
            setState(() {
              _dailyTimeLimit = value;
            });
          },
        ),
        _buildNavigationTile(
          icon: Icons.content_paste,
          title: AppStrings.contentFilter(context),
          subtitle: AppStrings.contentFilterSub(context),
          onTap: () => _showContentFilterDialog(),
        ),
        _buildNavigationTile(
          icon: Icons.schedule,
          title: AppStrings.usageSchedule(context),
          subtitle: AppStrings.usageScheduleSub(context),
          onTap: () => _showScheduleDialog(),
        ),
        _buildNavigationTile(
          icon: Icons.lock,
          title: AppStrings.pinCode(context),
          subtitle: AppStrings.pinCodeSub(context),
          onTap: () => _showChangePinDialog(),
        ),
      ],
    );
  }

  Widget _buildPrivacySettings() {
    return _buildSettingsSection(
      title: AppStrings.privacyData(context),
      icon: Icons.privacy_tip,
      children: [
        _buildSwitchTile(
          icon: Icons.analytics,
          title: AppStrings.shareAnalytics(context),
          subtitle: AppStrings.shareAnalyticsSub(context),
          value: _analyticsEnabled,
          onChanged: (value) {
            setState(() {
              _analyticsEnabled = value;
            });
          },
        ),
        _buildNavigationTile(
          icon: Icons.download,
          title: AppStrings.downloadData(context),
          subtitle: AppStrings.downloadDataSub(context),
          onTap: () => _downloadData(),
        ),
        _buildNavigationTile(
          icon: Icons.delete_forever,
          title: AppStrings.deleteData(context),
          subtitle: AppStrings.deleteDataSub(context),
          onTap: () => _showDeleteDataDialog(),
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildSupportSection() {
    return _buildSettingsSection(
      title: AppStrings.supportHelp(context),
      icon: Icons.help,
      children: [
        _buildNavigationTile(
          icon: Icons.help_outline,
          title: AppStrings.faq(context),
          subtitle: AppStrings.faqSub(context),
          onTap: () => _showFAQScreen(),
        ),
        _buildNavigationTile(
          icon: Icons.chat_bubble_outline,
          title: AppStrings.contactUs(context),
          subtitle: AppStrings.contactUsSub(context),
          onTap: () => _showContactDialog(),
        ),
        _buildNavigationTile(
          icon: Icons.star_outline,
          title: AppStrings.rateApp(context),
          subtitle: AppStrings.rateAppSub(context),
          onTap: () => _showRatingDialog(),
        ),
        _buildNavigationTile(
          icon: Icons.description,
          title: AppStrings.privacyPolicy(context),
          subtitle: AppStrings.privacyPolicySub(context),
          onTap: () => _showPrivacyPolicy(),
        ),
      ],
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme
                    .of(context)
                    .colorScheme
                    .primary, size: 22),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme
              .of(context)
              .colorScheme
              .primary
              .withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Theme
            .of(context)
            .colorScheme
            .primary, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(
          subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Theme
            .of(context)
            .colorScheme
            .primary,
      ),
    );
  }

  Widget _buildNavigationTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool enabled = true,
    bool isDestructive = false,
  }) {
    final color = isDestructive
        ? Colors.red
        : enabled
        ? Theme
        .of(context)
        .colorScheme
        .primary
        : Colors.grey;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      enabled: enabled,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: enabled ? (isDestructive ? Colors.red : null) : Colors.grey,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
            fontSize: 12, color: enabled ? Colors.grey[600] : Colors.grey[400]),
      ),
      trailing: Icon(
        Icons.chevron_left,
        color: enabled ? Colors.grey : Colors.grey[300],
      ),
      onTap: enabled ? onTap : null,
    );
  }

  Widget _buildSliderTile({
    required IconData icon,
    required String title,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String label,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme
                  .of(context)
                  .colorScheme
                  .primary
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Theme
                .of(context)
                .colorScheme
                .primary, size: 20),
          ),
          title: Text(
              title, style: const TextStyle(fontWeight: FontWeight.w500)),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme
                  .of(context)
                  .colorScheme
                  .primary
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: Theme
                    .of(context)
                    .colorScheme
                    .primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Theme
                .of(context)
                .colorScheme
                .primary,
            inactiveTrackColor: Theme
                .of(context)
                .colorScheme
                .primary
                .withOpacity(0.2),
            thumbColor: Theme
                .of(context)
                .colorScheme
                .primary,
            overlayColor: Theme
                .of(context)
                .colorScheme
                .primary
                .withOpacity(0.1),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.logout, color: Colors.red, size: 20),
        ),
        title: Text(
          AppStrings.logout(context),
          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.chevron_left, color: Colors.red),
        onTap: () => _showLogoutDialog(),
      ),
    );
  }

  Widget _buildAppInfo() {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme
                  .of(context)
                  .colorScheme
                  .primary
                  .withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/logo.png',
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.spa, color: Color(0xFF87CEEB), size: 32);
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppStrings.appTitle(context),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.appVersion(context),
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.copyright(context),
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog() {
    final currentName =
    (_userData?.name.trim().isNotEmpty ?? false)
        ? _userData!.name.trim()
        : AppStrings.defaultUserDisplayName(context);
    final currentEmail = _userData?.email ?? '';

    final nameController = TextEditingController(text: currentName);
    final emailController = TextEditingController(text: currentEmail);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        bool isSaving = false;
        return StatefulBuilder(
          builder: (sheetContext, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery
                    .of(sheetContext)
                    .viewInsets
                    .bottom,
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
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppStrings.editProfileSheetTitle(sheetContext),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () {},
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Theme
                          .of(sheetContext)
                          .colorScheme
                          .primary
                          .withOpacity(0.2),
                      child: Stack(
                        children: [
                          const Icon(
                              Icons.person, size: 50, color: Color(0xFF87CEEB)),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: Theme
                                  .of(sheetContext)
                                  .colorScheme
                                  .primary,
                              child: const Icon(Icons.camera_alt, size: 16,
                                  color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: AppStrings.nameFieldShort(sheetContext),
                      prefixIcon: const Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: AppStrings.emailLabel(sheetContext),
                      prefixIcon: const Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: AppStrings.newPasswordOptionalLabel(sheetContext),
                      prefixIcon: const Icon(Icons.lock),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isSaving ? null : () => Navigator.pop(sheetContext),
                          child: Text(AppStrings.cancel(sheetContext)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isSaving
                              ? null
                              : () async {
                            final messenger = ScaffoldMessenger.of(context);
                            final newName = nameController.text.trim();
                            if (newName.isEmpty) {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                      AppStrings.tr(context, 'الرجاء إدخال الاسم', 'Please enter your name')),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            setModalState(() => isSaving = true);
                            final result = await _authService.updateProfile(
                              name: newName,
                            );
                            if (!mounted || !sheetContext.mounted) return;
                            setModalState(() => isSaving = false);

                            if (result.success) {
                              setState(() {
                                _userData = result.user ?? _userData?.copyWith(name: newName);
                              });
                              await _loadData();
                              if (!mounted || !sheetContext.mounted) return;
                              Navigator.pop(sheetContext);
                              messenger.showSnackBar(
                                SnackBar(content: Text(AppStrings.changesSaved(context))),
                              );
                            } else {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(result.message),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          child: isSaving
                              ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                              : Text(AppStrings.save(sheetContext)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showChildSettingsDialog(String childName) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                AppStrings.childSettingsTitle(context, childName),
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.edit, color: Color(0xFF87CEEB)),
                title: Text(AppStrings.childSettingsEditProfile(context)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/child-profile');
                },
              ),
              ListTile(
                leading: const Icon(Icons.timer, color: Color(0xFF90EE90)),
                title: Text(AppStrings.childSettingsTimeLimit(context)),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.assessment, color: Color(0xFFFFB74D)),
                title: Text(AppStrings.childSettingsReports(context)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/progress');
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text(
                    AppStrings.childSettingsDeleteProfile(context),
                    style: const TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteChildDialog(childName);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteChildDialog(String childName) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.red[400]),
                const SizedBox(width: 8),
                Text(AppStrings.deleteChildFileTitle(context)),
              ],
            ),
            content: Text(
              AppStrings.deleteChildFileBody(context, childName),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppStrings.cancel(context)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            AppStrings.childFileDeletedSnack(
                                context, childName))),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text(AppStrings.delete(context)),
              ),
            ],
          ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                const Icon(Icons.language, color: Color(0xFF87CEEB)),
                const SizedBox(width: 8),
                Text(AppStrings.chooseLanguage(context)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  title: Text(AppStrings.languageArabicTitle(context)),
                  subtitle: Text(AppStrings.languageArabicSubtitle(context)),
                  value: 'ar',
                  groupValue: Localizations.localeOf(context).languageCode,
                  activeColor: Theme
                      .of(context)
                      .colorScheme
                      .primary,
                  onChanged: (value) async {
                    if (value == null) return;
                    await AppLocale.setLocale(Locale(value));
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          value == 'ar'
                              ? AppStrings.languageChangedAr(context)
                              : AppStrings.languageChangedEn(context),
                        ),
                      ),
                    );
                  },
                ),
                RadioListTile<String>(
                  title: Text(AppStrings.languageEnglishTitle(context)),
                  subtitle: Text(AppStrings.languageEnglishSubtitle(context)),
                  value: 'en',
                  groupValue: Localizations.localeOf(context).languageCode,
                  activeColor: Theme
                      .of(context)
                      .colorScheme
                      .primary,
                  onChanged: (value) async {
                    if (value == null) return;
                    await AppLocale.setLocale(Locale(value));
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          value == 'ar'
                              ? AppStrings.languageChangedAr(context)
                              : AppStrings.languageChangedEn(context),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showNotificationTypesDialog() {
    bool activityNotifications = true;
    bool progressNotifications = true;
    bool tipsNotifications = true;
    bool updateNotifications = false;

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
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppStrings.notifCustomizeSheetTitle(context),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  SwitchListTile(
                    title: Text(AppStrings.notifChildActivityTitle(context)),
                    subtitle: Text(AppStrings.notifChildActivitySub(context)),
                    value: activityNotifications,
                    activeColor: Theme
                        .of(context)
                        .colorScheme
                        .primary,
                    onChanged: (value) {
                      setModalState(() {
                        activityNotifications = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: Text(AppStrings.notifProgressReportsTitle(context)),
                    subtitle: Text(AppStrings.notifProgressReportsSub(context)),
                    value: progressNotifications,
                    activeColor: Theme
                        .of(context)
                        .colorScheme
                        .primary,
                    onChanged: (value) {
                      setModalState(() {
                        progressNotifications = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: Text(AppStrings.notifTipsTitle(context)),
                    subtitle: Text(AppStrings.notifTipsSub(context)),
                    value: tipsNotifications,
                    activeColor: Theme
                        .of(context)
                        .colorScheme
                        .primary,
                    onChanged: (value) {
                      setModalState(() {
                        tipsNotifications = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: Text(AppStrings.notifUpdatesTitle(context)),
                    subtitle: Text(AppStrings.notifUpdatesSub(context)),
                    value: updateNotifications,
                    activeColor: Theme
                        .of(context)
                        .colorScheme
                        .primary,
                    onChanged: (value) {
                      setModalState(() {
                        updateNotifications = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                AppStrings.notifSettingsSavedSnack(context))),
                      );
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

  void _showContentFilterDialog() {
    Map<String, bool> contentFilters = Map.fromEntries(
      AppStrings.initialContentFilterEntries(),
    );

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
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppStrings.contentFilterSheetTitle(context),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.contentFilterSheetSubtitle(context),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 20),
                  ...contentFilters.entries.map((entry) {
                    return CheckboxListTile(
                      title: Text(AppStrings.contentFilterOptionLabel(
                          context, entry.key)),
                      value: entry.value,
                      activeColor: Theme
                          .of(context)
                          .colorScheme
                          .primary,
                      onChanged: (value) {
                        setModalState(() {
                          contentFilters[entry.key] = value!;
                        });
                      },
                    );
                  }),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                AppStrings.contentFilterSavedSnack(context))),
                      );
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

  void _showScheduleDialog() {
    TimeOfDay startTime = const TimeOfDay(hour: 16, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 19, minute: 0);
    List<bool> selectedDays = [true, true, true, true, true, true, true];

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
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppStrings.scheduleSheetTitle(context),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppStrings.startTimeLabel(context),
                                style: const TextStyle(fontWeight: FontWeight.w500)),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: startTime,
                                );
                                if (time != null) {
                                  setModalState(() {
                                    startTime = time;
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.access_time, size: 20),
                                    const SizedBox(width: 8),
                                    Text(startTime.format(context)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppStrings.endTimeLabel(context),
                                style: const TextStyle(fontWeight: FontWeight.w500)),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: endTime,
                                );
                                if (time != null) {
                                  setModalState(() {
                                    endTime = time;
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.access_time, size: 20),
                                    const SizedBox(width: 8),
                                    Text(endTime.format(context)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(AppStrings.usageDaysLabel(context),
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(7, (index) {
                      final dayNames = AppStrings.weekDayShortLetters(context);
                      return GestureDetector(
                        onTap: () {
                          setModalState(() {
                            selectedDays[index] = !selectedDays[index];
                          });
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: selectedDays[index]
                                ? Theme
                                .of(context)
                                .colorScheme
                                .primary
                                : Colors.grey[200],
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              dayNames[index],
                              style: TextStyle(
                                color: selectedDays[index]
                                    ? Colors.white
                                    : Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                            Text(AppStrings.scheduleSavedSnack(context))),
                      );
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

  void _showChangePinDialog() {
    final currentPinController = TextEditingController();
    final newPinController = TextEditingController();
    final confirmPinController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery
                .of(context)
                .viewInsets
                .bottom,
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
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                AppStrings.changePinSheetTitle(context),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: currentPinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                decoration: InputDecoration(
                  labelText: AppStrings.pinCurrentLabel(context),
                  prefixIcon: const Icon(Icons.lock_outline),
                  counterText: '',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                decoration: InputDecoration(
                  labelText: AppStrings.pinNewLabel(context),
                  prefixIcon: const Icon(Icons.lock),
                  counterText: '',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                decoration: InputDecoration(
                  labelText: AppStrings.pinConfirmLabel(context),
                  prefixIcon: const Icon(Icons.lock),
                  counterText: '',
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
                      onPressed: () {
                        if (newPinController.text ==
                            confirmPinController.text &&
                            newPinController.text.length == 4) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    AppStrings.pinChangedSnack(context))),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  AppStrings.pinMismatchSnack(context)),
                              backgroundColor: Colors.red,
                            ),
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
    );
  }

  void _downloadData() {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                const Icon(Icons.download, color: Color(0xFF87CEEB)),
                const SizedBox(width: 8),
                Text(AppStrings.downloadDataTitle(context)),
              ],
            ),
            content: Text(AppStrings.downloadDataBody(context)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppStrings.cancel(context)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            AppStrings.downloadConfirmSnack(context))),
                  );
                },
                child: Text(AppStrings.downloadAction(context)),
              ),
            ],
          ),
    );
  }

  void _showDeleteDataDialog() {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.red[400]),
                const SizedBox(width: 8),
                Text(AppStrings.deleteAllDataTitle(context)),
              ],
            ),
            content: Text(AppStrings.deleteAllDataBody(context)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppStrings.cancel(context)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showFinalDeleteConfirmation();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text(AppStrings.delete(context)),
              ),
            ],
          ),
    );
  }

  void _showFinalDeleteConfirmation() {
    final confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: Text(AppStrings.finalDeleteTitle(context)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(AppStrings.typeDeleteToConfirm(context)),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmController,
                  decoration: InputDecoration(
                    hintText: AppStrings.hintTypeDelete(context),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppStrings.cancel(context)),
              ),
              ElevatedButton(
                onPressed: () {
                  if (confirmController.text ==
                      AppStrings.deleteConfirmKeyword(context)) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                          Text(AppStrings.allDataDeletedSnack(context))),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text(AppStrings.confirmDeleteAction(context)),
              ),
            ],
          ),
    );
  }

  void _showFAQScreen() {
    final faqCount = AppStrings.faqCount;
    final faqs = List.generate(
      faqCount,
          (i) => <String, String>{
        'question': AppStrings.faqQ(context, i),
        'answer': AppStrings.faqA(context, i),
      },
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppStrings.faqSheetTitle(context),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: faqs.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ExpansionTile(
                            title: Text(
                              faqs[index]['question']!,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  faqs[index]['answer']!,
                                  style: TextStyle(
                                      color: Colors.grey[700], height: 1.5),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showContactDialog() {
    final subjectController = TextEditingController();
    final messageController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery
                .of(context)
                .viewInsets
                .bottom,
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
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                AppStrings.contactSheetTitle(context),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: subjectController,
                decoration: InputDecoration(
                  labelText: AppStrings.contactSubjectLabel(context),
                  prefixIcon: const Icon(Icons.subject),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: messageController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: AppStrings.contactMessageLabel(context),
                  prefixIcon: const Icon(Icons.message),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(AppStrings.contactSentSnack(context))),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(AppStrings.send(context)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showRatingDialog() {
    int rating = 0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Text(AppStrings.rateAppDialogTitle(context),
                  textAlign: TextAlign.center),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(AppStrings.rateAppQuestion(context)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        onPressed: () {
                          setDialogState(() {
                            rating = index + 1;
                          });
                        },
                        icon: Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: const Color(0xFFFFB74D),
                          size: 36,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    rating == 0
                        ? AppStrings.rateTapStars(context)
                        : rating <= 2
                        ? AppStrings.rateSorry(context)
                        : rating <= 4
                        ? AppStrings.rateThanks(context)
                        : AppStrings.rateGreat(context),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppStrings.later(context)),
                ),
                ElevatedButton(
                  onPressed: rating > 0
                      ? () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                          Text(AppStrings.thanksForRatingSnack(context))),
                    );
                  }
                      : null,
                  child: Text(AppStrings.send(context)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showPrivacyPolicy() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppStrings.privacyPolicySheetTitle(context),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPolicySection(
                            context,
                            AppStrings.policyCollectTitle(context),
                            AppStrings.policyCollectBody(context),
                          ),
                          _buildPolicySection(
                            context,
                            AppStrings.policyUseTitle(context),
                            AppStrings.policyUseBody(context),
                          ),
                          _buildPolicySection(
                            context,
                            AppStrings.policyProtectTitle(context),
                            AppStrings.policyProtectBody(context),
                          ),
                          _buildPolicySection(
                            context,
                            AppStrings.policyRightsTitle(context),
                            AppStrings.policyRightsBody(context),
                          ),
                          _buildPolicySection(
                            context,
                            AppStrings.policyChildrenTitle(context),
                            AppStrings.policyChildrenBody(context),
                          ),
                          _buildPolicySection(
                            context,
                            AppStrings.policyCookiesTitle(context),
                            AppStrings.policyCookiesBody(context),
                          ),
                          _buildPolicySection(
                            context,
                            AppStrings.policyUpdatesTitle(context),
                            AppStrings.policyUpdatesBody(context),
                          ),
                          _buildPolicySection(
                            context,
                            AppStrings.policyContactTitle(context),
                            AppStrings.policyContactBody(context),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  AppStrings.policyUpdatedLine(context),
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  AppStrings.policyVersionLine(context),
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPolicySection(
      BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF87CEEB),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                const Icon(Icons.logout, color: Colors.red),
                const SizedBox(width: 8),
                Text(AppStrings.logoutConfirmTitle(context)),
              ],
            ),
            content: Text(AppStrings.logoutConfirmBody(context)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppStrings.cancel(context)),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _authService.logout();
                  if (mounted) {
                    Navigator.pushReplacementNamed(context, '/login');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                          Text(AppStrings.logoutSuccess(context))),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text(AppStrings.logout(context)),
              ),
            ],
          ),
    );
  }
}