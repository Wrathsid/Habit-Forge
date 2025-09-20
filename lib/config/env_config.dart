import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static Future<void> initialize() async {
    await dotenv.load(fileName: ".env");
  }

  // Supabase Configuration
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static String get supabaseServiceKey => dotenv.env['SUPABASE_SERVICE_KEY'] ?? '';

  // FastAPI Configuration
  static String get fastApiBaseUrl => dotenv.env['FASTAPI_BASE_URL'] ?? '';
  static String get fastApiApiKey => dotenv.env['FASTAPI_API_KEY'] ?? '';

  // App Configuration
  static String get appEnv => dotenv.env['APP_ENV'] ?? 'development';
  static bool get isDebug => dotenv.env['DEBUG']?.toLowerCase() == 'true';

  // Validation
  static bool get isSupabaseConfigured => 
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
  
  static bool get isFastApiConfigured => 
      fastApiBaseUrl.isNotEmpty && fastApiApiKey.isNotEmpty;
}

