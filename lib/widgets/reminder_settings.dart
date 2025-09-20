import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'neumorphic_box.dart';
import 'neumorphic_colors.dart';

class ReminderSettings extends StatefulWidget {
  final bool hasReminder;
  final TimeOfDay? reminderTime;
  final List<int> reminderDays;
  final ValueChanged<bool> onReminderChanged;
  final ValueChanged<TimeOfDay?> onTimeChanged;
  final ValueChanged<List<int>> onDaysChanged;

  const ReminderSettings({
    super.key,
    required this.hasReminder,
    this.reminderTime,
    required this.reminderDays,
    required this.onReminderChanged,
    required this.onTimeChanged,
    required this.onDaysChanged,
  });

  @override
  State<ReminderSettings> createState() => _ReminderSettingsState();
}

class _ReminderSettingsState extends State<ReminderSettings> {
  final List<String> _dayNames = [
    'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<NeumorphicColors>()!;
    
    return NeumorphicBox(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.bell,
                color: colors.textColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Reminder Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Enable/Disable Reminder Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Enable Reminder',
                style: TextStyle(
                  fontSize: 16,
                  color: colors.textColor,
                ),
              ),
              Switch(
                value: widget.hasReminder,
                onChanged: widget.onReminderChanged,
                activeColor: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
          
          if (widget.hasReminder) ...[
            const SizedBox(height: 16),
            
            // Time Picker
            GestureDetector(
              onTap: _selectTime,
              child: NeumorphicBox(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.clock,
                      color: colors.textColor,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Time: ${widget.reminderTime?.format(context) ?? 'Select Time'}',
                      style: TextStyle(
                        fontSize: 16,
                        color: colors.textColor,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      LucideIcons.chevronRight,
                      color: colors.textColor,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Days of Week Selector
            Text(
              'Repeat on:',
              style: TextStyle(
                fontSize: 16,
                color: colors.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: List.generate(7, (index) {
                final isSelected = widget.reminderDays.contains(index);
                return GestureDetector(
                  onTap: () => _toggleDay(index),
                  child: NeumorphicBox(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    isPressed: isSelected,
                    child: Text(
                      _dayNames[index],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected 
                            ? Theme.of(context).colorScheme.primary
                            : colors.textColor,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: widget.reminderTime ?? const TimeOfDay(hour: 9, minute: 0),
    );
    
    if (picked != null) {
      widget.onTimeChanged(picked);
    }
  }

  void _toggleDay(int dayIndex) {
    final newDays = List<int>.from(widget.reminderDays);
    if (newDays.contains(dayIndex)) {
      newDays.remove(dayIndex);
    } else {
      newDays.add(dayIndex);
    }
    widget.onDaysChanged(newDays);
  }
}
