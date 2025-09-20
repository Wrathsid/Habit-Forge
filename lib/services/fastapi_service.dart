import 'package:dio/dio.dart';
import '../config/env_config.dart';

class FastApiService {
  static final FastApiService _instance = FastApiService._internal();
  factory FastApiService() => _instance;
  FastApiService._internal();

  static FastApiService get instance => _instance;

  late Dio _dio;

  Future<void> initialize() async {
    if (!EnvConfig.isFastApiConfigured) {
      throw Exception('FastAPI configuration is missing. Please check your .env file.');
    }

    _dio = Dio(BaseOptions(
      baseUrl: EnvConfig.fastApiBaseUrl,
      headers: {
        'Authorization': 'Bearer ${EnvConfig.fastApiApiKey}',
        'Content-Type': 'application/json',
      },
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));

    // Add interceptors for logging and error handling
    _dio.interceptors.add(LogInterceptor(
      requestBody: EnvConfig.isDebug,
      responseBody: EnvConfig.isDebug,
      logPrint: (obj) => print(obj),
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) {
        print('FastAPI Error: ${error.message}');
        handler.next(error);
      },
    ));
  }

  // AI-Powered Analytics
  Future<Map<String, dynamic>> getHabitInsights(String userId) async {
    try {
      final response = await _dio.get('/analytics/habit-insights/$userId');
      return response.data;
    } catch (e) {
      print('Error getting habit insights: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getMoodAnalysis(String userId) async {
    try {
      final response = await _dio.get('/analytics/mood-analysis/$userId');
      return response.data;
    } catch (e) {
      print('Error getting mood analysis: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getPersonalizedRecommendations(String userId) async {
    try {
      final response = await _dio.get('/recommendations/$userId');
      return response.data;
    } catch (e) {
      print('Error getting recommendations: $e');
      rethrow;
    }
  }

  // Smart Notifications
  Future<Map<String, dynamic>> getOptimalNotificationTimes(String userId) async {
    try {
      final response = await _dio.get('/notifications/optimal-times/$userId');
      return response.data;
    } catch (e) {
      print('Error getting optimal notification times: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> scheduleSmartNotification({
    required String userId,
    required String habitId,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _dio.post('/notifications/schedule', data: {
        'user_id': userId,
        'habit_id': habitId,
        'type': type,
        'data': data,
      });
      return response.data;
    } catch (e) {
      print('Error scheduling smart notification: $e');
      rethrow;
    }
  }

  // Habit Correlation Analysis
  Future<Map<String, dynamic>> getHabitCorrelations(String userId) async {
    try {
      final response = await _dio.get('/analytics/habit-correlations/$userId');
      return response.data;
    } catch (e) {
      print('Error getting habit correlations: $e');
      rethrow;
    }
  }

  // Streak Prediction
  Future<Map<String, dynamic>> predictStreakSuccess(String userId, String habitId) async {
    try {
      final response = await _dio.get('/analytics/streak-prediction/$userId/$habitId');
      return response.data;
    } catch (e) {
      print('Error predicting streak success: $e');
      rethrow;
    }
  }

  // Social Features
  Future<Map<String, dynamic>> getSocialInsights(String userId) async {
    try {
      final response = await _dio.get('/social/insights/$userId');
      return response.data;
    } catch (e) {
      print('Error getting social insights: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createGroupChallenge({
    required String userId,
    required String name,
    required String description,
    required List<String> habitIds,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _dio.post('/challenges/group', data: {
        'user_id': userId,
        'name': name,
        'description': description,
        'habit_ids': habitIds,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
      });
      return response.data;
    } catch (e) {
      print('Error creating group challenge: $e');
      rethrow;
    }
  }

  // Data Export/Import
  Future<Map<String, dynamic>> exportUserData(String userId) async {
    try {
      final response = await _dio.get('/data/export/$userId');
      return response.data;
    } catch (e) {
      print('Error exporting user data: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> importUserData(String userId, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/data/import/$userId', data: data);
      return response.data;
    } catch (e) {
      print('Error importing user data: $e');
      rethrow;
    }
  }

  // Health Check
  Future<bool> healthCheck() async {
    try {
      final response = await _dio.get('/health');
      return response.statusCode == 200;
    } catch (e) {
      print('FastAPI health check failed: $e');
      return false;
    }
  }

  // Batch Operations
  Future<Map<String, dynamic>> batchUpdateHabits(String userId, List<Map<String, dynamic>> habits) async {
    try {
      final response = await _dio.post('/habits/batch-update', data: {
        'user_id': userId,
        'habits': habits,
      });
      return response.data;
    } catch (e) {
      print('Error batch updating habits: $e');
      rethrow;
    }
  }

  // Advanced Analytics
  Future<Map<String, dynamic>> getAdvancedAnalytics(String userId) async {
    try {
      final response = await _dio.get('/analytics/advanced/$userId');
      return response.data;
    } catch (e) {
      print('Error getting advanced analytics: $e');
      rethrow;
    }
  }
}
