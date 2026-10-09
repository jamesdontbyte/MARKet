import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../domain/models/business_location.dart';
import '../theme/app_colors.dart';

/// Map with a fixed centre pin and the fixed 100-meter coverage circle
/// (spec §5.2). The owner pans the map underneath the pin to place it
/// accurately; the circle radius can never be changed (§5.1).
class GeofenceMap extends StatefulWidget {
  const GeofenceMap({
    super.key,
    required this.center,
    required this.onCenterChanged,
    this.interactive = true,
    this.initialZoom = 17,
  });

  final LatLng center;
  final ValueChanged<LatLng> onCenterChanged;
  final bool interactive;
  final double initialZoom;

  @override
  State<GeofenceMap> createState() => _GeofenceMapState();
}

class _GeofenceMapState extends State<GeofenceMap> {
  late double _zoom = widget.initialZoom;
  late double _lat = widget.center.latitude;

  double get _radiusPx {
    // Web-mercator ground resolution at the current latitude and zoom.
    final metersPerPixel =
        156543.03392 * math.cos(_lat * math.pi / 180) / math.pow(2, _zoom);
    return BusinessLocation.geofenceRadiusMeters / metersPerPixel;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: widget.center,
            initialZoom: widget.initialZoom,
            minZoom: 12,
            maxZoom: 19,
            interactionOptions: InteractionOptions(
              flags: widget.interactive
                  ? InteractiveFlag.all & ~InteractiveFlag.rotate
                  : InteractiveFlag.none,
            ),
            onPositionChanged: (camera, _) {
              widget.onCenterChanged(camera.center);
              if ((camera.zoom - _zoom).abs() > 0.01 ||
                  (camera.center.latitude - _lat).abs() > 0.002) {
                setState(() {
                  _zoom = camera.zoom;
                  _lat = camera.center.latitude;
                });
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.market.market_app',
            ),
            const RichAttributionWidget(
              alignment: AttributionAlignment.bottomLeft,
              attributions: [TextSourceAttribution('© OpenStreetMap contributors')],
            ),
          ],
        ),
        IgnorePointer(
          child: Container(
            width: _radiusPx * 2,
            height: _radiusPx * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.coral.withValues(alpha: 0.18),
              border: Border.all(color: AppColors.coral, width: 2),
            ),
          ),
        ),
        // Pin tip sits exactly on the map centre.
        const IgnorePointer(
          child: Padding(
            padding: EdgeInsets.only(bottom: 40),
            child: Icon(Icons.location_on_rounded, size: 44, color: AppColors.deepTeal),
          ),
        ),
      ],
    );
  }
}
