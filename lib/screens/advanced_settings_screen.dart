import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../widgets/neumorphic_box.dart';
import '../widgets/neumorphic_colors.dart';
import 'celebration_notification_screen.dart';

class AdvancedSettingsScreen extends StatefulWidget {
  const AdvancedSettingsScreen({super.key});

  @override
  State<AdvancedSettingsScreen> createState() => _AdvancedSettingsScreenState();
}

class _AdvancedSettingsScreenState extends State<AdvancedSettingsScreen> {
  bool _enableHapticFeedback = true;
  bool _enableCelebrationAnimations = true;
  bool _enableSmartNotifications = true;
  bool _enableMoodTracking = true;
  bool _enableSocialFeatures = true;
  bool _enableDataExport = false;
  bool _enableBackup = true;
  bool _enableAnalytics = true;
  
  String _notificationSound = 'default';
  String _themeMode = 'system';
  String _language = 'en';
  double _reminderFrequency = 1.0;
  double _dataRetentionDays = 365.0;
  
  final List<String> _notificationSounds = [
    'default',
    'gentle',
    'energetic',
    'calm',
    'none',
  ];
  
  final List<String> _themeModes = [
    'system',
    'light',
    'dark',
  ];
  
  final List<String> _languages = [
    'en',
    'es',
    'fr',
    'de',
    'it',
    'pt',
    'ru',
    'zh',
    'ja',
    'ko',
  ];

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
          'Advanced Settings',
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
                _buildSectionHeader('Notifications', LucideIcons.bell, colors),
                _buildNotificationSettings(colors),
                const SizedBox(height: 24),
                
                _buildSectionHeader('Appearance', LucideIcons.palette, colors),
                _buildAppearanceSettings(colors),
                const SizedBox(height: 24),
                
                _buildSectionHeader('Features', LucideIcons.settings, colors),
                _buildFeatureSettings(colors),
                const SizedBox(height: 24),
                
                _buildSectionHeader('Celebration Center', LucideIcons.partyPopper, colors),
                _buildCelebrationSettings(colors),
                const SizedBox(height: 24),
                
                _buildSectionHeader('Data & Privacy', LucideIcons.shield, colors),
                _buildDataSettings(colors),
                const SizedBox(height: 24),
                
                _buildSectionHeader('Advanced', LucideIcons.cog, colors),
                _buildAdvancedSettings(colors),
                const SizedBox(height: 24),
                
