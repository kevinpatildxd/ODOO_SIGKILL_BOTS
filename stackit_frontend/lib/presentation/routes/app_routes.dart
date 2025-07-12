import 'package:flutter/material.dart';
import 'package:stackit_frontend/presentation/screens/auth/login_screen.dart';
import 'package:stackit_frontend/presentation/screens/auth/register_screen.dart';
import 'package:stackit_frontend/presentation/screens/auth/forgot_password_screen.dart';
import 'package:stackit_frontend/presentation/screens/home/home_screen.dart';
import 'package:stackit_frontend/presentation/screens/question/question_detail_screen.dart';
import 'package:stackit_frontend/presentation/screens/question/ask_question_screen.dart';
import 'package:stackit_frontend/presentation/screens/profile/profile_screen.dart';
import 'package:stackit_frontend/presentation/screens/profile/user_questions_screen.dart';
import 'package:stackit_frontend/presentation/screens/profile/user_answers_screen.dart';
import 'package:stackit_frontend/presentation/screens/notification/notification_screen.dart';
import 'package:stackit_frontend/presentation/screens/settings/settings_screen.dart';

class AppRoutes {
  // Route names
  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String questionDetail = '/question';
  static const String askQuestion = '/ask-question';
  static const String profile = '/profile';
  static const String userQuestions = '/user-questions';
  static const String userAnswers = '/user-answers';
  static const String notifications = '/notifications';
  static const String settings = '/settings';

  // Route map
  static Map<String, WidgetBuilder> get routes => {
        home: (context) => const HomeScreen(),
        login: (context) => const LoginScreen(),
        register: (context) => const RegisterScreen(),
        forgotPassword: (context) => const ForgotPasswordScreen(),
        questionDetail: (context) => const QuestionDetailScreen(),
        askQuestion: (context) => const AskQuestionScreen(),
        profile: (context) => const ProfileScreen(),
        userQuestions: (context) => const UserQuestionsScreen(),
        userAnswers: (context) => const UserAnswersScreen(),
        notifications: (context) => const NotificationScreen(),
        settings: (context) => const SettingsScreen(),
      };
}
