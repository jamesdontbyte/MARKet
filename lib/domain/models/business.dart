import 'business_location.dart';
import 'msme_category.dart';
import 'product.dart';
import 'promotion.dart';
import 'pulse_metrics.dart';
import 'review_summary.dart';
import 'verification_document.dart';
import 'verification_status.dart';

/// The MSME business profile built from onboarding data (spec §3, §6).
class Business {
  const Business({
    required this.name,
    required this.category,
    required this.description,
    required this.municipality,
    required this.barangay,
    required this.address,
    required this.contactNumber,
    required this.operatingHours,
    required this.verificationStatus,
    required this.products,
    required this.promotions,
    required this.reviews,
    this.logoAsset,
    this.storefrontAsset,
    this.interiorAsset,
    this.location,
    this.documents = const [],
    this.metrics = const PulseMetrics(),
  });

  final String name;
  final String category;
  final String description;
  final String municipality;
  final String barangay;
  final String address;
  final String contactNumber;
  final String operatingHours;
  final VerificationStatus verificationStatus;

  /// Image paths: either a bundled `assets/...` path or a local file path
  /// from an owner upload.
  final String? logoAsset;
  final String? storefrontAsset;
  final String? interiorAsset;
  final List<Product> products;
  final List<Promotion> promotions;
  final ReviewSummary reviews;
  final BusinessLocation? location;
  final List<VerificationDocument> documents;
  final PulseMetrics metrics;

  MsmeCategory get msmeCategory => MsmeCategory.fromLabel(category);

  String get locationLabel => '$municipality, Antique';

  /// The photo that represents the business on Home: storefront first, then
  /// interior. Null means the owner has not uploaded either yet.
  String? get heroPhoto => storefrontAsset ?? interiorAsset;

  List<Product> get bestsellers =>
      products.where((p) => p.isBestseller).toList(growable: false);

  List<Promotion> get activePromotions =>
      promotions.where((p) => p.isActive).toList(growable: false);

  /// Profile completion items, limited to fields the spec already defines.
  Map<String, bool> get completionChecklist => {
        'Logo': logoAsset != null,
        'Storefront photo': storefrontAsset != null,
        'Interior photo': interiorAsset != null,
        'Description': description.trim().isNotEmpty,
        'Operating hours': operatingHours.trim().isNotEmpty,
        'Contact information': contactNumber.trim().isNotEmpty,
        'Products or services': products.isNotEmpty,
      };

  double get profileCompletion {
    final items = completionChecklist.values;
    return items.where((done) => done).length / items.length;
  }

  List<String> get missingProfileItems => completionChecklist.entries
      .where((e) => !e.value)
      .map((e) => e.key)
      .toList(growable: false);

  /// Nullable media fields use [clearLogo]-style flags only where needed;
  /// passing null keeps the current value.
  Business copyWith({
    String? name,
    String? category,
    String? description,
    String? municipality,
    String? barangay,
    String? address,
    String? contactNumber,
    String? operatingHours,
    VerificationStatus? verificationStatus,
    List<Product>? products,
    List<Promotion>? promotions,
    ReviewSummary? reviews,
    String? logoAsset,
    String? storefrontAsset,
    String? interiorAsset,
    BusinessLocation? location,
    List<VerificationDocument>? documents,
    PulseMetrics? metrics,
  }) {
    return Business(
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      municipality: municipality ?? this.municipality,
      barangay: barangay ?? this.barangay,
      address: address ?? this.address,
      contactNumber: contactNumber ?? this.contactNumber,
      operatingHours: operatingHours ?? this.operatingHours,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      products: products ?? this.products,
      promotions: promotions ?? this.promotions,
      reviews: reviews ?? this.reviews,
      logoAsset: logoAsset ?? this.logoAsset,
      storefrontAsset: storefrontAsset ?? this.storefrontAsset,
      interiorAsset: interiorAsset ?? this.interiorAsset,
      location: location ?? this.location,
      documents: documents ?? this.documents,
      metrics: metrics ?? this.metrics,
    );
  }
}
