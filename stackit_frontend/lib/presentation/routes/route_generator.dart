import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stackit_frontend/presentation/providers/auth_provider.dart';
import 'package:stackit_frontend/presentation/routes/app_routes.dart';
import 'package:stackit_frontend/presentation/screens/auth/login_screen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Extract arguments if any
    final args = settings.arguments;

    switch (settings.name) {
      case AppRoutes.home:
      case AppRoutes.login:
      case AppRoutes.register:
      case AppRoutes.forgotPassword:
        // Public routes - no authentication required
        return MaterialPageRoute(
          builder: (_) => AppRoutes.routes[settings.name]!(_.createChildContext(_)),
          settings: settings,
        );

      default:
        // All other routes require authentication
        return MaterialPageRoute(
          builder: (context) => AuthGuard(
            routeName: settings.name!,
            routeArguments: args,
          ),
          settings: settings,
        );
    }
  }
}

class AuthGuard extends StatelessWidget {
  final String routeName;
  final dynamic routeArguments;

  const AuthGuard({
    Key? key,
    required this.routeName,
    this.routeArguments,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Access the auth provider
    final authProvider = Provider.of<AuthProvider>(context);

    // Check if user is authenticated
    if (authProvider.isAuthenticated) {
      // User is authenticated, proceed to the requested route
      final routeBuilder = AppRoutes.routes[routeName];
      if (routeBuilder != null) {
        return routeBuilder(context);
      } else {
        // Route doesn't exist, go to home
        return AppRoutes.routes[AppRoutes.home]!(context);
      }
    } else {
      // User is not authenticated, redirect to login
      return const LoginScreen();
    }
  }
}

// Extension to create a child context
extension ContextExtension on BuildContext {
  BuildContext createChildContext(BuildContext context) {
    return context;
  }
}
