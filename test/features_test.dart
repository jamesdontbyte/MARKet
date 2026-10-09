import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:market_app/data/repositories/business_repository.dart';
import 'package:market_app/data/services/mock_business_service.dart';
import 'package:market_app/domain/models/personal_account.dart';
import 'package:market_app/ui/core/session_view_model.dart';
import 'package:market_app/ui/core/theme/app_theme.dart';
import 'package:market_app/ui/features/account/views/account_view.dart';
import 'package:market_app/ui/features/business_pulse/views/business_pulse_view.dart';
import 'package:market_app/ui/features/home/view_models/home_view_model.dart';
import 'package:market_app/ui/features/onboarding/views/onboarding_view.dart';
import 'package:market_app/ui/features/promo_studio/views/promo_studio_view.dart';
import 'package:provider/provider.dart';

Widget _wrap(Widget child, {required HomeViewModel home, required SessionViewModel session}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<HomeViewModel>.value(value: home),
      ChangeNotifierProvider<SessionViewModel>.value(value: session),
    ],
    child: MaterialApp(
      theme: AppTheme.light(),
      home: child,
    ),
  );
}

Future<void> _prepareBusiness(WidgetTester tester, HomeViewModel vm) async {
  vm.load();
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pumpAndSettle();
}

void main() {
  late MockBusinessRepository repo;
  late HomeViewModel homeVm;
  late SessionViewModel sessionVm;

  setUp(() {
    repo = MockBusinessRepository(service: MockBusinessService());
    homeVm = HomeViewModel(repository: repo);
    sessionVm = SessionViewModel()
      ..completeOnboarding(
        const PersonalAccount(
          fullName: 'Maria Dela Cruz',
          email: 'maria@antiquebrew.ph',
          mobile: '0917 555 0142',
        ),
      );
  });

  testWidgets('OnboardingView renders welcome and can explore demo', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap(const OnboardingView(), home: homeVm, session: sessionVm));
    await tester.pumpAndSettle();

    expect(find.text('Put your business\non the map.'), findsOneWidget);
    expect(find.text('Create my account'), findsOneWidget);
    expect(find.text('Explore with demo data'), findsOneWidget);
  });

  testWidgets('PromoStudioView shows active promotions and tabs', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap(const PromoStudioView(), home: homeVm, session: sessionVm));
    await _prepareBusiness(tester, homeVm);

    expect(find.text('Promo Studio'), findsOneWidget);
    expect(find.text('Create promotion'), findsOneWidget);
    expect(find.text('Morning pair'), findsOneWidget);
    expect(find.text('Buy 1 Take 1'), findsOneWidget);
  });

  testWidgets('BusinessPulseView shows 100m geofence and metrics', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap(const BusinessPulseView(), home: homeVm, session: sessionVm));
    await _prepareBusiness(tester, homeVm);

    expect(find.text('Business Pulse'), findsOneWidget);
    expect(find.text('100 m coverage'), findsOneWidget);
    expect(find.text('Profile views'), findsOneWidget);
    expect(find.text('127'), findsOneWidget);
    expect(find.text('Notifications sent'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);
    expect(find.text('Notifications opened'), findsOneWidget);
    expect(find.text('18'), findsOneWidget);
    expect(find.text('42.9%'), findsOneWidget);
  });

  testWidgets('AccountView displays business information and menu items', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap(const AccountView(), home: homeVm, session: sessionVm));
    await _prepareBusiness(tester, homeVm);

    expect(find.text('Account'), findsOneWidget);
    expect(find.text('Personal information'), findsOneWidget);
    expect(find.text('Business information'), findsOneWidget);
    expect(find.text('Business media'), findsOneWidget);
    expect(find.text('Verification documents'), findsOneWidget);
    expect(find.text('Location'), findsOneWidget);
    expect(find.text('Sign out'), findsOneWidget);
  });
}
