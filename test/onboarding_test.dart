import 'package:flutter_test/flutter_test.dart';
import 'package:market_app/domain/models/business_location.dart';
import 'package:market_app/domain/models/msme_category.dart';
import 'package:market_app/domain/models/pulse_metrics.dart';
import 'package:market_app/domain/models/verification_document.dart';
import 'package:market_app/domain/models/verification_status.dart';
import 'package:market_app/ui/features/onboarding/view_models/onboarding_view_model.dart';

void main() {
  group('OnboardingViewModel', () {
    test('walks the spec workflow in order', () {
      final vm = OnboardingViewModel();
      expect(vm.step, OnboardingStep.welcome);
      final seen = <OnboardingStep>[];
      for (var i = 0; i < 5; i++) {
        vm.next();
        seen.add(vm.step);
      }
      expect(seen, [
        OnboardingStep.personal,
        OnboardingStep.business,
        OnboardingStep.documents,
        OnboardingStep.verification,
        OnboardingStep.location,
      ]);
    });

    test('documents cannot be submitted until all four are uploaded', () {
      final vm = OnboardingViewModel();
      for (final t in DocumentType.values.take(3)) {
        vm.setDocument(t, 'x/${t.name}.jpg');
      }
      expect(vm.submitDocuments(), isFalse);
      vm.setDocument(DocumentType.values.last, 'x/id.jpg');
      expect(vm.submitDocuments(), isTrue);
      expect(vm.verification, VerificationStatus.underReview);
      expect(vm.step, OnboardingStep.verification);
    });

    test('built business keeps the chosen category, any MSME type', () {
      final vm = OnboardingViewModel()
        ..businessName = 'Patadyong Hub'
        ..category = MsmeCategory.retail
        ..municipality = 'Tibiao';
      final b = vm.buildBusiness();
      expect(b.category, 'Retail');
      expect(b.msmeCategory, MsmeCategory.retail);
      expect(b.heroPhoto, isNull);
      expect(b.location, isNotNull);
    });
  });

  group('PulseMetrics', () {
    test('open rate matches the spec example', () {
      const m = PulseMetrics(notificationsSent: 42, notificationsOpened: 18);
      expect(m.openRate!.toStringAsFixed(1), '42.9');
    });

    test('open rate is null when nothing was sent', () {
      expect(const PulseMetrics().openRate, isNull);
    });
  });

  test('geofence radius is fixed at 100 meters', () {
    expect(BusinessLocation.geofenceRadiusMeters, 100);
  });
}
