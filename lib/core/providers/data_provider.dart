import 'package:flutter/material.dart';
import '../models/github_models.dart';
import '../services/api_service.dart';

class DataProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<ContributorStat> _contributors = [];
  List<Repository> _repositories = [];
  List<Commit> _recentCommits = [];
  
  bool _isLoading = false;
  String _loadingMessage = '';
  String? _error;
  String _currentPeriod = 'all_time';
  
  List<ContributorStat> get sortedContributors => _contributors;
  List<Repository> get repositories => _repositories;
  List<Commit> get recentCommits => _recentCommits;
  
  bool get isLoading => _isLoading;
  String get loadingMessage => _loadingMessage;
  String? get error => _error;
  String get currentPeriod => _currentPeriod;

  Future<void> fetchData({String period = 'monthly'}) async {
    _currentPeriod = period;
    _isLoading = true;
    _error = null;
    _loadingMessage = 'Veriler güncelleniyor ($period)...';
    notifyListeners();

    try {
      final results = await Future.wait([
        _apiService.getStats(period),
        _apiService.getRepositories(),
        _apiService.getRecentCommits(),
      ]);

      _contributors = results[0] as List<ContributorStat>;
      _repositories = results[1] as List<Repository>;
      _recentCommits = results[2] as List<Commit>;

      if (_contributors.isEmpty && _repositories.isEmpty) {
        _loadingMessage = 'Backend senkronizasyonu bekleniyor...';
      }
    } catch (e) {
      _error = 'Sunucu bağlantı hatası. Docker çalışıyor mu?';
      debugPrint('Error fetching data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  
  // Helpers for Titles
  ContributorStat? get coderOfTheMonth {
    if (_contributors.isEmpty) return null;
    return _contributors.first;
  }
  
  Future<void> setToken(String token) async {}
}
