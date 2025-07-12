import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stackit_frontend/config/theme.dart';
import 'package:stackit_frontend/core/utils/helpers.dart';
import 'package:stackit_frontend/presentation/providers/answer_provider.dart';
import 'package:stackit_frontend/presentation/providers/auth_provider.dart';

class AnswerForm extends StatefulWidget {
  final int questionId;
  final String? initialContent;
  final bool isEditing;
  final int? answerId;
  final VoidCallback? onSuccess;

  const AnswerForm({
    super.key,
    required this.questionId,
    this.initialContent,
    this.isEditing = false,
    this.answerId,
    this.onSuccess,
  });

  @override
  State<AnswerForm> createState() => _AnswerFormState();
}

class _AnswerFormState extends State<AnswerForm> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialContent != null) {
      _contentController.text = widget.initialContent!;
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submitAnswer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final content = _contentController.text.trim();
    if (content.isEmpty) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final answerProvider = Provider.of<AnswerProvider>(context, listen: false);

    try {
      if (widget.isEditing && widget.answerId != null) {
        await answerProvider.updateAnswer(widget.answerId!, content);
      } else {
        await answerProvider.createAnswer(widget.questionId, content);
      }

      if (context.mounted) {
        if (answerProvider.status == AnswerStatus.success) {
          _contentController.clear();
          if (widget.onSuccess != null) {
            widget.onSuccess!();
          }
          Helpers.showSnackBar(
            context, 
            widget.isEditing 
                ? 'Your answer has been updated' 
                : 'Your answer has been posted',
          );
        } else if (answerProvider.status == AnswerStatus.error) {
          Helpers.showSnackBar(
            context, 
            answerProvider.errorMessage, 
            isError: true,
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAuthenticated = authProvider.isAuthenticated;

    if (!isAuthenticated) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'You must be logged in to answer this question',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Navigate to login screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                ),
                child: const Text('Login to Answer'),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.isEditing ? 'Edit Your Answer' : 'Your Answer',
                style: AppTextStyles.h2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Answer cannot be empty';
                  }
                  if (value.trim().length < 30) {
                    return 'Answer must be at least 30 characters';
                  }
                  return null;
                },
                maxLines: 8,
                decoration: const InputDecoration(
                  hintText: 'Write your answer here...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (widget.isEditing)
                    TextButton(
                      onPressed: _isSubmitting ? null : () {
                        if (widget.onSuccess != null) {
                          widget.onSuccess!();
                        }
                      },
                      child: const Text('Cancel'),
                    ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitAnswer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.onPrimary,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(widget.isEditing ? 'Update Answer' : 'Post Answer'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
