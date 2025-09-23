import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/env_config.dart';

class FastApiService {
  static final FastApiService _instance = FastApiService._internal();
  factory FastApiService() => _instance;
  FastApiService._internal();

  static FastApiService get instance => _instance;

  late Dio _dio;

  Future<void> initialize() async {
    try {
      if (!EnvConfig.isFastApiConfigured) {
        // FastAPI configuration is missing - continue without FastAPI
        return; // Don't throw, just log and continue
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
      if (EnvConfig.isDebug) {
        _dio.interceptors.add(LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (obj) => debugPrint(obj),
        ));
      }

      _dio.interceptors.add(InterceptorsWrapper(
        onError: (error, handler) {
          if (EnvConfig.isDebug) {
            debugPrint('FastAPI Error: ${error.message}');
          }
          handler.next(error);
        },
      ));
    } catch (e) {
      if (EnvConfig.isDebug) {
        debugPrint('Error initializing FastAPI service: $e');
      }
      // Continue without FastAPI if initialization fails
    }
  }

  // AI-Powered Analytics
  Future<Map<String, dynamic>> getHabitInsights(String userId) async {
    try {
      if (!EnvConfig.isFastApiConfigured) {
        throw Exception('FastAPI service not initialized');
      }
      final response = await _dio.get('/analytics/habit-insights/$userId');
      return response.data;
    } catch (e) {
      if (EnvConfig.isDebug) {
        debugPrint('Error getting habit insights: $e');
      }
      return {}; // Return empty map instead of rethrowing
    }
  }

  Future<Map<String, dynamic>> getMoodAnalysis(String userId) async {
    try {
      if (!EnvConfig.isFastApiConfigured) {
        throw Exception('FastAPI service not initialized');
      }
      final response = await _dio.get('/analytics/mood-analysis/$userId');
      return response.data;
    } catch (e) {
      if (EnvConfig.isDebug) {
        debugPrint('Error getting mood analysis: $e');
      }
      return {}; // Return empty map instead of rethrowing
    }
  }

  Future<Map<String, dynamic>> getPersonalizedRecommendations(String userId) async {
    try {
      if (!EnvConfig.isFastApiConfigured) {
        throw Exception('FastAPI service not initialized');
      }
      final response = await _dio.get('/analytics/recommendations/$userId');
      return response.data;
    } catch (e) {
      if (EnvConfig.isDebug) {
        debugPrint('Error getting personalized recommendations: $e');
      }
      return {}; // Return empty map instead of rethrowing
    }
  }

  // Smart Notifications
  Future<Map<String, dynamic>> getOptimalNotificationTimes(String userId) async {
    try {
      if (!EnvConfig.isFastApiConfigured) {
        throw Exception('FastAPI service not initialized');
      }
      final response = await _dio.get('/notifications/optimal-times/$userId');
      return response.data;
    } catch (e) {
      if (EnvConfig.isDebug) {
        debugPrint('Error getting optimal notification times: $e');
      }
      return {}; // Return empty map instead of rethrowing
    }
  }

