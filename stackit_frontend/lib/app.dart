import 'package:flutter/material.dart';
import 'package:stackit_frontend/config/constants.dart';
import 'package:stackit_frontend/config/theme.dart';
import 'package:stackit_frontend/presentation/routes/app_routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: appTheme,
      initialRoute: AppRoutes.home,
      routes: AppRoutes.routes,
    );
  }
}
