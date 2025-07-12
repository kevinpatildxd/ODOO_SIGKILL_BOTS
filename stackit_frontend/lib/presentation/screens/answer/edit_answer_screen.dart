import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stackit_frontend/data/models/answer_model.dart';
import 'package:stackit_frontend/presentation/providers/answer_provider.dart';
import 'package:stackit_frontend/presentation/widgets/common/app_bar.dart';
import 'package:stackit_frontend/presentation/widgets/common/loading_widget.dart';
import 'package:stackit_frontend/presentation/widgets/editor/rich_text_editor.dart';

class EditAnswerScreen extends StatefulWidget {
  const EditAnswerScreen({super.key});

  @override
  State<EditAnswerScreen> createState() => _EditAnswerScreenState();
}

class _EditAnswerScreenState extends State<EditAnswerScreen> {
  final TextEditingController _contentController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  late Answer? answer;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      final answerData = args?['answer'] as Answer?;
      
      if (answerData != null) {
        setState(() {
          answer = answerData;
          _contentController.text = answerData.content;
        });
      }
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _updateAnswer() async {
    if (_formKey.currentState!.validate() && answer != null) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final answerRequest = AnswerRequest(
          questionId: answer!.questionId,
          content: _contentController.text,
        );
        
        await Provider.of<AnswerProvider>(context, listen: false)
            .updateAnswer(answer!.id, answerRequest);
            
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Answer updated successfully!')),
        );
        
        Navigator.pop(context, true);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update answer: ${e.toString()}')),
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
    if (answer == null) {
      // If we're still waiting for the answer data
      return Scaffold(
        appBar: CustomAppBar(
          title: 'Edit Answer',
          showBackButton: true,
        ),
        body: const Center(child: LoadingWidget()),
      );
    }
    
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Edit Answer',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit your answer:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  RichTextEditor(
                    controller: _contentController,
                    hint: 'Edit your answer here...',
                    minLines: 10,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an answer';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: _isSubmitting ? null : _updateAnswer,
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Update Answer'),
                      ),
                    ],
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
