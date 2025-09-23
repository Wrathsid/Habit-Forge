import 'dart:math';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/timezone.dart' as tz;
import '../models/habit.dart';
import '../models/mood.dart';
import '../services/smart_notification_service.dart';

class ContextualNotificationService {
  static ContextualNotificationService? _instance;
  static ContextualNotificationService get instance => _instance ??= ContextualNotificationService._();
  
  ContextualNotificationService._();

  final Map<String, List<DateTime>> _contextHistory = {};
  final Map<String, String> _lastKnownLocation = {};
  final Map<String, String> _lastKnownWeather = {};

  // Contextual triggers
  Future<void> checkAndTriggerContextualNotifications({
    required List<Habit> habits,
    required List<Mood> recentMoods,
    String? currentLocation,
    String? currentWeather,
    double? temperature,
  }) async {
    for (final habit in habits) {
      await _checkHabitContext(habit, recentMoods, currentLocation, currentWeather, temperature);
    }
  }

  Future<void> _checkHabitContext(
    Habit habit,
    List<Mood> recentMoods,
    String? currentLocation,
    String? currentWeather,
    double? temperature,
  ) async {
    // Check for mood-based triggers
    await _checkMoodBasedTrigger(habit, recentMoods);
    
    // Check for location-based triggers
    if (currentLocation != null) {
      await _checkLocationBasedTrigger(habit, currentLocation);
    }
    
    // Check for weather-based triggers
    if (currentWeather != null && temperature != null) {
      await _checkWeatherBasedTrigger(habit, currentWeather, temperature);
    }
    
    // Check for time-based triggers
    await _checkTimeBasedTrigger(habit);
    
    // Check for streak-based triggers
    await _checkStreakBasedTrigger(habit);
    
    // Check for completion pattern triggers
    await _checkCompletionPatternTrigger(habit);
  }

  Future<void> _checkMoodBasedTrigger(Habit habit, List<Mood> recentMoods) async {
    if (recentMoods.isEmpty) return;
    
    final latestMood = recentMoods.last;
    // final averageMood = recentMoods.fold<double>(0, (sum, mood) => sum + mood.numericValue) / recentMoods.length;
    
    // Low mood motivation
    if (latestMood.numericValue < 2.5 && !_hasRecentContextNotification(habit.id, 'low_mood')) {
      await SmartNotificationService.instance.scheduleContextualNotification(
        habitId: habit.id,
        title: 'Gentle Reminder 💙',
        body: 'We know you\'re not feeling your best today. A small step with ${habit.name} might help lift your spirits.',
        scheduledTime: DateTime.now().add(const Duration(minutes: 5)),
        data: {'context': 'low_mood', 'mood_value': latestMood.numericValue.toString()},
      );
      _recordContextNotification(habit.id, 'low_mood');
    }
    
    // High mood celebration
    if (latestMood.numericValue > 4.0 && !_hasRecentContextNotification(habit.id, 'high_mood')) {
      await SmartNotificationService.instance.scheduleContextualNotification(
        habitId: habit.id,
        title: 'Great Energy! ⚡',
        body: 'You\'re feeling amazing today! Perfect time to tackle ${habit.name} with enthusiasm!',
        scheduledTime: DateTime.now().add(const Duration(minutes: 2)),
        data: {'context': 'high_mood', 'mood_value': latestMood.numericValue.toString()},
      );
      _recordContextNotification(habit.id, 'high_mood');
    }
  }

  Future<void> _checkLocationBasedTrigger(Habit habit, String currentLocation) async {
    final lastLocation = _lastKnownLocation[habit.id];
    
    // Location change trigger
    if (lastLocation != null && lastLocation != currentLocation) {
      if (!_hasRecentContextNotification(habit.id, 'location_change')) {
        await SmartNotificationService.instance.scheduleLocationBasedNotification(
          habit: habit,
          location: currentLocation,
        );
        _recordContextNotification(habit.id, 'location_change');
      }
    }
    
    // Specific location triggers
    if (_isHabitLocationRelevant(habit, currentLocation) && !_hasRecentContextNotification(habit.id, 'relevant_location')) {
      await SmartNotificationService.instance.scheduleContextualNotification(
        habitId: habit.id,
        title: 'Perfect Location! 📍',
        body: 'You\'re at $currentLocation - ideal place for ${habit.name}!',
        scheduledTime: DateTime.now().add(const Duration(minutes: 1)),
        data: {'context': 'relevant_location', 'location': currentLocation},
      );
      _recordContextNotification(habit.id, 'relevant_location');
    }
    
    _lastKnownLocation[habit.id] = currentLocation;
  }

