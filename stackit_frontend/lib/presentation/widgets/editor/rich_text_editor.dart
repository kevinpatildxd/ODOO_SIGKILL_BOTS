import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:stackit_frontend/config/theme.dart';
import 'package:stackit_frontend/presentation/widgets/editor/editor_toolbar.dart';

class RichTextEditor extends StatefulWidget {
  final String initialContent;
  final Function(String) onContentChanged;
  final double height;
  final bool autofocus;
  final String? placeholder;
  final FocusNode? focusNode;
  final bool readOnly;
  final bool showToolbar;

  const RichTextEditor({
    super.key,
    this.initialContent = '',
    required this.onContentChanged,
    this.height = 300,
    this.autofocus = false,
    this.placeholder,
    this.focusNode,
    this.readOnly = false,
    this.showToolbar = true,
  });

  @override
  State<RichTextEditor> createState() => _RichTextEditorState();
}

class _RichTextEditorState extends State<RichTextEditor> {
  late QuillController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    
    // Initialize the controller with the initial content
    if (widget.initialContent.isEmpty) {
      _controller = QuillController.basic();
    } else {
      try {
        final document = Document.fromJson(
          _getJsonFromString(widget.initialContent)
        );
        _controller = QuillController(
          document: document,
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (e) {
        // Fallback to empty document if parsing fails
        _controller = QuillController.basic();
      }
    }

    // Listen for content changes
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    final json = _controller.document.toDelta().toJson();
    final content = _getStringFromJson(json);
    widget.onContentChanged(content);
  }

  // Helper method to convert string to json for quill
  dynamic _getJsonFromString(String text) {
    try {
      if (text.startsWith('[') && text.endsWith(']')) {
        // It's already in JSON format
        return text;
      } else {
        // It's plain text, convert to Delta
        return [
          {"insert": text}
        ];
      }
    } catch (e) {
      return [
        {"insert": ""}
      ];
    }
  }

  // Helper method to convert quill json to string
  String _getStringFromJson(List<dynamic> json) {
    return json.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Column(
        children: [
          // Editor toolbar
          if (widget.showToolbar && !widget.readOnly)
            EditorToolbar(controller: _controller),
          
          // Editor
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: QuillEditor(
                controller: _controller,
                scrollController: ScrollController(),
                focusNode: _focusNode,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
