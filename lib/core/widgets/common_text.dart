import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

enum CommonTextStyle {
  headline,
  title,
  body,
  subtitle,
  caption,
  button,
  label,
}

/// Reusable text widget with app typography presets.
class CommonText extends StatelessWidget {
  const CommonText(
    this.text, {
    super.key,
    this.style = CommonTextStyle.body,
    this.color,
    this.fontWeight,
    this.fontSize,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
  });

  const CommonText.headline(
    this.text, {
    super.key,
    this.color,
    this.fontWeight,
    this.fontSize,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
  }) : style = CommonTextStyle.headline;

  const CommonText.title(
    this.text, {
    super.key,
    this.color,
    this.fontWeight,
    this.fontSize,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
  }) : style = CommonTextStyle.title;

  const CommonText.body(
    this.text, {
    super.key,
    this.color,
    this.fontWeight,
    this.fontSize,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
  }) : style = CommonTextStyle.body;

  const CommonText.subtitle(
    this.text, {
    super.key,
    this.color,
    this.fontWeight,
    this.fontSize,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
  }) : style = CommonTextStyle.subtitle;

  const CommonText.caption(
    this.text, {
    super.key,
    this.color,
    this.fontWeight,
    this.fontSize,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
  }) : style = CommonTextStyle.caption;

  final String text;
  final CommonTextStyle style;
  final Color? color;
  final FontWeight? fontWeight;
  final double? fontSize;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;

  TextStyle _resolveStyle(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final TextStyle base = switch (style) {
      CommonTextStyle.headline => (theme.headlineMedium ?? const TextStyle()).copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      CommonTextStyle.title => (theme.titleMedium ?? const TextStyle()).copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      CommonTextStyle.body => (theme.bodyMedium ?? const TextStyle()).copyWith(
          color: AppColors.textPrimary,
        ),
      CommonTextStyle.subtitle => (theme.bodyMedium ?? const TextStyle()).copyWith(
          color: AppColors.textSecondary,
        ),
      CommonTextStyle.caption => (theme.bodySmall ?? const TextStyle()).copyWith(
          color: AppColors.textSecondary,
          fontSize: 12,
        ),
      CommonTextStyle.button => (theme.labelLarge ?? const TextStyle()).copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      CommonTextStyle.label => (theme.labelMedium ?? const TextStyle()).copyWith(
          color: AppColors.textSecondary,
        ),
    };

    return base.copyWith(
      color: color ?? base.color,
      fontWeight: fontWeight ?? base.fontWeight,
      fontSize: fontSize ?? base.fontSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: _resolveStyle(context),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
    );
  }
}
