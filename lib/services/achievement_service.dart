import 'dart:convert';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/achievement.dart';
import '../models/habit.dart';

class AchievementService {
  static const String _achievementsKey = 'achievements';
  static const String _userProgressKey = 'user_progress';
  static AchievementService? _instance;
  static AchievementService get instance => _instance ??= AchievementService._();
  
  AchievementService._();

  List<Achievement> _achievements = [];
  UserProgress _userProgress = UserProgress(
    totalXP: 0,
    currentLevel: 1,
    xpToNextLevel: 100,
    totalHabits: 0,
    completedHabits: 0,
    totalStreaks: 0,
    longestStreak: 0,
    lastActivity: DateTime.now(),
  );

  List<Achievement> get achievements => List.unmodifiable(_achievements);
  UserProgress get userProgress => _userProgress;

  Future<void> initialize() async {
    await _loadAchievements();
    await _loadUserProgress();
    await _initializeDefaultAchievements();
  }

  Future<void> _loadAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final achievementsJson = prefs.getStringList(_achievementsKey) ?? [];
    
    _achievements = achievementsJson
        .map((json) => Achievement.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<void> _loadUserProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final progressJson = prefs.getString(_userProgressKey);
    
    if (progressJson != null) {
      _userProgress = UserProgress.fromJson(jsonDecode(progressJson));
    }
  }

  Future<void> _saveAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final achievementsJson = _achievements
        .map((achievement) => jsonEncode(achievement.toJson()))
        .toList();
    
