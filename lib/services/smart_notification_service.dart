import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import '../models/habit.dart';
import '../models/mood.dart';

enum NotificationType {
  reminder,
  celebration,
  streak,
  achievement,
  motivation,
  weeklySummary,
}

class SmartNotificationService {
  static SmartNotificationService? _instance;
  static SmartNotificationService get instance => _instance ??= SmartNotificationService._();
  
  SmartNotificationService._();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final Map<String, List<DateTime>> _completionHistory = {};
  final Map<String, List<DateTime>> _notificationHistory = {};

  Future<void> initialize() async {
    tzdata.initializeTimeZones();
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notifications.initialize(initializationSettings);
  }

  Future<void> scheduleSmartReminder({
    required Habit habit,
    required List<Mood> recentMoods,
  }) async {
    if (!habit.hasReminder || habit.reminderTime == null) return;

    final optimalTime = _calculateOptimalReminderTime(habit, recentMoods);
    
    for (int dayOfWeek in habit.reminderDays) {
      final scheduledTime = _getNextScheduledTime(dayOfWeek, optimalTime);
      
      await _notifications.zonedSchedule(
        '${habit.id}_$dayOfWeek'.hashCode,
        _getReminderTitle(habit),
        _getReminderBody(habit, recentMoods),
        tz.TZDateTime.from(scheduledTime, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'smart_reminders',
            'Smart Habit Reminders',
            channelDescription: 'Intelligent habit reminders based on your patterns',
            importance: Importance.high,
            priority: Priority.high,
            category: AndroidNotificationCategory.reminder,
            showWhen: true,
            enableVibration: true,
            playSound: true,
            actions: [
              const AndroidNotificationAction(
                'complete',
                'Mark Complete',
                showsUserInterface: true,
              ),
              const AndroidNotificationAction(
                'snooze',
                'Snooze 1h',
                showsUserInterface: false,
              ),
            ],
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            sound: 'default',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  DateTime _calculateOptimalReminderTime(Habit habit, List<Mood> recentMoods) {
    // Get completion history for this habit
    final completions = _completionHistory[habit.id] ?? [];
    
    if (completions.isEmpty) {
      // Default to morning if no history
      return DateTime(2024, 1, 1, 9, 0);
    }

    // Calculate average completion time
    final completionHours = completions.map((c) => c.hour).toList();
    final averageHour = completionHours.reduce((a, b) => a + b) / completionHours.length;
    
    // Adjust based on mood patterns
    final moodAdjustment = _getMoodBasedTimeAdjustment(recentMoods);
    
    // Calculate optimal time (average completion time - 30 minutes + mood adjustment)
    final optimalHour = (averageHour - 0.5 + moodAdjustment).round().clamp(6, 22);
    
    return DateTime(2024, 1, 1, optimalHour, 0);
  }

  double _getMoodBasedTimeAdjustment(List<Mood> recentMoods) {
    if (recentMoods.isEmpty) return 0.0;
    
    final averageMood = recentMoods.fold<double>(0, (sum, mood) => sum + mood.numericValue) / recentMoods.length;
    
    // If mood is low, suggest earlier reminders (more motivation needed)
    // If mood is high, suggest later reminders (less motivation needed)
    return (3.0 - averageMood) * 0.5;
  }

  DateTime _getNextScheduledTime(int dayOfWeek, DateTime optimalTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    int daysUntilNext = (dayOfWeek - now.weekday) % 7;
    if (daysUntilNext == 0) {
      // If it's today, check if the time has passed
      final scheduledTime = DateTime(
        now.year,
        now.month,
        now.day,
        optimalTime.hour,
        optimalTime.minute,
      );
      if (scheduledTime.isBefore(now)) {
        daysUntilNext = 7; // Schedule for next week
      }
    }
    
    final scheduledDate = today.add(Duration(days: daysUntilNext));
    return DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      optimalTime.hour,
      optimalTime.minute,
    );
  }

  String _getReminderTitle(Habit habit) {
    final titles = [
      'Time for ${habit.name}!',
      'Don\'t forget: ${habit.name}',
      'Your ${habit.name} awaits!',
      'Ready for ${habit.name}?',
      '${habit.name} reminder',
    ];
    return titles[Random().nextInt(titles.length)];
  }

  String _getReminderBody(Habit habit, List<Mood> recentMoods) {
    final streak = habit.currentStreak;
    final mood = recentMoods.isNotEmpty ? recentMoods.last : null;
    
    if (streak > 0) {
      return 'You\'re on a $streak-day streak! Keep it going! 🔥';
    } else if (mood != null && mood.numericValue < 3) {
      return 'A small step can make a big difference. You\'ve got this! 💪';
    } else {
      return 'Every journey begins with a single step. Let\'s do this! ✨';
    }
  }

  Future<void> scheduleCelebrationNotification({
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    await _notifications.zonedSchedule(
      'celebration_${DateTime.now().millisecondsSinceEpoch}'.hashCode,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'celebrations',
          'Habit Celebrations',
          channelDescription: 'Celebration notifications for habit milestones',
          importance: Importance.high,
          priority: Priority.high,
          category: AndroidNotificationCategory.status,
          showWhen: true,
          enableVibration: true,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('celebration'),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'celebration.wav',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> scheduleStreakRecoveryNotification({
    required Habit habit,
    required int daysMissed,
  }) async {
    final recoveryTime = DateTime.now().add(const Duration(hours: 2));
    
    await _notifications.zonedSchedule(
      'recovery_${habit.id}'.hashCode,
      'Streak Recovery',
      'You\'ve missed $daysMissed days of ${habit.name}. Ready to get back on track?',
      tz.TZDateTime.from(recoveryTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'streak_recovery',
          'Streak Recovery',
          channelDescription: 'Notifications to help recover broken streaks',
          importance: Importance.high,
          priority: Priority.high,
          category: AndroidNotificationCategory.reminder,
          showWhen: true,
          enableVibration: true,
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> scheduleWeeklySummaryNotification() async {
    // Schedule for Sunday evening
    final now = DateTime.now();
    final nextSunday = now.add(Duration(days: (7 - now.weekday) % 7));
    final summaryTime = DateTime(nextSunday.year, nextSunday.month, nextSunday.day, 20, 0);
    
    await _notifications.zonedSchedule(
      'weekly_summary'.hashCode,
      'Weekly Summary',
      'Check out your progress this week!',
      tz.TZDateTime.from(summaryTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'weekly_summary',
          'Weekly Summary',
          channelDescription: 'Weekly habit progress summaries',
          importance: Importance.high,
          priority: Priority.high,
          category: AndroidNotificationCategory.status,
          showWhen: true,
          enableVibration: true,
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  Future<void> scheduleMotivationalNotification({
    required String message,
    required DateTime scheduledTime,
  }) async {
    await _notifications.zonedSchedule(
      'motivation_${DateTime.now().millisecondsSinceEpoch}'.hashCode,
      'Daily Motivation',
      message,
      tz.TZDateTime.from(scheduledTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'motivation',
          'Daily Motivation',
          channelDescription: 'Daily motivational messages',
          importance: Importance.high,
          priority: Priority.high,
          category: AndroidNotificationCategory.status,
          showWhen: true,
          enableVibration: true,
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> recordHabitCompletion(String habitId, DateTime completionTime) async {
    _completionHistory[habitId] ??= [];
    _completionHistory[habitId]!.add(completionTime);
    
    // Keep only last 30 completions
    if (_completionHistory[habitId]!.length > 30) {
      _completionHistory[habitId]!.removeAt(0);
    }
  }

  Future<void> recordNotificationSent(String habitId, DateTime notificationTime) async {
    _notificationHistory[habitId] ??= [];
    _notificationHistory[habitId]!.add(notificationTime);
    
    // Keep only last 30 notifications
    if (_notificationHistory[habitId]!.length > 30) {
      _notificationHistory[habitId]!.removeAt(0);
    }
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  Future<void> scheduleContextualNotification({
    required String habitId,
    required String title,
    required String body,
    required DateTime scheduledTime,
    Map<String, dynamic>? data,
  }) async {
    await _notifications.zonedSchedule(
      'contextual_${habitId}_${DateTime.now().millisecondsSinceEpoch}'.hashCode,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'contextual',
          'Contextual Notifications',
          channelDescription: 'Context-aware habit notifications',
          importance: Importance.high,
          priority: Priority.high,
          category: AndroidNotificationCategory.reminder,
          showWhen: true,
          enableVibration: true,
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> scheduleWeatherBasedNotification({
    required Habit habit,
    required String weatherCondition,
    required double temperature,
  }) async {
    final message = _getWeatherBasedMessage(habit, weatherCondition, temperature);
    final scheduledTime = DateTime.now().add(const Duration(minutes: 5));
    
    await scheduleContextualNotification(
      habitId: habit.id,
      title: 'Weather Update for ${habit.name}',
      body: message,
      scheduledTime: scheduledTime,
      data: {'habit_id': habit.id, 'weather': weatherCondition},
    );
  }

  String _getWeatherBasedMessage(Habit habit, String weather, double temperature) {
    switch (weather.toLowerCase()) {
      case 'rain':
        return 'It\'s raining outside! Perfect time for indoor ${habit.name.toLowerCase()}. 🌧️';
      case 'sunny':
        return 'Beautiful sunny day! Great weather for ${habit.name.toLowerCase()}. ☀️';
      case 'snow':
        return 'Snowy day ahead! Stay warm and don\'t forget your ${habit.name.toLowerCase()}. ❄️';
      case 'cloudy':
        return 'Cloudy day - perfect for focusing on ${habit.name.toLowerCase()}. ☁️';
      default:
        return 'Weather update: ${temperature}°C. Time for ${habit.name.toLowerCase()}! 🌤️';
    }
  }

  Future<void> scheduleLocationBasedNotification({
    required Habit habit,
    required String location,
  }) async {
    final message = _getLocationBasedMessage(habit, location);
    final scheduledTime = DateTime.now().add(const Duration(minutes: 2));
    
    await scheduleContextualNotification(
      habitId: habit.id,
      title: 'Location Reminder',
      body: message,
      scheduledTime: scheduledTime,
      data: {'habit_id': habit.id, 'location': location},
    );
  }

  String _getLocationBasedMessage(Habit habit, String location) {
    return 'You\'re at $location! Perfect place for ${habit.name.toLowerCase()}. 📍';
  }

  Future<void> scheduleTimeBasedNotification({
    required Habit habit,
    required String timeOfDay,
  }) async {
    final message = _getTimeBasedMessage(habit, timeOfDay);
    final scheduledTime = DateTime.now().add(const Duration(minutes: 1));
    
    await scheduleContextualNotification(
      habitId: habit.id,
      title: 'Time-based Reminder',
      body: message,
      scheduledTime: scheduledTime,
      data: {'habit_id': habit.id, 'time_of_day': timeOfDay},
    );
  }

  String _getTimeBasedMessage(Habit habit, String timeOfDay) {
    switch (timeOfDay.toLowerCase()) {
      case 'morning':
        return 'Good morning! Start your day with ${habit.name.toLowerCase()}. 🌅';
      case 'afternoon':
        return 'Afternoon energy boost! Time for ${habit.name.toLowerCase()}. ☀️';
      case 'evening':
        return 'Evening wind-down with ${habit.name.toLowerCase()}. 🌆';
      case 'night':
        return 'Night time routine: ${habit.name.toLowerCase()}. 🌙';
      default:
        return 'Perfect time for ${habit.name.toLowerCase()}! ⏰';
    }
  }

  Future<void> scheduleSocialNotification({
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    await _notifications.zonedSchedule(
      'social_${DateTime.now().millisecondsSinceEpoch}'.hashCode,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'social',
          'Social Notifications',
          channelDescription: 'Social updates and friend activities',
          importance: Importance.high,
          priority: Priority.high,
          category: AndroidNotificationCategory.social,
          showWhen: true,
          enableVibration: true,
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> scheduleAchievementNotification({
    required String title,
    required String body,
    required String achievementType,
  }) async {
    final scheduledTime = DateTime.now().add(const Duration(seconds: 2));
    
    await _notifications.zonedSchedule(
      'achievement_${DateTime.now().millisecondsSinceEpoch}'.hashCode,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'achievements',
          'Achievement Notifications',
          channelDescription: 'Achievement unlocks and milestones',
          importance: Importance.high,
          priority: Priority.high,
          category: AndroidNotificationCategory.status,
          showWhen: true,
          enableVibration: true,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('achievement'),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'achievement.wav',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> scheduleSmartSnooze({
    required String habitId,
    required int snoozeMinutes,
  }) async {
    final scheduledTime = DateTime.now().add(Duration(minutes: snoozeMinutes));
    
    await _notifications.zonedSchedule(
      'snooze_${habitId}_${DateTime.now().millisecondsSinceEpoch}'.hashCode,
      'Snooze Reminder',
      'Time to get back to your habit!',
      tz.TZDateTime.from(scheduledTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'snooze',
          'Snooze Reminders',
          channelDescription: 'Snoozed habit reminders',
          importance: Importance.high,
          priority: Priority.high,
          category: AndroidNotificationCategory.reminder,
          showWhen: true,
          enableVibration: true,
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> scheduleBatchNotifications({
    required List<Map<String, dynamic>> notifications,
  }) async {
    for (final notification in notifications) {
      await scheduleContextualNotification(
        habitId: notification['habitId'] ?? '',
        title: notification['title'] ?? '',
        body: notification['body'] ?? '',
        scheduledTime: notification['scheduledTime'] ?? DateTime.now(),
        data: notification['data'],
      );
    }
  }

  Future<Map<String, dynamic>> getNotificationAnalytics() async {
    final pending = await getPendingNotifications();
    final completionHistory = getCompletionHistory();
    final notificationHistory = getNotificationHistory();
    
    return {
      'pendingCount': pending.length,
      'totalCompletions': completionHistory.values.fold(0, (sum, list) => sum + list.length),
      'totalNotifications': notificationHistory.values.fold(0, (sum, list) => sum + list.length),
      'averageResponseTime': _calculateAverageResponseTime(),
      'completionRate': _calculateCompletionRate(),
    };
  }

  double _calculateAverageResponseTime() {
    // Calculate average time between notification and completion
    double totalTime = 0;
    int count = 0;
    
    for (final habitId in _notificationHistory.keys) {
      final notifications = _notificationHistory[habitId]!;
      final completions = _completionHistory[habitId] ?? [];
      
      for (int i = 0; i < notifications.length && i < completions.length; i++) {
        final timeDiff = completions[i].difference(notifications[i]).inMinutes;
        if (timeDiff > 0) {
          totalTime += timeDiff;
          count++;
        }
      }
    }
    
    return count > 0 ? totalTime / count : 0.0;
  }

  double _calculateCompletionRate() {
    int totalNotifications = 0;
    int totalCompletions = 0;
    
    for (final habitId in _notificationHistory.keys) {
      final notifications = _notificationHistory[habitId]!;
      final completions = _completionHistory[habitId] ?? [];
      
      totalNotifications += notifications.length;
      totalCompletions += completions.length;
    }
    
    return totalNotifications > 0 ? totalCompletions / totalNotifications : 0.0;
  }

  Map<String, List<DateTime>> getCompletionHistory() => Map.unmodifiable(_completionHistory);
  Map<String, List<DateTime>> getNotificationHistory() => Map.unmodifiable(_notificationHistory);
}
