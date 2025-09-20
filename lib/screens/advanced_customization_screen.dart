import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../widgets/neumorphic_box.dart';
import '../widgets/neumorphic_colors.dart';
import '../widgets/micro_interactions.dart';
import '../services/haptic_service.dart';
import '../services/voice_service.dart';

class AdvancedCustomizationScreen extends StatefulWidget {
  const AdvancedCustomizationScreen({super.key});

  @override
  State<AdvancedCustomizationScreen> createState() => _AdvancedCustomizationScreenState();
}

class _AdvancedCustomizationScreenState extends State<AdvancedCustomizationScreen> {
  // Theme Customization
  bool _isDarkMode = true;
  double _primaryColorHue = 120.0; // Green
  double _accentColorHue = 200.0; // Blue
  double _backgroundOpacity = 0.9;
  
  // Animation Settings
  bool _enableAnimations = true;
  double _animationSpeed = 1.0;
  bool _enableHapticFeedback = true;
  bool _enableVoiceCommands = true;
  
  // UI Customization
  double _borderRadius = 20.0;
  double _cardElevation = 4.0;
  double _spacing = 16.0;
  bool _compactMode = false;
  
  // Notification Customization
  bool _enableNotifications = true;
  double _notificationVolume = 0.8;
  bool _enableCelebrationSounds = true;
  bool _enableStreakReminders = true;
  
  // Data & Privacy
  bool _enableAnalytics = true;
  bool _enableCrashReporting = true;
  bool _enablePersonalization = true;
  bool _enableDataSync = true;
  
