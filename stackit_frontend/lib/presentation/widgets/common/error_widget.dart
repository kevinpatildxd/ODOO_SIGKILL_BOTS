import 'package:flutter/material.dart';
import 'package:stackit_frontend/config/theme.dart';

class CustomErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final bool fullScreen;

  const CustomErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.fullScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final errorWidget = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(
          Icons.error_outline,
          color: AppColors.error,
          size: 64,
        ),
        const SizedBox(height: 16),
        Text(
          'Error',
          style: AppTextStyles.h2,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            message,
            style: AppTextStyles.body1,
            textAlign: TextAlign.center,
          ),
        ),
        if (onRetry != null) ...[
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
            ),
          ),
        ]
      ],
    );

    if (fullScreen) {
      return Scaffold(
        body: Center(child: errorWidget),
      );
    }

    return Center(child: errorWidget);
  }
}
