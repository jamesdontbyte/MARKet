import 'package:flutter/material.dart';

import '../theme/app_typography.dart';

/// "MARKet" text wordmark with an empty slot reserved for a future logo.
class Wordmark extends StatelessWidget {
  const Wordmark({super.key, this.color = Colors.white, this.size = 20});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'MARKet',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo slot: intentionally empty until a brand mark exists.
          Container(
            width: size * 1.3,
            height: size * 1.3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(size * 0.35),
              border: Border.all(color: color.withValues(alpha: 0.45), width: 1.5),
            ),
          ),
          SizedBox(width: size * 0.45),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'MARK',
                  style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.4),
                ),
                const TextSpan(
                  text: 'et',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            style: TextStyle(
              fontFamily: AppTypography.heading,
              fontSize: size,
              color: color,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
