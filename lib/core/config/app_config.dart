class AppConfig {
  // Use '--dart-define=API_URL=https://your-backend.com' during build
  // Default fallback is for local development
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.0.2.2:3001', 
  );
}
