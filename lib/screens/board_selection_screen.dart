import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_strings.dart';

import '../models/zone_model.dart';
import '../services/board_service.dart';
import '../widgets/empty_state.dart';

/// شاشة اختيار البورد المتغير المفعّل حالياً على الجهاز.
/// الأهل يختارون أي منطقة متغيرة (حديقة الحيوانات / مدينة المهن ...)
/// محطوطة الآن على البورد، والرازبيري تقرأ الاختيار من Supabase.
class BoardSelectionScreen extends StatefulWidget {
  const BoardSelectionScreen({super.key});

  @override
  State<BoardSelectionScreen> createState() => _BoardSelectionScreenState();
}

class _BoardSelectionScreenState extends State<BoardSelectionScreen> {
  final BoardService _boardService = BoardService();

  List<Zone> _boards = [];
  bool _isLoading = true;
  String? _updatingKey; // مفتاح البورد الجاري تفعيله

  // إيموجي لكل منطقة متغيرة (حسب key)
  static const Map<String, String> _boardEmoji = {
    'zoo': '🦁',
    'careers': '👷',
    'farm': '🚜',
    'space': '🚀',
    'sea': '🐠',
  };

  // لون مميّز لكل بورد
  static const List<Color> _palette = [
    Color(0xFFFFB74D),
    Color(0xFF4DD0E1),
    Color(0xFFBA68C8),
    Color(0xFF81C784),
    Color(0xFF7986CB),
  ];

  @override
  void initState() {
    super.initState();
    _loadBoards();
  }

  Future<void> _loadBoards() async {
    setState(() => _isLoading = true);
    final boards = await _boardService.getDynamicBoards();
    if (mounted) {
      setState(() {
        _boards = boards;
        _isLoading = false;
      });
    }
  }

  Future<void> _activate(Zone zone) async {
    if (zone.isActive) return; // مفعّل أصلاً
    setState(() => _updatingKey = zone.key);

    final result = await _boardService.setActiveBoard(zone.key);

    if (!mounted) return;
    if (result.success) {
      // حدّث الحالة محلياً بدون إعادة تحميل كامل
      setState(() {
        _boards = _boards
            .map((z) => z.copyWith(isActive: z.key == zone.key))
            .toList();
        _updatingKey = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.tr(context,
              '✅ البورد المفعّل الآن: ${zone.displayName}',
              '✅ Active board now: ${zone.displayName}')),
          backgroundColor: const Color(0xFF81C784),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      setState(() => _updatingKey = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: const Color(0xFFE74C3C),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.tr(context, 'اختيار البورد', 'Board Selection')),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadBoards,
              child: _boards.isEmpty ? _buildEmpty() : _buildList(),
            ),
    );
  }

  Widget _buildEmpty() {
    // قائمة قابلة للسحب حتى يبقى التحديث بالسحب متاحاً رغم الفراغ.
    return ListView(
      children: [
        const SizedBox(height: 120),
        EmptyState(
          icon: Icons.dashboard_customize_outlined,
          message: AppStrings.tr(
              context, 'لا توجد بوردات متغيرة', 'No dynamic boards'),
        ),
      ],
    );
  }

  Widget _buildList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHeader(),
        const SizedBox(height: 16),
        ...List.generate(_boards.length, (i) {
          final zone = _boards[i];
          final color = _palette[i % _palette.length];
          return _buildBoardCard(zone, color);
        }),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF87CEEB), Color(0xFF90EE90)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppStrings.tr(
                  context,
                  'اختاري البورد المحطوط حالياً على الجهاز. الفسيلة والجهاز '
                  'سيتعاملان مع القطع الخاصة به.',
                  'Pick the board currently mounted on the toy. Faseelah and '
                  'the device will play with its pieces.'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoardCard(Zone zone, Color color) {
    final emoji = _boardEmoji[zone.key] ?? '🧩';
    final isActive = zone.isActive;
    final isUpdating = _updatingKey == zone.key;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isActive
            ? const BorderSide(color: Color(0xFF81C784), width: 2.5)
            : BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: InkWell(
        onTap: isUpdating ? null : () => _activate(zone),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(emoji,
                          style: const TextStyle(fontSize: 30)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          zone.displayName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppStrings.tr(context, '${zone.pieces.length} قطعة',
                              '${zone.pieces.length} pieces'),
                          style: TextStyle(
                            fontSize: 13,
                            color: ThemeColors.subtle(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(isActive, isUpdating),
                ],
              ),
              if (zone.pieces.isNotEmpty) ...[
                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Text(
                  AppStrings.tr(context, 'القطع على هذا البورد:',
                      'Pieces on this board:'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: ThemeColors.subtle(context),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: zone.pieces
                      .map((p) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              p.displayName,
                              style: TextStyle(
                                fontSize: 12,
                                color: color.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive, bool isUpdating) {
    if (isUpdating) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2.5),
      );
    }
    if (isActive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF81C784),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 16),
            const SizedBox(width: 4),
            Text(
              AppStrings.tr(context, 'مفعّل', 'Active'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        AppStrings.tr(context, 'تفعيل', 'Activate'),
        style: TextStyle(
          color: ThemeColors.subtle(context),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
