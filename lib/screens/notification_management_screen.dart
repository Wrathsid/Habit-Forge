import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../services/smart_notification_service.dart';
import '../services/habit_service.dart';
import '../widgets/neumorphic_box.dart';
import '../widgets/neumorphic_colors.dart';

class NotificationManagementScreen extends StatefulWidget {
  const NotificationManagementScreen({super.key});

  @override
  State<NotificationManagementScreen> createState() => _NotificationManagementScreenState();
}

class _NotificationManagementScreenState extends State<NotificationManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<PendingNotificationRequest> _pendingNotifications = [];
  Map<String, dynamic> _analytics = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final pending = await SmartNotificationService.instance.getPendingNotifications();
    final analytics = await SmartNotificationService.instance.getNotificationAnalytics();
    
    setState(() {
      _pendingNotifications = pending;
      _analytics = analytics;
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
          'Notification Center',
          style: TextStyle(color: colors.textColor),
        ),
        actions: [
          IconButton(
            icon: Icon(LucideIcons.refreshCw, color: colors.textColor),
            onPressed: _loadData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: colors.textColor,
          unselectedLabelColor: colors.textColor.withValues(alpha: 0.5),
          indicatorColor: Theme.of(context).colorScheme.primary,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Analytics'),
            Tab(text: 'Settings'),
            Tab(text: 'Test'),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: colors.textColor))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildPendingTab(colors),
                _buildAnalyticsTab(colors),
                _buildSettingsTab(colors),
                _buildTestTab(colors),
              ],
            ),
    );
  }

  Widget _buildPendingTab(NeumorphicColors colors) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pending Notifications (${_pendingNotifications.length})',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colors.textColor,
                  ),
                ),
                if (_pendingNotifications.isNotEmpty)
                  TextButton.icon(
                    onPressed: _clearAllNotifications,
                    icon: const Icon(LucideIcons.trash2, size: 16),
                    label: const Text('Clear All'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _pendingNotifications.isEmpty
                  ? _buildEmptyState('No Pending Notifications', 'All caught up!', LucideIcons.checkCircle, colors)
                  : ListView.builder(
                      itemCount: _pendingNotifications.length,
                      itemBuilder: (context, index) {
                        final notification = _pendingNotifications[index];
                        return _buildNotificationCard(notification, colors);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsTab(NeumorphicColors colors) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notification Analytics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors.textColor,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildAnalyticsCard(
                    'Pending Notifications',
                    _analytics['pendingCount']?.toString() ?? '0',
                    LucideIcons.clock,
                    colors,
                  ),
                  _buildAnalyticsCard(
                    'Total Completions',
                    _analytics['totalCompletions']?.toString() ?? '0',
                    LucideIcons.checkCircle,
                    colors,
                  ),
                  _buildAnalyticsCard(
                    'Total Notifications',
                    _analytics['totalNotifications']?.toString() ?? '0',
                    LucideIcons.bell,
                    colors,
                  ),
                  _buildAnalyticsCard(
                    'Average Response Time',
                    '${(_analytics['averageResponseTime'] ?? 0).toStringAsFixed(1)} min',
                    LucideIcons.timer,
                    colors,
                  ),
                  _buildAnalyticsCard(
                    'Completion Rate',
                    '${((_analytics['completionRate'] ?? 0) * 100).toStringAsFixed(1)}%',
                    LucideIcons.target,
                    colors,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTab(NeumorphicColors colors) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notification Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors.textColor,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildSettingCard(
                    'Smart Timing',
                    'AI-powered optimal notification timing',
                    true,
                    colors,
                    (value) => _updateSetting('smart_timing', value),
                  ),
                  _buildSettingCard(
                    'Contextual Messages',
                    'Weather, location, and time-based notifications',
                    true,
                    colors,
                    (value) => _updateSetting('contextual', value),
                  ),
                  _buildSettingCard(
                    'Celebration Notifications',
                    'Achievement and milestone celebrations',
                    true,
                    colors,
                    (value) => _updateSetting('celebrations', value),
                  ),
                  _buildSettingCard(
                    'Social Notifications',
                    'Friend activities and challenges',
                    true,
                    colors,
                    (value) => _updateSetting('social', value),
                  ),
                  _buildSettingCard(
                    'Weekly Summaries',
                    'Weekly progress and insights',
                    true,
                    colors,
                    (value) => _updateSetting('weekly_summary', value),
                  ),
                  _buildSettingCard(
                    'Streak Recovery',
                    'Notifications to help recover broken streaks',
                    true,
                    colors,
                    (value) => _updateSetting('streak_recovery', value),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestTab(NeumorphicColors colors) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Test Notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors.textColor,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildTestButton(
                    'Test Smart Reminder',
                    'Send a test smart reminder notification',
                    LucideIcons.bell,
                    colors,
                    () => _testSmartReminder(),
                  ),
                  _buildTestButton(
                    'Test Celebration',
                    'Send a test achievement celebration',
                    LucideIcons.trophy,
                    colors,
                    () => _testCelebration(),
                  ),
                  _buildTestButton(
                    'Test Weather Notification',
                    'Send a test weather-based notification',
                    LucideIcons.cloud,
                    colors,
                    () => _testWeatherNotification(),
                  ),
                  _buildTestButton(
                    'Test Social Notification',
                    'Send a test social notification',
                    LucideIcons.users,
                    colors,
                    () => _testSocialNotification(),
                  ),
                  _buildTestButton(
                    'Test Batch Notifications',
                    'Send multiple test notifications',
                    LucideIcons.layers,
                    colors,
                    () => _testBatchNotifications(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(PendingNotificationRequest notification, NeumorphicColors colors) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: NeumorphicBox(
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
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title ?? 'No Title',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colors.textColor,
                        ),
                      ),
                      Text(
                        notification.body ?? 'No Body',
                        style: TextStyle(
                          fontSize: 14,
                          color: colors.textColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(LucideIcons.moreVertical, color: colors.textColor),
                  onSelected: (value) => _handleNotificationAction(value, notification),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'cancel',
                      child: Text('Cancel'),
                    ),
                    const PopupMenuItem(
                      value: 'snooze',
                      child: Text('Snooze 1h'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'ID: ${notification.id}',
              style: TextStyle(
                fontSize: 12,
                color: colors.textColor.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsCard(String title, String value, IconData icon, NeumorphicColors colors) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: NeumorphicBox(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colors.textColor,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard(String title, String description, bool value, NeumorphicColors colors, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: NeumorphicBox(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colors.textColor,
                    ),
                  ),
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
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestButton(String title, String description, IconData icon, NeumorphicColors colors, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: NeumorphicBox(
        padding: const EdgeInsets.all(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colors.textColor,
                      ),
                    ),
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
                LucideIcons.chevronRight,
                color: colors.textColor.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String message, IconData icon, NeumorphicColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: colors.textColor.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: colors.textColor.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _handleNotificationAction(String action, PendingNotificationRequest notification) {
    switch (action) {
      case 'cancel':
        SmartNotificationService.instance.cancelNotification(notification.id);
        _loadData();
        break;
      case 'snooze':
        SmartNotificationService.instance.scheduleSmartSnooze(
          habitId: 'test',
          snoozeMinutes: 60,
        );
        _loadData();
        break;
    }
  }

  void _clearAllNotifications() async {
    await SmartNotificationService.instance.cancelAllNotifications();
    _loadData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All notifications cleared')),
      );
    }
  }

  void _updateSetting(String setting, bool value) {
    // Implement setting updates
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$setting updated to $value')),
      );
    }
  }

  void _testSmartReminder() async {
    final habits = HabitService.instance.habits;
    if (habits.isNotEmpty) {
      await SmartNotificationService.instance.scheduleSmartReminder(
        habit: habits.first,
        recentMoods: [],
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Test smart reminder scheduled')),
        );
      }
    }
  }

  void _testCelebration() async {
    await SmartNotificationService.instance.scheduleAchievementNotification(
      title: 'Achievement Unlocked! 🎉',
      body: 'You\'ve completed 7 days in a row!',
      achievementType: 'streak',
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Test celebration notification sent')),
      );
    }
  }

  void _testWeatherNotification() async {
    final habits = HabitService.instance.habits;
    if (habits.isNotEmpty) {
      await SmartNotificationService.instance.scheduleWeatherBasedNotification(
        habit: habits.first,
        weatherCondition: 'sunny',
        temperature: 25.0,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Test weather notification sent')),
        );
      }
    }
  }

  void _testSocialNotification() async {
    await SmartNotificationService.instance.scheduleSocialNotification(
      title: 'Friend Activity',
      body: 'Your friend just completed their morning workout!',
      scheduledTime: DateTime.now().add(const Duration(seconds: 2)),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Test social notification sent')),
      );
    }
  }

  void _testBatchNotifications() async {
    final notifications = [
      {
        'habitId': 'test1',
        'title': 'Batch Test 1',
        'body': 'First test notification',
        'scheduledTime': DateTime.now().add(const Duration(seconds: 1)),
      },
      {
        'habitId': 'test2',
        'title': 'Batch Test 2',
        'body': 'Second test notification',
        'scheduledTime': DateTime.now().add(const Duration(seconds: 3)),
      },
      {
        'habitId': 'test3',
        'title': 'Batch Test 3',
        'body': 'Third test notification',
        'scheduledTime': DateTime.now().add(const Duration(seconds: 5)),
      },
    ];

    await SmartNotificationService.instance.scheduleBatchNotifications(
      notifications: notifications,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Batch test notifications sent')),
      );
    }
  }
}
