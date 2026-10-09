import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Type scale: Plus Jakarta Sans for headings, Inter for body copy.
abstract final class AppTypography {
  static const String heading = 'PlusJakartaSans';
  static const String body = 'Inter';

  static const TextStyle display = TextStyle(
    fontFamily: heading,
    fontSize: 28,
    height: 1.15,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.6,
    color: AppColors.ink,
  );

  static const TextStyle title = TextStyle(
    fontFamily: heading,
    fontSize: 20,
    height: 1.25,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: AppColors.ink,
  );

  static const TextStyle section = TextStyle(
    fontFamily: heading,
    fontSize: 17,
    height: 1.3,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    color: AppColors.ink,
  );

  static const TextStyle bodyText = TextStyle(
    fontFamily: body,
    fontSize: 15,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: AppColors.ink,
  );

  static const TextStyle bodyMuted = TextStyle(
    fontFamily: body,
    fontSize: 14,
    height: 1.45,
    fontWeight: FontWeight.w400,
    color: AppColors.inkMuted,
  );

  static const TextStyle label = TextStyle(
    fontFamily: body,
    fontSize: 13,
    height: 1.3,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
  );

  static TextTheme get textTheme => const TextTheme(
        headlineMedium: display,
        titleLarge: title,
        titleMedium: section,
        bodyLarge: bodyText,
        bodyMedium: bodyMuted,
        labelLarge: label,
        labelMedium: label,
      );
}
