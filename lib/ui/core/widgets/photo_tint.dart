import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'app_image.dart';

/// Derives a rich dark brand tone from the dominant hue of a photo, so the
/// dashboard adapts to whatever the owner uploads (any kind of MSME).
Future<Color?> deriveTint(ImageProvider provider) async {
  final completer = Completer<ui.Image>();
  final stream = ResizeImage(provider, width: 32).resolve(ImageConfiguration.empty);
  late ImageStreamListener listener;
  listener = ImageStreamListener(
    (info, _) {
      if (!completer.isCompleted) completer.complete(info.image);
      stream.removeListener(listener);
    },
    onError: (e, s) {
      if (!completer.isCompleted) completer.completeError(e, s);
      stream.removeListener(listener);
    },
  );
  stream.addListener(listener);

  final image = await completer.future;
  final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  if (data == null) return null;

  var sumX = 0.0, sumY = 0.0, weightSum = 0.0, satSum = 0.0;
  for (var i = 0; i + 3 < data.lengthInBytes; i += 4) {
    final c = Color.fromARGB(255, data.getUint8(i), data.getUint8(i + 1), data.getUint8(i + 2));
    final hsv = HSVColor.fromColor(c);
    // Favour saturated, mid-brightness pixels; ignore near-grey ones.
    final w = hsv.saturation * (1 - (hsv.value - 0.6).abs());
    if (w < 0.05) continue;
    final rad = hsv.hue * math.pi / 180;
    sumX += w * math.cos(rad);
    sumY += w * math.sin(rad);
    weightSum += w;
    satSum += hsv.saturation * w;
  }
  if (weightSum < 1) return null; // photo is essentially grey
  final hue = (math.atan2(sumY, sumX) * 180 / math.pi + 360) % 360;
  final sat = (satSum / weightSum).clamp(0.25, 0.5);
  return HSLColor.fromAHSL(1, hue, sat, 0.2).toColor();
}


/// Supplies a photo-derived tint to [builder]; falls back to deep teal.
class PhotoTint extends StatefulWidget {
  const PhotoTint({super.key, required this.photoPath, required this.builder});

  final String? photoPath;
  final Widget Function(BuildContext context, Color tint) builder;

  @override
  State<PhotoTint> createState() => _PhotoTintState();
}

class _PhotoTintState extends State<PhotoTint> {
  Color _tint = AppColors.deepTeal;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void didUpdateWidget(PhotoTint old) {
    super.didUpdateWidget(old);
    if (old.photoPath != widget.photoPath) _resolve();
  }

  Future<void> _resolve() async {
    final path = widget.photoPath;
    if (path == null) {
      setState(() => _tint = AppColors.deepTeal);
      return;
    }
    try {
      final tint = await deriveTint(appImageProvider(path));
      if (mounted && path == widget.photoPath) {
        setState(() => _tint = tint ?? AppColors.deepTeal);
      }
    } catch (_) {
      // Keep the default brand tone if the photo cannot be read.
    }
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _tint);
}