  Future<void> _checkWeatherBasedTrigger(Habit habit, String weather, double temperature) async {
    final lastWeather = _lastKnownWeather[habit.id];
    
    // Weather change trigger
    if (lastWeather != null && lastWeather != weather) {
      if (!_hasRecentContextNotification(habit.id, 'weather_change')) {
        await SmartNotificationService.instance.scheduleWeatherBasedNotification(
          habit: habit,
          weatherCondition: weather,
          temperature: temperature,
        );
        _recordContextNotification(habit.id, 'weather_change');
      }
    }
    
    // Weather-specific triggers
    if (_isWeatherRelevantForHabit(habit, weather) && !_hasRecentContextNotification(habit.id, 'weather_relevant')) {
      await SmartNotificationService.instance.scheduleContextualNotification(
        habitId: habit.id,
        title: 'Weather Perfect! 🌤️',
        body: _getWeatherRelevantMessage(habit, weather, temperature),
        scheduledTime: DateTime.now().add(const Duration(minutes: 3)),
        data: {'context': 'weather_relevant', 'weather': weather, 'temperature': temperature.toString()},
      );
      _recordContextNotification(habit.id, 'weather_relevant');
    }
    
    _lastKnownWeather[habit.id] = weather;
  }

  Future<void> _checkTimeBasedTrigger(Habit habit) async {
    final now = DateTime.now();
    final hour = now.hour;
    
    // Morning motivation (6-9 AM)
    if (hour >= 6 && hour <= 9 && !_hasRecentContextNotification(habit.id, 'morning_motivation')) {
      await SmartNotificationService.instance.scheduleTimeBasedNotification(
        habit: habit,
        timeOfDay: 'morning',
      );
      _recordContextNotification(habit.id, 'morning_motivation');
    }
    
    // Afternoon energy (1-3 PM)
    if (hour >= 13 && hour <= 15 && !_hasRecentContextNotification(habit.id, 'afternoon_energy')) {
      await SmartNotificationService.instance.scheduleContextualNotification(
        habitId: habit.id,
        title: 'Afternoon Boost! ☀️',
        body: 'Beat the afternoon slump with ${habit.name}!',
        scheduledTime: DateTime.now().add(const Duration(minutes: 2)),
        data: {'context': 'afternoon_energy'},
      );
      _recordContextNotification(habit.id, 'afternoon_energy');
    }
    
    // Evening wind-down (7-9 PM)
    if (hour >= 19 && hour <= 21 && !_hasRecentContextNotification(habit.id, 'evening_wind_down')) {
      await SmartNotificationService.instance.scheduleContextualNotification(
        habitId: habit.id,
        title: 'Evening Routine 🌆',
        body: 'Wind down your day with ${habit.name}.',
        scheduledTime: DateTime.now().add(const Duration(minutes: 1)),
        data: {'context': 'evening_wind_down'},
      );
      _recordContextNotification(habit.id, 'evening_wind_down');
    }
  }

  Future<void> _checkStreakBasedTrigger(Habit habit) async {
    final streak = habit.currentStreak;
    
    // Streak milestones
    if (streak > 0 && _isStreakMilestone(streak) && !_hasRecentContextNotification(habit.id, 'streak_milestone_$streak')) {
      await SmartNotificationService.instance.scheduleCelebrationNotification(
        title: 'Streak Milestone! 🔥',
        body: 'Incredible! You\'ve maintained ${habit.name} for $streak days straight!',
        scheduledTime: DateTime.now().add(const Duration(seconds: 2)),
      );
      _recordContextNotification(habit.id, 'streak_milestone_$streak');
    }
    
    // Streak recovery (after breaking a streak)
    if (streak == 0 && habit.longestStreak > 0 && !_hasRecentContextNotification(habit.id, 'streak_recovery')) {
      await SmartNotificationService.instance.scheduleStreakRecoveryNotification(
        habit: habit,
        daysMissed: 1,
      );
      _recordContextNotification(habit.id, 'streak_recovery');
    }
  }

