import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:stackit_frontend/config/theme.dart';

class EditorToolbar extends StatelessWidget {
  final QuillController controller;
  final bool showInlineCode;
  final bool showCodeBlock;
  final bool showLink;

  const EditorToolbar({
    super.key,
    required this.controller,
    this.showInlineCode = true,
    this.showCodeBlock = true,
    this.showLink = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: QuillSimpleToolbar(
          controller: controller,
          config: QuillSimpleToolbarConfig(
multiRowsDisplay: false,
            showFontFamily: false,
            showFontSize: false,
            showBoldButton: true,
            showItalicButton: true,
            showUnderLineButton: true,
            showStrikeThrough: true,
            showColorButton: false,
            showBackgroundColorButton: false,
            showClearFormat: true,
            showAlignmentButtons: true,
            showLeftAlignment: false,
            showCenterAlignment: false,
            showRightAlignment: false,
            showJustifyAlignment: false,
            showHeaderStyle: true,
            showListNumbers: true,
            showListBullets: true,
            showListCheck: true,
            showQuote: true,
            showIndent: true,
            showLink: showLink,
            showCodeBlock: showCodeBlock,
            showInlineCode: showInlineCode,
            showDividers: true,
            customButtons: [
              // Custom button for inserting code snippet
              if (showCodeBlock)
                QuillToolbarCustomButtonOptions(
                  icon: Icon(Icons.code),
                  onPressed: () => _insertCodeBlock(context),
                ),
            ],
          ),
          
        ),
      ),
    );
  }

  void _insertCodeBlock(BuildContext context) {
    // Create a controller for the code input
    final TextEditingController codeController = TextEditingController();
    final TextEditingController languageController = TextEditingController(text: 'dart');

    // Show dialog to input code
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Insert Code Block'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Language selection
            TextField(
              controller: languageController,
              decoration: const InputDecoration(
                labelText: 'Language',
                hintText: 'dart, javascript, python, etc.',
              ),
            ),
            const SizedBox(height: 16),
            // Code input
            TextField(
              controller: codeController,
              maxLines: 10,
              decoration: const InputDecoration(
                labelText: 'Code',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Format code block with language
              final language = languageController.text.trim();
              final code = codeController.text;
              
              // Format as markdown code block with language
              final formattedCode = '```$language\n$code\n```';
              
              // Insert the code block at the current position
              final index = controller.selection.baseOffset;
              final length = controller.selection.extentOffset - index;
              
              // Insert a new line before the code block if not at the beginning
              controller.document.insert(index, '\n');
              
              // Insert the code block
              controller.document.insert(index + 1, formattedCode);
              
              // Insert a new line after the code block
              controller.document.insert(index + 1 + formattedCode.length, '\n');
              
              Navigator.pop(context);
            },
            child: const Text('Insert'),
          ),
        ],
      ),
    );
  }
}
