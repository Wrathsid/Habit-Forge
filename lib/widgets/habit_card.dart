import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/habit.dart';
import '../services/habit_service.dart';
import '../services/achievement_service.dart';
import '../services/smart_notification_service.dart';
import 'neumorphic_box.dart';
import 'neumorphic_colors.dart';
import 'celebration_animations.dart';

class HabitCard extends StatefulWidget {
  final Habit habit;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const HabitCard({
    super.key,
    required this.habit,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<NeumorphicColors>()!;

    return NeumorphicBox(
      isPressed: _isPressed,
      padding: const EdgeInsets.all(16),
      onTap: () async {
        setState(() {
          _isPressed = true;
        });

        // Haptic feedback
        // HapticFeedback.lightImpact();

        if (widget.habit.isCompletedToday) {
          await HabitService.instance.uncompleteHabit(widget.habit.id);
        } else {
          await HabitService.instance.completeHabit(widget.habit.id);
          
          // Check for achievements
          await AchievementService.instance.checkAchievements(HabitService.instance.habits);
          
          // Update user progress
          await AchievementService.instance.updateUserProgress(HabitService.instance.habits);
          
          // Record completion for smart notifications
          await SmartNotificationService.instance.recordHabitCompletion(widget.habit.id, DateTime.now());
          
          // Show celebration if streak milestone
          if (widget.habit.currentStreak > 0 && widget.habit.currentStreak % 7 == 0) {
            // Use a post-frame callback to ensure context is valid
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                CelebrationAnimations.showStreakCelebration(
                  context: context,
                  streak: widget.habit.currentStreak,
                  habitName: widget.habit.name,
                );
              }
            });
          }
        }

        // Reset pressed state
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) {
            setState(() {
              _isPressed = false;
            });
          }
        });

        widget.onTap?.call();
      },
      child: Row(
        children: [
          _buildIcon(colors),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(colors),
                const SizedBox(height: 8),
                _buildProgressBar(colors),
                const SizedBox(height: 4),
                _buildStats(colors),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _buildActionButtons(colors),
        ],
      ),
    );
  }

  Widget _buildIcon(NeumorphicColors colors) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: widget.habit.isCompletedToday
            ? Theme.of(context).colorScheme.primary
            : colors.background,
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
      child: Icon(
        _getIconData(widget.habit.icon),
        color: widget.habit.isCompletedToday
            ? Colors.white
            : colors.textColor,
        size: 24,
      ),
    );
  }

  Widget _buildHeader(NeumorphicColors colors) {
    return Row(
      children: [
        Expanded(
          child: Text(
            widget.habit.name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.textColor,
              decoration: widget.habit.isCompletedToday
                  ? TextDecoration.lineThrough
                  : null,
            ),
          ),
        ),
        if (widget.habit.isCompletedToday)
          Icon(
            LucideIcons.checkCircle,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
      ],
    );
  }

  Widget _buildProgressBar(NeumorphicColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${widget.habit.currentStreak}/${widget.habit.goal}',
              style: TextStyle(
                fontSize: 12,
                color: colors.textColor.withValues(alpha: 0.7),
              ),
            ),
            Text(
              '${(widget.habit.progressPercentage * 100).round()}%',
              style: TextStyle(
                fontSize: 12,
                color: colors.textColor.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: colors.shadowDark,
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: widget.habit.progressPercentage,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStats(NeumorphicColors colors) {
    return Row(
      children: [
        Icon(
          LucideIcons.flame,
          size: 14,
          color: Colors.orange,
        ),
        const SizedBox(width: 4),
        Text(
          '${widget.habit.currentStreak} day streak',
          style: TextStyle(
            fontSize: 12,
            color: colors.textColor.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(width: 16),
        Icon(
          LucideIcons.calendar,
          size: 14,
          color: colors.textColor.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 4),
        Text(
          '${widget.habit.completedDates.length} total',
          style: TextStyle(
            fontSize: 12,
            color: colors.textColor.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(NeumorphicColors colors) {
    return Column(
      children: [
        GestureDetector(
          onTap: widget.onEdit,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: colors.shadowDark,
                  offset: const Offset(1, 1),
                  blurRadius: 2,
                ),
                BoxShadow(
                  color: colors.shadowLight,
                  offset: const Offset(-1, -1),
                  blurRadius: 2,
                ),
              ],
            ),
            child: Icon(
              LucideIcons.edit,
              size: 16,
              color: colors.textColor,
            ),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: widget.onDelete,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: colors.shadowDark,
                  offset: const Offset(1, 1),
                  blurRadius: 2,
                ),
                BoxShadow(
                  color: colors.shadowLight,
                  offset: const Offset(-1, -1),
                  blurRadius: 2,
                ),
              ],
            ),
            child: Icon(
              LucideIcons.trash2,
              size: 16,
              color: Colors.red,
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
}
