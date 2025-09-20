import 'package:flutter/material.dart';
import 'dart:math' as math;

enum AchievementType {
  streak,
  completion,
  consistency,
  milestone,
  special,
}

enum AchievementRarity {
  common,
  rare,
  epic,
  legendary,
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final AchievementType type;
  final AchievementRarity rarity;
  final int xpReward;
  final Map<String, dynamic> requirements;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final String? category;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.type,
    required this.rarity,
    required this.xpReward,
    required this.requirements,
    this.isUnlocked = false,
    this.unlockedAt,
    this.category,
  });

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    AchievementType? type,
    AchievementRarity? rarity,
    int? xpReward,
    Map<String, dynamic>? requirements,
    bool? isUnlocked,
    DateTime? unlockedAt,
    String? category,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      type: type ?? this.type,
      rarity: rarity ?? this.rarity,
      xpReward: xpReward ?? this.xpReward,
      requirements: requirements ?? this.requirements,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      category: category ?? this.category,
    );
  }

  Color get rarityColor {
    switch (rarity) {
      case AchievementRarity.common:
        return Colors.grey;
      case AchievementRarity.rare:
        return Colors.blue;
      case AchievementRarity.epic:
        return Colors.purple;
      case AchievementRarity.legendary:
        return Colors.orange;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'type': type.name,
      'rarity': rarity.name,
      'xpReward': xpReward,
      'requirements': requirements,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'category': category,
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      icon: json['icon'],
      type: AchievementType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AchievementType.completion,
      ),
      rarity: AchievementRarity.values.firstWhere(
        (e) => e.name == json['rarity'],
        orElse: () => AchievementRarity.common,
      ),
      xpReward: json['xpReward'],
      requirements: Map<String, dynamic>.from(json['requirements']),
      isUnlocked: json['isUnlocked'] ?? false,
      unlockedAt: json['unlockedAt'] != null 
          ? DateTime.parse(json['unlockedAt']) 
          : null,
      category: json['category'],
    );
  }
}

class UserProgress {
  final int totalXP;
  final int currentLevel;
  final int xpToNextLevel;
  final int totalHabits;
  final int completedHabits;
  final int totalStreaks;
  final int longestStreak;
  final DateTime lastActivity;

  const UserProgress({
    required this.totalXP,
    required this.currentLevel,
    required this.xpToNextLevel,
    required this.totalHabits,
    required this.completedHabits,
    required this.totalStreaks,
    required this.longestStreak,
    required this.lastActivity,
  });

  double get completionRate {
    if (totalHabits == 0) return 0.0;
    return completedHabits / totalHabits;
  }

  double get levelProgress {
    if (xpToNextLevel == 0) return 1.0;
    final currentLevelXP = _getXPForLevel(currentLevel);
    final nextLevelXP = _getXPForLevel(currentLevel + 1);
    final progress = (totalXP - currentLevelXP) / (nextLevelXP - currentLevelXP);
    return progress.clamp(0.0, 1.0);
  }

  int _getXPForLevel(int level) {
    // XP formula: 100 * level^1.5
    return (100 * math.sqrt(level * level * level)).round();
  }

  Map<String, dynamic> toJson() {
    return {
      'totalXP': totalXP,
      'currentLevel': currentLevel,
      'xpToNextLevel': xpToNextLevel,
      'totalHabits': totalHabits,
      'completedHabits': completedHabits,
      'totalStreaks': totalStreaks,
      'longestStreak': longestStreak,
      'lastActivity': lastActivity.toIso8601String(),
    };
  }

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      totalXP: json['totalXP'] ?? 0,
      currentLevel: json['currentLevel'] ?? 1,
      xpToNextLevel: json['xpToNextLevel'] ?? 100,
      totalHabits: json['totalHabits'] ?? 0,
      completedHabits: json['completedHabits'] ?? 0,
      totalStreaks: json['totalStreaks'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      lastActivity: DateTime.parse(json['lastActivity'] ?? DateTime.now().toIso8601String()),
    );
  }
}
