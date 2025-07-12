import 'package:flutter/material.dart';
import 'package:stackit_frontend/config/theme.dart';
import 'package:stackit_frontend/presentation/widgets/auth/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Text(
                'Welcome Back',
                style: AppTextStyles.h1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Login to continue using StackIt',
                style: AppTextStyles.body1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              const Card(
                margin: EdgeInsets.zero,
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: LoginForm(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
