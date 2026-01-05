
class Repository {
  final String name;
  final String fullName;
  final String htmlUrl;
  final String? description;
  final int stargazersCount;
  final String? language;

  Repository({
    required this.name,
    required this.fullName,
    required this.htmlUrl,
    this.description,
    required this.stargazersCount,
    this.language,
  });

    factory Repository.fromJson(Map<String, dynamic> json) {
    return Repository(
      name: json['name'],
      fullName: json['fullName'] ?? json['full_name'],
      htmlUrl: json['htmlUrl'] ?? json['html_url'],
      description: json['description'],
      stargazersCount: json['stargazersCount'] ?? json['stargazers_count'] ?? 0,
      language: json['language'],
    );
  }
}

class Commit {
  final String sha;
  final String message;
  final String authorName;
  final String authorEmail;
  final DateTime date;
  final String htmlUrl;
  final String? avatarUrl;
  
  // Stats (only available in detail view usually, but useful if fetched)
  final int additions;
  final int deletions;

  Commit({
    required this.sha,
    required this.message,
    required this.authorName,
    required this.authorEmail,
    required this.date,
    required this.htmlUrl,
    this.avatarUrl,
    this.additions = 0,
    this.deletions = 0,
  });

  factory Commit.fromJson(Map<String, dynamic> json) {
    // Check if it's GitHub API format (nested commit object)
    if (json.containsKey('commit')) {
      final commit = json['commit'];
      final author = commit['author'];
      final user = json['author']; // GitHub User object
      return Commit(
        sha: json['sha'],
        message: commit['message'],
        authorName: author['name'] ?? 'Unknown',
        authorEmail: author['email'] ?? 'unknown',
        date: DateTime.parse(author['date']),
        htmlUrl: json['html_url'],
        avatarUrl: user != null ? user['avatar_url'] : null,
      );
    } else {
      // Backend Format (Direct properties)
      return Commit(
        sha: json['sha'],
        message: json['message'],
        authorName: json['authorName'] ?? 'Unknown',
        authorEmail: json['authorEmail'] ?? 'unknown',
        date: DateTime.parse(json['date']),
        htmlUrl: json['htmlUrl'],
        avatarUrl: json['user'] != null ? json['user']['avatarUrl'] : null,
        additions: json['additions'] ?? 0,
        deletions: json['deletions'] ?? 0,
      );
    }
  }

}

class ContributorStat {
  final String name;
  final String email; // Primary identifier
  final String? avatarUrl;
  int totalCommits;
  int reposContributedTo; // Count of unique repos
  DateTime? lastCommitDate;
  Set<String> activeRepos;

  ContributorStat({
    required this.name,
    required this.email,
    this.avatarUrl,
    this.totalCommits = 0,
    this.reposContributedTo = 0,
    this.lastCommitDate,
    required this.activeRepos,
  });
}
