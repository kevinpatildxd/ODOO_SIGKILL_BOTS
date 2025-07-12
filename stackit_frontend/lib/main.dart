import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stackit_frontend/app.dart';
import 'package:stackit_frontend/core/network/api_client.dart';
import 'package:stackit_frontend/data/datasources/auth_datasource.dart';
import 'package:stackit_frontend/data/datasources/question_datasource.dart';
import 'package:stackit_frontend/data/datasources/answer_datasource.dart';
import 'package:stackit_frontend/data/datasources/notification_datasource.dart';
import 'package:stackit_frontend/data/repositories/auth_repository.dart';
import 'package:stackit_frontend/data/repositories/question_repository.dart';
import 'package:stackit_frontend/data/repositories/answer_repository.dart';
import 'package:stackit_frontend/data/repositories/notification_repository.dart';
import 'package:stackit_frontend/presentation/providers/auth_provider.dart';
import 'package:stackit_frontend/presentation/providers/question_provider.dart';
import 'package:stackit_frontend/presentation/providers/answer_provider.dart';
import 'package:stackit_frontend/presentation/providers/notification_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependencies
  final preferences = await SharedPreferences.getInstance();
  final apiClient = ApiClient();
  
  // Initialize data sources
  final authDataSource = AuthDataSource(apiClient);
  final questionDataSource = QuestionDataSource(apiClient);
  final answerDataSource = AnswerDataSource(apiClient);
  final notificationDataSource = NotificationDataSource(apiClient);
  
  // Initialize repositories
  final authRepository = AuthRepository(authDataSource);
  final questionRepository = QuestionRepository(questionDataSource);
  final answerRepository = AnswerRepository(answerDataSource);
  final notificationRepository = NotificationRepository(notificationDataSource);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authRepository, preferences),
        ),
        ChangeNotifierProvider(
          create: (_) => QuestionProvider(questionRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => AnswerProvider(answerRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(notificationRepository),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
