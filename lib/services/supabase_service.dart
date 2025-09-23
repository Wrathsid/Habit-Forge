import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../config/env_config.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  static SupabaseService get instance => _instance;

  SupabaseClient get client => Supabase.instance.client;

  Future<void> initialize() async {
    if (!EnvConfig.isSupabaseConfigured) {
      throw Exception('Supabase configuration is missing. Please check your .env file.');
    }

    await Supabase.initialize(
      url: EnvConfig.supabaseUrl,
      anonKey: EnvConfig.supabaseAnonKey,
    );
  }

  // Authentication
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    return await client.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  User? get currentUser => client.auth.currentUser;
  bool get isSignedIn => currentUser != null;

  // Database Operations
  Future<List<Map<String, dynamic>>> getHabits() async {
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }
    
    final response = await client
        .from('habits')
        .select()
        .eq('user_id', currentUser!.id)
        .order('created_at', ascending: false);
    
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> createHabit(Map<String, dynamic> habit) async {
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }
    
    final response = await client
        .from('habits')
        .insert({
          ...habit,
          'user_id': currentUser!.id,
          'created_at': DateTime.now().toIso8601String(),
        })
        .select()
        .maybeSingle();
    
    return response;
  }

  Future<Map<String, dynamic>> updateHabit(String id, Map<String, dynamic> updates) async {
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }
    
    final response = await client
        .from('habits')
        .update({
          ...updates,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id)
        .eq('user_id', currentUser!.id)
        .select()
        .maybeSingle();
    
    return response;
  }

  Future<void> deleteHabit(String id) async {
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }
    
    await client
        .from('habits')
        .delete()
        .eq('id', id)
        .eq('user_id', currentUser!.id);
  }

  // Habit Completions
  Future<Map<String, dynamic>> markHabitComplete(String habitId, DateTime date) async {
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }
    
    final response = await client
        .from('habit_completions')
        .upsert({
          'habit_id': habitId,
          'user_id': currentUser!.id,
          'completed_at': date.toIso8601String(),
          'date': date.toIso8601String().split('T')[0], // YYYY-MM-DD format
        })
        .select()
        .maybeSingle();
    
    return response;
  }

  Future<List<Map<String, dynamic>>> getHabitCompletions(String habitId) async {
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }
    
    final response = await client
        .from('habit_completions')
        .select()
        .eq('habit_id', habitId)
        .eq('user_id', currentUser!.id)
        .order('date', ascending: false);
    
    return List<Map<String, dynamic>>.from(response);
  }

  // Mood Tracking
  Future<Map<String, dynamic>> saveMood(Map<String, dynamic> mood) async {
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }
    
    final response = await client
        .from('moods')
        .upsert({
          ...mood,
          'user_id': currentUser!.id,
          'created_at': DateTime.now().toIso8601String(),
        })
        .select()
        .maybeSingle();
    
    return response;
  }

  Future<List<Map<String, dynamic>>> getMoods() async {
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }
    
    final response = await client
        .from('moods')
        .select()
        .eq('user_id', currentUser!.id)
        .order('created_at', ascending: false);
    
    return List<Map<String, dynamic>>.from(response);
  }

  // Achievements
  Future<Map<String, dynamic>> saveAchievement(Map<String, dynamic> achievement) async {
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }
    
    final response = await client
        .from('achievements')
        .insert({
          ...achievement,
          'user_id': currentUser!.id,
          'earned_at': DateTime.now().toIso8601String(),
        })
        .select()
        .maybeSingle();
    
    return response;
  }

  Future<List<Map<String, dynamic>>> getAchievements() async {
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }
    
    final response = await client
        .from('achievements')
        .select()
        .eq('user_id', currentUser!.id)
        .order('earned_at', ascending: false);
    
    return List<Map<String, dynamic>>.from(response);
  }

  // User Progress
  Future<Map<String, dynamic>> updateUserProgress(Map<String, dynamic> progress) async {
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }
    
    final response = await client
        .from('user_progress')
        .upsert({
          ...progress,
          'user_id': currentUser!.id,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .select()
        .maybeSingle();
    
    return response;
  }

  Future<Map<String, dynamic>?> getUserProgress() async {
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }
    
    final response = await client
        .from('user_progress')
        .select()
        .eq('user_id', currentUser!.id)
        .maybeSingle();
    
    return response;
  }

  // Social Features
  Future<List<Map<String, dynamic>>> getFriends() async {
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }
    
    final response = await client
        .from('friends')
        .select('*, profiles(*)')
        .eq('user_id', currentUser!.id)
        .eq('status', 'accepted');
    
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> sendFriendRequest(String friendId) async {
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }
    
    final response = await client
        .from('friends')
        .insert({
          'user_id': currentUser!.id,
          'friend_id': friendId,
          'status': 'pending',
          'created_at': DateTime.now().toIso8601String(),
        })
        .select()
        .maybeSingle();
    
    return response;
  }

  // Real-time subscriptions
  RealtimeChannel subscribeToHabits() {
    return client
        .channel('habits')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'habits',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: currentUser?.id,
          ),
          callback: (payload) {
            // Handle real-time updates
            if (kDebugMode) {
              print('Habit updated: ${payload.newRecord}');
            }
          },
        )
        .subscribe();
  }
}
