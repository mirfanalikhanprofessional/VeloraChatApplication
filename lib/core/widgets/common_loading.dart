import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Centered loading indicator with app primary color.
class CommonLoading extends StatelessWidget {
  const CommonLoading({
    super.key,
    this.size = 28,
    this.strokeWidth = 2.5,
    this.color = AppColors.primary,
  });

  final double size;
  final double strokeWidth;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
          color: color,
        ),
      ),
    );
  }
}
