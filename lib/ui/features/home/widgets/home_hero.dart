import 'package:flutter/material.dart';

import '../../../../domain/models/business.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/verification_badge.dart';

/// Full-bleed business photo carrying the business identity (spec §6.1–6.2).
/// Uses the storefront photo, else the interior photo; until the owner
/// uploads one it shows a category-themed backdrop with a nudge to add it.
class HomeHeroBackground extends StatelessWidget {
  const HomeHeroBackground({super.key, required this.business, this.tint = AppColors.deepTeal});

  final Business business;

  /// Tone derived from the owner's photo; scrim and fallback follow it.
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final photo = business.heroPhoto;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (photo != null)
          AppImage(photo, semanticLabel: 'Photo of ${business.name}')
        else
          _CategoryBackdrop(business: business, tint: tint),
        // Top scrim keeps the wordmark legible; bottom scrim carries identity.
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0, 0.22, 0.5, 1],
              colors: [
                tint.withValues(alpha: 0.6),
                tint.withValues(alpha: 0),
                tint.withValues(alpha: 0),
                tint.withValues(alpha: 0.95),
              ],
            ),
          ),
        ),
        Positioned(
          left: AppSpace.lg,
          right: AppSpace.lg,
          bottom: AppSpace.xl + 14,
          child: _Identity(business: business),
        ),
      ],
    );
  }
}

/// Shown until a storefront or interior photo is uploaded. Themed by the
/// business category so it fits any kind of MSME.
class _CategoryBackdrop extends StatelessWidget {
  const _CategoryBackdrop({required this.business, required this.tint});

  final Business business;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [tint, Color.lerp(tint, AppColors.teal, 0.45)!],
        ),
      ),
      child: Align(
        alignment: const Alignment(0.7, -0.35),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(business.msmeCategory.icon, size: 96, color: Colors.white.withValues(alpha: 0.18)),
            const SizedBox(height: AppSpace.sm),
            Text(
              'Add a storefront photo',
              style: AppTypography.label.copyWith(color: Colors.white.withValues(alpha: 0.7)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Identity extends StatelessWidget {
  const _Identity({required this.business});

  final Business business;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _BusinessLogo(business: business),
            const SizedBox(width: AppSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    business.category,
                    style: AppTypography.label.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    business.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.display.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpace.md),
        Wrap(
          spacing: AppSpace.sm,
          runSpacing: AppSpace.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            VerificationBadge(status: business.verificationStatus),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 220),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.place_rounded, size: 16, color: Colors.white),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      business.locationLabel,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.label.copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Shows the uploaded logo, or initials until one is uploaded.
class _BusinessLogo extends StatelessWidget {
  const _BusinessLogo({required this.business});

  final Business business;

  String get _initials => business.name
      .split(' ')
      .where((w) => w.isNotEmpty)
      .take(2)
      .map((w) => w[0].toUpperCase())
      .join();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 2),
        image: business.logoAsset != null
            ? DecorationImage(image: appImageProvider(business.logoAsset!), fit: BoxFit.cover)
            : null,
      ),
      alignment: Alignment.center,
      child: business.logoAsset == null
          ? Text(
              _initials,
              style: AppTypography.title.copyWith(color: AppColors.deepTeal),
            )
          : null,
    );
  }
}
