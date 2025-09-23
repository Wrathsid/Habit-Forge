import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/habit.dart';
import '../services/habit_service.dart';
import '../widgets/neumorphic_box.dart';
import '../widgets/neumorphic_colors.dart';
import '../widgets/reminder_settings.dart';

class EditHabitScreen extends StatefulWidget {
  final Habit habit;

  const EditHabitScreen({super.key, required this.habit});

  @override
  State<EditHabitScreen> createState() => _EditHabitScreenState();
}

class _EditHabitScreenState extends State<EditHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _goalController;
  
  late String _selectedIcon;
  late String _selectedCategory;
  late bool _isActive;
  late bool _hasReminder;
  late TimeOfDay? _reminderTime;
  late List<int> _reminderDays;

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

  final List<String> _categories = [
    'Health',
    'Fitness',
    'Learning',
    'Productivity',
    'Mindfulness',
    'Social',
    'Creative',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.habit.name);
    _descriptionController = TextEditingController(text: widget.habit.description);
    _goalController = TextEditingController(text: widget.habit.goal.toString());
    _selectedIcon = widget.habit.icon;
    _selectedCategory = 'Health'; // Default category
    _isActive = widget.habit.isActive;
    _hasReminder = widget.habit.hasReminder;
    _reminderTime = widget.habit.reminderTime;
    _reminderDays = List<int>.from(widget.habit.reminderDays);
  }

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
          'Edit Habit',
          style: TextStyle(color: colors.textColor),
        ),
        actions: [
          IconButton(
            icon: Icon(LucideIcons.save, color: colors.textColor),
            onPressed: _saveHabit,
          ),
        ],
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
                        _buildCategorySelector(colors),
                        const SizedBox(height: 20),
                        _buildIconSelector(colors),
                        const SizedBox(height: 20),
                        _buildReminderSettings(colors),
                        const SizedBox(height: 20),
                        _buildActiveToggle(colors),
                        const SizedBox(height: 20),
                        _buildHabitStats(colors),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildActionButtons(colors),
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
          'Description',
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

  Widget _buildCategorySelector(NeumorphicColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colors.textColor,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categories.map((category) {
            final isSelected = category == _selectedCategory;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
              },
              child: NeumorphicBox(
                isPressed: isSelected,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  category,
                  style: TextStyle(
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

  Widget _buildActiveToggle(NeumorphicColors colors) {
    return NeumorphicBox(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Active Habit',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors.textColor,
                ),
              ),
              Text(
                'Show this habit in your daily list',
                style: TextStyle(
                  fontSize: 12,
                  color: colors.textColor.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          Switch(
            value: _isActive,
            onChanged: (value) {
              setState(() {
                _isActive = value;
              });
            },
            activeThumbColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildHabitStats(NeumorphicColors colors) {
    return NeumorphicBox(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Habit Statistics',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colors.textColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Current Streak', '${widget.habit.currentStreak}', LucideIcons.flame, colors),
              _buildStatItem('Total Completions', '${widget.habit.completedDates.length}', LucideIcons.checkCircle, colors),
              _buildStatItem('Created', '${_getDaysSinceCreation()} days ago', LucideIcons.calendar, colors),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, NeumorphicColors colors) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: colors.textColor,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: colors.textColor.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActionButtons(NeumorphicColors colors) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _saveHabit,
            child: NeumorphicBox(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.textColor,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: _deleteHabit,
            child: NeumorphicBox(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'Delete Habit',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
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

  int _getDaysSinceCreation() {
    final now = DateTime.now();
    final difference = now.difference(widget.habit.createdAt);
    return difference.inDays;
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

    final updatedHabit = widget.habit.copyWith(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      icon: _selectedIcon,
      goal: int.parse(_goalController.text),
      isActive: _isActive,
      hasReminder: _hasReminder,
      reminderTime: _reminderTime,
      reminderDays: _reminderDays,
    );

    await HabitService.instance.updateHabit(updatedHabit);
    
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  void _deleteHabit() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit'),
        content: Text('Are you sure you want to delete "${widget.habit.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await HabitService.instance.deleteHabit(widget.habit.id);
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }
}
