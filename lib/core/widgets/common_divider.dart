import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Horizontal divider with app defaults.
class CommonHorizontalDivider extends StatelessWidget {
  const CommonHorizontalDivider({
    super.key,
    this.height = 1,
    this.thickness = 1,
    this.indent = 0,
    this.endIndent = 0,
    this.color = AppColors.divider,
  });

  final double height;
  final double thickness;
  final double indent;
  final double endIndent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: height,
      thickness: thickness,
      indent: indent,
      endIndent: endIndent,
      color: color,
    );
  }
}

/// Vertical divider with app defaults.
class CommonVerticalDivider extends StatelessWidget {
  const CommonVerticalDivider({
    super.key,
    this.width = 1,
    this.thickness = 1,
    this.indent = 0,
    this.endIndent = 0,
    this.color = AppColors.divider,
  });

  final double width;
  final double thickness;
  final double indent;
  final double endIndent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return VerticalDivider(
      width: width,
      thickness: thickness,
      indent: indent,
      endIndent: endIndent,
      color: color,
    );
  }
}
