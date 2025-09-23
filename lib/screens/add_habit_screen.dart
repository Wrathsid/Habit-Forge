import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/habit.dart';
import '../services/habit_service.dart';
import '../widgets/neumorphic_box.dart';
import '../widgets/neumorphic_colors.dart';
import '../widgets/reminder_settings.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _goalController = TextEditingController(text: '7');
  
  String _selectedIcon = 'target';
  bool _hasReminder = false;
  TimeOfDay? _reminderTime;
  List<int> _reminderDays = [];
  
  final List<String> _availableIcons = [
    'target',
    'heart',
    'book',
    'dumbbell',
    'sun',
    'moon',
    'coffee',
    'music',
    'camera',
    'code',
    'paintbrush',
    'gamepad2',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _goalController.dispose();
    super.dispose();
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
          'Add New Habit',
          style: TextStyle(color: colors.textColor),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHabitNameField(colors),
                        const SizedBox(height: 20),
                        _buildDescriptionField(colors),
                        const SizedBox(height: 20),
                        _buildGoalField(colors),
                        const SizedBox(height: 20),
                        _buildIconSelector(colors),
                        const SizedBox(height: 20),
                        _buildReminderSettings(colors),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildSaveButton(colors),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHabitNameField(NeumorphicColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Habit Name',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colors.textColor,
          ),
        ),
        const SizedBox(height: 8),
        NeumorphicBox(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TextFormField(
            controller: _nameController,
            style: TextStyle(color: colors.textColor),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'e.g., Morning Meditation',
              hintStyle: TextStyle(color: colors.textColor.withValues(alpha: 0.6)),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a habit name';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField(NeumorphicColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description (Optional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colors.textColor,
          ),
        ),
        const SizedBox(height: 8),
        NeumorphicBox(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TextFormField(
            controller: _descriptionController,
            style: TextStyle(color: colors.textColor),
            maxLines: 3,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Describe your habit...',
              hintStyle: TextStyle(color: colors.textColor.withValues(alpha: 0.6)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGoalField(NeumorphicColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weekly Goal',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colors.textColor,
          ),
        ),
        const SizedBox(height: 8),
        NeumorphicBox(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TextFormField(
            controller: _goalController,
            style: TextStyle(color: colors.textColor),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: '7',
              hintStyle: TextStyle(color: colors.textColor.withValues(alpha: 0.6)),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a goal';
              }
              final goal = int.tryParse(value);
              if (goal == null || goal < 1 || goal > 7) {
                return 'Goal must be between 1 and 7';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildIconSelector(NeumorphicColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Icon',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colors.textColor,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _availableIcons.length,
          itemBuilder: (context, index) {
            final icon = _availableIcons[index];
            final isSelected = icon == _selectedIcon;
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIcon = icon;
                });
              },
              child: NeumorphicBox(
                isPressed: isSelected,
                padding: const EdgeInsets.all(8),
                child: Icon(
                  _getIconData(icon),
                  color: isSelected 
                      ? Theme.of(context).colorScheme.primary
                      : colors.textColor,
                  size: 24,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSaveButton(NeumorphicColors colors) {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: _saveHabit,
        child: NeumorphicBox(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: Text(
              'Save Habit',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colors.textColor,
              ),
            ),
          ),
        ),
      ),
    );
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

  Widget _buildReminderSettings(NeumorphicColors colors) {
    return ReminderSettings(
      hasReminder: _hasReminder,
      reminderTime: _reminderTime,
      reminderDays: _reminderDays,
      onReminderChanged: (value) {
        setState(() {
          _hasReminder = value;
        });
      },
      onTimeChanged: (value) {
        setState(() {
          _reminderTime = value;
        });
      },
      onDaysChanged: (value) {
        setState(() {
          _reminderDays = value;
        });
      },
    );
  }

  void _saveHabit() async {
    if (!_formKey.currentState!.validate()) return;

    final habit = Habit(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      icon: _selectedIcon,
      goal: int.parse(_goalController.text),
      hasReminder: _hasReminder,
      reminderTime: _reminderTime,
      reminderDays: _reminderDays,
    );

    await HabitService.instance.addHabit(habit);
    
    if (mounted) {
      Navigator.pop(context, true);
    }
  }
}
