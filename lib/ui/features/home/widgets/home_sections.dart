import 'package:flutter/material.dart';

import '../../../../domain/models/business.dart';
import '../../../../domain/models/product.dart';
import '../../../../domain/models/promotion.dart';
import '../../../../domain/models/review_summary.dart';
import '../../../../domain/models/verification_status.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/section_header.dart';

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

String formatDateRange(DateTime start, DateTime end) =>
    '${_months[start.month - 1]} ${start.day} – ${_months[end.month - 1]} ${end.day}';

BoxDecoration _cardDecoration() => BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.card),
      border: Border.all(color: AppColors.hairline),
    );

// ---------------------------------------------------------------------------
// Verification notice (shown only when not verified)
// ---------------------------------------------------------------------------

class VerificationNotice extends StatelessWidget {
  const VerificationNotice({super.key, required this.status});

  final VerificationStatus status;

  @override
  Widget build(BuildContext context) {
    final message = switch (status) {
      VerificationStatus.pending ||
      VerificationStatus.underReview =>
        'Your documents are being reviewed. Your business will show as verified once they are approved.',
      VerificationStatus.requiresCorrection =>
        'Some documents need correction. Update them in Account to continue verification.',
      VerificationStatus.rejected =>
        'Verification was not approved. Check Account for the reason and next steps.',
      VerificationStatus.verified => '',
    };
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpace.lg),
      padding: const EdgeInsets.all(AppSpace.lg),
      decoration: BoxDecoration(
        color: AppColors.warningTint,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.hourglass_top_rounded, color: AppColors.warning),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Verification: ${status.label.toLowerCase()}',
                    style: AppTypography.section.copyWith(fontSize: 15)),
                const SizedBox(height: 4),
                Text(message, style: AppTypography.bodyMuted.copyWith(color: AppColors.ink)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Profile completion (shown only while incomplete)
// ---------------------------------------------------------------------------

class ProfileCompletionCard extends StatelessWidget {
  const ProfileCompletionCard({super.key, required this.business, required this.onFinish});

  final Business business;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final percent = (business.profileCompletion * 100).round();
    final missing = business.missingProfileItems;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpace.lg),
      padding: const EdgeInsets.all(AppSpace.lg),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Your profile is $percent% complete', style: AppTypography.section),
              ),
              Text('$percent%',
                  style: AppTypography.section.copyWith(color: AppColors.tealInk)),
            ],
          ),
          const SizedBox(height: AppSpace.md),
          Semantics(
            label: 'Profile $percent percent complete',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: business.profileCompletion,
                minHeight: 8,
                backgroundColor: AppColors.tealTint,
                color: AppColors.teal,
              ),
            ),
          ),
          const SizedBox(height: AppSpace.md),
          Text('Still to add: ${missing.join(', ')}', style: AppTypography.bodyMuted),
          const SizedBox(height: AppSpace.md),
          FilledButton(onPressed: onFinish, child: const Text('Finish profile')),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Active promotions carousel
// ---------------------------------------------------------------------------

class ActivePromotionsSection extends StatefulWidget {
  const ActivePromotionsSection({
    super.key,
    required this.promotions,
    required this.onViewAll,
    required this.onCreate,
  });

  final List<Promotion> promotions;
  final VoidCallback onViewAll;
  final VoidCallback onCreate;

  @override
  State<ActivePromotionsSection> createState() => _ActivePromotionsSectionState();
}

class _ActivePromotionsSectionState extends State<ActivePromotionsSection> {
  final _controller = PageController(viewportFraction: 0.88);
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final promos = widget.promotions;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: promos.isEmpty ? 'Active promotions' : 'Active promotions (${promos.length})',
          trailingLabel: 'View all',
          onTrailingTap: widget.onViewAll,
        ),
        if (promos.isEmpty)
          _NoPromotions(onCreate: widget.onCreate)
        else ...[
          SizedBox(
            height: 196,
            child: PageView.builder(
              controller: _controller,
              padEnds: false,
              itemCount: promos.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (context, i) => Padding(
                padding: EdgeInsets.only(left: AppSpace.lg, right: i == promos.length - 1 ? AppSpace.lg : 0),
                child: _PromotionCard(promotion: promos[i], onTap: widget.onViewAll),
              ),
            ),
          ),
          if (promos.length > 1) ...[
            const SizedBox(height: AppSpace.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < promos.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _page ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == _page ? AppColors.coral : AppColors.hairline,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ],
    );
  }
}

class _PromotionCard extends StatelessWidget {
  const _PromotionCard({required this.promotion, required this.onTap});

