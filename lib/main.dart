import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'models/habit.dart';
import 'services/habit_service.dart';
import 'services/notification_service.dart';
import 'services/achievement_service.dart';
import 'services/mood_service.dart';
import 'services/social_service.dart';
import 'services/challenge_service.dart';
import 'services/smart_notification_service.dart';
import 'services/supabase_service.dart';
import 'services/fastapi_service.dart';
import 'services/voice_service.dart';
import 'config/env_config.dart';
import 'screens/add_habit_screen.dart';
import 'screens/edit_habit_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/reminder_management_screen.dart';
import 'screens/advanced_settings_screen.dart';
import 'screens/user_profile_screen.dart';
import 'screens/challenges_screen.dart';
import 'screens/social_feed_screen.dart';
import 'screens/celebration_notification_screen.dart';
import 'screens/notification_management_screen.dart';
import 'screens/mood_tracking_screen.dart';
import 'screens/gamification_screen.dart';
import 'screens/advanced_customization_screen.dart';
import 'screens/bulk_operations_screen.dart';
import 'screens/friends_screen.dart';
import 'widgets/habit_card.dart';
import 'widgets/habit_templates.dart';
import 'widgets/neumorphic_box.dart';
import 'widgets/neumorphic_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize environment configuration
  await EnvConfig.initialize();
  
  // Initialize local services
  await HabitService.instance.loadHabits();
  await AchievementService.instance.initialize();
  await MoodService.instance.initialize();
  await SocialService.instance.initialize();
  await ChallengeService.instance.initialize();
  
  // Initialize platform-specific services
  if (!kIsWeb) {
    // Mobile/Desktop specific services
    try {
      await NotificationService().initialize();
      await SmartNotificationService.instance.initialize();
      print('Mobile services initialized successfully');
    } catch (e) {
      print('Mobile services initialization failed: $e');
    }
    
    // Initialize haptic and voice services (not available on web)
    try {
      await VoiceService.instance.initialize();
      print('Voice service initialized successfully');
    } catch (e) {
      print('Voice service initialization failed: $e');
    }
  } else {
    print('Running on web - skipping mobile-specific services');
  }
  
  // Initialize backend services
  try {
    await SupabaseService.instance.initialize();
    await FastApiService.instance.initialize();
    print('Backend services initialized successfully');
  } catch (e) {
    print('Backend services initialization failed: $e');
    print('App will continue with local-only mode');
  }
  
  runApp(const HabitTrackerApp());
}

// -------------------- APP ROOT --------------------
class HabitTrackerApp extends StatefulWidget {
  const HabitTrackerApp({super.key});

  @override
  State<HabitTrackerApp> createState() => _HabitTrackerAppState();
}

class _HabitTrackerAppState extends State<HabitTrackerApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Tracker',
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,
      // Web-specific optimizations
      builder: (context, child) {
        return MediaQuery(
          // Ensure text doesn't scale beyond reasonable limits on web
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.of(context).textScaler.scale(1.0).clamp(0.8, 1.2),
            ),
          ),
          child: child!,
        );
      },
      home: HomePage(onToggleTheme: _toggleTheme),
    );
  }
}

// -------------------- THEMES --------------------
class AppThemes {
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF2E2E2E),
    fontFamily: 'sans-serif',
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.greenAccent,
      brightness: Brightness.dark,
      primary: Colors.greenAccent,
    ),
    extensions: const <ThemeExtension<dynamic>>[
      NeumorphicColors(
        background: Color(0xFF2E2E2E),
        shadowDark: Color(0xFF1C1C1C),
        shadowLight: Color(0xFF4A4A4A),
        textColor: Colors.white70,
      )
    ],
  );

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFE0E0E0),
    fontFamily: 'sans-serif',
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.green,
      brightness: Brightness.light,
      primary: Colors.green,
    ),
    extensions: const <ThemeExtension<dynamic>>[
      NeumorphicColors(
        background: Color(0xFFE0E0E0),
        shadowDark: Color(0xFFA3A3A3),
        shadowLight: Color(0xFFFFFFFF),
        textColor: Colors.black87,
      )
    ],
  );
}



// -------------------- HOME PAGE --------------------
class HomePage extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const HomePage({super.key, required this.onToggleTheme});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  void _loadHabits() async {
    await HabitService.instance.loadHabits();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<NeumorphicColors>()!;
    final habits = HabitService.instance.activeHabits;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Responsive design: Different layouts for different screen sizes
            final isDesktop = constraints.maxWidth > 1200;
            final isTablet = constraints.maxWidth > 768 && constraints.maxWidth <= 1200;
            
