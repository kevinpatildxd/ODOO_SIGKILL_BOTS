import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stackit_frontend/data/models/answer_request.dart';
import 'package:stackit_frontend/data/models/question_model.dart';
import 'package:stackit_frontend/presentation/providers/answer_provider.dart';
import 'package:stackit_frontend/presentation/widgets/answer/answer_form.dart';
import 'package:stackit_frontend/presentation/widgets/common/app_bar.dart';
import 'package:stackit_frontend/presentation/widgets/common/loading_widget.dart';
import 'package:stackit_frontend/presentation/widgets/common/error_widget.dart';
import 'package:stackit_frontend/presentation/widgets/editor/rich_text_editor.dart';

class AnswerScreen extends StatefulWidget {
  const AnswerScreen({Key? key}) : super(key: key);

  @override
  State<AnswerScreen> createState() => _AnswerScreenState();
}

class _AnswerScreenState extends State<AnswerScreen> {
  final TextEditingController _contentController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  late Question? question;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      setState(() {
        question = args?['question'] as Question?;
      });
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _submitAnswer() async {
    if (_formKey.currentState!.validate() && question != null) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final answerRequest = AnswerRequest(
          questionId: question!.id,
          content: _contentController.text,
        );
        
        await Provider.of<AnswerProvider>(context, listen: false)
            .createAnswer(answerRequest);
            
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Answer posted successfully!')),
        );
        
        Navigator.pop(context, true);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post answer: ${e.toString()}')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (question == null) {
      // If we're still waiting for the question data
      return Scaffold(
        appBar: CustomAppBar(
          title: 'Post Answer',
          showBackButton: true,
        ),
        body: const Center(child: LoadingWidget()),
      );
    }
    
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Post Answer',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  question!.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Your Answer:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  RichTextEditor(
                    controller: _contentController,
                    hint: 'Write your answer here...',
                    minLines: 10,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an answer';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitAnswer,
                      child: _isSubmitting
                          ? const CircularProgressIndicator()
                          : const Text('Post Answer'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
