import 'package:flutter_test/flutter_test.dart';
import 'package:market_app/data/repositories/business_repository.dart';
import 'package:market_app/data/services/mock_business_service.dart';
import 'package:market_app/domain/models/business.dart';
import 'package:market_app/ui/features/home/view_models/home_view_model.dart';

class _FailingRepository implements BusinessRepository {
  @override
  DemoScenario scenario = DemoScenario.verifiedNoReviews;

  @override
  Future<Business> getBusiness({bool forceRefresh = false}) async =>
      throw Exception('offline');
}

void main() {
  test('load exposes business and clears loading', () async {
    final vm = HomeViewModel(
      repository: MockBusinessRepository(service: MockBusinessService()),
    );
    final future = vm.load();
    expect(vm.isLoading, isTrue);
    await future;

    expect(vm.isLoading, isFalse);
    expect(vm.business?.name, 'Antique Brew Café');
    expect(vm.error, isNull);
  });

  test('load failure surfaces an actionable error', () async {
    final vm = HomeViewModel(repository: _FailingRepository());
    await vm.load();

    expect(vm.business, isNull);
    expect(vm.error, contains('try again'));
  });

  test('switchScenario reloads with the new state', () async {
    final vm = HomeViewModel(
      repository: MockBusinessRepository(service: MockBusinessService()),
    );
    await vm.load();
    await vm.switchScenario(DemoScenario.verifiedWithReviews);

    expect(vm.scenario, DemoScenario.verifiedWithReviews);
    expect(vm.business!.reviews.count, 24);
  });
}
