import 'package:flutter_test/flutter_test.dart';
import 'package:market_app/data/repositories/business_repository.dart';
import 'package:market_app/data/services/mock_business_service.dart';
import 'package:market_app/domain/models/verification_status.dart';

void main() {
  late MockBusinessRepository repository;

  setUp(() {
    repository = MockBusinessRepository(
      service: MockBusinessService(clock: () => DateTime(2026, 10, 8)),
    );
  });

  test('default scenario is verified with no reviews', () async {
    final business = await repository.getBusiness();

    expect(business.verificationStatus, VerificationStatus.verified);
    expect(business.reviews.hasReviews, isFalse);
  });

  test('bestsellers are flagged existing products, not duplicates', () async {
    final business = await repository.getBusiness();

    expect(business.bestsellers.map((p) => p.name), ['Cappuccino', 'Cheese ensaymada']);
    for (final b in business.bestsellers) {
      expect(business.products, contains(b));
    }
  });

  test('only active promotions are exposed as active', () async {
    final business = await repository.getBusiness();

    expect(business.promotions, hasLength(3));
    expect(business.activePromotions, hasLength(2));
  });

  test('profile completion reflects missing logo and interior photo', () async {
    final business = await repository.getBusiness();

    expect(business.missingProfileItems, ['Logo', 'Interior photo']);
    expect(business.profileCompletion, closeTo(5 / 7, 0.001));
  });

  test('caches until scenario changes', () async {
    final first = await repository.getBusiness();
    expect(identical(first, await repository.getBusiness()), isTrue);

    repository.scenario = DemoScenario.underReview;
    final second = await repository.getBusiness();
    expect(second.verificationStatus, VerificationStatus.underReview);
  });
}
