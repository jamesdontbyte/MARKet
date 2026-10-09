/// Confirmed business pin. The geofence radius is fixed (spec §5.1) and is
/// intentionally not a constructor parameter.
class BusinessLocation {
  const BusinessLocation({required this.latitude, required this.longitude});

  static const double geofenceRadiusMeters = 100;

  final double latitude;
  final double longitude;
}