  Future<Map<String, dynamic>> scheduleSmartNotification({
    required String userId,
    required String habitId,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    try {
      if (!EnvConfig.isFastApiConfigured) {
        throw Exception('FastAPI service not initialized');
      }
      final response = await _dio.post('/notifications/schedule', data: {
        'user_id': userId,
        'habit_id': habitId,
        'type': type,
        'data': data,
      });
      return response.data;
    } catch (e) {
      if (EnvConfig.isDebug) {
        debugPrint('Error scheduling smart notification: $e');
      }
      return {}; // Return empty map instead of rethrowing
    }
  }

  // Habit Correlation Analysis
  Future<Map<String, dynamic>> getHabitCorrelations(String userId) async {
    try {
      if (!EnvConfig.isFastApiConfigured) {
        throw Exception('FastAPI service not initialized');
      }
      final response = await _dio.get('/analytics/habit-correlations/$userId');
      return response.data;
    } catch (e) {
      if (EnvConfig.isDebug) {
        debugPrint('Error getting habit correlations: $e');
      }
      return {}; // Return empty map instead of rethrowing
    }
  }

  // Streak Prediction
  Future<Map<String, dynamic>> predictStreakSuccess(String userId, String habitId) async {
    try {
      if (!EnvConfig.isFastApiConfigured) {
        throw Exception('FastAPI service not initialized');
      }
      final response = await _dio.get('/analytics/streak-prediction/$userId/$habitId');
      return response.data;
    } catch (e) {
      if (EnvConfig.isDebug) {
        debugPrint('Error predicting streak success: $e');
      }
      return {}; // Return empty map instead of rethrowing
    }
  }

  // Social Features
  Future<Map<String, dynamic>> getSocialInsights(String userId) async {
    try {
      if (!EnvConfig.isFastApiConfigured) {
        throw Exception('FastAPI service not initialized');
      }
      final response = await _dio.get('/social/insights/$userId');
      return response.data;
    } catch (e) {
      if (EnvConfig.isDebug) {
        debugPrint('Error getting social insights: $e');
      }
      return {}; // Return empty map instead of rethrowing
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
      if (!EnvConfig.isFastApiConfigured) {
        throw Exception('FastAPI service not initialized');
      }
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
      if (EnvConfig.isDebug) {
        debugPrint('Error creating group challenge: $e');
      }
      return {}; // Return empty map instead of rethrowing
    }
  }

  // Data Export/Import
  Future<Map<String, dynamic>> exportUserData(String userId) async {
    try {
      if (!EnvConfig.isFastApiConfigured) {
        throw Exception('FastAPI service not initialized');
      }
      final response = await _dio.get('/data/export/$userId');
      return response.data;
    } catch (e) {
      if (EnvConfig.isDebug) {
        debugPrint('Error exporting user data: $e');
      }
      return {}; // Return empty map instead of rethrowing
    }
  }

  Future<Map<String, dynamic>> importUserData(String userId, Map<String, dynamic> data) async {
    try {
      if (!EnvConfig.isFastApiConfigured) {
        throw Exception('FastAPI service not initialized');
      }
      final response = await _dio.post('/data/import/$userId', data: data);
      return response.data;
    } catch (e) {
      if (EnvConfig.isDebug) {
        debugPrint('Error importing user data: $e');
      }
      return {}; // Return empty map instead of rethrowing
    }
  }

  // Health Check
  Future<bool> healthCheck() async {
    try {
      if (!EnvConfig.isFastApiConfigured) {
        return false;
      }
      final response = await _dio.get('/health');
      return response.statusCode == 200;
    } catch (e) {
      if (EnvConfig.isDebug) {
        debugPrint('FastAPI health check failed: $e');
      }
      return false;
    }
  }

  // Batch Operations
  Future<Map<String, dynamic>> batchUpdateHabits(String userId, List<Map<String, dynamic>> habits) async {
    try {
      if (!EnvConfig.isFastApiConfigured) {
        throw Exception('FastAPI service not initialized');
      }
      final response = await _dio.post('/habits/batch-update', data: {
        'user_id': userId,
        'habits': habits,
      });
      return response.data;
    } catch (e) {
      if (EnvConfig.isDebug) {
        debugPrint('Error batch updating habits: $e');
      }
      return {}; // Return empty map instead of rethrowing
    }
  }

  // Advanced Analytics
  Future<Map<String, dynamic>> getAdvancedAnalytics(String userId) async {
    try {
      if (!EnvConfig.isFastApiConfigured) {
        throw Exception('FastAPI service not initialized');
      }
      final response = await _dio.get('/analytics/advanced/$userId');
      return response.data;
    } catch (e) {
      if (EnvConfig.isDebug) {
        debugPrint('Error getting advanced analytics: $e');
      }
      return {}; // Return empty map instead of rethrowing
    }
  }
}
