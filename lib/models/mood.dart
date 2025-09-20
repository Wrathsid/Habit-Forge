import 'package:flutter/material.dart';

enum MoodType {
  terrible,
  bad,
  okay,
  good,
  excellent,
}

class Mood {
  final String id;
  final MoodType type;
  final DateTime date;
  final String? note;
  final List<String> tags;
  final Map<String, dynamic> metadata;

  const Mood({
    required this.id,
    required this.type,
    required this.date,
    this.note,
    this.tags = const [],
    this.metadata = const {},
  });

  Mood copyWith({
    String? id,
    MoodType? type,
    DateTime? date,
    String? note,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) {
    return Mood(
      id: id ?? this.id,
      type: type ?? this.type,
      date: date ?? this.date,
      note: note ?? this.note,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
    );
  }

  int get numericValue {
    switch (type) {
      case MoodType.terrible:
        return 1;
      case MoodType.bad:
        return 2;
      case MoodType.okay:
        return 3;
      case MoodType.good:
        return 4;
      case MoodType.excellent:
        return 5;
    }
  }

  String get emoji {
    switch (type) {
      case MoodType.terrible:
        return '😢';
      case MoodType.bad:
        return '😔';
      case MoodType.okay:
        return '😐';
      case MoodType.good:
        return '😊';
      case MoodType.excellent:
        return '🤩';
    }
  }

  String get label {
    switch (type) {
      case MoodType.terrible:
        return 'Terrible';
      case MoodType.bad:
        return 'Bad';
      case MoodType.okay:
        return 'Okay';
      case MoodType.good:
        return 'Good';
      case MoodType.excellent:
        return 'Excellent';
    }
  }

  Color get color {
    switch (type) {
      case MoodType.terrible:
        return Colors.red;
      case MoodType.bad:
        return Colors.orange;
      case MoodType.okay:
        return Colors.yellow;
      case MoodType.good:
        return Colors.lightGreen;
      case MoodType.excellent:
        return Colors.green;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'date': date.toIso8601String(),
      'note': note,
      'tags': tags,
      'metadata': metadata,
    };
  }

  factory Mood.fromJson(Map<String, dynamic> json) {
    return Mood(
      id: json['id'],
      type: MoodType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MoodType.okay,
      ),
      date: DateTime.parse(json['date']),
      note: json['note'],
      tags: List<String>.from(json['tags'] ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
}

class MoodInsight {
  final double averageMood;
  final MoodType mostCommonMood;
  final int totalEntries;
  final DateTime firstEntry;
  final DateTime lastEntry;
  final Map<String, double> moodTrends;
  final List<String> topTags;
  final Map<String, double> tagCorrelations;

  const MoodInsight({
    required this.averageMood,
    required this.mostCommonMood,
    required this.totalEntries,
    required this.firstEntry,
    required this.lastEntry,
    required this.moodTrends,
    required this.topTags,
    required this.tagCorrelations,
  });

  String get moodTrend {
    if (moodTrends.isEmpty) return 'No data';
    
    final recent = moodTrends.values.take(7).toList();
    if (recent.length < 2) return 'No trend';
    
    final first = recent.first;
    final last = recent.last;
    
    if (last > first + 0.5) return 'Improving';
    if (last < first - 0.5) return 'Declining';
    return 'Stable';
  }

  Map<String, dynamic> toJson() {
    return {
      'averageMood': averageMood,
      'mostCommonMood': mostCommonMood.name,
      'totalEntries': totalEntries,
      'firstEntry': firstEntry.toIso8601String(),
      'lastEntry': lastEntry.toIso8601String(),
      'moodTrends': moodTrends,
      'topTags': topTags,
      'tagCorrelations': tagCorrelations,
    };
  }

  factory MoodInsight.fromJson(Map<String, dynamic> json) {
    return MoodInsight(
      averageMood: json['averageMood'].toDouble(),
      mostCommonMood: MoodType.values.firstWhere(
        (e) => e.name == json['mostCommonMood'],
        orElse: () => MoodType.okay,
      ),
      totalEntries: json['totalEntries'],
      firstEntry: DateTime.parse(json['firstEntry']),
      lastEntry: DateTime.parse(json['lastEntry']),
      moodTrends: Map<String, double>.from(json['moodTrends']),
      topTags: List<String>.from(json['topTags']),
      tagCorrelations: Map<String, double>.from(json['tagCorrelations']),
    );
  }
}
