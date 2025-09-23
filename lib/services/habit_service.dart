import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/habit.dart';
import 'notification_service.dart';

class HabitService {
  static const String _habitsKey = 'habits';
  static HabitService? _instance;
  static HabitService get instance => _instance ??= HabitService._();
  
  HabitService._();

  List<Habit> _habits = [];
  List<Habit> get habits => List.unmodifiable(_habits);

  Future<void> loadHabits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final habitsJson = prefs.getStringList(_habitsKey) ?? [];
      
      _habits = habitsJson
          .map((json) {
            try {
              return Habit.fromJson(jsonDecode(json));
            } catch (e) {
              if (kDebugMode) {
                print('Error parsing habit JSON: $e');
              }
              return null;
            }
          })
          .where((habit) => habit != null)
          .cast<Habit>()
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading habits: $e');
      }
      _habits = [];
    }
  }

  Future<void> saveHabits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final habitsJson = _habits
          .map((habit) {
            try {
              return jsonEncode(habit.toJson());
            } catch (e) {
              if (kDebugMode) {
                print('Error encoding habit to JSON: $e');
              }
              return null;
            }
          })
          .where((json) => json != null)
          .cast<String>()
          .toList();
      
      await prefs.setStringList(_habitsKey, habitsJson);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving habits: $e');
      }
    }
  }

  Future<void> addHabit(Habit habit) async {
    _habits.add(habit);
    await saveHabits();
    
    // Schedule notifications if reminder is enabled
    if (habit.hasReminder && habit.reminderTime != null) {
      await _scheduleHabitReminders(habit);
    }
  }

  Future<void> updateHabit(Habit habit) async {
    final index = _habits.indexWhere((h) => h.id == habit.id);
    if (index != -1) {
      _habits[index] = habit;
      await saveHabits();
      
      // Cancel old notifications and schedule new ones if reminder settings changed
      await NotificationService.instance.cancelNotification(habit.id.hashCode);
      if (habit.hasReminder && habit.reminderTime != null) {
        await _scheduleHabitReminders(habit);
      }
    }
  }

  Future<void> deleteHabit(String habitId) async {
    // Cancel notifications before deleting
    await NotificationService.instance.cancelNotification(habitId.hashCode);
    _habits.removeWhere((habit) => habit.id == habitId);
    await saveHabits();
  }

  Future<void> completeHabit(String habitId) async {
    final habitIndex = _habits.indexWhere((h) => h.id == habitId);
    if (habitIndex == -1) return;

    final habit = _habits[habitIndex];
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    // Check if already completed today
    if (habit.isCompletedToday) return;

    // Add today's completion
    final updatedCompletedDates = List<DateTime>.from(habit.completedDates);
    updatedCompletedDates.add(todayDate);

    // Calculate new streak
    int newStreak = 1;
    for (int i = 1; i <= 30; i++) {
      final checkDate = todayDate.subtract(Duration(days: i));
      if (updatedCompletedDates.any((date) {
        final dateOnly = DateTime(date.year, date.month, date.day);
        return dateOnly.isAtSameMomentAs(checkDate);
      })) {
        newStreak++;
      } else {
        break;
      }
    }

    final updatedHabit = habit.copyWith(
      currentStreak: newStreak,
      completedDates: updatedCompletedDates,
    );

    _habits[habitIndex] = updatedHabit;
    await saveHabits();
  }

  Future<void> uncompleteHabit(String habitId) async {
    final habitIndex = _habits.indexWhere((h) => h.id == habitId);
    if (habitIndex == -1) return;

    final habit = _habits[habitIndex];
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    // Remove today's completion
    final updatedCompletedDates = habit.completedDates
        .where((date) {
          final dateOnly = DateTime(date.year, date.month, date.day);
          return !dateOnly.isAtSameMomentAs(todayDate);
        })
        .toList();

    // Recalculate streak
    int newStreak = 0;
    for (int i = 0; i <= 30; i++) {
      final checkDate = todayDate.subtract(Duration(days: i));
      if (updatedCompletedDates.any((date) {
        final dateOnly = DateTime(date.year, date.month, date.day);
        return dateOnly.isAtSameMomentAs(checkDate);
      })) {
        newStreak++;
      } else {
        break;
      }
    }

    final updatedHabit = habit.copyWith(
      currentStreak: newStreak,
      completedDates: updatedCompletedDates,
    );

    _habits[habitIndex] = updatedHabit;
    await saveHabits();
  }

  List<Habit> get activeHabits => _habits.where((h) => h.isActive).toList();
  
  int get totalActiveHabits => activeHabits.length;
  
  int get completedTodayCount => activeHabits.where((h) => h.isCompletedToday).length;
  
  double get todayCompletionRate {
    if (totalActiveHabits == 0) return 0.0;
    return completedTodayCount / totalActiveHabits;
  }

  bool isCompletedToday(String habitId) {
    try {
      final habit = _habits.firstWhere((h) => h.id == habitId);
      return habit.isCompletedToday;
    } catch (e) {
      if (kDebugMode) {
        print('Habit not found: $habitId');
      }
      return false;
    }
  }

  Future<void> markComplete(String habitId) async {
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index != -1) {
      final habit = _habits[index];
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      
      // Check if already completed today
      if (!habit.isCompletedToday) {
        final updatedCompletedDates = List<DateTime>.from(habit.completedDates);
        updatedCompletedDates.add(todayDate);
        
        // Calculate new streak
        int newStreak = habit.currentStreak + 1;
        int newLongestStreak = newStreak > habit.longestStreak ? newStreak : habit.longestStreak;
        
        final updatedHabit = habit.copyWith(
          completedDates: updatedCompletedDates,
          currentStreak: newStreak,
          longestStreak: newLongestStreak,
        );
        
        _habits[index] = updatedHabit;
        await saveHabits();
      }
    }
  }

  Future<void> _scheduleHabitReminders(Habit habit) async {
    if (!habit.hasReminder || habit.reminderTime == null) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Schedule notifications for each selected day
    for (int dayOfWeek in habit.reminderDays) {
      // Calculate the next occurrence of this day
      int daysUntilNext = (dayOfWeek - now.weekday) % 7;
      if (daysUntilNext == 0) {
        // If it's today, check if the time has passed
        final scheduledTime = DateTime(
          now.year,
          now.month,
          now.day,
          habit.reminderTime!.hour,
          habit.reminderTime!.minute,
        );
        if (scheduledTime.isBefore(now)) {
          daysUntilNext = 7; // Schedule for next week
        }
      }
      
      final scheduledDate = today.add(Duration(days: daysUntilNext));
      final scheduledDateTime = DateTime(
        scheduledDate.year,
        scheduledDate.month,
        scheduledDate.day,
        habit.reminderTime!.hour,
        habit.reminderTime!.minute,
      );

      await NotificationService.instance.scheduleHabitReminder(
        id: '${habit.id}_$dayOfWeek'.hashCode,
        title: 'Habit Reminder',
        body: "Don't forget to ${habit.name.toLowerCase()}!",
        scheduledTime: scheduledDateTime,
      );
    }
  }
}
