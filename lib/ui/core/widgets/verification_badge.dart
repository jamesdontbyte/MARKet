import 'package:flutter/material.dart';

import '../../../domain/models/verification_status.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Pill showing the real verification status. Never shows "Verified"
/// unless the status is actually verified (spec §4).
class VerificationBadge extends StatelessWidget {
  const VerificationBadge({super.key, required this.status});

  final VerificationStatus status;

  @override
  Widget build(BuildContext context) {
    final (IconData icon, Color fg, Color bg) = switch (status) {
      VerificationStatus.verified => (Icons.verified_rounded, AppColors.tealInk, Colors.white),
      VerificationStatus.pending ||
      VerificationStatus.underReview =>
        (Icons.schedule_rounded, AppColors.warning, AppColors.warningTint),
      VerificationStatus.requiresCorrection =>
        (Icons.error_outline_rounded, AppColors.coralInk, AppColors.coralTint),
      VerificationStatus.rejected => (Icons.block_rounded, AppColors.danger, AppColors.dangerTint),
    };

    return Semantics(
      label: 'Verification status: ${status.label}',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 5, 12, 5),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: fg),
            const SizedBox(width: 5),
            Text(status.label, style: AppTypography.label.copyWith(color: fg)),
          ],
        ),
      ),
    );
  }
}
