import 'package:flutter/foundation.dart';
import 'package:stackit_frontend/core/network/network_exceptions.dart';
import 'package:stackit_frontend/data/models/tag_model.dart';
import 'package:stackit_frontend/data/repositories/tag_repository.dart';

enum TagStatus { initial, loading, success, error }

class TagProvider extends ChangeNotifier {
  final TagRepository _repository;
  
  TagStatus _status = TagStatus.initial;
  List<Tag> _tags = [];
  List<Tag> _allTags = [];
  String _errorMessage = '';
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMore = true;
  String? _searchQuery;
  
  TagProvider(this._repository);
  
  // Getters
  TagStatus get status => _status;
  List<Tag> get tags => _tags;
  List<Tag> get allTags => _allTags;
  String get errorMessage => _errorMessage;
  bool get isLoading => _status == TagStatus.loading;
  bool get hasMore => _hasMore;
  
  // Methods
  Future<void> getTags({bool refresh = false, String? search}) async {
    if (refresh) {
      _currentPage = 1;
      _tags = [];
      _hasMore = true;
      _searchQuery = search;
    }
    
    if (_status == TagStatus.loading || !_hasMore) {
      return;
    }
    
    _status = TagStatus.loading;
    _errorMessage = '';
    notifyListeners();
    
    try {
      final result = await _repository.getTags(
        page: _currentPage,
        limit: 20,
        search: _searchQuery,
      );
      
      if (refresh) {
        _tags = result.data;
      } else {
        _tags.addAll(result.data);
      }
      
      _totalPages = result.totalPages;
      _hasMore = _currentPage < _totalPages;
      _currentPage++;
      _status = TagStatus.success;
    } catch (e) {
      _status = TagStatus.error;
      _errorMessage = e is NetworkException 
          ? e.message 
          : 'Failed to fetch tags. Please try again.';
    }
    
    notifyListeners();
  }
  
  Future<void> getAllTags() async {
    if (_allTags.isNotEmpty) {
      return; // Already fetched all tags
    }
    
    _status = TagStatus.loading;
    _errorMessage = '';
    notifyListeners();
    
    try {
      _allTags = await _repository.getAllTags();
      _status = TagStatus.success;
    } catch (e) {
      _status = TagStatus.error;
      _errorMessage = e is NetworkException 
          ? e.message 
          : 'Failed to fetch all tags. Please try again.';
    }
    
    notifyListeners();
  }
  
  Future<Tag?> getTagById(int id) async {
    // First check if we already have the tag in our lists
    Tag? tag = _allTags.firstWhere((t) => t.id == id, orElse: () => _tags.firstWhere((t) => t.id == id, orElse: () => null));
    
    return tag;
      
    _status = TagStatus.loading;
    _errorMessage = '';
    notifyListeners();
    
    try {
      tag = await _repository.getTagById(id);
      _status = TagStatus.success;
    } catch (e) {
      _status = TagStatus.error;
      _errorMessage = e is NetworkException 
          ? e.message 
          : 'Failed to fetch tag details. Please try again.';
      tag = null;
    }
    
    notifyListeners();
    return tag;
  }
  
  void clearSearch() {
    _searchQuery = null;
    _currentPage = 1;
    _tags = [];
    _hasMore = true;
    notifyListeners();
  }
  
  void clearError() {
    _errorMessage = '';
    if (_status == TagStatus.error) {
      _status = TagStatus.initial;
    }
    notifyListeners();
  }
}
