import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/habit.dart';
import '../models/mood.dart';
import '../services/habit_service.dart';
import '../services/mood_service.dart';
// import '../services/achievement_service.dart';
import '../widgets/neumorphic_box.dart';
import '../widgets/neumorphic_colors.dart';

class AdvancedChartsScreen extends StatefulWidget {
  const AdvancedChartsScreen({super.key});

  @override
  State<AdvancedChartsScreen> createState() => _AdvancedChartsScreenState();
}

class _AdvancedChartsScreenState extends State<AdvancedChartsScreen> {
  String _selectedTimeframe = '7 days';
  final List<String> _timeframes = ['7 days', '30 days', '90 days', '1 year'];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<NeumorphicColors>()!;
    final habits = HabitService.instance.habits;
    final moods = MoodService.instance.getRecentMoods(_getDaysFromTimeframe(_selectedTimeframe));
    // final userProgress = AchievementService.instance.userProgress;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: colors.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Advanced Charts',
          style: TextStyle(color: colors.textColor),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(LucideIcons.calendar, color: colors.textColor),
            onSelected: (value) => setState(() => _selectedTimeframe = value),
            itemBuilder: (context) => _timeframes.map((timeframe) {
              return PopupMenuItem<String>(
                value: timeframe,
                child: Text(timeframe),
              );
            }).toList(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTimeframeSelector(colors),
                const SizedBox(height: 24),
                _buildMoodTrendChart(moods, colors),
                const SizedBox(height: 24),
                _buildHabitCompletionChart(habits, colors),
                const SizedBox(height: 24),
                _buildStreakAnalysis(habits, colors),
                const SizedBox(height: 24),
                _buildProductivityInsights(habits, moods, colors),
                const SizedBox(height: 24),
                _buildGoalProgressChart(habits, colors),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeframeSelector(NeumorphicColors colors) {
    return NeumorphicBox(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(LucideIcons.calendar, color: colors.textColor, size: 20),
          const SizedBox(width: 12),
          Text(
            'Timeframe: $_selectedTimeframe',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colors.textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodTrendChart(List<Mood> moods, NeumorphicColors colors) {
    if (moods.isEmpty) {
      return _buildEmptyChart('Mood Trend', 'No mood data available', LucideIcons.heart, colors);
    }

    return NeumorphicBox(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mood Trend',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.textColor,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: _buildMoodLineChart(moods, colors),
          ),
          const SizedBox(height: 16),
          _buildMoodStats(moods, colors),
        ],
      ),
    );
  }

  Widget _buildMoodLineChart(List<Mood> moods, NeumorphicColors colors) {
    if (moods.isEmpty) return Container();

    final sortedMoods = List<Mood>.from(moods)..sort((a, b) => a.date.compareTo(b.date));
    final maxMood = 5.0;
    final minMood = 1.0;

    return CustomPaint(
      painter: MoodLineChartPainter(
        moods: sortedMoods,
        maxMood: maxMood,
        minMood: minMood,
        colors: colors,
      ),
      size: const Size(double.infinity, 200),
    );
  }

  Widget _buildMoodStats(List<Mood> moods, NeumorphicColors colors) {
    if (moods.isEmpty) return Container();

    final averageMood = moods.fold<double>(0, (sum, mood) => sum + mood.numericValue) / moods.length;
    final moodCounts = <MoodType, int>{};
    for (final mood in moods) {
      moodCounts[mood.type] = (moodCounts[mood.type] ?? 0) + 1;
    }
    final mostCommonMood = moodCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Average',
            '${averageMood.toStringAsFixed(1)}/5',
            LucideIcons.barChart3,
            colors,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Most Common',
            _getMoodEmoji(mostCommonMood),
            LucideIcons.trendingUp,
            colors,
          ),
        ),
      ],
    );
  }

  Widget _buildHabitCompletionChart(List<Habit> habits, NeumorphicColors colors) {
    if (habits.isEmpty) {
      return _buildEmptyChart('Habit Completion', 'No habits available', LucideIcons.target, colors);
    }

    final days = _getDaysFromTimeframe(_selectedTimeframe);
    final completionData = _getCompletionData(habits, days);

    return NeumorphicBox(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Habit Completion Rate',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.textColor,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: _buildCompletionBarChart(completionData, colors),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionBarChart(List<Map<String, dynamic>> data, NeumorphicColors colors) {
    if (data.isEmpty) return Container();

    return CustomPaint(
      painter: CompletionBarChartPainter(
        data: data,
        colors: colors,
      ),
      size: const Size(double.infinity, 200),
    );
  }

  Widget _buildStreakAnalysis(List<Habit> habits, NeumorphicColors colors) {
    final activeHabits = habits.where((h) => h.isActive).toList();
    final streakData = _getStreakData(activeHabits);

    return NeumorphicBox(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Streak Analysis',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.textColor,
            ),
          ),
          const SizedBox(height: 16),
          ...streakData.map((habit) => _buildStreakItem(habit, colors)),
        ],
      ),
    );
  }

  Widget _buildStreakItem(Map<String, dynamic> habit, NeumorphicColors colors) {
    final name = habit['name'] as String;
    final streak = habit['streak'] as int;
    final longestStreak = habit['longestStreak'] as int;
    final completionRate = habit['completionRate'] as double;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.textColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colors.textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Current: $streak days | Longest: $longestStreak days',
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.textColor.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${(completionRate * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colors.textColor,
                ),
              ),
              Text(
                'completion',
                style: TextStyle(
                  fontSize: 12,
                  color: colors.textColor.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductivityInsights(List<Habit> habits, List<Mood> moods, NeumorphicColors colors) {
    final insights = _generateProductivityInsights(habits, moods);

    return NeumorphicBox(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Productivity Insights',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.textColor,
            ),
          ),
          const SizedBox(height: 16),
          ...insights.map((insight) => _buildInsightItem(insight, colors)),
        ],
      ),
    );
  }

  Widget _buildInsightItem(Map<String, dynamic> insight, NeumorphicColors colors) {
    final title = insight['title'] as String;
    final description = insight['description'] as String;
    final icon = insight['icon'] as IconData;
    final color = insight['color'] as Color;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colors.textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.textColor.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalProgressChart(List<Habit> habits, NeumorphicColors colors) {
    final goalData = _getGoalProgressData(habits);

    return NeumorphicBox(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Goal Progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.textColor,
            ),
          ),
          const SizedBox(height: 16),
          ...goalData.map((goal) => _buildGoalItem(goal, colors)),
        ],
      ),
    );
  }

  Widget _buildGoalItem(Map<String, dynamic> goal, NeumorphicColors colors) {
    final name = goal['name'] as String;
    final progress = goal['progress'] as double;
    final current = goal['current'] as int;
    final target = goal['target'] as int;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.textColor,
                ),
              ),
              Text(
                '$current/$target',
                style: TextStyle(
                  fontSize: 14,
                  color: colors.textColor.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: colors.textColor.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChart(String title, String message, IconData icon, NeumorphicColors colors) {
    return NeumorphicBox(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(icon, size: 48, color: colors.textColor.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: colors.textColor.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, NeumorphicColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.textColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: colors.textColor, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colors.textColor,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: colors.textColor.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  int _getDaysFromTimeframe(String timeframe) {
    switch (timeframe) {
      case '7 days': return 7;
      case '30 days': return 30;
      case '90 days': return 90;
      case '1 year': return 365;
      default: return 7;
    }
  }

  List<Map<String, dynamic>> _getCompletionData(List<Habit> habits, int days) {
    final data = <Map<String, dynamic>>[];
    final now = DateTime.now();

    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateOnly = DateTime(date.year, date.month, date.day);
      
      int completed = 0;
      for (final habit in habits) {
        if (habit.completedDates.any((d) {
          final habitDate = DateTime(d.year, d.month, d.day);
          return habitDate.isAtSameMomentAs(dateOnly);
        })) {
          completed++;
        }
      }
      
      data.add({
        'date': dateOnly,
        'completions': completed,
        'total': habits.length,
      });
    }

    return data;
  }

  List<Map<String, dynamic>> _getStreakData(List<Habit> habits) {
    return habits.map((habit) {
      final completionRate = habit.completedDates.length / 
          (DateTime.now().difference(habit.createdAt).inDays + 1);
      
      return {
        'name': habit.name,
        'streak': habit.currentStreak,
        'longestStreak': habit.currentStreak, // Simplified for demo
        'completionRate': completionRate.clamp(0.0, 1.0),
      };
    }).toList();
  }

  List<Map<String, dynamic>> _generateProductivityInsights(List<Habit> habits, List<Mood> moods) {
    final insights = <Map<String, dynamic>>[];
    
    if (habits.isNotEmpty) {
      final completionRate = habits.where((h) => h.isCompletedToday).length / habits.length;
      
      if (completionRate >= 0.8) {
        insights.add({
          'title': 'Excellent Progress!',
          'description': 'You\'re completing ${(completionRate * 100).toInt()}% of your habits today.',
          'icon': LucideIcons.trophy,
          'color': Colors.green,
        });
      } else if (completionRate >= 0.5) {
        insights.add({
          'title': 'Good Progress',
          'description': 'You\'re on track with ${(completionRate * 100).toInt()}% completion rate.',
          'icon': LucideIcons.checkCircle,
          'color': Colors.blue,
        });
      } else {
        insights.add({
          'title': 'Room for Improvement',
          'description': 'Try to complete more habits to reach your goals.',
          'icon': LucideIcons.target,
          'color': Colors.orange,
        });
      }
    }

    if (moods.isNotEmpty) {
      final averageMood = moods.fold<double>(0, (sum, mood) => sum + mood.numericValue) / moods.length;
      
      if (averageMood >= 4.0) {
        insights.add({
          'title': 'Great Mood!',
          'description': 'Your average mood is excellent. Keep up the good work!',
          'icon': LucideIcons.heart,
          'color': Colors.pink,
        });
      } else if (averageMood <= 2.0) {
        insights.add({
          'title': 'Mood Support',
          'description': 'Consider focusing on habits that improve your mood.',
          'icon': LucideIcons.helpCircle,
          'color': Colors.amber,
        });
      }
    }

    return insights;
  }

  List<Map<String, dynamic>> _getGoalProgressData(List<Habit> habits) {
    return habits.map((habit) {
      final progress = habit.completedDates.length / habit.goal;
      return {
        'name': habit.name,
        'progress': progress.clamp(0.0, 1.0),
        'current': habit.completedDates.length,
        'target': habit.goal,
      };
    }).toList();
  }

  String _getMoodEmoji(MoodType mood) {
    switch (mood) {
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
}

// Custom painters for charts
class MoodLineChartPainter extends CustomPainter {
  final List<Mood> moods;
  final double maxMood;
  final double minMood;
  final NeumorphicColors colors;

  MoodLineChartPainter({
    required this.moods,
    required this.maxMood,
    required this.minMood,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (moods.isEmpty) return;

    final paint = Paint()
      ..color = Theme.of(colors as BuildContext).colorScheme.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final pointPaint = Paint()
      ..color = Theme.of(colors as BuildContext).colorScheme.primary
      ..style = PaintingStyle.fill;

    for (int i = 0; i < moods.length; i++) {
      final mood = moods[i];
      final x = (i / (moods.length - 1)) * size.width;
      final y = size.height - ((mood.numericValue - minMood) / (maxMood - minMood)) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      canvas.drawCircle(Offset(x, y), 4, pointPaint);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class CompletionBarChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final NeumorphicColors colors;

  CompletionBarChartPainter({
    required this.data,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = Theme.of(colors as BuildContext).colorScheme.primary
      ..style = PaintingStyle.fill;

    final barWidth = size.width / data.length * 0.8;
    final spacing = size.width / data.length * 0.2;

    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      final completions = item['completions'] as int;
      final total = item['total'] as int;
      final height = total > 0 ? (completions / total) * size.height : 0.0;

      final x = i * (barWidth + spacing) + spacing / 2;
      final y = size.height - height;

      canvas.drawRect(
        Rect.fromLTWH(x, y, barWidth, height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
