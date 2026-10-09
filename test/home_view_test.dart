import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:market_app/data/repositories/business_repository.dart';
import 'package:market_app/data/services/mock_business_service.dart';
import 'package:market_app/ui/core/theme/app_theme.dart';
import 'package:market_app/ui/features/home/view_models/home_view_model.dart';
import 'package:market_app/ui/features/home/views/home_view.dart';

Future<HomeViewModel> _pumpHome(WidgetTester tester, DemoScenario scenario) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.75;
  addTearDown(tester.view.reset);

  final repo = MockBusinessRepository(service: MockBusinessService())..scenario = scenario;
  final vm = HomeViewModel(repository: repo);
  await tester.pumpWidget(MaterialApp(theme: AppTheme.light(), home: HomeView(viewModel: vm)));
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pumpAndSettle();
  return vm;
}

Future<void> _scrollTo(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(finder, 300, scrollable: find.byType(Scrollable).first);
}

void main() {
  testWidgets('verified business shows identity and Verified badge', (tester) async {
    await _pumpHome(tester, DemoScenario.verifiedNoReviews);

    expect(find.text('Antique Brew Café'), findsOneWidget);
    expect(find.text('Coffee Shop'), findsOneWidget);
    expect(find.text('Verified'), findsOneWidget);
    expect(find.textContaining('Verification:'), findsNothing);
  });

  testWidgets('unverified business never shows Verified', (tester) async {
    await _pumpHome(tester, DemoScenario.underReview);

    expect(find.text('Verified'), findsNothing);
    expect(find.text('Under review'), findsOneWidget);
    expect(find.textContaining('Verification: under review'), findsOneWidget);
  });

  testWidgets('shows "No reviews yet" when there are no reviews', (tester) async {
    await _pumpHome(tester, DemoScenario.verifiedNoReviews);
    await _scrollTo(tester, find.text('No reviews yet'));

    expect(find.text('No reviews yet'), findsOneWidget);
  });

  testWidgets('shows rating summary when reviews exist', (tester) async {
    await _pumpHome(tester, DemoScenario.verifiedWithReviews);
    await _scrollTo(tester, find.text('24 reviews'));

    expect(find.text('4.6'), findsOneWidget);
    expect(find.text('No reviews yet'), findsNothing);
  });

  testWidgets('profile completion card lists missing items', (tester) async {
    await _pumpHome(tester, DemoScenario.verifiedNoReviews);
    await _scrollTo(tester, find.text('Finish profile'));

    expect(find.text('Your profile is 71% complete'), findsOneWidget);
    expect(find.text('Still to add: Logo, Interior photo'), findsOneWidget);
  });
}
