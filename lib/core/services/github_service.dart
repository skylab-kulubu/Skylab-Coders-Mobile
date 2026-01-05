import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/github_models.dart';

class GithubService {
  static const String _baseUrl = 'https://api.github.com';
  final String _orgName = 'skylab-kulubu';
  
  // Singleton pattern
  static final GithubService _instance = GithubService._internal();
  factory GithubService() => _instance;
  GithubService._internal();

  String? _token;

  void setToken(String token) {
    _token = token;
  }

  Map<String, String> get _headers {
    final headers = <String, String>{
      'Accept': 'application/vnd.github.v3+json',
    };
    if (_token != null && _token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Future<List<Repository>> getRepositories() async {
    List<Repository> allRepos = [];
    int page = 1;
    while (true) {
      final response = await http.get(
        Uri.parse('$_baseUrl/orgs/$_orgName/repos?per_page=100&page=$page&type=all'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isEmpty) break;
        
        allRepos.addAll(data.map((e) => Repository.fromJson(e)).toList());
        if (data.length < 100) break; // Last page
        page++;
      } else {
        throw Exception('Failed to load repos: ${response.statusCode} - ${response.body}');
      }
    }
    return allRepos;
  }

  // Fetch commits for a specific repo
  Future<List<Commit>> getCommits(String repoName) async {
    List<Commit> allCommits = [];
    int page = 1;
    // Limit to last 300 commits per repo to be safe on rate limits/time for this demo
    // or fetch last month only
    final oneMonthAgo = DateTime.now().subtract(const Duration(days: 30));
    final since = oneMonthAgo.toIso8601String();

    while (true) {
      final response = await http.get(
        Uri.parse('$_baseUrl/repos/$_orgName/$repoName/commits?per_page=100&page=$page&since=$since'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isEmpty) break;
        
        allCommits.addAll(data.map((e) => Commit.fromJson(e)).toList());
        if (data.length < 100) break;
        page++;
        
        // Safety break for huge repos in this demo context
        if (page > 5) break; 
      } else {
        // If repo is empty or other error, just return what we have or empty
        print('Error fetching commits for $repoName: ${response.statusCode}');
        break;
      }
    }
    return allCommits;
  }
  
  Future<Map<String, dynamic>> checkRateLimit() async {
    final response = await http.get(Uri.parse('$_baseUrl/rate_limit'), headers: _headers);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return {};
  }
}
