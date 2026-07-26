import 'package:flutter/material.dart';

import 'common_button.dart';
import 'common_spacer.dart';
import 'common_text.dart';

/// Centered empty / error message with optional retry action.
class CommonEmptyView extends StatelessWidget {
  const CommonEmptyView({
    super.key,
    required this.message,
    this.retryLabel = 'Retry',
    this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CommonText.subtitle(
              message,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const VerticalSpace(12),
              CommonButton.primary(
                label: retryLabel,
                onPressed: onRetry,
                isExpanded: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
