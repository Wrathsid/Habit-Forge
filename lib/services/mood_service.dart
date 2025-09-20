import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/mood.dart';
import '../models/habit.dart';

class MoodService {
  static const String _moodsKey = 'moods';
  static MoodService? _instance;
  static MoodService get instance => _instance ??= MoodService._();
  
  MoodService._();

  List<Mood> _moods = [];
  List<Mood> get moods => List.unmodifiable(_moods);

  Future<void> initialize() async {
    await _loadMoods();
  }

  Future<void> _loadMoods() async {
    final prefs = await SharedPreferences.getInstance();
    final moodsJson = prefs.getStringList(_moodsKey) ?? [];
    
    _moods = moodsJson
        .map((json) => Mood.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<void> _saveMoods() async {
    final prefs = await SharedPreferences.getInstance();
    final moodsJson = _moods
        .map((mood) => jsonEncode(mood.toJson()))
        .toList();
    
    await prefs.setStringList(_moodsKey, moodsJson);
  }

  Future<void> addMood({
    required MoodType type,
    String? note,
    List<String> tags = const [],
    Map<String, dynamic> metadata = const {},
  }) async {
    final mood = Mood(
      id: const Uuid().v4(),
      type: type,
      date: DateTime.now(),
      note: note,
      tags: tags,
      metadata: metadata,
    );

    _moods.add(mood);
    await _saveMoods();
  }

  Future<void> updateMood(Mood mood) async {
    final index = _moods.indexWhere((m) => m.id == mood.id);
    if (index != -1) {
      _moods[index] = mood;
      await _saveMoods();
    }
  }

  Future<void> deleteMood(String moodId) async {
    _moods.removeWhere((mood) => mood.id == moodId);
    await _saveMoods();
  }

  Mood? getMoodForDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
      try {
        return _moods.firstWhere(
          (mood) {
            final moodDate = DateTime(mood.date.year, mood.date.month, mood.date.day);
            return moodDate.isAtSameMomentAs(dateOnly);
          },
        );
      } catch (e) {
        return null;
      }
  }

  Mood? getTodayMood() {
    return getMoodForDate(DateTime.now());
  }

  List<Mood> getMoodsForDateRange(DateTime start, DateTime end) {
    return _moods.where((mood) {
      return mood.date.isAfter(start.subtract(const Duration(days: 1))) &&
             mood.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  List<Mood> getRecentMoods(int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return _moods.where((mood) => mood.date.isAfter(cutoff)).toList();
  }

  MoodInsight generateInsights() {
    if (_moods.isEmpty) {
    return MoodInsight(
      averageMood: 0.0,
      mostCommonMood: MoodType.okay,
      totalEntries: 0,
      firstEntry: DateTime.now(),
      lastEntry: DateTime.now(),
      moodTrends: {},
      topTags: [],
      tagCorrelations: {},
    );
    }

    // Calculate average mood
    final totalMoodValue = _moods.fold<double>(0, (sum, mood) => sum + mood.numericValue);
    final averageMood = totalMoodValue / _moods.length;

    // Find most common mood
    final moodCounts = <MoodType, int>{};
    for (final mood in _moods) {
      moodCounts[mood.type] = (moodCounts[mood.type] ?? 0) + 1;
    }
    final mostCommonMood = moodCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    // Calculate mood trends (weekly averages)
    final moodTrends = <String, double>{};
    final sortedMoods = List<Mood>.from(_moods)..sort((a, b) => a.date.compareTo(b.date));
    
    for (int i = 0; i < sortedMoods.length; i += 7) {
      final weekMoods = sortedMoods.skip(i).take(7).toList();
      if (weekMoods.isNotEmpty) {
        final weekAverage = weekMoods.fold<double>(0, (sum, mood) => sum + mood.numericValue) / weekMoods.length;
        final weekKey = 'Week ${(i ~/ 7) + 1}';
        moodTrends[weekKey] = weekAverage;
      }
    }

    // Find top tags
    final tagCounts = <String, int>{};
    for (final mood in _moods) {
      for (final tag in mood.tags) {
        tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
      }
    }
    final topTags = tagCounts.entries
        .toList()
        ..sort((a, b) => b.value.compareTo(a.value));
    final topTagsList = topTags.take(5).map((e) => e.key).toList();

    // Calculate tag correlations
    final tagCorrelations = <String, double>{};
    for (final tag in topTagsList) {
      final moodsWithTag = _moods.where((mood) => mood.tags.contains(tag)).toList();
      if (moodsWithTag.isNotEmpty) {
        final tagAverageMood = moodsWithTag.fold<double>(0, (sum, mood) => sum + mood.numericValue) / moodsWithTag.length;
        tagCorrelations[tag] = tagAverageMood;
      }
    }

    return MoodInsight(
      averageMood: averageMood,
      mostCommonMood: mostCommonMood,
      totalEntries: _moods.length,
      firstEntry: sortedMoods.first.date,
      lastEntry: sortedMoods.last.date,
      moodTrends: moodTrends,
      topTags: topTagsList,
      tagCorrelations: tagCorrelations,
    );
  }

  Future<Map<String, double>> analyzeHabitMoodCorrelation(List<Habit> habits) async {
    final correlations = <String, double>{};
    
    for (final habit in habits) {
      final habitMoods = <Mood>[];
      
      // Find moods on days when this habit was completed
      for (final completionDate in habit.completedDates) {
        final mood = getMoodForDate(completionDate);
        if (mood != null) {
          habitMoods.add(mood);
        }
      }
      
      if (habitMoods.isNotEmpty) {
        final averageMoodOnCompletion = habitMoods.fold<double>(0, (sum, mood) => sum + mood.numericValue) / habitMoods.length;
        correlations[habit.name] = averageMoodOnCompletion;
      }
    }
    
    return correlations;
  }

  List<Mood> getMoodsByTag(String tag) {
    return _moods.where((mood) => mood.tags.contains(tag)).toList();
  }

  List<String> getAllTags() {
    final allTags = <String>{};
    for (final mood in _moods) {
      allTags.addAll(mood.tags);
    }
    return allTags.toList()..sort();
  }

  double getMoodTrendForPeriod(int days) {
    final recentMoods = getRecentMoods(days);
    if (recentMoods.length < 2) return 0.0;
    
    final sortedMoods = List<Mood>.from(recentMoods)..sort((a, b) => a.date.compareTo(b.date));
    final firstHalf = sortedMoods.take(sortedMoods.length ~/ 2).toList();
    final secondHalf = sortedMoods.skip(sortedMoods.length ~/ 2).toList();
    
    final firstHalfAverage = firstHalf.fold<double>(0, (sum, mood) => sum + mood.numericValue) / firstHalf.length;
    final secondHalfAverage = secondHalf.fold<double>(0, (sum, mood) => sum + mood.numericValue) / secondHalf.length;
    
    return secondHalfAverage - firstHalfAverage;
  }

  Map<String, int> getMoodDistribution() {
    final distribution = <String, int>{};
    for (final mood in _moods) {
      distribution[mood.label] = (distribution[mood.label] ?? 0) + 1;
    }
    return distribution;
  }

  List<Mood> searchMoods(String query) {
    if (query.isEmpty) return _moods;
    
    final lowercaseQuery = query.toLowerCase();
    return _moods.where((mood) {
      return mood.note?.toLowerCase().contains(lowercaseQuery) == true ||
             mood.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }
}