  // Accessibility
  double _fontSize = 16.0;
  bool _highContrast = false;
  bool _reduceMotion = false;
  bool _screenReader = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<NeumorphicColors>()!;
    
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        title: Text(
          'Advanced Customization',
          style: TextStyle(color: colors.textColor),
        ),
        leading: MicroInteractions.animatedIcon(
          icon: LucideIcons.arrowLeft,
          context: context,
          onTap: () => Navigator.pop(context),
          hapticType: HapticType.light,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              'Theme & Appearance',
              LucideIcons.palette,
              colors,
              [
                _buildThemeToggle(colors),
                _buildColorPicker('Primary Color', _primaryColorHue, (value) {
                  setState(() => _primaryColorHue = value);
                }, colors),
                _buildColorPicker('Accent Color', _accentColorHue, (value) {
                  setState(() => _accentColorHue = value);
                }, colors),
                _buildSliderSetting(
                  'Background Opacity',
                  _backgroundOpacity,
                  0.1,
                  1.0,
                  (value) => setState(() => _backgroundOpacity = value),
                  colors,
                ),
                _buildSliderSetting(
                  'Border Radius',
                  _borderRadius,
                  5.0,
                  30.0,
                  (value) => setState(() => _borderRadius = value),
                  colors,
                ),
                _buildSliderSetting(
                  'Card Elevation',
                  _cardElevation,
                  0.0,
                  10.0,
                  (value) => setState(() => _cardElevation = value),
                  colors,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            _buildSection(
              'Animations & Interactions',
              LucideIcons.zap,
              colors,
              [
                _buildSwitchSetting(
                  'Enable Animations',
                  _enableAnimations,
                  (value) => setState(() => _enableAnimations = value),
                  colors,
                ),
                _buildSliderSetting(
                  'Animation Speed',
                  _animationSpeed,
                  0.5,
                  2.0,
                  (value) => setState(() => _animationSpeed = value),
                  colors,
                ),
                _buildSwitchSetting(
                  'Haptic Feedback',
                  _enableHapticFeedback,
                  (value) {
                    setState(() => _enableHapticFeedback = value);
                    HapticService.instance.setEnabled(value);
                  },
                  colors,
                ),
                _buildSwitchSetting(
                  'Voice Commands',
                  _enableVoiceCommands,
                  (value) {
                    setState(() => _enableVoiceCommands = value);
                    VoiceService.instance.setEnabled(value);
                  },
                  colors,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            _buildSection(
              'Layout & Spacing',
              LucideIcons.layout,
              colors,
              [
                _buildSliderSetting(
                  'Spacing',
                  _spacing,
                  8.0,
                  32.0,
                  (value) => setState(() => _spacing = value),
                  colors,
                ),
                _buildSwitchSetting(
                  'Compact Mode',
                  _compactMode,
                  (value) => setState(() => _compactMode = value),
                  colors,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            _buildSection(
              'Notifications & Sounds',
              LucideIcons.bell,
              colors,
              [
                _buildSwitchSetting(
                  'Enable Notifications',
                  _enableNotifications,
                  (value) => setState(() => _enableNotifications = value),
                  colors,
                ),
                _buildSliderSetting(
                  'Notification Volume',
                  _notificationVolume,
                  0.0,
                  1.0,
                  (value) => setState(() => _notificationVolume = value),
                  colors,
                ),
                _buildSwitchSetting(
                  'Celebration Sounds',
                  _enableCelebrationSounds,
                  (value) => setState(() => _enableCelebrationSounds = value),
                  colors,
                ),
                _buildSwitchSetting(
                  'Streak Reminders',
                  _enableStreakReminders,
                  (value) => setState(() => _enableStreakReminders = value),
                  colors,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            _buildSection(
              'Data & Privacy',
              LucideIcons.shield,
              colors,
              [
                _buildSwitchSetting(
                  'Analytics',
                  _enableAnalytics,
                  (value) => setState(() => _enableAnalytics = value),
                  colors,
                ),
                _buildSwitchSetting(
                  'Crash Reporting',
                  _enableCrashReporting,
                  (value) => setState(() => _enableCrashReporting = value),
                  colors,
                ),
                _buildSwitchSetting(
                  'Personalization',
                  _enablePersonalization,
                  (value) => setState(() => _enablePersonalization = value),
                  colors,
                ),
                _buildSwitchSetting(
                  'Data Sync',
                  _enableDataSync,
                  (value) => setState(() => _enableDataSync = value),
                  colors,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            _buildSection(
              'Accessibility',
              LucideIcons.accessibility,
              colors,
              [
                _buildSliderSetting(
                  'Font Size',
                  _fontSize,
                  12.0,
                  24.0,
                  (value) => setState(() => _fontSize = value),
                  colors,
                ),
                _buildSwitchSetting(
                  'High Contrast',
                  _highContrast,
                  (value) => setState(() => _highContrast = value),
                  colors,
                ),
                _buildSwitchSetting(
                  'Reduce Motion',
                  _reduceMotion,
                  (value) => setState(() => _reduceMotion = value),
                  colors,
                ),
                _buildSwitchSetting(
                  'Screen Reader',
                  _screenReader,
                  (value) => setState(() => _screenReader = value),
                  colors,
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            _buildActionButtons(colors),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, NeumorphicColors colors, List<Widget> children) {
    return NeumorphicBox(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: colors.textColor, size: 20),
              const SizedBox(width: 12),
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
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildThemeToggle(NeumorphicColors colors) {
    return MicroInteractions.animatedCard(
      context: context,
      onTap: () {
        setState(() => _isDarkMode = !_isDarkMode);
        HapticService.instance.selection();
      },
      hapticType: HapticType.selection,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  _isDarkMode ? LucideIcons.moon : LucideIcons.sun,
                  color: colors.textColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'Dark Mode',
                  style: TextStyle(
                    fontSize: 16,
                    color: colors.textColor,
                  ),
                ),
              ],
            ),
            MicroInteractions.animatedSwitch(
              value: _isDarkMode,
              onChanged: (value) {
                setState(() => _isDarkMode = value);
                HapticService.instance.selection();
              },
              context: context,
              hapticType: HapticType.selection,
              activeColor: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPicker(String label, double hue, ValueChanged<double> onChanged, NeumorphicColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: colors.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: HSVColor.fromAHSV(1.0, hue, 0.7, 0.8).toColor(),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colors.textColor.withOpacity(0.3)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Slider(
                  value: hue,
                  min: 0,
                  max: 360,
                  divisions: 36,
                  activeColor: HSVColor.fromAHSV(1.0, hue, 0.7, 0.8).toColor(),
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSliderSetting(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
    NeumorphicColors colors,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  color: colors.textColor,
                ),
              ),
              Text(
                value.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 14,
                  color: colors.textColor.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: ((max - min) * 10).round(),
            activeColor: Theme.of(context).primaryColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchSetting(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
    NeumorphicColors colors,
  ) {
    return MicroInteractions.animatedCard(
      context: context,
      onTap: () {
        onChanged(!value);
        HapticService.instance.selection();
      },
      hapticType: HapticType.selection,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: colors.textColor,
              ),
            ),
            MicroInteractions.animatedSwitch(
              value: value,
              onChanged: onChanged,
              context: context,
              hapticType: HapticType.selection,
              activeColor: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(NeumorphicColors colors) {
    return Row(
      children: [
        Expanded(
          child: MicroInteractions.animatedButton(
            context: context,
            onPressed: () {
              HapticService.instance.success();
              _showResetDialog();
            },
            hapticType: HapticType.medium,
            child: NeumorphicBox(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.rotateCcw, color: colors.textColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Reset to Default',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colors.textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: MicroInteractions.animatedButton(
            context: context,
            onPressed: () {
              HapticService.instance.success();
              _saveSettings();
            },
            hapticType: HapticType.success,
            child: NeumorphicBox(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.save, color: colors.textColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Save Settings',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colors.textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text('Are you sure you want to reset all settings to their default values?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetToDefaults();
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _resetToDefaults() {
    setState(() {
      _isDarkMode = true;
      _primaryColorHue = 120.0;
      _accentColorHue = 200.0;
      _backgroundOpacity = 0.9;
      _enableAnimations = true;
      _animationSpeed = 1.0;
      _enableHapticFeedback = true;
      _enableVoiceCommands = true;
      _borderRadius = 20.0;
      _cardElevation = 4.0;
      _spacing = 16.0;
      _compactMode = false;
      _enableNotifications = true;
      _notificationVolume = 0.8;
      _enableCelebrationSounds = true;
      _enableStreakReminders = true;
      _enableAnalytics = true;
      _enableCrashReporting = true;
      _enablePersonalization = true;
      _enableDataSync = true;
      _fontSize = 16.0;
      _highContrast = false;
      _reduceMotion = false;
      _screenReader = false;
    });
    
    HapticService.instance.success();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings reset to defaults')),
    );
  }

  void _saveSettings() {
    // TODO: Implement settings persistence
    HapticService.instance.success();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved successfully')),
    );
  }
}
