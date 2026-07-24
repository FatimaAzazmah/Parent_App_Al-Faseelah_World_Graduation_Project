import 'package:flutter/material.dart';
import '../models/child_model.dart';
import '../services/child_service.dart';
import '../utils/app_strings.dart';
import '../utils/app_colors.dart';

class AddChildScreen extends StatefulWidget {
  const AddChildScreen({super.key});

  @override
  State<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nameEnController = TextEditingController();
  final _rfidController = TextEditingController();
  final _childService = ChildService();

  int _selectedAge = 5;
  String _selectedGender = 'ذكر';
  String _selectedAvatar = '👦';
  final List<String> _selectedInterests = [];
  bool _isLoading = false;

  final List<String> _avatars = ['👦', '👧', '🧒', '👶', '🧒🏻', '👦🏻', '👧🏻'];

  final List<Map<String, dynamic>> _allInterests = [
    {'name': 'القصص', 'icon': Icons.auto_stories},
    {'name': 'الأرقام', 'icon': Icons.calculate},
    {'name': 'الحروف', 'icon': Icons.abc},
    {'name': 'الألوان', 'icon': Icons.palette},
    {'name': 'الحيوانات', 'icon': Icons.pets},
    {'name': 'الطبيعة', 'icon': Icons.park},
    {'name': 'الفضاء', 'icon': Icons.rocket},
    {'name': 'القرآن', 'icon': Icons.menu_book},
    {'name': 'الرسم', 'icon': Icons.brush},
    {'name': 'الرياضة', 'icon': Icons.sports_soccer},
    {'name': 'العلوم', 'icon': Icons.science},
    {'name': 'الطبخ', 'icon': Icons.restaurant},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _nameEnController.dispose();
    _rfidController.dispose();
    super.dispose();
  }

  Future<void> _saveChild() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedInterests.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.validationPickOneInterest(context)),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final rfidText = _rfidController.text.trim();

      final nameEnText = _nameEnController.text.trim();

      final newChild = Child(
        id: '',
        name: _nameController.text,
        nameEn: nameEnText.isEmpty ? null : nameEnText,
        age: _selectedAge,
        gender: _selectedGender,
        avatar: _selectedAvatar,
        interests: _selectedInterests,
        createdAt: DateTime.now(),
        rfidId: rfidText.isEmpty ? null : rfidText,
      );

      final result = await _childService.addChild(newChild);

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        if (result.success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.childAddedSuccess(
                  context, _nameController.text)),
              backgroundColor: const Color(0xFF90EE90),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.addChildAppBar(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatarSection(),
              const SizedBox(height: 32),
              _buildNameSection(),
              const SizedBox(height: 24),
              _buildRfidSection(),
              const SizedBox(height: 24),
              _buildAgeSection(),
              const SizedBox(height: 24),
              _buildGenderSection(),
              const SizedBox(height: 24),
              _buildInterestsSection(),
              const SizedBox(height: 32),
              _buildSaveButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 3,
              ),
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.transparent,
              child: Text(
                _selectedAvatar,
                style: const TextStyle(fontSize: 60),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.selectAvatarTitle(context),
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: _avatars.map((avatar) {
              final isSelected = avatar == _selectedAvatar;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedAvatar = avatar;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                        : ThemeColors.softFill(context),
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    )
                        : null,
                  ),
                  child: Text(avatar, style: const TextStyle(fontSize: 28)),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNameSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.person, color: Color(0xFF87CEEB), size: 20),
            const SizedBox(width: 8),
            Text(
              AppStrings.childNameFieldTitle(context),
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: AppStrings.childNameHint(context),
            prefixIcon: const Icon(Icons.child_care),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppStrings.validationChildNameRequired(context);
            }
            if (value.length < 2) {
              return AppStrings.validationChildNameMin(context);
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _nameEnController,
          textCapitalization: TextCapitalization.words,
          textDirection: TextDirection.ltr,
          decoration: InputDecoration(
            hintText: AppStrings.tr(context, 'الاسم بالإنجليزية (اختياري)',
                'Name in English (optional)'),
            prefixIcon: const Icon(Icons.translate),
          ),
        ),
      ],
    );
  }

  Widget _buildRfidSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.nfc, color: Color(0xFFBA68C8), size: 20),
            const SizedBox(width: 8),
            Text(
              AppStrings.rfidLabel(context),
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _rfidController,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            hintText: AppStrings.rfidHint(context),
            prefixIcon: const Icon(Icons.nfc),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          AppStrings.rfidHelperText(context),
          style: TextStyle(color: ThemeColors.faint(context), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildAgeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.cake, color: Color(0xFF90EE90), size: 20),
            const SizedBox(width: 8),
            Text(
              AppStrings.ageSectionTitle(context),
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: ThemeColors.softFill(context),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.cake, color: Color(0xFF90EE90)),
              const SizedBox(width: 12),
              Expanded(
                child: Slider(
                  value: _selectedAge.toDouble(),
                  min: 3,
                  max: 9,
                  divisions: 6,
                  label: AppStrings.yearsOldShort(context, _selectedAge),
                  activeColor: const Color(0xFF90EE90),
                  onChanged: (value) {
                    setState(() {
                      _selectedAge = value.round();
                    });
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF90EE90),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$_selectedAge',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            AppStrings.ageRangeHint(context),
            style: TextStyle(color: ThemeColors.faint(context), fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.wc, color: Color(0xFFFFB74D), size: 20),
            const SizedBox(width: 8),
            Text(
              AppStrings.genderSectionTitle(context),
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildGenderOption(
                context,
                AppStrings.genderMale(context),
                'ذكر',
                '👦',
                const Color(0xFF87CEEB),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildGenderOption(
                context,
                AppStrings.genderFemale(context),
                'أنثى',
                '👧',
                const Color(0xFFFF9ECE),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOption(
    BuildContext context,
    String label,
    String genderValue,
    String emoji,
    Color color,
  ) {
    final isSelected = _selectedGender == genderValue;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = genderValue;
          _selectedAvatar = emoji;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : ThemeColors.softFill(context),
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? Border.all(color: color, width: 2) : null,
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : ThemeColors.subtle(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.favorite, color: Color(0xFFBA68C8), size: 20),
                const SizedBox(width: 8),
                Text(
                  AppStrings.interests(context),
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                ),
              ],
            ),
            Text(
              AppStrings.interestsSelectedCount(
                  context, _selectedInterests.length),
              style: TextStyle(
                color: ThemeColors.faint(context),
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.interestsPickHint(context),
          style: TextStyle(color: ThemeColors.faint(context), fontSize: 12),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _allInterests.map((interest) {
            final isSelected = _selectedInterests.contains(interest['name']);
            return FilterChip(
              selected: isSelected,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    interest['icon'] as IconData,
                    size: 16,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : ThemeColors.subtle(context),
                  ),
                  const SizedBox(width: 4),
                  Text(AppStrings.interestDisplayLabel(
                      context, interest['name'] as String)),
                ],
              ),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedInterests.add(interest['name'] as String);
                  } else {
                    _selectedInterests.remove(interest['name']);
                  }
                });
              },
              selectedColor:
              Theme.of(context).colorScheme.primary.withOpacity(0.2),
              checkmarkColor: Theme.of(context).colorScheme.primary,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveChild,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isLoading
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.save),
            const SizedBox(width: 8),
            Text(AppStrings.save(context),
                style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
