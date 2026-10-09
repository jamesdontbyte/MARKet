enum PromotionState { active, draft, expired }

/// A digital promotion (spec §8.2).
class Promotion {
  const Promotion({
    required this.id,
    required this.title,
    required this.offer,
    required this.startDate,
    required this.endDate,
    required this.state,
    this.description = '',
    this.imageAsset,
    this.relatedProductId,
  });

  final String id;
  final String title;

  /// Short offer line, e.g. "Buy 1 Take 1" or "₱20 off".
  final String offer;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final PromotionState state;
  final String? imageAsset;
  final String? relatedProductId;

  bool get isActive => state == PromotionState.active;

  Promotion copyWith({
    String? title,
    String? offer,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    PromotionState? state,
    String? imageAsset,
    String? relatedProductId,
  }) =>
      Promotion(
        id: id,
        title: title ?? this.title,
        offer: offer ?? this.offer,
        description: description ?? this.description,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        state: state ?? this.state,
        imageAsset: imageAsset ?? this.imageAsset,
        relatedProductId: relatedProductId ?? this.relatedProductId,
      );
}
