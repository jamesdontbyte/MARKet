import 'package:flutter/material.dart';

/// Standardised MSME categories (spec §3). The app serves every kind of MSME,
/// so the category only drives labels and fallback icons, never layout.
enum MsmeCategory {
  coffeeShop('Coffee Shop', Icons.local_cafe_rounded, 'Menu'),
  restaurant('Restaurant', Icons.restaurant_rounded, 'Menu'),
  retail('Retail', Icons.shopping_bag_rounded, 'Products'),
  salon('Salon', Icons.content_cut_rounded, 'Services'),
  barbershop('Barbershop', Icons.face_retouching_natural_rounded, 'Services'),
  services('Services', Icons.handyman_rounded, 'Services'),
  accommodation('Accommodation', Icons.bed_rounded, 'Rooms & packages'),
  other('Other MSME', Icons.storefront_rounded, 'Products & services');

  const MsmeCategory(this.label, this.icon, this.itemLabel);

  final String label;
  final IconData icon;

  /// What this kind of business calls its offerings.
  final String itemLabel;

  static MsmeCategory fromLabel(String label) => MsmeCategory.values.firstWhere(
        (c) => c.label.toLowerCase() == label.toLowerCase(),
        orElse: () => MsmeCategory.other,
      );
}

/// Municipalities of Antique offered during business registration.
const antiqueMunicipalities = <String>[
  'Anini-y',
  'Barbaza',
  'Belison',
  'Bugasong',
  'Caluya',
  'Culasi',
  'Hamtic',
  'Laua-an',
  'Libertad',
  'Pandan',
  'Patnongon',
  'San Jose de Buenavista',
  'San Remigio',
  'Sebaste',
  'Sibalom',
  'Tibiao',
  'Tobias Fornier',
  'Valderrama',
];
