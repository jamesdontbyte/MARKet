import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../domain/models/business.dart';
import '../../../../domain/models/promotion.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/brand_header.dart';
import '../../home/view_models/home_view_model.dart';
import '../../home/widgets/home_sections.dart' show formatDateRange;
import 'promotion_editor.dart';

/// Promo Studio (spec §8): create and manage promotions.
class PromoStudioView extends StatefulWidget {
  const PromoStudioView({super.key});

  @override
  State<PromoStudioView> createState() => _PromoStudioViewState();
}

class _PromoStudioViewState extends State<PromoStudioView> {
  int _tab = 0;

  static const _states = [PromotionState.active, PromotionState.draft, PromotionState.expired];

  Future<void> _create(Business business) async {
    final result = await showPromotionEditor(context, products: business.products);
    if (result == null || !mounted) return;
    context.read<HomeViewModel>().update((b) => b.copyWith(promotions: [result, ...b.promotions]));
    setState(() => _tab = result.state == PromotionState.draft ? 1 : 0);
    _toast(result.state == PromotionState.draft ? 'Saved as draft' : 'Promotion published');
  }

  Future<void> _edit(Business business, Promotion promo) async {
    final result = await showPromotionEditor(context, products: business.products, existing: promo);
    if (result == null || !mounted) return;
    _replace(result);
  }

  void _replace(Promotion updated) {
    context.read<HomeViewModel>().update((b) => b.copyWith(
          promotions: [for (final p in b.promotions) p.id == updated.id ? updated : p],
        ));
  }

  Future<void> _delete(Promotion promo) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete this promotion?'),
        content: Text('"${promo.title}" will be removed. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    context.read<HomeViewModel>().update(
        (b) => b.copyWith(promotions: b.promotions.where((p) => p.id != promo.id).toList()));
    _toast('Promotion deleted');
  }

  void _toast(String message) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    final business = context.watch<HomeViewModel>().business;
    if (business == null) return const SizedBox.shrink();

    final all = business.promotions;
    int count(PromotionState s) => all.where((p) => p.state == s).length;
    final shown = all.where((p) => p.state == _states[_tab]).toList();

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          BrandHeader(
            title: 'Promo Studio',
            subtitle: 'Create offers for customers within 100 meters.',
            photoPath: business.heroPhoto,
            bottom: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _create(business),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Create promotion'),
              ),
            ),
          ),
          const SizedBox(height: AppSpace.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg),
            child: PillTabs(
              labels: [
                'Active (${count(PromotionState.active)})',
                'Drafts (${count(PromotionState.draft)})',
                'Expired (${count(PromotionState.expired)})',
              ],
              selected: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
          ),
          const SizedBox(height: AppSpace.lg),
          if (shown.isEmpty)
            _Empty(tab: _tab, onCreate: () => _create(business))
          else
            for (final p in shown)
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpace.lg, 0, AppSpace.lg, AppSpace.md),
                child: _PromoTile(
                  promotion: p,
                  fallbackImage: business.products
                      .where((x) => x.id == p.relatedProductId)
                      .map((x) => x.imageAsset)
                      .firstOrNull,
                  onToggle: (on) => _replace(
                      p.copyWith(state: on ? PromotionState.active : PromotionState.draft)),
                  onEdit: () => _edit(business, p),
                  onDelete: () => _delete(p),
                ),
              ),
          const SizedBox(height: AppSpace.xl),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.tab, required this.onCreate});
  final int tab;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final (title, body) = switch (tab) {
      0 => ('No active promotions', 'Publish an offer so nearby customers can see it.'),
      1 => ('No drafts', 'Drafts you save while you are still working appear here.'),
      _ => ('Nothing expired yet', 'Promotions that have ended appear here.'),
    };
    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: AppSpace.lg),
      child: Column(
        children: [
          const Icon(Icons.campaign_outlined, size: 40, color: AppColors.tealInk),
          const SizedBox(height: AppSpace.sm),
          Text(title, style: AppTypography.section),
          const SizedBox(height: 4),
          Text(body, textAlign: TextAlign.center, style: AppTypography.bodyMuted),
          if (tab == 0) ...[
            const SizedBox(height: AppSpace.md),
            FilledButton(onPressed: onCreate, child: const Text('Create promotion')),
          ],
        ],
      ),
    );
  }
}

class _PromoTile extends StatelessWidget {
  const _PromoTile({
    required this.promotion,
    required this.fallbackImage,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final Promotion promotion;
  final String? fallbackImage;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final image = promotion.imageAsset ?? fallbackImage;
    final expired = promotion.state == PromotionState.expired;
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 96,
                  child: image != null
                      ? Opacity(opacity: expired ? 0.55 : 1, child: AppImage(image))
                      : ColoredBox(
                          color: expired ? AppColors.hairline : AppColors.coralTint,
                          child: Icon(Icons.local_offer_rounded,
                              color: expired ? AppColors.inkMuted : AppColors.coralInk),
                        ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpace.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(promotion.offer,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.title.copyWith(
                                color: expired ? AppColors.inkMuted : AppColors.coralInk)),
                        const SizedBox(height: 2),
                        Text(promotion.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.section.copyWith(fontSize: 15)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.event_rounded, size: 14, color: AppColors.inkMuted),
                            const SizedBox(width: 4),
                            Text(formatDateRange(promotion.startDate, promotion.endDate),
                                style: AppTypography.label.copyWith(color: AppColors.inkMuted)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.hairline),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpace.md, 2, AppSpace.xs, 2),
            child: Row(
              children: [
                StatusPill(
                  label: switch (promotion.state) {
                    PromotionState.active => 'Active',
                    PromotionState.draft => 'Draft',
                    PromotionState.expired => 'Expired',
                  },
                  foreground: switch (promotion.state) {
                    PromotionState.active => AppColors.tealInk,
                    PromotionState.draft => AppColors.warning,
                    PromotionState.expired => AppColors.inkMuted,
                  },
                  background: switch (promotion.state) {
                    PromotionState.active => AppColors.tealTint,
                    PromotionState.draft => AppColors.warningTint,
                    PromotionState.expired => AppColors.hairline,
                  },
                ),
                const Spacer(),
                if (!expired)
                  Semantics(
                    label: promotion.isActive ? 'Deactivate promotion' : 'Activate promotion',
                    child: Switch(
                      value: promotion.isActive,
                      activeTrackColor: AppColors.teal,
                      onChanged: onToggle,
                    ),
                  ),
                IconButton(
                  tooltip: 'Edit promotion',
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, color: AppColors.deepTeal),
                ),
                IconButton(
                  tooltip: 'Delete promotion',
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.inkMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
