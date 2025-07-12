import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:stackit_frontend/config/theme.dart';
import 'package:stackit_frontend/presentation/widgets/editor/rich_text_editor.dart';

class MarkdownPreview extends StatelessWidget {
  final String content;
  final double? height;
  final EdgeInsetsGeometry padding;

  const MarkdownPreview({
    super.key,
    required this.content,
    this.height,
    this.padding = const EdgeInsets.all(16.0),
  });

  @override
  Widget build(BuildContext context) {
    // Parse the content to a QuillController
    final controller = _parseContent();

    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: QuillEditor(
        controller: controller,
        scrollController: ScrollController(),
        scrollable: true,
        focusNode: FocusNode(),
        autoFocus: false,
        readOnly: true,
        expands: height == null,
        padding: EdgeInsets.zero,
        customStyles: DefaultStyles(
          paragraph: DefaultTextBlockStyle(
            AppTextStyles.body1,
            const Tuple2(16.0, 0), 
            const Tuple2(0, 10), 
            null
          ),
          h1: DefaultTextBlockStyle(
            AppTextStyles.h1,
            const Tuple2(16.0, 0), 
            const Tuple2(0, 10),
            null
          ),
          h2: DefaultTextBlockStyle(
            AppTextStyles.h2,
            const Tuple2(16.0, 0), 
            const Tuple2(0, 10), 
            null
          ),
          code: DefaultTextBlockStyle(
            const TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
              color: Color(0xFF333333),
              height: 1.5,
            ),
            const Tuple2(16.0, 16.0), 
            const Tuple2(8.0, 8.0), 
            BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4.0),
            )
          ),
        ),
      ),
    );
  }

  QuillController _parseContent() {
    try {
      // Try to parse as JSON
      if (content.startsWith('[') && content.endsWith(']')) {
        final document = Document.fromJson(_parseJson(content));
        return QuillController(
          document: document,
          selection: const TextSelection.collapsed(offset: 0),
        );
      } else {
        // Fallback to plain text
        return QuillController(
          document: Document.fromDelta(
            Delta()..insert(content),
          ),
          selection: const TextSelection.collapsed(offset: 0),
        );
      }
    } catch (e) {
      // In case of any error, return a controller with the raw content
      return QuillController(
        document: Document.fromDelta(
          Delta()..insert('Error rendering content'),
        ),
        selection: const TextSelection.collapsed(offset: 0),
      );
    }
  }

  dynamic _parseJson(String jsonString) {
    try {
      // Remove any non-json characters (in case string has other content)
      final start = jsonString.indexOf('[');
      final end = jsonString.lastIndexOf(']') + 1;
      
      if (start >= 0 && end > 0) {
        final cleanJson = jsonString.substring(start, end);
        return cleanJson;
      } else {
        // Convert to plain text delta if not a valid JSON
        return [
          {"insert": content}
        ];
      }
    } catch (e) {
      return [
        {"insert": content}
      ];
    }
  }
}

// Helper widget to toggle between edit and preview modes
class EditorWithPreview extends StatefulWidget {
  final String initialContent;
  final Function(String) onContentChanged;
  final double height;
  final String? placeholder;

  const EditorWithPreview({
    super.key,
    this.initialContent = '',
    required this.onContentChanged,
    this.height = 300,
    this.placeholder,
  });

  @override
  State<EditorWithPreview> createState() => _EditorWithPreviewState();
}

class _EditorWithPreviewState extends State<EditorWithPreview> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _currentContent = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _currentContent = widget.initialContent;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleContentChanged(String content) {
    setState(() {
      _currentContent = content;
    });
    widget.onContentChanged(content);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab bar for switching between edit and preview
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.shade300,
              ),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Edit'),
              Tab(text: 'Preview'),
            ],
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
          ),
        ),
        
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Edit view
              _buildEditorView(),
              
              // Preview view
              _buildPreviewView(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditorView() {
    return RichTextEditor(
      initialContent: widget.initialContent,
      onContentChanged: _handleContentChanged,
      height: widget.height,
      placeholder: widget.placeholder,
      autofocus: true,
    );
  }

  Widget _buildPreviewView() {
    return MarkdownPreview(
      content: _currentContent,
    );
  }
}