    await prefs.setStringList(_achievementsKey, achievementsJson);
  }

  Future<void> _saveUserProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userProgressKey, jsonEncode(_userProgress.toJson()));
  }

  Future<void> _initializeDefaultAchievements() async {
    if (_achievements.isNotEmpty) return;

    final defaultAchievements = [
      // Streak Achievements
      Achievement(
        id: 'first_streak',
        title: 'Getting Started',
        description: 'Complete your first habit streak',
        icon: 'target',
        type: AchievementType.streak,
        rarity: AchievementRarity.common,
        xpReward: 50,
        requirements: {'streak': 1},
        category: 'Streaks',
      ),
      Achievement(
        id: 'week_warrior',
        title: 'Week Warrior',
        description: 'Maintain a 7-day streak',
        icon: 'calendar',
        type: AchievementType.streak,
        rarity: AchievementRarity.rare,
        xpReward: 200,
        requirements: {'streak': 7},
        category: 'Streaks',
      ),
      Achievement(
        id: 'month_master',
        title: 'Month Master',
        description: 'Maintain a 30-day streak',
        icon: 'trophy',
        type: AchievementType.streak,
        rarity: AchievementRarity.epic,
        xpReward: 500,
        requirements: {'streak': 30},
        category: 'Streaks',
      ),
      Achievement(
        id: 'century_club',
        title: 'Century Club',
        description: 'Maintain a 100-day streak',
        icon: 'crown',
        type: AchievementType.streak,
        rarity: AchievementRarity.legendary,
        xpReward: 1000,
        requirements: {'streak': 100},
        category: 'Streaks',
      ),

      // Completion Achievements
      Achievement(
        id: 'first_completion',
        title: 'First Step',
        description: 'Complete your first habit',
        icon: 'check',
        type: AchievementType.completion,
        rarity: AchievementRarity.common,
        xpReward: 25,
        requirements: {'completions': 1},
        category: 'Completions',
      ),
      Achievement(
        id: 'hundred_completions',
        title: 'Century',
        description: 'Complete 100 habits',
        icon: 'star',
        type: AchievementType.completion,
        rarity: AchievementRarity.rare,
        xpReward: 300,
        requirements: {'completions': 100},
        category: 'Completions',
      ),
      Achievement(
        id: 'thousand_completions',
        title: 'Millennium',
        description: 'Complete 1000 habits',
        icon: 'diamond',
        type: AchievementType.completion,
        rarity: AchievementRarity.legendary,
        xpReward: 2000,
        requirements: {'completions': 1000},
        category: 'Completions',
      ),

      // Consistency Achievements
      Achievement(
        id: 'perfect_week',
        title: 'Perfect Week',
        description: 'Complete all habits for 7 days straight',
        icon: 'calendar-check',
        type: AchievementType.consistency,
        rarity: AchievementRarity.rare,
        xpReward: 400,
        requirements: {'perfect_days': 7},
        category: 'Consistency',
      ),
      Achievement(
        id: 'perfect_month',
        title: 'Perfect Month',
        description: 'Complete all habits for 30 days straight',
        icon: 'award',
        type: AchievementType.consistency,
        rarity: AchievementRarity.epic,
        xpReward: 1000,
        requirements: {'perfect_days': 30},
        category: 'Consistency',
      ),

      // Milestone Achievements
      Achievement(
        id: 'habit_collector',
        title: 'Habit Collector',
        description: 'Create 10 different habits',
        icon: 'layers',
        type: AchievementType.milestone,
        rarity: AchievementRarity.common,
        xpReward: 150,
        requirements: {'habits_created': 10},
        category: 'Milestones',
      ),
      Achievement(
        id: 'habit_master',
        title: 'Habit Master',
        description: 'Create 50 different habits',
        icon: 'zap',
        type: AchievementType.milestone,
        rarity: AchievementRarity.epic,
        xpReward: 800,
        requirements: {'habits_created': 50},
        category: 'Milestones',
      ),

      // Special Achievements
      Achievement(
        id: 'early_bird',
        title: 'Early Bird',
        description: 'Complete a habit before 6 AM',
        icon: 'sunrise',
        type: AchievementType.special,
        rarity: AchievementRarity.rare,
        xpReward: 100,
        requirements: {'early_completion': 1},
        category: 'Special',
      ),
      Achievement(
        id: 'night_owl',
        title: 'Night Owl',
        description: 'Complete a habit after 10 PM',
        icon: 'moon',
        type: AchievementType.special,
        rarity: AchievementRarity.rare,
        xpReward: 100,
        requirements: {'late_completion': 1},
        category: 'Special',
      ),
    ];

    _achievements = defaultAchievements;
    await _saveAchievements();
  }

  Future<void> checkAchievements(List<Habit> habits) async {
    final newUnlocks = <Achievement>[];
    
    for (final achievement in _achievements) {
      if (achievement.isUnlocked) continue;
      
      if (_checkAchievementRequirements(achievement, habits)) {
        final unlockedAchievement = achievement.copyWith(
          isUnlocked: true,
          unlockedAt: DateTime.now(),
        );
        
        final index = _achievements.indexWhere((a) => a.id == achievement.id);
        if (index != -1) {
          _achievements[index] = unlockedAchievement;
          newUnlocks.add(unlockedAchievement);
          
          // Award XP
          await _awardXP(unlockedAchievement.xpReward);
        }
      }
    }
    
    if (newUnlocks.isNotEmpty) {
      await _saveAchievements();
      await _saveUserProgress();
    }
  }

  bool _checkAchievementRequirements(Achievement achievement, List<Habit> habits) {
    final requirements = achievement.requirements;
    
    switch (achievement.type) {
      case AchievementType.streak:
        final requiredStreak = requirements['streak'] as int;
        return habits.any((habit) => habit.currentStreak >= requiredStreak);
        
      case AchievementType.completion:
        final requiredCompletions = requirements['completions'] as int;
        final totalCompletions = habits.fold<int>(
          0, (sum, habit) => sum + habit.completedDates.length);
        return totalCompletions >= requiredCompletions;
        
      case AchievementType.consistency:
        final requiredPerfectDays = requirements['perfect_days'] as int;
        return _calculatePerfectDays(habits) >= requiredPerfectDays;
        
      case AchievementType.milestone:
        final requiredHabits = requirements['habits_created'] as int;
        return habits.length >= requiredHabits;
        
      case AchievementType.special:
        if (requirements.containsKey('early_completion')) {
          return _hasEarlyCompletion(habits);
        } else if (requirements.containsKey('late_completion')) {
          return _hasLateCompletion(habits);
        }
        return false;
    }
  }

  int _calculatePerfectDays(List<Habit> habits) {
    if (habits.isEmpty) return 0;
    
    final activeHabits = habits.where((h) => h.isActive).toList();
    if (activeHabits.isEmpty) return 0;
    
    int perfectDays = 0;
    final today = DateTime.now();
    
    for (int i = 0; i < 365; i++) {
      final checkDate = today.subtract(Duration(days: i));
      final dateOnly = DateTime(checkDate.year, checkDate.month, checkDate.day);
      
      bool isPerfectDay = true;
      for (final habit in activeHabits) {
        if (!habit.completedDates.any((date) {
          final habitDate = DateTime(date.year, date.month, date.day);
          return habitDate.isAtSameMomentAs(dateOnly);
        })) {
          isPerfectDay = false;
          break;
        }
      }
      
      if (isPerfectDay) {
        perfectDays++;
      } else {
        break; // Stop counting if we hit a non-perfect day
      }
    }
    
    return perfectDays;
  }

  bool _hasEarlyCompletion(List<Habit> habits) {
    for (final habit in habits) {
      for (final completionDate in habit.completedDates) {
        if (completionDate.hour < 6) {
          return true;
        }
      }
    }
    return false;
  }

  bool _hasLateCompletion(List<Habit> habits) {
    for (final habit in habits) {
      for (final completionDate in habit.completedDates) {
        if (completionDate.hour >= 22) {
          return true;
        }
      }
    }
    return false;
  }

  Future<void> _awardXP(int xp) async {
    final newTotalXP = _userProgress.totalXP + xp;
    final newLevel = _calculateLevel(newTotalXP);
    final xpToNextLevel = _calculateXPToNextLevel(newTotalXP, newLevel);
    
    _userProgress = UserProgress(
      totalXP: newTotalXP,
      currentLevel: newLevel,
      xpToNextLevel: xpToNextLevel,
      totalHabits: _userProgress.totalHabits,
      completedHabits: _userProgress.completedHabits,
      totalStreaks: _userProgress.totalStreaks,
      longestStreak: _userProgress.longestStreak,
      lastActivity: DateTime.now(),
    );
  }

  int _calculateLevel(int totalXP) {
    // Level formula: level = sqrt(xp / 100)
    return (math.sqrt(totalXP / 100)).floor() + 1;
  }

  int _calculateXPToNextLevel(int totalXP, int currentLevel) {
    // final currentLevelXP = (100 * math.sqrt(currentLevel * currentLevel * currentLevel)).round();
    final nextLevelXP = (100 * math.sqrt((currentLevel + 1) * (currentLevel + 1) * (currentLevel + 1))).round();
    return nextLevelXP - totalXP;
  }

  Future<void> updateUserProgress(List<Habit> habits) async {
    final totalHabits = habits.length;
    final completedHabits = habits.where((h) => h.isCompletedToday).length;
    final totalStreaks = habits.fold<int>(0, (sum, h) => sum + h.currentStreak);
    final longestStreak = habits.isEmpty ? 0 : habits.map((h) => h.currentStreak).reduce(math.max);
    
    _userProgress = UserProgress(
      totalXP: _userProgress.totalXP,
      currentLevel: _userProgress.currentLevel,
      xpToNextLevel: _userProgress.xpToNextLevel,
      totalHabits: totalHabits,
      completedHabits: completedHabits,
      totalStreaks: totalStreaks,
      longestStreak: longestStreak,
      lastActivity: DateTime.now(),
    );
    
    await _saveUserProgress();
  }

  List<Achievement> getUnlockedAchievements() {
    return _achievements.where((a) => a.isUnlocked).toList();
  }

  List<Achievement> getLockedAchievements() {
    return _achievements.where((a) => !a.isUnlocked).toList();
  }

  List<Achievement> getAchievementsByCategory(String category) {
    return _achievements.where((a) => a.category == category).toList();
  }

  List<String> getCategories() {
    return _achievements.map((a) => a.category).where((c) => c != null).cast<String>().toSet().toList();
  }
}