  Future<void> _checkCompletionPatternTrigger(Habit habit) async {
    final completionHistory = SmartNotificationService.instance.getCompletionHistory()[habit.id] ?? [];
    
    if (completionHistory.length < 3) return;
    
    // Check for consistent completion pattern
    final recentCompletions = completionHistory.length > 7 
        ? completionHistory.sublist(completionHistory.length - 7)
        : completionHistory;
    final completionRate = recentCompletions.length / 7;
    
    // High completion rate celebration
    if (completionRate >= 0.8 && !_hasRecentContextNotification(habit.id, 'high_completion_rate')) {
      await SmartNotificationService.instance.scheduleContextualNotification(
        habitId: habit.id,
        title: 'Consistency Champion! 🏆',
        body: 'You\'ve been crushing ${habit.name} with ${(completionRate * 100).toInt()}% completion rate!',
        scheduledTime: DateTime.now().add(const Duration(minutes: 1)),
        data: {'context': 'high_completion_rate', 'rate': completionRate.toString()},
      );
      _recordContextNotification(habit.id, 'high_completion_rate');
    }
    
    // Low completion rate motivation
    if (completionRate < 0.3 && !_hasRecentContextNotification(habit.id, 'low_completion_rate')) {
      await SmartNotificationService.instance.scheduleContextualNotification(
        habitId: habit.id,
        title: 'Let\'s Get Back on Track! 💪',
        body: 'We believe in you! Small steps with ${habit.name} can make a big difference.',
        scheduledTime: DateTime.now().add(const Duration(minutes: 10)),
        data: {'context': 'low_completion_rate', 'rate': completionRate.toString()},
      );
      _recordContextNotification(habit.id, 'low_completion_rate');
    }
  }

  bool _isHabitLocationRelevant(Habit habit, String location) {
    final habitName = habit.name.toLowerCase();
    final locationLower = location.toLowerCase();
    
    // Simple location relevance check
    if (habitName.contains('gym') && locationLower.contains('gym')) return true;
    if (habitName.contains('run') && locationLower.contains('park')) return true;
    if (habitName.contains('meditation') && locationLower.contains('home')) return true;
    if (habitName.contains('workout') && locationLower.contains('fitness')) return true;
    
    return false;
  }

  bool _isWeatherRelevantForHabit(Habit habit, String weather) {
    final habitName = habit.name.toLowerCase();
    
    if (habitName.contains('run') && weather.toLowerCase().contains('sunny')) return true;
    if (habitName.contains('meditation') && weather.toLowerCase().contains('rain')) return true;
    if (habitName.contains('gym') && weather.toLowerCase().contains('cloudy')) return true;
    
    return false;
  }

  String _getWeatherRelevantMessage(Habit habit, String weather, double temperature) {
    final habitName = habit.name.toLowerCase();
    
    if (habitName.contains('run') && weather.toLowerCase().contains('sunny')) {
      return 'Perfect sunny weather for ${habit.name}! Time to hit the pavement! ☀️';
    }
    if (habitName.contains('meditation') && weather.toLowerCase().contains('rain')) {
      return 'Rainy day - perfect atmosphere for ${habit.name} and mindfulness. 🌧️';
    }
    if (habitName.contains('gym') && weather.toLowerCase().contains('cloudy')) {
      return 'Cloudy day - great time for indoor ${habit.name}! ☁️';
    }
    
    return 'Weather conditions are ideal for ${habit.name}! 🌤️';
  }

  bool _isStreakMilestone(int streak) {
    return streak == 3 || streak == 7 || streak == 14 || streak == 30 || streak == 60 || streak == 100;
  }

