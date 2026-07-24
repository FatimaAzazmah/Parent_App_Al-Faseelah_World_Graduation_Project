import 'package:flutter/material.dart';

/// Theme-aware color helpers so screens render correctly in light & dark mode.
/// Use these instead of hardcoded [Colors.white] / [Colors.grey] values.
class ThemeColors {
  ThemeColors._();

  static bool isDark(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark;

  /// Card / section background (white in light, dark surface in dark).
  static Color surface(BuildContext c) => Theme.of(c).colorScheme.surface;

  /// Primary body text (dark slate in light, white in dark).
  static Color text(BuildContext c) =>
      isDark(c) ? Colors.white : const Color(0xFF2C3E50);

  /// Secondary / subtle text (grey[600] in light, grey[400] in dark).
  static Color subtle(BuildContext c) =>
      isDark(c) ? Colors.grey[400]! : Colors.grey[600]!;

  /// Faint text such as hints and timestamps.
  static Color faint(BuildContext c) =>
      isDark(c) ? Colors.grey[500]! : Colors.grey[500]!;

  /// Soft fill for chips, inputs and highlighted rows.
  static Color softFill(BuildContext c) =>
      isDark(c) ? const Color(0xFF2A2A34) : Colors.grey[100]!;

  /// Slightly stronger fill (grey[200] in light).
  static Color fill(BuildContext c) =>
      isDark(c) ? const Color(0xFF32323E) : Colors.grey[200]!;

  /// Border / divider color.
  static Color border(BuildContext c) =>
      isDark(c) ? Colors.grey[700]! : Colors.grey[300]!;
}
