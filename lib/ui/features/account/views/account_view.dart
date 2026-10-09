import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/session_view_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/brand_header.dart';
import '../../../core/widgets/verification_badge.dart';
import '../../home/view_models/home_view_model.dart';
import 'account_pages.dart';
import 'products_page.dart';

/// Account (spec §10): personal details, business details, media, products,
/// verification documents and location.
class AccountView extends StatelessWidget {
  const AccountView({super.key});

  void _open(BuildContext context, Widget page) =>
      Navigator.push(context, MaterialPageRoute<void>(builder: (_) => page));

  Future<void> _signOut(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You will return to the start screen.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Sign out')),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    context.read<HomeViewModel>().clear();
    context.read<SessionViewModel>().signOut();
  }

  @override
  Widget build(BuildContext context) {
    final business = context.watch<HomeViewModel>().business;
    final account = context.watch<SessionViewModel>().account;
    if (business == null) return const SizedBox.shrink();

    final loc = business.location;
    final tiles = <_Item>[
      _Item(Icons.person_outline_rounded, 'Personal information',
          account?.email.isNotEmpty == true ? account!.email : account?.mobile ?? '',
          () => _open(context, const PersonalInfoPage())),
      _Item(Icons.storefront_outlined, 'Business information', business.name,
          () => _open(context, const BusinessInfoPage())),
      _Item(Icons.photo_library_outlined, 'Business media',
          'Logo, storefront and interior photos', () => _open(context, const MediaPage())),
      _Item(business.msmeCategory.icon, business.msmeCategory.itemLabel,
          '${business.products.length} ${business.products.length == 1 ? 'item' : 'items'}',
          () => openProductsPage(context)),
      _Item(Icons.fact_check_outlined, 'Verification documents', business.verificationStatus.label,
          () => _open(context, const DocumentsPage())),
      _Item(Icons.place_outlined, 'Location',
          loc == null ? 'Not set' : '${business.locationLabel} · 100 m geofence',
          () => _open(context, const LocationPage())),
    ];

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          BrandHeader(
            title: 'Account',
            subtitle: account?.fullName ?? 'Manage your account and business.',
            photoPath: business.heroPhoto,
            bottom: Row(
              children: [
                Flexible(
                  child: Text(business.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.section.copyWith(color: Colors.white)),
                ),
                const SizedBox(width: AppSpace.md),
                VerificationBadge(status: business.verificationStatus),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.lg),
          for (final t in tiles)
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpace.lg, 0, AppSpace.lg, AppSpace.md),
              child: AppCard(
                onTap: t.onTap,
                padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg, vertical: AppSpace.md),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.tealTint,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(t.icon, color: AppColors.tealInk),
                    ),
                    const SizedBox(width: AppSpace.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.title, style: AppTypography.section.copyWith(fontSize: 15)),
                          if (t.subtitle.isNotEmpty)
                            Text(t.subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.bodyMuted.copyWith(fontSize: 13)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.inkMuted),
                  ],
                ),
              ),
            ),
          const SizedBox(height: AppSpace.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg),
            child: OutlinedButton.icon(
              onPressed: () => _signOut(context),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sign out'),
            ),
          ),
          const SizedBox(height: AppSpace.xxl),
        ],
      ),
    );
  }
}

class _Item {
  const _Item(this.icon, this.title, this.subtitle, this.onTap);
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
}
