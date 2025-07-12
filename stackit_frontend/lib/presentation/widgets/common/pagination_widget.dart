import 'package:flutter/material.dart';
import 'package:stackit_frontend/config/theme.dart';

class PaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;
  final bool isLoading;

  const PaginationWidget({
    Key? key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous page button
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: currentPage > 1 && !isLoading
                ? () => onPageChanged(currentPage - 1)
                : null,
            color: AppColors.primary,
          ),
          
          // Page number indicators
          _buildPageNumbers(),
          
          // Next page button
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: currentPage < totalPages && !isLoading
                ? () => onPageChanged(currentPage + 1)
                : null,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildPageNumbers() {
    List<Widget> pageWidgets = [];
    
    // Determine range of pages to show
    int startPage = currentPage > 2 ? currentPage - 2 : 1;
    int endPage = startPage + 4;
    
    if (endPage > totalPages) {
      endPage = totalPages;
      startPage = totalPages > 4 ? totalPages - 4 : 1;
    }
    
    // Add first page button if not starting at page 1
    if (startPage > 1) {
      pageWidgets.add(
        _buildPageButton(1),
      );
      
      // Add ellipsis if there's a gap
      if (startPage > 2) {
        pageWidgets.add(
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text('...', style: TextStyle(color: AppColors.onSurface)),
          ),
        );
      }
    }
    
    // Add page number buttons
    for (int i = startPage; i <= endPage; i++) {
      pageWidgets.add(
        _buildPageButton(i),
      );
    }
    
    // Add last page button if not ending at the last page
    if (endPage < totalPages) {
      // Add ellipsis if there's a gap
      if (endPage < totalPages - 1) {
        pageWidgets.add(
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text('...', style: TextStyle(color: AppColors.onSurface)),
          ),
        );
      }
      
      pageWidgets.add(
        _buildPageButton(totalPages),
      );
    }
    
    return Row(children: pageWidgets);
  }
  
  Widget _buildPageButton(int page) {
    final bool isCurrentPage = page == currentPage;
    
    return InkWell(
      onTap: isLoading || isCurrentPage ? null : () => onPageChanged(page),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: isCurrentPage ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Text(
          page.toString(),
          style: TextStyle(
            color: isCurrentPage ? AppColors.onPrimary : AppColors.onSurface,
            fontWeight: isCurrentPage ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
