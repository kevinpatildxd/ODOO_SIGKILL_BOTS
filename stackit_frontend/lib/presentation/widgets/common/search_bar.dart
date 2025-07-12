import 'package:flutter/material.dart';
import 'package:stackit_frontend/config/theme.dart';

class CustomSearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final String hintText;
  final bool autoFocus;
  final TextEditingController? controller;
  final VoidCallback? onFilterPressed;
  final bool showFilterIcon;
  final FocusNode? focusNode;
  final String initialQuery;

  const CustomSearchBar({
    super.key,
    required this.onSearch,
    this.hintText = 'Search...',
    this.autoFocus = false,
    this.controller,
    this.onFilterPressed,
    this.showFilterIcon = false,
    this.focusNode,
    this.initialQuery = '',
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialQuery);
    _focusNode = widget.focusNode ?? FocusNode();
    _controller.addListener(_updateClearButtonVisibility);
    _showClearButton = _controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _updateClearButtonVisibility() {
    final shouldShowClearButton = _controller.text.isNotEmpty;
    if (shouldShowClearButton != _showClearButton) {
      setState(() {
        _showClearButton = shouldShowClearButton;
      });
    }
  }

  void _clearSearch() {
    _controller.clear();
    widget.onSearch('');
    FocusScope.of(context).unfocus();
  }

  void _handleSubmitted(String value) {
    widget.onSearch(value.trim());
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        autofocus: widget.autoFocus,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: AppTextStyles.body2.copyWith(
            color: Colors.grey,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.primary,
          ),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Clear button
              if (_showClearButton)
                IconButton(
                  icon: const Icon(
                    Icons.clear,
                    size: 20,
                  ),
                  onPressed: _clearSearch,
                  color: Colors.grey,
                ),
              // Filter button
              if (widget.showFilterIcon)
                IconButton(
                  icon: const Icon(
                    Icons.filter_list,
                    color: AppColors.primary,
                  ),
                  onPressed: widget.onFilterPressed,
                ),
            ],
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onSubmitted: _handleSubmitted,
        onChanged: (value) {
          // Update clear button visibility is handled by listener
          // Optionally implement real-time search here
        },
        style: AppTextStyles.body1,
      ),
    );
  }
}

// Helper widget for a search bar with dropdown filters
class SearchBarWithFilters extends StatelessWidget {
  final Function(String) onSearch;
  final String hintText;
  final List<String> filterOptions;
  final String selectedFilter;
  final Function(String) onFilterChanged;
  
  const SearchBarWithFilters({
    super.key,
    required this.onSearch,
    required this.hintText,
    required this.filterOptions,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Search bar
        Expanded(
          child: CustomSearchBar(
            onSearch: onSearch,
            hintText: hintText,
          ),
        ),
        const SizedBox(width: 8),
        // Filter dropdown
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedFilter,
              icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
              items: filterOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: AppTextStyles.body2,
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  onFilterChanged(newValue);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
