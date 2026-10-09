import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';
import 'photo_tint.dart';

/// Top banner shared by Promo Studio, Business Pulse and Account. It takes
/// its tone from the owner's photo, like the Home hero does.
class BrandHeader extends StatelessWidget {
  const BrandHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.photoPath,
    this.bottom,
  });

  final String title;
  final String subtitle;
  final String? photoPath;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return PhotoTint(
      photoPath: photoPath,
      builder: (context, tint) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.fromLTRB(AppSpace.xl, top + AppSpace.lg, AppSpace.xl, AppSpace.xl),
        decoration: BoxDecoration(
          color: tint,
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(title, style: AppTypography.display.copyWith(color: Colors.white)),
            ),
            const SizedBox(height: 4),
            Text(subtitle,
                style: AppTypography.bodyText.copyWith(color: Colors.white.withValues(alpha: 0.82))),
            if (bottom != null) ...[const SizedBox(height: AppSpace.lg), bottom!],
          ],
        ),
      ),
    );
  }
}

/// Pill segmented control used for Promo Studio's Active/Drafts/Expired.
class PillTabs extends StatelessWidget {
  const PillTabs({super.key, required this.labels, required this.selected, required this.onChanged});

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: Semantics(
                button: true,
                selected: i == selected,
                label: labels[i],
                excludeSemantics: true,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: i == selected ? AppColors.deepTeal : Colors.transparent,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      labels[i],
                      style: AppTypography.label.copyWith(
                        color: i == selected ? Colors.white : AppColors.inkMuted,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
