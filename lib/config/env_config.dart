import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class EnvConfig {
  static bool _initialized = false;
  
  static Future<void> initialize() async {
    try {
      await dotenv.load(fileName: ".env");
      _initialized = true;
    } catch (e) {
      if (kDebugMode) {
        print('Warning: Could not load .env file: $e');
        print('App will continue with default configuration');
      }
      _initialized = true; // Still mark as initialized to prevent repeated attempts
    }
  }

  // Supabase Configuration
  static String get supabaseUrl => _initialized ? (dotenv.env['SUPABASE_URL'] ?? '') : '';
  static String get supabaseAnonKey => _initialized ? (dotenv.env['SUPABASE_ANON_KEY'] ?? '') : '';
  static String get supabaseServiceKey => _initialized ? (dotenv.env['SUPABASE_SERVICE_KEY'] ?? '') : '';

  // FastAPI Configuration
  static String get fastApiBaseUrl => _initialized ? (dotenv.env['FASTAPI_BASE_URL'] ?? '') : '';
  static String get fastApiApiKey => _initialized ? (dotenv.env['FASTAPI_API_KEY'] ?? '') : '';

  // App Configuration
  static String get appEnv => _initialized ? (dotenv.env['APP_ENV'] ?? 'development') : 'development';
  static bool get isDebug => _initialized ? (dotenv.env['DEBUG']?.toLowerCase() == 'true') : false;

  // Validation
  static bool get isSupabaseConfigured => 
      _initialized && supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
  
  static bool get isFastApiConfigured => 
      _initialized && fastApiBaseUrl.isNotEmpty && fastApiApiKey.isNotEmpty;
      
  static bool get isInitialized => _initialized;
}

