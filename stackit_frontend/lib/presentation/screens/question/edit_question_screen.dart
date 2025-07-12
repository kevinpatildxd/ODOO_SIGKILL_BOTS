import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stackit_frontend/presentation/providers/auth_provider.dart';
import 'package:stackit_frontend/presentation/providers/question_provider.dart';
import 'package:stackit_frontend/presentation/routes/app_routes.dart';
import 'package:stackit_frontend/presentation/screens/question/ask_question_screen.dart';

class EditQuestionScreen extends StatefulWidget {
  const EditQuestionScreen({super.key});

  @override
  State<EditQuestionScreen> createState() => _EditQuestionScreenState();
}

class _EditQuestionScreenState extends State<EditQuestionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndQuestion();
    });
  }

  void _checkAuthAndQuestion() {
    final questionProvider = Provider.of<QuestionProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final question = questionProvider.selectedQuestion;
    
    // Check if user is authenticated and has a selected question
    if (!authProvider.isAuthenticated) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
      return;
    }
    
    if (question == null) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
      return;
    }
    
    // Check if user is the author of the question
    if (authProvider.user?.id != question.userId) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuestionProvider>(
      builder: (context, questionProvider, child) {
        final question = questionProvider.selectedQuestion;
        
        // This screen just delegates to AskQuestionScreen with the question as argument
        if (question == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        // Using AskQuestionScreen with the question passed as argument for editing
        return const AskQuestionScreen();
      },
    );
  }
}
