import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';

class Habit {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String category;
  final int currentStreak;
  final int longestStreak;
  final int goal;
  final int priority;
  final List<DateTime> completedDates;
  final DateTime createdAt;
  final bool isActive;
  final bool hasReminder;
  final TimeOfDay? reminderTime;
  final List<int> reminderDays; // 0 = Sunday, 1 = Monday, etc.

  Habit({
    String? id,
    required this.name,
    required this.description,
    required this.icon,
    this.category = 'Personal',
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.goal = 7,
    this.priority = 1,
    this.completedDates = const [],
    DateTime? createdAt,
    this.isActive = true,
    this.hasReminder = false,
    this.reminderTime,
    this.reminderDays = const [],
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  Habit copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    String? category,
    int? currentStreak,
    int? longestStreak,
    int? goal,
    int? priority,
    List<DateTime>? completedDates,
    DateTime? createdAt,
    bool? isActive,
    bool? hasReminder,
    TimeOfDay? reminderTime,
    List<int>? reminderDays,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      category: category ?? this.category,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      goal: goal ?? this.goal,
      priority: priority ?? this.priority,
      completedDates: completedDates ?? this.completedDates,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      hasReminder: hasReminder ?? this.hasReminder,
      reminderTime: reminderTime ?? this.reminderTime,
      reminderDays: reminderDays ?? this.reminderDays,
    );
  }

  bool get isCompletedToday {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    return completedDates.any((date) {
      final dateOnly = DateTime(date.year, date.month, date.day);
      return dateOnly.isAtSameMomentAs(todayDate);
    });
  }

  double get progressPercentage {
    if (goal == 0) return 0.0;
    return (currentStreak / goal).clamp(0.0, 1.0);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'category': category,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'goal': goal,
      'priority': priority,
      'completedDates': completedDates.map((e) => e.toIso8601String()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
      'hasReminder': hasReminder,
      'reminderTime': reminderTime != null ? '${reminderTime!.hour}:${reminderTime!.minute}' : null,
      'reminderDays': reminderDays,
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    TimeOfDay? reminderTime;
    if (json['reminderTime'] != null) {
      try {
        final timeParts = json['reminderTime'].split(':');
        reminderTime = TimeOfDay(
          hour: int.parse(timeParts[0]),
          minute: int.parse(timeParts[1]),
        );
        } catch (e) {
          if (kDebugMode) {
            print('Error parsing reminder time: $e');
          }
          reminderTime = null;
        }
    }

    List<DateTime> completedDates = [];
    try {
      completedDates = (json['completedDates'] as List?)
          ?.map((e) => DateTime.parse(e))
          .toList() ?? [];
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing completed dates: $e');
      }
      completedDates = [];
    }

    DateTime createdAt;
    try {
      createdAt = DateTime.parse(json['createdAt']);
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing created date: $e');
      }
      createdAt = DateTime.now();
    }

    return Habit(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '📝',
      category: json['category'] ?? 'Personal',
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      goal: json['goal'] ?? 7,
      priority: json['priority'] ?? 1,
      completedDates: completedDates,
      createdAt: createdAt,
      isActive: json['isActive'] ?? true,
      hasReminder: json['hasReminder'] ?? false,
      reminderTime: reminderTime,
      reminderDays: (json['reminderDays'] as List?)?.cast<int>() ?? [],
    );
  }
}
