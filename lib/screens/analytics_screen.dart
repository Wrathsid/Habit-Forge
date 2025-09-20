import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../services/habit_service.dart';
import '../widgets/neumorphic_box.dart';
import '../widgets/neumorphic_colors.dart';
import 'habit_correlation_screen.dart';
import 'advanced_charts_screen.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<NeumorphicColors>()!;
    final habits = HabitService.instance.habits;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: colors.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Analytics',
          style: TextStyle(color: colors.textColor),
        ),
        actions: [
          IconButton(
            icon: Icon(LucideIcons.barChart3, color: colors.textColor),
            onPressed: _openCorrelationAnalysis,
          ),
          IconButton(
            icon: Icon(LucideIcons.trendingUp, color: colors.textColor),
            onPressed: _openAdvancedCharts,
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
                _buildOverviewStats(colors),
                const SizedBox(height: 20),
                _buildStreakLeaderboard(colors, habits),
                const SizedBox(height: 20),
                _buildCompletionChart(colors, habits),
                const SizedBox(height: 20),
                _buildHabitBreakdown(colors, habits),
                const SizedBox(height: 20),
                _buildWeeklyProgress(colors, habits),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewStats(NeumorphicColors colors) {
    final service = HabitService.instance;
    final totalHabits = service.habits.length;
    final activeHabits = service.totalActiveHabits;
    final completedToday = service.completedTodayCount;
    final completionRate = service.todayCompletionRate;

    return NeumorphicBox(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overview',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colors.textColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Habits',
                  '$totalHabits',
                  LucideIcons.list,
                  colors,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Active',
                  '$activeHabits',
                  LucideIcons.activity,
                  colors,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Completed Today',
                  '$completedToday',
                  LucideIcons.checkCircle,
                  colors,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Success Rate',
                  '${(completionRate * 100).round()}%',
                  LucideIcons.target,
                  colors,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, NeumorphicColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colors.shadowDark,
            offset: const Offset(2, 2),
            blurRadius: 4,
          ),
          BoxShadow(
            color: colors.shadowLight,
            offset: const Offset(-2, -2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.textColor,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: colors.textColor.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStreakLeaderboard(NeumorphicColors colors, List<dynamic> habits) {
    final sortedHabits = List.from(habits)
      ..sort((a, b) => b.currentStreak.compareTo(a.currentStreak));

    return NeumorphicBox(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Streak Leaderboard',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colors.textColor,
            ),
          ),
          const SizedBox(height: 16),
          ...sortedHabits.take(5).map((habit) => _buildLeaderboardItem(habit, colors, sortedHabits)),
        ],
      ),
    );
  }

  Widget _buildLeaderboardItem(dynamic habit, NeumorphicColors colors, List<dynamic> habits) {
    final index = habits.indexOf(habit);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              habit.name,
              style: TextStyle(
                fontSize: 16,
                color: colors.textColor,
              ),
            ),
          ),
          Row(
            children: [
              Icon(LucideIcons.flame, color: Colors.orange, size: 16),
              const SizedBox(width: 4),
              Text(
                '${habit.currentStreak}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colors.textColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionChart(NeumorphicColors colors, List<dynamic> habits) {
    return NeumorphicBox(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Completion Progress',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colors.textColor,
            ),
          ),
          const SizedBox(height: 16),
          ...habits.map((habit) => _buildProgressItem(habit, colors)),
        ],
      ),
    );
  }

  Widget _buildProgressItem(dynamic habit, NeumorphicColors colors) {
    final progress = habit.progressPercentage;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                habit.name,
                style: TextStyle(
                  fontSize: 14,
                  color: colors.textColor,
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: colors.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: colors.shadowDark,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitBreakdown(NeumorphicColors colors, List<dynamic> habits) {
    final activeHabits = habits.where((h) => h.isActive).length;
    final inactiveHabits = habits.where((h) => !h.isActive).length;
    final completedToday = habits.where((h) => h.isCompletedToday).length;

    return NeumorphicBox(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Habit Breakdown',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colors.textColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildBreakdownItem('Active Habits', '$activeHabits', LucideIcons.activity, colors),
          _buildBreakdownItem('Inactive Habits', '$inactiveHabits', LucideIcons.pause, colors),
          _buildBreakdownItem('Completed Today', '$completedToday', LucideIcons.checkCircle, colors),
        ],
      ),
    );
  }

  Widget _buildBreakdownItem(String label, String value, IconData icon, NeumorphicColors colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: colors.textColor,
              ),
            ),
          ),
          Text(
            value,
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

  Widget _buildWeeklyProgress(NeumorphicColors colors, List<dynamic> habits) {
    final now = DateTime.now();
    final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final weekData = List.generate(7, (index) {
      final day = now.subtract(Duration(days: now.weekday - 1 - index));
      final dayDate = DateTime(day.year, day.month, day.day);
      
      int completions = 0;
      for (var habit in habits) {
        if (habit.completedDates.any((date) {
          final dateOnly = DateTime(date.year, date.month, date.day);
          return dateOnly.isAtSameMomentAs(dayDate);
        })) {
          completions++;
        }
      }
      
      return {
        'day': weekDays[index],
        'completions': completions,
        'total': habits.length,
      };
    });

    return NeumorphicBox(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Progress',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colors.textColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekData.map((data) => _buildWeekDay(data, colors)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDay(Map<String, dynamic> data, NeumorphicColors colors) {
    final progress = data['total'] > 0 ? data['completions'] / data['total'] : 0.0;
    
    return Column(
      children: [
        Text(
          data['day'],
          style: TextStyle(
            fontSize: 12,
            color: colors.textColor.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: progress > 0 
                ? Theme.of(context).colorScheme.primary.withOpacity(progress)
                : colors.shadowDark,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              '${data['completions']}',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: progress > 0.5 ? Colors.white : colors.textColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _openCorrelationAnalysis() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HabitCorrelationScreen(),
      ),
    );
  }

  void _openAdvancedCharts() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdvancedChartsScreen(),
      ),
    );
  }
}
