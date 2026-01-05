import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/github_models.dart';
import '../config/app_config.dart';

class ApiService {
  // Base URL is now configured via AppConfig
  static const String _baseUrl = AppConfig.apiUrl;

  Future<List<ContributorStat>> getStats(String period) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/stats?period=$period'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ContributorStat(
          name: json['name'] ?? json['login'], // Fallback
          email: json['email'] ?? '',
          avatarUrl: json['avatarUrl'], // Matches API response
          totalCommits: json['totalCommits'] ?? 0,
          reposContributedTo: json['repoCount'] ?? 0,
          activeRepos: {}, // Backend doesn't return this in list view efficiently yet
        )).toList();
      } else {
        throw Exception('Failed to load stats');
      }
    } catch (e) {
      print('API Error: $e');
      return [];
    }
  }

  Future<List<Repository>> getRepositories() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/repos'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Repository.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load repositories');
      }
    } catch (e) {
      print('API Error: $e');
      return [];
    }
  }

  Future<List<Commit>> getRecentCommits() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/commits'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Commit.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load commits');
      }
    } catch (e) {
      print('API Error: $e');
      return [];
    }
  }


}