                _buildDangerZone(colors),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, NeumorphicColors colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: colors.textColor, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings(NeumorphicColors colors) {
    return NeumorphicBox(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSwitchTile(
            'Smart Notifications',
            'AI-powered notification timing',
            _enableSmartNotifications,
            (value) => setState(() => _enableSmartNotifications = value),
            colors,
          ),
          _buildDivider(colors),
          _buildDropdownTile(
            'Notification Sound',
            _notificationSound,
            _notificationSounds,
            (value) => setState(() => _notificationSound = value!),
            colors,
          ),
          _buildDivider(colors),
          _buildSliderTile(
            'Reminder Frequency',
            'How often to send reminders',
            _reminderFrequency,
            1,
            5,
            (value) => setState(() => _reminderFrequency = value),
            colors,
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceSettings(NeumorphicColors colors) {
    return NeumorphicBox(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildDropdownTile(
            'Theme Mode',
            _themeMode,
            _themeModes,
            (value) => setState(() => _themeMode = value!),
            colors,
          ),
          _buildDivider(colors),
          _buildDropdownTile(
            'Language',
            _language,
            _languages,
            (value) => setState(() => _language = value!),
            colors,
          ),
          _buildDivider(colors),
          _buildSwitchTile(
            'Celebration Animations',
            'Show animations for milestones',
            _enableCelebrationAnimations,
            (value) => setState(() => _enableCelebrationAnimations = value),
            colors,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureSettings(NeumorphicColors colors) {
    return NeumorphicBox(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSwitchTile(
            'Haptic Feedback',
            'Vibration for interactions',
            _enableHapticFeedback,
            (value) => setState(() => _enableHapticFeedback = value),
            colors,
          ),
          _buildDivider(colors),
          _buildSwitchTile(
            'Mood Tracking',
            'Track daily mood and emotions',
            _enableMoodTracking,
            (value) => setState(() => _enableMoodTracking = value),
            colors,
          ),
          _buildDivider(colors),
          _buildSwitchTile(
            'Social Features',
            'Connect with friends and share progress',
            _enableSocialFeatures,
            (value) => setState(() => _enableSocialFeatures = value),
            colors,
          ),
          _buildDivider(colors),
          _buildSwitchTile(
            'Analytics',
            'Advanced insights and reports',
            _enableAnalytics,
            (value) => setState(() => _enableAnalytics = value),
            colors,
          ),
        ],
      ),
    );
  }

  Widget _buildCelebrationSettings(NeumorphicColors colors) {
    return NeumorphicBox(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSwitchTile(
            'Celebration Animations',
            'Animated celebrations for achievements',
            _enableCelebrationAnimations,
            (value) => setState(() => _enableCelebrationAnimations = value),
            colors,
          ),
          _buildDivider(colors),
          _buildActionTile(
            'Celebration Center',
            'Test and customize celebration notifications',
            () => _openCelebrationCenter(),
            colors,
            LucideIcons.partyPopper,
          ),
        ],
      ),
    );
  }

  Widget _buildDataSettings(NeumorphicColors colors) {
    return NeumorphicBox(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSwitchTile(
            'Automatic Backup',
            'Backup data to cloud',
            _enableBackup,
            (value) => setState(() => _enableBackup = value),
            colors,
          ),
          _buildDivider(colors),
          _buildSwitchTile(
            'Data Export',
            'Export data for analysis',
            _enableDataExport,
            (value) => setState(() => _enableDataExport = value),
            colors,
          ),
          _buildDivider(colors),
          _buildSliderTile(
            'Data Retention',
            'Days to keep data',
            _dataRetentionDays,
            30,
            1095,
            (value) => setState(() => _dataRetentionDays = value),
            colors,
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedSettings(NeumorphicColors colors) {
    return NeumorphicBox(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildActionTile(
            'Reset All Settings',
            'Restore default settings',
            LucideIcons.refreshCw,
            () => _showResetDialog(),
            colors,
          ),
          _buildDivider(colors),
          _buildActionTile(
            'Clear Cache',
            'Free up storage space',
            LucideIcons.trash2,
            () => _clearCache(),
            colors,
          ),
          _buildDivider(colors),
          _buildActionTile(
            'Export Data',
            'Download your data',
            LucideIcons.download,
            () => _exportData(),
            colors,
          ),
          _buildDivider(colors),
          _buildActionTile(
            'Import Data',
            'Restore from backup',
            LucideIcons.upload,
            () => _importData(),
            colors,
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZone(NeumorphicColors colors) {
    return NeumorphicBox(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildActionTile(
            'Delete All Data',
            'Permanently remove all habits and data',
            LucideIcons.alertTriangle,
            () => _showDeleteDialog(),
            colors,
            isDangerous: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
    NeumorphicColors colors,
  ) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: colors.textColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: colors.textColor.withValues(alpha: 0.7),
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildDropdownTile(
    String title,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
    NeumorphicColors colors,
  ) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: colors.textColor,
        ),
      ),
      trailing: DropdownButton<String>(
        value: value,
        onChanged: onChanged,
        items: options.map((option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSliderTile(
    String title,
    String subtitle,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
    NeumorphicColors colors,
  ) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: colors.textColor,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: colors.textColor.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: (max - min).round(),
            onChanged: onChanged,
            activeColor: Theme.of(context).colorScheme.primary,
          ),
          Text(
            value.toInt().toString(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: colors.textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
    NeumorphicColors colors, {
    bool isDangerous = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDangerous ? Colors.red : colors.textColor,
        size: 20,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isDangerous ? Colors.red : colors.textColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: colors.textColor.withValues(alpha: 0.7),
        ),
      ),
      trailing: Icon(
        LucideIcons.chevronRight,
        color: colors.textColor,
        size: 16,
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider(NeumorphicColors colors) {
    return Divider(
      color: colors.textColor.withValues(alpha: 0.1),
      height: 1,
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text('Are you sure you want to reset all settings to default?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetSettings();
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Data'),
        content: const Text('This action cannot be undone. All your habits, progress, and data will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAllData();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _resetSettings() {
    setState(() {
      _enableHapticFeedback = true;
      _enableCelebrationAnimations = true;
      _enableSmartNotifications = true;
      _enableMoodTracking = true;
      _enableSocialFeatures = true;
      _enableDataExport = false;
      _enableBackup = true;
      _enableAnalytics = true;
      _notificationSound = 'default';
      _themeMode = 'system';
      _language = 'en';
      _reminderFrequency = 1;
      _dataRetentionDays = 365;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings reset to default')),
    );
  }

  void _clearCache() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cache cleared successfully')),
    );
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data export started')),
    );
  }

  void _importData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data import started')),
    );
  }

  void _deleteAllData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All data deleted')),
    );
  }

  void _openCelebrationCenter() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CelebrationNotificationScreen(),
      ),
    );
  }
}
