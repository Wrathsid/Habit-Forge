import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/habit.dart';
import '../models/mood.dart';
import '../services/habit_service.dart';
import '../services/mood_service.dart';
import '../widgets/neumorphic_box.dart';
import '../widgets/neumorphic_colors.dart';

class HabitCorrelationScreen extends StatefulWidget {
  const HabitCorrelationScreen({super.key});

  @override
  State<HabitCorrelationScreen> createState() => _HabitCorrelationScreenState();
}

class _HabitCorrelationScreenState extends State<HabitCorrelationScreen> {
  Map<String, double> _correlations = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCorrelations();
  }

  Future<void> _loadCorrelations() async {
    setState(() => _isLoading = true);
    
    final habits = HabitService.instance.habits;
    final correlations = await MoodService.instance.analyzeHabitMoodCorrelation(habits);
    
    setState(() {
      _correlations = correlations;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<NeumorphicColors>()!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: colors.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Habit Correlation',
          style: TextStyle(color: colors.textColor),
        ),
        actions: [
          IconButton(
            icon: Icon(LucideIcons.refreshCw, color: colors.textColor),
            onPressed: _loadCorrelations,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(colors),
              const SizedBox(height: 24),
              if (_isLoading)
                _buildLoadingState(colors)
              else
                Expanded(
                  child: _buildCorrelationsList(colors),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(NeumorphicColors colors) {
    return NeumorphicBox(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.barChart3, color: colors.textColor, size: 24),
              const SizedBox(width: 12),
              Text(
                'Habit-Mood Analysis',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Discover which habits positively impact your mood',
            style: TextStyle(
              fontSize: 14,
              color: colors.textColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(NeumorphicColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Analyzing your habits...',
            style: TextStyle(
              fontSize: 16,
              color: colors.textColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorrelationsList(NeumorphicColors colors) {
    if (_correlations.isEmpty) {
      return _buildEmptyState(colors);
    }

    // Sort correlations by mood impact (highest first)
    final sortedCorrelations = _correlations.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ListView.builder(
      itemCount: sortedCorrelations.length,
      itemBuilder: (context, index) {
        final entry = sortedCorrelations[index];
        final habitName = entry.key;
        final moodImpact = entry.value;
        
        return _buildCorrelationCard(habitName, moodImpact, colors);
      },
    );
  }

  Widget _buildCorrelationCard(String habitName, double moodImpact, NeumorphicColors colors) {
    final impactLevel = _getImpactLevel(moodImpact);
    final impactColor = _getImpactColor(moodImpact);
    final impactIcon = _getImpactIcon(moodImpact);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: NeumorphicBox(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: impactColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                impactIcon,
                color: impactColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habitName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colors.textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    impactLevel,
                    style: TextStyle(
                      fontSize: 14,
                      color: impactColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${moodImpact.toStringAsFixed(1)}/5',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colors.textColor,
                  ),
                ),
                Text(
                  'avg mood',
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.textColor.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(NeumorphicColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.barChart3,
            size: 64,
            color: colors.textColor.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No correlation data available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete some habits and track your mood\nto see correlations',
            style: TextStyle(
              fontSize: 14,
              color: colors.textColor.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getImpactLevel(double moodImpact) {
    if (moodImpact >= 4.0) return 'Excellent Impact';
    if (moodImpact >= 3.5) return 'Strong Impact';
    if (moodImpact >= 3.0) return 'Good Impact';
    if (moodImpact >= 2.5) return 'Moderate Impact';
    return 'Low Impact';
  }

  Color _getImpactColor(double moodImpact) {
    if (moodImpact >= 4.0) return Colors.green;
    if (moodImpact >= 3.5) return Colors.lightGreen;
    if (moodImpact >= 3.0) return Colors.yellow;
    if (moodImpact >= 2.5) return Colors.orange;
    return Colors.red;
  }

  IconData _getImpactIcon(double moodImpact) {
    if (moodImpact >= 4.0) return LucideIcons.trendingUp;
    if (moodImpact >= 3.5) return LucideIcons.arrowUp;
    if (moodImpact >= 3.0) return LucideIcons.minus;
    if (moodImpact >= 2.5) return LucideIcons.arrowDown;
    return LucideIcons.trendingDown;
  }
}

