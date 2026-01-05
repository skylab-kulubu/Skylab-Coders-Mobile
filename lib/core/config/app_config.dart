import 'package:flutter/foundation.dart';

class AppConfig {
  // Use '--dart-define=API_URL=https://your-backend.com' during build
  // Default fallback uses production URL in Release mode, and Emulator localhost in Debug mode.
  // Port 24680 is the new rare port assigned to avoid conflicts.
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: kReleaseMode 
        ? 'http://api.yildizskylab.com:24680' 
        : 'http://10.0.2.2:24680', 
  );
}
