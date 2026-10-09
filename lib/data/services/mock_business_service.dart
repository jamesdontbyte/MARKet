import '../../domain/models/business.dart';
import '../../domain/models/business_location.dart';
import '../../domain/models/product.dart';
import '../../domain/models/pulse_metrics.dart';
import '../../domain/models/verification_document.dart';
import '../../domain/models/promotion.dart';
import '../../domain/models/review_summary.dart';
import '../../domain/models/verification_status.dart';

/// Demo states so every Home state required by the spec can be shown.
enum DemoScenario {
  verifiedNoReviews('Verified, no reviews'),
  underReview('Under review'),
  verifiedWithReviews('Verified, with reviews');

  const DemoScenario(this.label);
  final String label;
}

/// Local stand-in for a backend. Replace with a real API service later;
/// the repository contract stays the same.
class MockBusinessService {
  MockBusinessService({DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;

  Future<Business> fetchBusiness(DemoScenario scenario) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final base = _baseBusiness();
    return switch (scenario) {
      DemoScenario.verifiedNoReviews => base,
      DemoScenario.underReview =>
        base.copyWith(verificationStatus: VerificationStatus.underReview),
      DemoScenario.verifiedWithReviews => base.copyWith(
          reviews: const ReviewSummary(count: 24, averageRating: 4.6),
        ),
    };
  }

  Business _baseBusiness() {
    final today = _clock();
    final d = DateTime(today.year, today.month, today.day);

    return Business(
      name: 'Antique Brew Café',
      category: 'Coffee Shop',
      description:
          'A neighborhood café in San Jose de Buenavista serving locally '
          'roasted coffee and freshly baked Antiqueño pastries.',
      municipality: 'San Jose de Buenavista',
      barangay: 'Poblacion',
      address: 'T. Fornier St., Poblacion, San Jose de Buenavista',
      contactNumber: '0917 555 0142',
      operatingHours: 'Mon–Sat, 7:00 AM – 9:00 PM',
      verificationStatus: VerificationStatus.verified,
      storefrontAsset: 'assets/images/storefront.jpg',
      location: const BusinessLocation(latitude: 10.7447, longitude: 121.9402),
      documents: [
        for (final t in DocumentType.values)
          VerificationDocument(type: t, filePath: 'demo/${t.name}'),
      ],
      metrics: const PulseMetrics(
        profileViews: 127,
        productViews: 83,
        promotionViews: 54,
        notificationsSent: 42,
        notificationsOpened: 18,
      ),
      // Logo and interior photo intentionally not uploaded yet.
      products: const [
        Product(
          id: 'p1',
          name: 'Cappuccino',
          category: 'Coffee',
          priceLabel: '₱120',
          imageAsset: 'assets/images/promo_cappuccino.jpg',
          isBestseller: true,
        ),
        Product(
          id: 'p2',
          name: 'Cheese ensaymada',
          category: 'Pastry',
          priceLabel: '₱65',
          imageAsset: 'assets/images/promo_ensaymada.jpg',
          isBestseller: true,
        ),
        Product(id: 'p3', name: 'Spanish latte', category: 'Coffee', priceLabel: '₱140'),
        Product(id: 'p4', name: 'Americano', category: 'Coffee', priceLabel: '₱100'),
        Product(id: 'p5', name: 'Iced mocha', category: 'Coffee', priceLabel: '₱150'),
        Product(id: 'p6', name: 'Mango cheesecake', category: 'Pastry', priceLabel: '₱130'),
        Product(id: 'p7', name: 'Banana bread', category: 'Pastry', priceLabel: '₱75'),
        Product(id: 'p8', name: 'Event catering', category: 'Service', priceLabel: '₱2,500–₱8,000'),
      ],
      promotions: [
        Promotion(
          id: 'promo1',
          title: 'Morning pair',
          offer: 'Buy 1 Take 1',
          description: 'Two cappuccinos for the price of one before 10 AM.',
          startDate: d.subtract(const Duration(days: 2)),
          endDate: d.add(const Duration(days: 5)),
          state: PromotionState.active,
          imageAsset: 'assets/images/promo_cappuccino.jpg',
          relatedProductId: 'p1',
        ),
        Promotion(
          id: 'promo2',
          title: 'Merienda deal',
          offer: '₱20 off',
          description: 'Ensaymada with any iced coffee.',
          startDate: d,
          endDate: d.add(const Duration(days: 10)),
          state: PromotionState.active,
          imageAsset: 'assets/images/promo_ensaymada.jpg',
          relatedProductId: 'p2',
        ),
        Promotion(
          id: 'promo3',
          title: 'Student discount',
          offer: '10% off',
          startDate: d.subtract(const Duration(days: 20)),
          endDate: d.subtract(const Duration(days: 8)),
          state: PromotionState.expired,
        ),
      ],
      reviews: const ReviewSummary.empty(),
    );
  }
}
