import 'package:flutter/material.dart';
import 'package:stackit_frontend/config/theme.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final bool fullScreen;

  const LoadingWidget({
    super.key, 
    this.message,
    this.fullScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final loadingWidget = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            textAlign: TextAlign.center,
            style: AppTextStyles.body1,
          ),
        ],
      ],
    );

    if (fullScreen) {
      return Scaffold(
        body: Center(child: loadingWidget),
      );
    }

    return Center(child: loadingWidget);
  }
}
