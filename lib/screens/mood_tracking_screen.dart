import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/mood.dart';
import '../services/mood_service.dart';
import '../widgets/neumorphic_box.dart';
import '../widgets/neumorphic_colors.dart';

class MoodTrackingScreen extends StatefulWidget {
  const MoodTrackingScreen({super.key});

  @override
  State<MoodTrackingScreen> createState() => _MoodTrackingScreenState();
}

class _MoodTrackingScreenState extends State<MoodTrackingScreen> {
  MoodType? _selectedMood;
  final TextEditingController _noteController = TextEditingController();
  final List<String> _selectedTags = [];
  final List<String> _availableTags = [
    'Happy', 'Stressed', 'Energetic', 'Tired', 'Motivated',
    'Anxious', 'Calm', 'Excited', 'Focused', 'Relaxed',
    'Productive', 'Creative', 'Social', 'Alone', 'Exercise',
    'Work', 'Family', 'Friends', 'Health', 'Weather'
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<NeumorphicColors>()!;
    final todayMood = MoodService.instance.getTodayMood();
    final insights = MoodService.instance.generateInsights();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: colors.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Mood Tracking',
          style: TextStyle(color: colors.textColor),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTodayMood(todayMood, colors),
                const SizedBox(height: 24),
                _buildMoodSelector(colors),
                const SizedBox(height: 24),
                _buildNoteField(colors),
                const SizedBox(height: 24),
                _buildTagSelector(colors),
                const SizedBox(height: 24),
                _buildSaveButton(colors),
                const SizedBox(height: 24),
                _buildInsights(insights, colors),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTodayMood(Mood? todayMood, NeumorphicColors colors) {
    return NeumorphicBox(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Mood',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.textColor,
            ),
          ),
          const SizedBox(height: 16),
          if (todayMood != null) ...[
            Row(
              children: [
                Text(
                  todayMood.emoji,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        todayMood.label,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colors.textColor,
                        ),
                      ),
                      if (todayMood.note != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          todayMood.note!,
                          style: TextStyle(
                            fontSize: 14,
                            color: colors.textColor.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (todayMood.tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: todayMood.tags.map((tag) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: todayMood.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 12,
                      color: todayMood.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )).toList(),
              ),
            ],
          ] else ...[
            Text(
              'No mood recorded today',
              style: TextStyle(
                fontSize: 16,
                color: colors.textColor.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMoodSelector(NeumorphicColors colors) {
    return NeumorphicBox(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How are you feeling?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.textColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: MoodType.values.map((mood) {
              final isSelected = _selectedMood == mood;
              return GestureDetector(
                onTap: () => setState(() => _selectedMood = mood),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? _getMoodColor(mood).withValues(alpha: 0.1)
                        : colors.textColor.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                    border: isSelected 
                        ? Border.all(color: _getMoodColor(mood), width: 2)
                        : null,
                  ),
                  child: Column(
                    children: [
                      Text(
                        _getMoodEmoji(mood),
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getMoodLabel(mood),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? _getMoodColor(mood) : colors.textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteField(NeumorphicColors colors) {
    return NeumorphicBox(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add a note (optional)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.textColor,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'What\'s on your mind?',
              hintStyle: TextStyle(color: colors.textColor.withValues(alpha: 0.5)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: colors.textColor.withValues(alpha: 0.05),
            ),
            style: TextStyle(color: colors.textColor),
          ),
        ],
      ),
    );
  }

  Widget _buildTagSelector(NeumorphicColors colors) {
    return NeumorphicBox(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tags (optional)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.textColor,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableTags.map((tag) {
              final isSelected = _selectedTags.contains(tag);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedTags.remove(tag);
                    } else {
                      _selectedTags.add(tag);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                        : colors.textColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: isSelected 
                        ? Border.all(color: Theme.of(context).colorScheme.primary)
                        : null,
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected 
                          ? Theme.of(context).colorScheme.primary
                          : colors.textColor,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(NeumorphicColors colors) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _selectedMood != null ? _saveMood : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Save Mood',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildInsights(MoodInsight insights, NeumorphicColors colors) {
    return NeumorphicBox(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mood Insights',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.textColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInsightItem(
                  'Average Mood',
                  '${insights.averageMood.toStringAsFixed(1)}/5',
                  LucideIcons.barChart3,
                  colors,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInsightItem(
                  'Total Entries',
                  insights.totalEntries.toString(),
                  LucideIcons.calendar,
                  colors,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInsightItem(
                  'Most Common',
                  _getMoodLabel(insights.mostCommonMood),
                  LucideIcons.trendingUp,
                  colors,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInsightItem(
                  'Trend',
                  insights.moodTrend,
                  LucideIcons.arrowUp,
                  colors,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(String label, String value, IconData icon, NeumorphicColors colors) {
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _saveMood() async {
    if (_selectedMood == null) return;

    await MoodService.instance.addMood(
      type: _selectedMood!,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      tags: _selectedTags,
    );

    setState(() {
      _selectedMood = null;
      _noteController.clear();
      _selectedTags.clear();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mood saved successfully!')),
      );
    }
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

  String _getMoodLabel(MoodType mood) {
    switch (mood) {
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

  Color _getMoodColor(MoodType mood) {
    switch (mood) {
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
}
