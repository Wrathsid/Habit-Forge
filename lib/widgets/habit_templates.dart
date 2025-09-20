import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/habit.dart';
import '../services/habit_service.dart';
import '../widgets/neumorphic_box.dart';
import '../widgets/neumorphic_colors.dart';

class HabitTemplates extends StatelessWidget {
  final VoidCallback? onHabitCreated;

  const HabitTemplates({super.key, this.onHabitCreated});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<NeumorphicColors>()!;

    return NeumorphicBox(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Add Templates',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colors.textColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Tap any template to quickly create a habit',
            style: TextStyle(
              fontSize: 14,
              color: colors.textColor.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: _templates.length,
            itemBuilder: (context, index) {
              final template = _templates[index];
              return _buildTemplateCard(template, colors, context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(HabitTemplate template, NeumorphicColors colors, BuildContext context) {
    return GestureDetector(
      onTap: () => _createHabitFromTemplate(template, context),
      child: NeumorphicBox(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              template.icon,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              template.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              template.description,
              style: TextStyle(
                fontSize: 10,
                color: colors.textColor.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _createHabitFromTemplate(HabitTemplate template, BuildContext context) async {
    final habit = Habit(
      name: template.name,
      description: template.description,
      icon: template.iconName,
      goal: template.goal,
    );

    await HabitService.instance.addHabit(habit);
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${template.name} habit created!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      onHabitCreated?.call();
    }
  }

  static final List<HabitTemplate> _templates = [
    HabitTemplate(
      name: 'Morning Meditation',
      description: 'Start your day with mindfulness',
      icon: LucideIcons.brain,
      iconName: 'target',
      goal: 7,
    ),
    HabitTemplate(
      name: 'Daily Exercise',
      description: 'Stay active and healthy',
      icon: LucideIcons.dumbbell,
      iconName: 'dumbbell',
      goal: 5,
    ),
    HabitTemplate(
      name: 'Read Books',
      description: 'Expand your knowledge',
      icon: LucideIcons.book,
      iconName: 'book',
      goal: 7,
    ),
    HabitTemplate(
      name: 'Drink Water',
      description: 'Stay hydrated throughout the day',
      icon: LucideIcons.droplets,
      iconName: 'heart',
      goal: 7,
    ),
    HabitTemplate(
      name: 'Journal Writing',
      description: 'Reflect on your thoughts',
      icon: LucideIcons.penTool,
      iconName: 'paintbrush',
      goal: 7,
    ),
    HabitTemplate(
      name: 'Learn Code',
      description: 'Improve your programming skills',
      icon: LucideIcons.code,
      iconName: 'code',
      goal: 5,
    ),
    HabitTemplate(
      name: 'Practice Music',
      description: 'Develop your musical skills',
      icon: LucideIcons.music,
      iconName: 'music',
      goal: 6,
    ),
    HabitTemplate(
      name: 'Take Photos',
      description: 'Capture beautiful moments',
      icon: LucideIcons.camera,
      iconName: 'camera',
      goal: 7,
    ),
  ];
}

class HabitTemplate {
  final String name;
  final String description;
  final IconData icon;
  final String iconName;
  final int goal;

  HabitTemplate({
    required this.name,
    required this.description,
    required this.icon,
    required this.iconName,
    required this.goal,
  });
}
