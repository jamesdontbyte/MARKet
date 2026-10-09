/// A product or service offered by the business (spec §6.4, §10.4).
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.priceLabel,
    this.description = '',
    this.imageAsset,
    this.isBestseller = false,
  });

  final String id;
  final String name;
  final String category;

  /// Price or price range, already formatted (e.g. "₱120" or "₱90–₱150").
  final String priceLabel;
  final String description;
  final String? imageAsset;

  /// Bestseller is a flag on an existing product, not a separate entry (§6.5).
  final bool isBestseller;

  Product copyWith({
    String? name,
    String? category,
    String? priceLabel,
    String? description,
    String? imageAsset,
    bool? isBestseller,
  }) =>
      Product(
        id: id,
        name: name ?? this.name,
        category: category ?? this.category,
        priceLabel: priceLabel ?? this.priceLabel,
        description: description ?? this.description,
        imageAsset: imageAsset ?? this.imageAsset,
        isBestseller: isBestseller ?? this.isBestseller,
      );
}