  bool _hasRecentContextNotification(String habitId, String contextType) {
    final history = _contextHistory[habitId] ?? [];
    final now = DateTime.now();
    
    // Check if we've sent this type of notification in the last 24 hours
    return history.any((timestamp) {
      final timeDiff = now.difference(timestamp).inHours;
      return timeDiff < 24;
    });
  }

  void _recordContextNotification(String habitId, String contextType) {
    _contextHistory[habitId] ??= [];
    _contextHistory[habitId]!.add(DateTime.now());
    
    // Keep only last 50 context notifications per habit
    if (_contextHistory[habitId]!.length > 50) {
      _contextHistory[habitId]!.removeAt(0);
    }
  }

  // Smart notification scheduling based on user patterns
  Future<void> scheduleOptimalNotification({
    required Habit habit,
    required List<Mood> recentMoods,
    required List<DateTime> completionHistory,
  }) async {
    final optimalTime = _calculateOptimalNotificationTime(habit, recentMoods, completionHistory);
    final message = _generateContextualMessage(habit, recentMoods, completionHistory);
    
    await SmartNotificationService.instance.scheduleContextualNotification(
      habitId: habit.id,
      title: 'Smart Reminder',
      body: message,
      scheduledTime: optimalTime,
      data: {'type': 'optimal', 'habit_id': habit.id},
    );
  }

  DateTime _calculateOptimalNotificationTime(
    Habit habit,
    List<Mood> recentMoods,
    List<DateTime> completionHistory,
  ) {
    if (completionHistory.isEmpty) {
      // Default to morning if no history
      return DateTime.now().add(const Duration(hours: 1));
    }
    
    // Calculate average completion time
    final completionHours = completionHistory.map((c) => c.hour).toList();
    final averageHour = completionHours.reduce((a, b) => a + b) / completionHours.length;
    
    // Adjust based on mood
    final moodAdjustment = recentMoods.isNotEmpty 
        ? (3.0 - recentMoods.last.numericValue) * 0.5 
        : 0.0;
    
    // Calculate optimal time (30 minutes before average completion)
    final optimalHour = (averageHour - 0.5 + moodAdjustment).round().clamp(6, 22);
    
    return DateTime.now().add(Duration(hours: optimalHour - DateTime.now().hour));
  }

  String _generateContextualMessage(
    Habit habit,
    List<Mood> recentMoods,
    List<DateTime> completionHistory,
  ) {
    final streak = habit.currentStreak;
    final mood = recentMoods.isNotEmpty ? recentMoods.last : null;
    
    // Streak-based messages
    if (streak > 0) {
      final streakMessages = [
        'You\'re on fire! $streak days strong with ${habit.name}! 🔥',
        'Amazing streak! Keep the momentum going with ${habit.name}! 💪',
        'Incredible consistency! $streak days of ${habit.name}! ⭐',
      ];
      return streakMessages[Random().nextInt(streakMessages.length)];
    }
    
    // Mood-based messages
    if (mood != null) {
      if (mood.numericValue < 2.5) {
        return 'A small step with ${habit.name} might help brighten your day. You\'ve got this! 💙';
      } else if (mood.numericValue > 4.0) {
        return 'Great energy! Perfect time to tackle ${habit.name} with enthusiasm! ⚡';
      }
    }
    
    // Default motivational messages
    final defaultMessages = [
      'Time for ${habit.name}! Every step counts! ✨',
      'Ready to make progress with ${habit.name}? Let\'s go! 🚀',
      'Your future self will thank you for ${habit.name}! 💫',
      'Small actions, big results with ${habit.name}! 🌟',
    ];
    
    return defaultMessages[Random().nextInt(defaultMessages.length)];
  }

  // Get contextual insights
  Map<String, dynamic> getContextualInsights() {
    return {
      'totalContextNotifications': _contextHistory.values.fold(0, (sum, list) => sum + list.length),
      'activeHabits': _contextHistory.keys.length,
      'lastKnownLocations': _lastKnownLocation,
      'lastKnownWeather': _lastKnownWeather,
    };
  }
}