  final Promotion promotion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${promotion.offer}, ${promotion.title}, '
          '${formatDateRange(promotion.startDate, promotion.endDate)}',
      excludeSemantics: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.media),
        child: Material(
          color: AppColors.coral,
          child: InkWell(
            onTap: onTap,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (promotion.imageAsset != null)
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    width: 220,
                    child: AppImage(promotion.imageAsset!),
                  ),
                // Coral wash fades into the photo so the offer always reads.
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      stops: [0, 0.42, 0.75],
                      colors: [AppColors.coral, AppColors.coral, Color(0x00E76F51)],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpace.lg + 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        promotion.offer,
                        style: AppTypography.display.copyWith(color: Colors.white, fontSize: 26),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: 170,
                        child: Text(
                          promotion.title,
                          maxLines: 2,
                          style: AppTypography.section.copyWith(color: Colors.white, fontSize: 18),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.event_rounded, size: 14, color: AppColors.coralInk),
                            const SizedBox(width: 5),
                            Text(
                              formatDateRange(promotion.startDate, promotion.endDate),
                              style: AppTypography.label.copyWith(color: AppColors.coralInk),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NoPromotions extends StatelessWidget {
  const _NoPromotions({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpace.lg),
      padding: const EdgeInsets.all(AppSpace.lg),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('No active promotions', style: AppTypography.section),
          const SizedBox(height: 4),
          Text('Create one to reach customers within 100 meters of your business.',
              style: AppTypography.bodyMuted),
          const SizedBox(height: AppSpace.md),
          FilledButton(onPressed: onCreate, child: const Text('Create promotion')),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bestsellers strip
// ---------------------------------------------------------------------------

class BestsellersSection extends StatelessWidget {
  const BestsellersSection({super.key, required this.products, this.fallbackIcon = Icons.storefront_rounded});

  final List<Product> products;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Bestsellers'),
        SizedBox(
          height: 236,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpace.md),
            itemBuilder: (context, i) => _BestsellerCard(product: products[i], fallbackIcon: fallbackIcon),
          ),
        ),
      ],
    );
  }
}

class _BestsellerCard extends StatelessWidget {
  const _BestsellerCard({required this.product, required this.fallbackIcon});

  final Product product;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 172,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.media),
            child: AspectRatio(
              aspectRatio: 1,
              child: product.imageAsset != null
                  ? AppImage(product.imageAsset!, semanticLabel: product.name)
                  : ColoredBox(
                      color: AppColors.tealTint,
                      child: Icon(fallbackIcon, color: AppColors.tealInk, size: 40),
                    ),
            ),
          ),
          const SizedBox(height: AppSpace.sm),
          Text(product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.section.copyWith(fontSize: 15)),
          const SizedBox(height: 2),
          Text(product.priceLabel, style: AppTypography.label.copyWith(color: AppColors.tealInk)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Business summary (spec §6.3) — summary only, editing lives in Account
// ---------------------------------------------------------------------------

class BusinessSummaryCard extends StatelessWidget {
  const BusinessSummaryCard({super.key, required this.business, required this.onEdit});

  final Business business;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'About your business', trailingLabel: 'Edit', onTrailingTap: onEdit),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpace.lg),
          padding: const EdgeInsets.all(AppSpace.lg),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(business.description, style: AppTypography.bodyText),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpace.md),
                child: Divider(height: 1, color: AppColors.hairline),
              ),
              _InfoRow(icon: Icons.schedule_rounded, text: business.operatingHours),
              _InfoRow(icon: Icons.call_rounded, text: business.contactNumber),
              _InfoRow(icon: Icons.place_outlined, text: business.address),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.tealInk),
          const SizedBox(width: AppSpace.md),
          Expanded(child: Text(text, style: AppTypography.bodyText.copyWith(fontSize: 14))),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Products & services summary (spec §6.4)
// ---------------------------------------------------------------------------

class ProductsSummaryTile extends StatelessWidget {
  const ProductsSummaryTile({
    super.key,
    required this.count,
    required this.onViewAll,
    this.label = 'Products & services',
    this.icon = Icons.inventory_2_outlined,
    this.color = AppColors.deepTeal,
  });

  final int count;
  final VoidCallback onViewAll;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.card),
          onTap: onViewAll,
          child: Padding(
            padding: const EdgeInsets.all(AppSpace.lg),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: Colors.white),
                ),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: AppTypography.section.copyWith(color: Colors.white)),
                      Text('$count ${count == 1 ? 'item' : 'items'}',
                          style: AppTypography.bodyMuted.copyWith(color: Colors.white70)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reviews (spec §6.7)
// ---------------------------------------------------------------------------

class ReviewsCard extends StatelessWidget {
  const ReviewsCard({super.key, required this.reviews, required this.onViewAll});

  final ReviewSummary reviews;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Reviews',
          trailingLabel: reviews.hasReviews ? 'View all' : null,
          onTrailingTap: onViewAll,
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpace.lg),
          padding: const EdgeInsets.all(AppSpace.lg),
          decoration: _cardDecoration(),
          child: reviews.hasReviews ? _withReviews() : _empty(),
        ),
      ],
    );
  }

  Widget _empty() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(color: AppColors.coralTint, shape: BoxShape.circle),
          child: const Icon(Icons.star_outline_rounded, color: AppColors.coralInk),
        ),
        const SizedBox(width: AppSpace.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('No reviews yet', style: AppTypography.section),
              const SizedBox(height: 2),
              Text('Customers have not submitted a review for this business yet.',
                  style: AppTypography.bodyMuted),
            ],
          ),
        ),
      ],
    );
  }

  Widget _withReviews() {
    final full = reviews.averageRating.floor();
    final half = reviews.averageRating - full >= 0.5;
    return Semantics(
      label: 'Rated ${reviews.averageRating} out of 5 from ${reviews.count} reviews',
      excludeSemantics: true,
      child: Row(
        children: [
          Text(reviews.averageRating.toStringAsFixed(1),
              style: AppTypography.display.copyWith(fontSize: 40)),
          const SizedBox(width: AppSpace.lg),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  for (var i = 0; i < 5; i++)
                    Icon(
                      i < full
                          ? Icons.star_rounded
                          : (i == full && half ? Icons.star_half_rounded : Icons.star_outline_rounded),
                      size: 22,
                      color: AppColors.coral,
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text('${reviews.count} reviews', style: AppTypography.bodyMuted),
            ],
          ),
        ],
      ),
    );
  }
}
