import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/habit.dart';
import '../services/habit_service.dart';
import '../widgets/neumorphic_box.dart';
import '../widgets/neumorphic_colors.dart';
import 'edit_habit_screen.dart';

class ReminderManagementScreen extends StatefulWidget {
  const ReminderManagementScreen({super.key});

  @override
  State<ReminderManagementScreen> createState() => _ReminderManagementScreenState();
}

class _ReminderManagementScreenState extends State<ReminderManagementScreen> {
  List<Habit> _habitsWithReminders = [];

  @override
  void initState() {
    super.initState();
    _loadHabitsWithReminders();
  }

  void _loadHabitsWithReminders() {
    final allHabits = HabitService.instance.habits;
    _habitsWithReminders = allHabits.where((habit) => habit.hasReminder).toList();
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
          'Reminder Management',
          style: TextStyle(color: colors.textColor),
        ),
        actions: [
          IconButton(
            icon: Icon(LucideIcons.refreshCw, color: colors.textColor),
            onPressed: () {
              setState(() {
                _loadHabitsWithReminders();
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _habitsWithReminders.isEmpty
              ? _buildEmptyState(colors)
              : _buildRemindersList(colors),
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
            LucideIcons.bellOff,
            size: 64,
            color: colors.textColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Reminders Set',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colors.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add reminders to your habits to stay on track!',
            style: TextStyle(
              fontSize: 16,
              color: colors.textColor.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRemindersList(NeumorphicColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Active Reminders',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colors.textColor,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: _habitsWithReminders.length,
            itemBuilder: (context, index) {
              final habit = _habitsWithReminders[index];
              return _buildReminderCard(habit, colors);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReminderCard(Habit habit, NeumorphicColors colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NeumorphicBox(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getIconData(habit.icon),
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colors.textColor,
                        ),
                      ),
                      Text(
                        habit.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: colors.textColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    LucideIcons.settings,
                    color: colors.textColor,
                    size: 20,
                  ),
                  onPressed: () => _editReminder(habit),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  LucideIcons.clock,
                  color: colors.textColor.withOpacity(0.7),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Time: ${habit.reminderTime?.format(context) ?? 'Not set'}',
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.textColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  LucideIcons.calendar,
                  color: colors.textColor.withOpacity(0.7),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Days: ${_formatReminderDays(habit.reminderDays)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: colors.textColor.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatReminderDays(List<int> days) {
    if (days.isEmpty) return 'None';
    
    final dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final selectedDays = days.map((day) => dayNames[day]).join(', ');
    return selectedDays;
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'target':
        return LucideIcons.target;
      case 'heart':
        return LucideIcons.heart;
      case 'book':
        return LucideIcons.book;
      case 'dumbbell':
        return LucideIcons.dumbbell;
      case 'sun':
        return LucideIcons.sun;
      case 'moon':
        return LucideIcons.moon;
      case 'coffee':
        return LucideIcons.coffee;
      case 'music':
        return LucideIcons.music;
      case 'camera':
        return LucideIcons.camera;
      case 'code':
        return LucideIcons.code;
      case 'paintbrush':
        return LucideIcons.paintbrush;
      case 'gamepad2':
        return LucideIcons.gamepad2;
      default:
        return LucideIcons.target;
    }
  }

  void _editReminder(Habit habit) {
    // Navigate to edit habit screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditHabitScreen(habit: habit),
      ),
    ).then((_) {
      // Refresh the list when returning from edit screen
      setState(() {
        _loadHabitsWithReminders();
      });
    });
  }
}

