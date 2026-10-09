import 'package:flutter/material.dart';

/// MARKet brand palette.
///
/// The four brand fills are fixed by the product owner. `tealInk` and
/// `coralInk` are darker tones of the same hues, used only for small text and
/// icons where the brand fills would fail WCAG AA contrast on light surfaces.
abstract final class AppColors {
  // Brand fills
  static const Color deepTeal = Color(0xFF264653);
  static const Color teal = Color(0xFF2A9D8F);
  static const Color coral = Color(0xFFE76F51);
  static const Color cream = Color(0xFFF4EDE4);

  // Text-safe derived tones (≥4.5:1 on white and cream)
  static const Color tealInk = Color(0xFF1E7268);
  static const Color coralInk = Color(0xFFB5482E);

  // Neutrals
  static const Color surface = Color(0xFFFFFFFF);
  static const Color ink = deepTeal;
  static const Color inkMuted = Color(0xFF5B6B71);
  static const Color hairline = Color(0xFFE6DCCF);

  // Tints for subtle fills
  static const Color tealTint = Color(0xFFDDF0EC);
  static const Color coralTint = Color(0xFFFBE4DC);

  // Status
  static const Color warning = Color(0xFF9A6A00);
  static const Color warningTint = Color(0xFFFFF1CC);
  static const Color danger = Color(0xFFB3261E);
  static const Color dangerTint = Color(0xFFFBE0DE);
}
