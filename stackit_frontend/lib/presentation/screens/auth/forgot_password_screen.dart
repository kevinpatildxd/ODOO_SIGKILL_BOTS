import 'package:flutter/material.dart';
import 'package:stackit_frontend/config/theme.dart';
import 'package:stackit_frontend/presentation/widgets/auth/auth_form.dart';
import 'package:stackit_frontend/presentation/routes/app_routes.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Text(
                'Forgot Password?',
                style: AppTextStyles.h1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Enter your email address and we\'ll send you instructions to reset your password',
                style: AppTextStyles.body1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              const Card(
                margin: EdgeInsets.zero,
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: ForgotPasswordForm(),
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
                child: const Text('Back to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
