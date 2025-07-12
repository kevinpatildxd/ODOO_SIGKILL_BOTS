import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stackit_frontend/config/theme.dart';
import 'package:stackit_frontend/core/utils/helpers.dart';
import 'package:stackit_frontend/data/models/question_model.dart';
import 'package:stackit_frontend/presentation/providers/auth_provider.dart';
import 'package:stackit_frontend/presentation/providers/question_provider.dart';
import 'package:stackit_frontend/presentation/providers/tag_provider.dart';
import 'package:stackit_frontend/presentation/routes/app_routes.dart';

class AskQuestionScreen extends StatefulWidget {
  const AskQuestionScreen({super.key});

  @override
  State<AskQuestionScreen> createState() => _AskQuestionScreenState();
}

class _AskQuestionScreenState extends State<AskQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<String> _selectedTags = [];
  Question? _questionToEdit;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTags();
      _checkAuthentication();
      _loadQuestionIfEditing();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _checkAuthentication() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  void _loadQuestionIfEditing() {
    // Check if question is passed as argument for editing
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Question) {
      setState(() {
        _questionToEdit = args;
        _titleController.text = args.title;
        _descriptionController.text = args.description;
        if (args.tags != null) {
          _selectedTags.addAll(args.tags!.map((tag) => tag.name));
        }
      });
    }
  }

  Future<void> _loadTags() async {
    final tagProvider = Provider.of<TagProvider>(context, listen: false);
    await tagProvider.getAllTags();
  }

  Future<void> _submitQuestion() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedTags.isEmpty) {
      Helpers.showSnackBar(
        context, 
        'Please select at least one tag', 
        isError: true,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final questionProvider = Provider.of<QuestionProvider>(context, listen: false);

    try {
      if (_questionToEdit != null) {
        // Update existing question
        await questionProvider.updateQuestion(
          _questionToEdit!.id,
          _titleController.text.trim(),
          _descriptionController.text.trim(),
          _selectedTags,
        );
      } else {
        // Create new question
        await questionProvider.createQuestion(
          _titleController.text.trim(),
          _descriptionController.text.trim(),
          _selectedTags,
        );
      }

      if (context.mounted) {
        if (questionProvider.status == QuestionStatus.success) {
          Helpers.showSnackBar(
            context, 
            _questionToEdit != null
                ? 'Question updated successfully'
                : 'Question posted successfully',
          );
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        } else if (questionProvider.status == QuestionStatus.error) {
          Helpers.showSnackBar(
            context, 
            questionProvider.errorMessage, 
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

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _questionToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Question' : 'Ask a Question'),
      ),
      body: Consumer<TagProvider>(
        builder: (context, tagProvider, child) {
          if (tagProvider.status == TagStatus.loading && tagProvider.allTags.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        hintText: 'e.g. How to implement authentication in Flutter?',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Title is required';
                        }
                        if (value.trim().length < 15) {
                          return 'Title must be at least 15 characters long';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Describe your problem in detail...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 10,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Description is required';
                        }
                        if (value.trim().length < 30) {
                          return 'Description must be at least 30 characters long';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Tags',
                      style: AppTextStyles.h2.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select tags that best describe your question (at least one)',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTagSelector(tagProvider.allTags),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitQuestion,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
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
                            : Text(isEditing ? 'Update Question' : 'Post Question'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTagSelector(List<dynamic> availableTags) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: availableTags.map((tag) {
        final tagName = tag is String ? tag : tag.name;
        final isSelected = _selectedTags.contains(tagName);
        
        return FilterChip(
          label: Text(tagName),
          selected: isSelected,
          onSelected: (_) => _toggleTag(tagName),
          backgroundColor: AppColors.surface,
          selectedColor: AppColors.primary.withOpacity(0.2),
          checkmarkColor: AppColors.primary,
          labelStyle: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.onSurface,
          ),
        );
      }).toList(),
    );
  }
}