            // Adjust padding based on screen size
            final horizontalPadding = isDesktop ? 32.0 : (isTablet ? 24.0 : 16.0);
            final verticalPadding = isDesktop ? 24.0 : 16.0;
            
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: Column(
                children: [
                  _buildHeader(colors, isDesktop, isTablet),
                  SizedBox(height: isDesktop ? 32.0 : 20.0),
                  _buildStats(colors, isDesktop),
                  SizedBox(height: isDesktop ? 32.0 : 20.0),
                  Expanded(
                    child: habits.isEmpty
                        ? _buildEmptyState(colors, isDesktop)
                        : _buildHabitsList(habits, isDesktop, isTablet),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addHabit,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(LucideIcons.plus, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader(NeumorphicColors colors, bool isDesktop, bool isTablet) {
    // Responsive header layout
    if (isDesktop) {
      return _buildDesktopHeader(colors);
    } else if (isTablet) {
      return _buildTabletHeader(colors);
    } else {
      return _buildMobileHeader(colors);
    }
  }

  Widget _buildDesktopHeader(NeumorphicColors colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Good morning!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: colors.textColor,
                )),
            Text('Ready to build something amazing today? ✨',
                style: TextStyle(
                  fontSize: 16,
                  color: colors.textColor,
                )),
          ],
        ),
        _buildActionButtons(colors, isDesktop: true),
      ],
    );
  }

  Widget _buildTabletHeader(NeumorphicColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Good morning!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colors.textColor,
                    )),
                Text('Ready to build something amazing today? ✨',
                    style: TextStyle(color: colors.textColor)),
              ],
            ),
            GestureDetector(
              onTap: widget.onToggleTheme,
              child: NeumorphicBox(
                padding: const EdgeInsets.all(12),
                child: Icon(LucideIcons.sun, size: 20, color: colors.textColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildActionButtons(colors, isTablet: true),
      ],
    );
  }

  Widget _buildMobileHeader(NeumorphicColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Good morning!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colors.textColor,
                      )),
                  Text('Ready to build something amazing today? ✨',
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.textColor,
                      )),
                ],
              ),
            ),
            GestureDetector(
              onTap: widget.onToggleTheme,
              child: NeumorphicBox(
                padding: const EdgeInsets.all(10),
                child: Icon(LucideIcons.sun, size: 18, color: colors.textColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildActionButtons(colors, isMobile: true),
      ],
    );
  }

  Widget _buildActionButtons(NeumorphicColors colors, {bool isDesktop = false, bool isTablet = false, bool isMobile = false}) {
    final buttonSize = isDesktop ? 16.0 : (isTablet ? 14.0 : 12.0);
    final iconSize = isDesktop ? 20.0 : (isTablet ? 18.0 : 16.0);
    final spacing = isDesktop ? 16.0 : (isTablet ? 12.0 : 8.0);
    
    // Define all action buttons
    final actions = [
      {'icon': LucideIcons.heart, 'action': _openMoodTracking, 'tooltip': 'Mood Tracking'},
      {'icon': LucideIcons.trophy, 'action': _openGamification, 'tooltip': 'Gamification'},
      {'icon': LucideIcons.users, 'action': _openFriends, 'tooltip': 'Friends'},
      {'icon': LucideIcons.target, 'action': _openChallenges, 'tooltip': 'Challenges'},
      {'icon': LucideIcons.messageSquare, 'action': _openSocialFeed, 'tooltip': 'Social Feed'},
      {'icon': LucideIcons.bell, 'action': _openReminderManagement, 'tooltip': 'Reminders'},
      {'icon': LucideIcons.settings, 'action': _openNotificationManagement, 'tooltip': 'Notifications'},
      {'icon': LucideIcons.partyPopper, 'action': _openCelebrationCenter, 'tooltip': 'Celebrations'},
      {'icon': LucideIcons.barChart3, 'action': _openAnalytics, 'tooltip': 'Analytics'},
      {'icon': LucideIcons.settings, 'action': _openAdvancedSettings, 'tooltip': 'Settings'},
      {'icon': LucideIcons.user, 'action': _openUserProfile, 'tooltip': 'Profile'},
      {'icon': LucideIcons.palette, 'action': _openAdvancedCustomization, 'tooltip': 'Customization'},
      {'icon': LucideIcons.layers, 'action': _openBulkOperations, 'tooltip': 'Bulk Operations'},
    ];

    if (isMobile) {
      // On mobile, show buttons in a scrollable row
      return SizedBox(
        height: 50,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return Padding(
              padding: EdgeInsets.only(right: spacing),
              child: GestureDetector(
                onTap: action['action'] as VoidCallback,
                child: NeumorphicBox(
                  padding: EdgeInsets.all(buttonSize),
                  child: Icon(
                    action['icon'] as IconData,
                    size: iconSize,
                    color: colors.textColor,
                  ),
                ),
              ),
            );
          },
        ),
      );
    } else {
      // On desktop/tablet, show all buttons in a row
      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: actions.map((action) {
          return GestureDetector(
            onTap: action['action'] as VoidCallback,
            child: NeumorphicBox(
              padding: EdgeInsets.all(buttonSize),
              child: Icon(
                action['icon'] as IconData,
                size: iconSize,
                color: colors.textColor,
              ),
            ),
          );
        }).toList(),
      );
    }
  }

  Widget _buildStats(NeumorphicColors colors, bool isDesktop) {
    final service = HabitService.instance;
    final completedToday = service.completedTodayCount;
    final totalHabits = service.totalActiveHabits;
    
    final todayMood = MoodService.instance.getTodayMood();
    final userProgress = AchievementService.instance.userProgress;

    return NeumorphicBox(
      padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Completed',
            '$completedToday/$totalHabits',
            LucideIcons.checkCircle,
            colors,
            isDesktop,
          ),
          _buildStatItem(
            'Level',
            '${userProgress.currentLevel}',
            LucideIcons.trophy,
            colors,
            isDesktop,
          ),
          _buildStatItem(
            'Mood',
            todayMood?.emoji ?? '😐',
            LucideIcons.heart,
            colors,
            isDesktop,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, NeumorphicColors colors, bool isDesktop) {
    final iconSize = isDesktop ? 28.0 : 24.0;
    final valueFontSize = isDesktop ? 20.0 : 18.0;
    final labelFontSize = isDesktop ? 14.0 : 12.0;
    
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: iconSize),
        SizedBox(height: isDesktop ? 8.0 : 4.0),
        Text(
          value,
          style: TextStyle(
            fontSize: valueFontSize,
            fontWeight: FontWeight.bold,
            color: colors.textColor,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: labelFontSize,
            color: colors.textColor.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildHabitsList(List<Habit> habits, bool isDesktop, bool isTablet) {
    if (isDesktop) {
      // Desktop: Show habits in a grid layout
      return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
        ),
        itemCount: habits.length,
        itemBuilder: (context, index) {
          final habit = habits[index];
          return HabitCard(
            habit: habit,
            onEdit: () => _editHabit(habit),
            onDelete: () => _deleteHabit(habit),
          );
        },
      );
    } else if (isTablet) {
      // Tablet: Show habits in a single column with larger spacing
      return ListView.builder(
        itemCount: habits.length,
        itemBuilder: (context, index) {
          final habit = habits[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: HabitCard(
              habit: habit,
              onEdit: () => _editHabit(habit),
              onDelete: () => _deleteHabit(habit),
            ),
          );
        },
      );
    } else {
      // Mobile: Show habits in a single column with standard spacing
      return ListView.builder(
        itemCount: habits.length,
        itemBuilder: (context, index) {
          final habit = habits[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: HabitCard(
              habit: habit,
              onEdit: () => _editHabit(habit),
              onDelete: () => _deleteHabit(habit),
            ),
          );
        },
      );
    }
  }

  Widget _buildEmptyState(NeumorphicColors colors, bool isDesktop) {
    final iconSize = isDesktop ? 80.0 : 64.0;
    final titleFontSize = isDesktop ? 28.0 : 24.0;
    final subtitleFontSize = isDesktop ? 18.0 : 16.0;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.target,
            size: iconSize,
            color: colors.textColor.withValues(alpha: 0.5),
          ),
          SizedBox(height: isDesktop ? 24.0 : 16.0),
          Text(
            'No habits yet',
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
              color: colors.textColor,
            ),
          ),
          SizedBox(height: isDesktop ? 12.0 : 8.0),
          Text(
            'Tap the + button to create your first habit',
            style: TextStyle(
              fontSize: subtitleFontSize,
              color: colors.textColor.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isDesktop ? 32.0 : 20.0),
          HabitTemplates(onHabitCreated: _loadHabits),
        ],
      ),
    );
  }

  void _addHabit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddHabitScreen()),
    );
    
    if (result == true) {
      _loadHabits();
    }
  }

  void _editHabit(Habit habit) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditHabitScreen(habit: habit),
      ),
    );
    
    if (result == true) {
      _loadHabits();
    }
  }

  void _openAnalytics() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AnalyticsScreen(),
      ),
    );
  }

  void _openReminderManagement() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ReminderManagementScreen(),
      ),
    );
  }

  void _openAdvancedSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdvancedSettingsScreen(),
      ),
    );
  }

  void _openMoodTracking() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MoodTrackingScreen(),
      ),
    );
  }

  void _openGamification() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GamificationScreen(),
      ),
    );
  }

  void _openFriends() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FriendsScreen(),
      ),
    );
  }

  void _openUserProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UserProfileScreen(),
      ),
    );
  }

  void _openChallenges() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChallengesScreen(),
      ),
    );
  }

  void _openSocialFeed() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SocialFeedScreen(),
      ),
    );
  }

  void _openNotificationManagement() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificationManagementScreen(),
      ),
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

  void _openAdvancedCustomization() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdvancedCustomizationScreen(),
      ),
    );
  }

  void _openBulkOperations() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BulkOperationsScreen(),
      ),
    );
  }

  void _deleteHabit(Habit habit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit'),
        content: Text('Are you sure you want to delete "${habit.name}"?'),
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
      await HabitService.instance.deleteHabit(habit.id);
      _loadHabits();
    }
  }
}