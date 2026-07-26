import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'common_text.dart';

enum CommonButtonType {
  primary,
  outlined,
  text,
}

/// Reusable app button with primary / outlined / text variants.
class CommonButton extends StatelessWidget {
  const CommonButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.type = CommonButtonType.primary,
    this.isLoading = false,
    this.isExpanded = true,
    this.height = 48,
    this.foregroundColor,
    this.backgroundColor,
    this.icon,
  });

  const CommonButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isExpanded = true,
    this.height = 48,
    this.foregroundColor,
    this.backgroundColor,
    this.icon,
  }) : type = CommonButtonType.primary;

  const CommonButton.outlined({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isExpanded = true,
    this.height = 48,
    this.foregroundColor,
    this.backgroundColor,
    this.icon,
  }) : type = CommonButtonType.outlined;

  const CommonButton.text({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isExpanded = false,
    this.height = 48,
    this.foregroundColor,
    this.backgroundColor,
    this.icon,
  }) : type = CommonButtonType.text;

  final String label;
  final VoidCallback? onPressed;
  final CommonButtonType type;
  final bool isLoading;
  final bool isExpanded;
  final double height;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final IconData? icon;

  Widget _label(Color color) {
    return CommonText(
      label,
      color: color,
      fontWeight: FontWeight.w600,
    );
  }

  Widget _child(Color color) {
    if (isLoading) {
      return SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: color,
        ),
      );
    }

    if (icon == null) return _label(color);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        _label(color),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || isLoading;

    late final Widget button;
    switch (type) {
      case CommonButtonType.primary:
        final fg = foregroundColor ?? AppColors.onPrimary;
        button = FilledButton(
          onPressed: disabled ? null : onPressed,
          style: FilledButton.styleFrom(
            minimumSize: Size(isExpanded ? double.infinity : 64, height),
            backgroundColor: backgroundColor ?? AppColors.primary,
            foregroundColor: fg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: _child(fg),
        );
      case CommonButtonType.outlined:
        final fg = foregroundColor ?? AppColors.primary;
        button = OutlinedButton(
          onPressed: disabled ? null : onPressed,
          style: OutlinedButton.styleFrom(
            minimumSize: Size(isExpanded ? double.infinity : 64, height),
            foregroundColor: fg,
            side: BorderSide(color: fg),
          ),
          child: _child(fg),
        );
      case CommonButtonType.text:
        final fg = foregroundColor ?? AppColors.primary;
        button = TextButton(
          onPressed: disabled ? null : onPressed,
          style: TextButton.styleFrom(
            minimumSize: Size(isExpanded ? double.infinity : 64, height),
            foregroundColor: fg,
          ),
          child: _child(fg),
        );
    }

    return button;
  }
}
