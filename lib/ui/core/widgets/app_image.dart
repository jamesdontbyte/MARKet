import 'dart:io';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Bundled assets start with `assets/`; anything else is a local file the
/// owner uploaded.
ImageProvider appImageProvider(String path) =>
    path.startsWith('assets/') ? AssetImage(path) : FileImage(File(path));

/// Displays a bundled or owner-uploaded photo with a safe fallback.
class AppImage extends StatelessWidget {
  const AppImage(this.path, {super.key, this.fit = BoxFit.cover, this.semanticLabel});

  final String path;
  final BoxFit fit;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Image(
      image: appImageProvider(path),
      fit: fit,
      semanticLabel: semanticLabel,
      errorBuilder: (_, __, ___) => const ColoredBox(
        color: AppColors.tealTint,
        child: Center(child: Icon(Icons.image_not_supported_outlined, color: AppColors.tealInk)),
      ),
    );
  }
}
