import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../../domain/models/business.dart';
import '../../../../domain/models/business_location.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/brand_header.dart';
import '../../../core/widgets/geofence_map.dart';
import '../../../core/widgets/section_header.dart';
import '../../home/view_models/home_view_model.dart';

/// Business Pulse (spec §9): geofence status plus measured activity.
class BusinessPulseView extends StatelessWidget {
  const BusinessPulseView({super.key});

  @override
  Widget build(BuildContext context) {
    final business = context.watch<HomeViewModel>().business;
    if (business == null) return const SizedBox.shrink();
    final m = business.metrics;
    final noActivity = m.profileViews + m.productViews + m.promotionViews + m.notificationsSent == 0;

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          BrandHeader(
            title: 'Business Pulse',
            subtitle: 'How your business is being reached through MARKet.',
            photoPath: business.heroPhoto,
          ),
          const SizedBox(height: AppSpace.xl),
          const SectionHeader(title: 'Geofence'),
          _GeofenceCard(business: business),
          const SizedBox(height: AppSpace.xl),
          SectionHeader(
            title: 'Business activity',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg),
            child: Row(
              children: [
                Expanded(child: _Metric(icon: Icons.storefront_rounded, label: 'Profile views', value: m.profileViews)),
                const SizedBox(width: AppSpace.md),
                Expanded(child: _Metric(icon: Icons.inventory_2_outlined, label: 'Item views', value: m.productViews)),
                const SizedBox(width: AppSpace.md),
                Expanded(child: _Metric(icon: Icons.local_offer_outlined, label: 'Promo views', value: m.promotionViews)),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.xl),
          const SectionHeader(title: 'Geofence activity'),
          AppCard(
            margin: const EdgeInsets.symmetric(horizontal: AppSpace.lg),
            child: Column(
              children: [
                _Line(label: 'Notifications sent', value: '${m.notificationsSent}'),
                const Divider(height: AppSpace.xl, color: AppColors.hairline),
                _Line(label: 'Notifications opened', value: '${m.notificationsOpened}'),
                const Divider(height: AppSpace.xl, color: AppColors.hairline),
                _Line(
                  label: 'Open rate',
                  value: m.openRate == null ? 'No data yet' : '${m.openRate!.toStringAsFixed(1)}%',
                  emphasize: m.openRate != null,
                ),
                if (m.openRate != null)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpace.sm),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${m.notificationsOpened} opened ÷ ${m.notificationsSent} sent × 100',
                        style: AppTypography.bodyMuted.copyWith(fontSize: 13),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (noActivity)
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpace.lg, AppSpace.md, AppSpace.lg, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.inkMuted),
                  const SizedBox(width: AppSpace.sm),
                  Expanded(
                    child: Text(
                      'Numbers appear here once customers start finding your business.',
                      style: AppTypography.bodyMuted,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppSpace.xxl),
        ],
      ),
    );
  }
}

class _GeofenceCard extends StatelessWidget {
  const _GeofenceCard({required this.business});
  final Business business;

  @override
  Widget build(BuildContext context) {
    final loc = business.location;
    final live = loc != null && business.verificationStatus.isVerified;
    final active = business.activePromotions.length;

    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: AppSpace.lg),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (loc != null)
            SizedBox(
              height: 190,
              child: GeofenceMap(
                key: ValueKey('${loc.latitude},${loc.longitude}'),
                center: LatLng(loc.latitude, loc.longitude),
                onCenterChanged: (_) {},
                interactive: false,
                initialZoom: 17,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(AppSpace.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    StatusPill(
                      label: live ? 'Active' : (loc == null ? 'Location not set' : 'Waiting for verification'),
                      icon: Icons.circle,
                      foreground: live ? AppColors.tealInk : AppColors.warning,
                      background: live ? AppColors.tealTint : AppColors.warningTint,
                    ),
                    const Spacer(),
                    Text('${BusinessLocation.geofenceRadiusMeters.round()} m coverage',
                        style: AppTypography.label.copyWith(color: AppColors.coralInk)),
                  ],
                ),
                const SizedBox(height: AppSpace.md),
                _Line(label: 'Business location', value: business.locationLabel),
                const SizedBox(height: AppSpace.sm),
                _Line(
                  label: 'Promotions in the area',
                  value: active == 0 ? 'None active' : '$active active',
                ),
                if (!live) ...[
                  const SizedBox(height: AppSpace.md),
                  Text(
                    loc == null
                        ? 'Set your business location to start reaching nearby customers.'
                        : 'The geofence turns on once your business is verified.',
                    style: AppTypography.bodyMuted,
                  ),
                  TextButton(onPressed: () => context.go('/account'), child: const Text('Open Account')),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.tealInk, size: 22),
          const SizedBox(height: AppSpace.md),
          Text('$value', style: AppTypography.display.copyWith(fontSize: 26)),
          const SizedBox(height: 2),
          Text(label, style: AppTypography.bodyMuted.copyWith(fontSize: 12)),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value, this.emphasize = false});
  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: AppTypography.bodyMuted)),
        const SizedBox(width: AppSpace.md),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: emphasize
                ? AppTypography.title.copyWith(color: AppColors.coralInk)
                : AppTypography.section.copyWith(fontSize: 15),
          ),
        ),
      ],
    );
  }
}
