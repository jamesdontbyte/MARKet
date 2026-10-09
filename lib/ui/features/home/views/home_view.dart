import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../data/services/mock_business_service.dart';
import '../../../../domain/models/business.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/photo_tint.dart';
import '../../../core/widgets/wordmark.dart';
import '../view_models/home_view_model.dart';
import '../widgets/home_hero.dart';
import '../widgets/home_sections.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key, required this.viewModel});

  final HomeViewModel viewModel;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.viewModel.business == null) {
        widget.viewModel.load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final vm = widget.viewModel;
        final business = vm.business;
        if (business == null) {
          return Scaffold(
            backgroundColor: AppColors.deepTeal,
            body: Center(
              child: vm.error != null
                  ? _ErrorState(message: vm.error!, onRetry: vm.load)
                  : const CircularProgressIndicator(color: Colors.white),
            ),
          );
        }
        return Scaffold(
          body: RefreshIndicator(
            color: AppColors.deepTeal,
            edgeOffset: 120,
            onRefresh: () => vm.load(forceRefresh: true),
            child: _HomeContent(business: business, viewModel: vm),
          ),
        );
      },
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.business, required this.viewModel});

  final Business business;
  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final heroHeight = (MediaQuery.sizeOf(context).height * 0.5).clamp(340.0, 480.0);
    const gap = SliverToBoxAdapter(child: SizedBox(height: AppSpace.xl + 4));

    return PhotoTint(
      photoPath: business.heroPhoto,
      builder: (context, tint) => _scroll(context, tint, reduceMotion, heroHeight, gap),
    );
  }

  Widget _scroll(BuildContext context, Color tint, bool reduceMotion, double heroHeight, Widget gap) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      slivers: [
        SliverAppBar(
          pinned: true,
          stretch: !reduceMotion,
          expandedHeight: heroHeight,
          backgroundColor: tint,
          surfaceTintColor: Colors.transparent,
          titleSpacing: AppSpace.lg,
          title: const Wordmark(),
          actions: [
            if (kDebugMode)
              IconButton(
                tooltip: 'Switch demo state',
                icon: const Icon(Icons.tune_rounded, color: Colors.white),
                onPressed: () => _showScenarioSheet(context),
              ),
            const SizedBox(width: AppSpace.xs),
          ],
          flexibleSpace: FlexibleSpaceBar(
            collapseMode: reduceMotion ? CollapseMode.pin : CollapseMode.parallax,
            stretchModes: const [StretchMode.zoomBackground],
            background: HomeHeroBackground(business: business, tint: tint),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(20),
            child: Container(
              height: 20,
              decoration: const BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
            ),
          ),
        ),
        if (!business.verificationStatus.isVerified) ...[
          SliverToBoxAdapter(child: VerificationNotice(status: business.verificationStatus)),
          gap,
        ],
        if (business.profileCompletion < 1) ...[
          SliverToBoxAdapter(
            child: ProfileCompletionCard(
              business: business,
              onFinish: () => context.go('/account'),
            ),
          ),
          gap,
        ],
        SliverToBoxAdapter(
          child: ActivePromotionsSection(
            promotions: business.activePromotions,
            onViewAll: () => context.go('/promo-studio'),
            onCreate: () => context.go('/promo-studio'),
          ),
        ),
        gap,
        SliverToBoxAdapter(
          child: BestsellersSection(products: business.bestsellers, fallbackIcon: business.msmeCategory.icon),
        ),
        gap,
        SliverToBoxAdapter(
          child: ProductsSummaryTile(
            count: business.products.length,
            label: business.msmeCategory.itemLabel,
            icon: business.msmeCategory.icon,
            color: tint,
            onViewAll: () => context.go('/account'),
          ),
        ),
        gap,
        SliverToBoxAdapter(
          child: BusinessSummaryCard(business: business, onEdit: () => context.go('/account')),
        ),
        gap,
        SliverToBoxAdapter(
          child: ReviewsCard(
            reviews: business.reviews,
            onViewAll: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('The full review list is coming in a later update.')),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpace.xxl)),
      ],
    );
  }

  void _showScenarioSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpace.xl, 0, AppSpace.xl, AppSpace.sm),
              child: Text('Demo state (debug only)', style: AppTypography.section),
            ),
            for (final s in DemoScenario.values)
              ListTile(
                title: Text(s.label, style: AppTypography.bodyText),
                trailing: s == viewModel.scenario
                    ? const Icon(Icons.check_rounded, color: AppColors.tealInk)
                    : null,
                onTap: () {
                  Navigator.pop(sheetContext);
                  viewModel.switchScenario(s);
                },
              ),
            const SizedBox(height: AppSpace.sm),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpace.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_rounded, color: Colors.white, size: 48),
          const SizedBox(height: AppSpace.lg),
          Text(message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyText.copyWith(color: Colors.white)),
          const SizedBox(height: AppSpace.lg),
          FilledButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    );
  }
}
