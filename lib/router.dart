import 'package:go_router/go_router.dart';

import 'ui/core/session_view_model.dart';
import 'ui/core/widgets/app_shell.dart';
import 'ui/features/account/views/account_view.dart';
import 'ui/features/business_pulse/views/business_pulse_view.dart';
import 'ui/features/home/view_models/home_view_model.dart';
import 'ui/features/home/views/home_view.dart';
import 'ui/features/onboarding/views/onboarding_view.dart';
import 'ui/features/promo_studio/views/promo_studio_view.dart';

GoRouter buildRouter({
  required HomeViewModel homeViewModel,
  required SessionViewModel session,
}) {
  return GoRouter(
    initialLocation: '/onboarding',
    refreshListenable: session,
    // Everything except onboarding requires a finished onboarding.
    redirect: (context, state) {
      final onboarding = state.matchedLocation == '/onboarding';
      if (!session.isOnboarded && !onboarding) return '/onboarding';
      if (session.isOnboarded && onboarding) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingView()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => HomeView(viewModel: homeViewModel),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/promo-studio', builder: (context, state) => const PromoStudioView()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/business-pulse', builder: (context, state) => const BusinessPulseView()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/account', builder: (context, state) => const AccountView()),
          ]),
        ],
      ),
    ],
  );
}
