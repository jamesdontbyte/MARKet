import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import '../../../../domain/models/business.dart';
import '../../../../domain/models/business_location.dart';
import '../../../../domain/models/msme_category.dart';
import '../../../../domain/models/personal_account.dart';
import '../../../../domain/models/review_summary.dart';
import '../../../../domain/models/verification_document.dart';
import '../../../../domain/models/verification_status.dart';

/// Steps of the MSME onboarding workflow (spec §2).
enum OnboardingStep { welcome, personal, business, documents, verification, location }

class OnboardingViewModel extends ChangeNotifier {
  /// Default map centre: San Jose de Buenavista, Antique.
  static const defaultPin = LatLng(10.7447, 121.9402);

  OnboardingStep _step = OnboardingStep.welcome;
  OnboardingStep get step => _step;

  // Personal registration (§2.1)
  String fullName = '';
  String email = '';
  String mobile = '';
  String password = '';

  // Business information (§3)
  String businessName = '';
  MsmeCategory? category;
  String description = '';
  String? municipality;
  String barangay = '';
  String address = '';
  String contactNumber = '';
  String operatingHours = '';

  // Verification (§4)
  final Map<DocumentType, String> _documents = {};
  VerificationStatus _verification = VerificationStatus.pending;
  VerificationStatus get verification => _verification;

  // Geofence location (§5)
  LatLng pin = defaultPin;

  String? documentPath(DocumentType type) => _documents[type];
  bool get allDocumentsUploaded => DocumentType.values.every(_documents.containsKey);
  int get documentsUploaded => _documents.length;

  /// 1-based index among the numbered steps, for the progress header.
  int get stepNumber => _step.index; // welcome=0 → personal=1 … location=5
  static const totalSteps = 5;

  void go(OnboardingStep step) {
    _step = step;
    notifyListeners();
  }

  void next() {
    if (_step.index < OnboardingStep.values.length - 1) {
      go(OnboardingStep.values[_step.index + 1]);
    }
  }

  void back() {
    if (_step.index > 0) go(OnboardingStep.values[_step.index - 1]);
  }

  void setDocument(DocumentType type, String path) {
    _documents[type] = path;
    notifyListeners();
  }

  void removeDocument(DocumentType type) {
    _documents.remove(type);
    notifyListeners();
  }

  /// Sends the documents for review (spec §4). Only allowed when complete.
  bool submitDocuments() {
    if (!allDocumentsUploaded) return false;
    _verification = VerificationStatus.underReview;
    go(OnboardingStep.verification);
    return true;
  }

  /// There is no review backend yet, so the demo lets the owner simulate the
  /// reviewer's decision. The business is never shown as verified before this.
  void simulateReview(VerificationStatus result) {
    _verification = result;
    notifyListeners();
  }

  void movePin(LatLng value) {
    pin = value;
  }

  PersonalAccount buildAccount() =>
      PersonalAccount(fullName: fullName.trim(), email: email.trim(), mobile: mobile.trim());

  Business buildBusiness() {
    return Business(
      name: businessName.trim(),
      category: (category ?? MsmeCategory.other).label,
      description: description.trim(),
      municipality: municipality ?? '',
      barangay: barangay.trim(),
      address: address.trim(),
      contactNumber: contactNumber.trim(),
      operatingHours: operatingHours.trim(),
      verificationStatus: _verification,
      products: const [],
      promotions: const [],
      reviews: const ReviewSummary.empty(),
      location: BusinessLocation(latitude: pin.latitude, longitude: pin.longitude),
      documents: [
        for (final t in DocumentType.values)
          VerificationDocument(type: t, filePath: _documents[t]),
      ],
    );
  }
}
