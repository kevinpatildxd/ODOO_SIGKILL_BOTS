import 'package:flutter/material.dart';
import 'package:stackit_frontend/config/theme.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final VoidCallback? onAction;
  final String? actionLabel;
  final bool fullScreen;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.onAction,
    this.actionLabel,
    this.fullScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final emptyStateWidget = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: AppColors.primary.withOpacity(0.7),
          size: 72,
        ),
        const SizedBox(height: 24),
        Text(
          title,
          style: AppTextStyles.h2,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            message,
            style: AppTextStyles.body1,
            textAlign: TextAlign.center,
          ),
        ),
        if (onAction != null && actionLabel != null) ...[
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: onAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(actionLabel!),
          ),
        ],
      ],
    );

    if (fullScreen) {
      return Scaffold(
        body: Center(child: emptyStateWidget),
      );
    }

    return Center(child: emptyStateWidget);
  }
}
