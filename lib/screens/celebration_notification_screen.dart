import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../services/smart_notification_service.dart';
import '../widgets/neumorphic_box.dart';
import '../widgets/neumorphic_colors.dart';

class CelebrationNotificationScreen extends StatefulWidget {
  const CelebrationNotificationScreen({super.key});

  @override
  State<CelebrationNotificationScreen> createState() => _CelebrationNotificationScreenState();
}

class _CelebrationNotificationScreenState extends State<CelebrationNotificationScreen> 
    with TickerProviderStateMixin {
  late AnimationController _celebrationController;
  late AnimationController _streakController;
  late AnimationController _achievementController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _streakController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _achievementController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.elasticOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _streakController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _achievementController,
      curve: Curves.bounceOut,
    ));
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    _streakController.dispose();
    _achievementController.dispose();
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
          'Celebration Center',
          style: TextStyle(color: colors.textColor),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Celebration Notifications',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colors.textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Test and customize celebration notifications for achievements and milestones',
                style: TextStyle(
                  fontSize: 16,
                  color: colors.textColor.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 24),
              
              Expanded(
                child: ListView(
                  children: [
                    _buildCelebrationCard(
                      'Streak Celebration',
                      'Celebrate habit streaks with animated notifications',
                      LucideIcons.flame,
                      Colors.orange,
                      () => _testStreakCelebration(),
                    ),
                    _buildCelebrationCard(
                      'Achievement Unlock',
                      'Celebrate achievement unlocks with special effects',
                      LucideIcons.trophy,
                      Colors.amber,
                      () => _testAchievementCelebration(),
                    ),
                    _buildCelebrationCard(
                      'Level Up',
                      'Celebrate level progression with confetti',
                      LucideIcons.trendingUp,
                      Colors.purple,
                      () => _testLevelUpCelebration(),
                    ),
                    _buildCelebrationCard(
                      'Perfect Week',
                      'Celebrate perfect weekly completion',
                      LucideIcons.calendar,
                      Colors.green,
                      () => _testPerfectWeekCelebration(),
                    ),
                    _buildCelebrationCard(
                      'Habit Mastery',
                      'Celebrate habit mastery milestones',
                      LucideIcons.star,
                      Colors.blue,
                      () => _testHabitMasteryCelebration(),
                    ),
                    _buildCelebrationCard(
                      'Social Achievement',
                      'Celebrate social milestones and challenges',
                      LucideIcons.users,
                      Colors.pink,
                      () => _testSocialCelebration(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCelebrationCard(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final colors = Theme.of(context).extension<NeumorphicColors>()!;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: NeumorphicBox(
        padding: const EdgeInsets.all(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
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
              Icon(
                LucideIcons.play,
                color: color,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _testStreakCelebration() async {
    _streakController.forward().then((_) {
      _streakController.reverse();
    });

    await SmartNotificationService.instance.scheduleCelebrationNotification(
      title: '🔥 Streak Celebration!',
      body: 'Amazing! You\'ve maintained your habit for 7 days in a row!',
      scheduledTime: DateTime.now().add(const Duration(seconds: 1)),
    );

    _showCelebrationDialog(
      'Streak Celebration!',
      'You\'ve maintained your habit for 7 days in a row!',
      LucideIcons.flame,
      Colors.orange,
    );
  }

  void _testAchievementCelebration() async {
    _achievementController.forward().then((_) {
      _achievementController.reverse();
    });

    await SmartNotificationService.instance.scheduleAchievementNotification(
      title: '🏆 Achievement Unlocked!',
      body: 'You\'ve earned the "Early Bird" achievement!',
      achievementType: 'early_bird',
    );

    _showCelebrationDialog(
      'Achievement Unlocked!',
      'You\'ve earned the "Early Bird" achievement!',
      LucideIcons.trophy,
      Colors.amber,
    );
  }

  void _testLevelUpCelebration() async {
    _celebrationController.forward().then((_) {
      _celebrationController.reverse();
    });

    await SmartNotificationService.instance.scheduleCelebrationNotification(
      title: '⭐ Level Up!',
      body: 'Congratulations! You\'ve reached Level 5!',
      scheduledTime: DateTime.now().add(const Duration(seconds: 1)),
    );

    _showCelebrationDialog(
      'Level Up!',
      'Congratulations! You\'ve reached Level 5!',
      LucideIcons.trendingUp,
      Colors.purple,
    );
  }

  void _testPerfectWeekCelebration() async {
    _celebrationController.forward().then((_) {
      _celebrationController.reverse();
    });

    await SmartNotificationService.instance.scheduleCelebrationNotification(
      title: '📅 Perfect Week!',
      body: 'Outstanding! You completed all your habits this week!',
      scheduledTime: DateTime.now().add(const Duration(seconds: 1)),
    );

    _showCelebrationDialog(
      'Perfect Week!',
      'Outstanding! You completed all your habits this week!',
      LucideIcons.calendar,
      Colors.green,
    );
  }

  void _testHabitMasteryCelebration() async {
    _achievementController.forward().then((_) {
      _achievementController.reverse();
    });

    await SmartNotificationService.instance.scheduleAchievementNotification(
      title: '🌟 Habit Mastery!',
      body: 'Incredible! You\'ve mastered the "Morning Exercise" habit!',
      achievementType: 'habit_mastery',
    );

    _showCelebrationDialog(
      'Habit Mastery!',
      'Incredible! You\'ve mastered the "Morning Exercise" habit!',
      LucideIcons.star,
      Colors.blue,
    );
  }

  void _testSocialCelebration() async {
    _celebrationController.forward().then((_) {
      _celebrationController.reverse();
    });

    await SmartNotificationService.instance.scheduleSocialNotification(
      title: '👥 Social Achievement!',
      body: 'Your friend just completed their 30-day challenge!',
      scheduledTime: DateTime.now().add(const Duration(seconds: 1)),
    );

    _showCelebrationDialog(
      'Social Achievement!',
      'Your friend just completed their 30-day challenge!',
      LucideIcons.users,
      Colors.pink,
    );
  }

  void _showCelebrationDialog(String title, String message, IconData icon, Color color) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SlideTransition(
        position: _slideAnimation,
        child: RotationTransition(
          turns: _rotationAnimation,
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) => Transform.scale(
              scale: _scaleAnimation.value,
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: 48, color: color),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Awesome!'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
