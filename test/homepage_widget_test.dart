import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:habit_tracker/main.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/widgets/habit_card.dart';
import 'package:habit_tracker/widgets/neumorphic_colors.dart';

void main() {
  group('HomePage Widget Tests', () {
    testWidgets('HomePage renders correctly with empty habits', (WidgetTester tester) async {
      await tester.pumpWidget(const HabitTrackerApp());

      // Verify the app loads with the greeting text
      expect(find.text('Good morning!'), findsOneWidget);
      expect(find.text('Ready to build something amazing today? ✨'), findsOneWidget);

      // Verify empty state is shown
      expect(find.text('No habits yet'), findsOneWidget);
      expect(find.text('Tap the + button to create your first habit'), findsOneWidget);
    });

    testWidgets('FloatingActionButton is present', (WidgetTester tester) async {
      await tester.pumpWidget(const HabitTrackerApp());

      // Verify FAB is present
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(LucideIcons.plus), findsOneWidget);
    });

    testWidgets('Theme toggle button is present', (WidgetTester tester) async {
      await tester.pumpWidget(const HabitTrackerApp());

      // Find theme toggle button (sun icon)
      final themeButton = find.byIcon(LucideIcons.sun);
      expect(themeButton, findsOneWidget);
    });

    testWidgets('Key action buttons are present', (WidgetTester tester) async {
      await tester.pumpWidget(const HabitTrackerApp());

      // Verify key action buttons are present (using findsAtLeastNWidgets to handle duplicates)
      expect(find.byIcon(LucideIcons.heart), findsAtLeastNWidgets(1)); // Mood tracking
      expect(find.byIcon(LucideIcons.trophy), findsAtLeastNWidgets(1)); // Gamification
      expect(find.byIcon(LucideIcons.users), findsAtLeastNWidgets(1)); // Friends
      expect(find.byIcon(LucideIcons.target), findsAtLeastNWidgets(1)); // Challenges
      expect(find.byIcon(LucideIcons.barChart3), findsAtLeastNWidgets(1)); // Analytics
    });
  });

  group('HabitCard Widget Tests', () {
    late Habit testHabit;

    setUp(() {
      testHabit = Habit(
        name: 'Test Habit',
        description: 'Test description',
        icon: '🧪',
        currentStreak: 5,
        goal: 7,
        priority: 2,
      );
    });

    testWidgets('HabitCard renders correctly with habit data', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: const [
              NeumorphicColors(
                background: Color(0xFF2E2E2E),
                shadowDark: Color(0xFF1C1C1C),
                shadowLight: Color(0xFF4A4A4A),
                textColor: Colors.white70,
              ),
            ],
          ),
          home: Scaffold(
            body: HabitCard(
              habit: testHabit,
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Verify habit data is displayed
      expect(find.text('Test Habit'), findsOneWidget);
      expect(find.text('5/7'), findsOneWidget); // Current streak/goal
      expect(find.text('71%'), findsOneWidget); // Progress percentage

      // Verify action buttons are present
      expect(find.byIcon(LucideIcons.edit), findsOneWidget);
      expect(find.byIcon(LucideIcons.trash2), findsOneWidget);
    });

    testWidgets('HabitCard handles zero streak correctly', (WidgetTester tester) async {
      // Create habit with zero streak
      final zeroStreakHabit = testHabit.copyWith(currentStreak: 0);
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: const [
              NeumorphicColors(
                background: Color(0xFF2E2E2E),
                shadowDark: Color(0xFF1C1C1C),
                shadowLight: Color(0xFF4A4A4A),
                textColor: Colors.white70,
              ),
            ],
          ),
          home: Scaffold(
            body: HabitCard(
              habit: zeroStreakHabit,
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Verify zero streak is displayed
      expect(find.text('0/7'), findsOneWidget);
      expect(find.text('0%'), findsOneWidget);
    });

    testWidgets('HabitCard handles completed goal correctly', (WidgetTester tester) async {
      // Create habit that has reached its goal
      final completedGoalHabit = testHabit.copyWith(
        currentStreak: 7,
        goal: 7,
      );
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: const [
              NeumorphicColors(
                background: Color(0xFF2E2E2E),
                shadowDark: Color(0xFF1C1C1C),
                shadowLight: Color(0xFF4A4A4A),
                textColor: Colors.white70,
              ),
            ],
          ),
          home: Scaffold(
            body: HabitCard(
              habit: completedGoalHabit,
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Verify completed goal is displayed
      expect(find.text('7/7'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
    });

    testWidgets('HabitCard edit and delete buttons work', (WidgetTester tester) async {
      bool editCalled = false;
      bool deleteCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: const [
              NeumorphicColors(
                background: Color(0xFF2E2E2E),
                shadowDark: Color(0xFF1C1C1C),
                shadowLight: Color(0xFF4A4A4A),
                textColor: Colors.white70,
              ),
            ],
          ),
          home: Scaffold(
            body: HabitCard(
              habit: testHabit,
              onEdit: () => editCalled = true,
              onDelete: () => deleteCalled = true,
            ),
          ),
        ),
      );

      // Tap edit button
      await tester.tap(find.byIcon(LucideIcons.edit));
      await tester.pumpAndSettle();
      expect(editCalled, isTrue);

      // Reset for delete test
      editCalled = false;

      // Tap delete button
      await tester.tap(find.byIcon(LucideIcons.trash2));
      await tester.pumpAndSettle();
      expect(deleteCalled, isTrue);
    });

    testWidgets('HabitCard shows completion status correctly', (WidgetTester tester) async {
      // Create a completed habit
      final completedHabit = testHabit.copyWith(
        completedDates: [DateTime.now()],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: const [
              NeumorphicColors(
                background: Color(0xFF2E2E2E),
                shadowDark: Color(0xFF1C1C1C),
                shadowLight: Color(0xFF4A4A4A),
                textColor: Colors.white70,
              ),
            ],
          ),
          home: Scaffold(
            body: HabitCard(
              habit: completedHabit,
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Verify completion status is shown
      expect(find.text('Test Habit'), findsOneWidget);
      expect(find.byIcon(LucideIcons.checkCircle), findsOneWidget);
    });
  });

  group('Habit Model Tests', () {
    test('Habit model creates correctly', () {
      final habit = Habit(
        name: 'Test Habit',
        description: 'Test description',
        icon: '🧪',
        currentStreak: 5,
        goal: 7,
      );

      expect(habit.name, equals('Test Habit'));
      expect(habit.description, equals('Test description'));
      expect(habit.icon, equals('🧪'));
      expect(habit.currentStreak, equals(5));
      expect(habit.goal, equals(7));
      expect(habit.id, isNotEmpty);
    });

    test('Habit progress percentage calculates correctly', () {
      final habit = Habit(
        name: 'Test Habit',
        description: 'Test description',
        icon: '🧪',
        currentStreak: 5,
        goal: 7,
      );

      expect(habit.progressPercentage, closeTo(5.0 / 7.0, 0.01));
    });

    test('Habit progress percentage clamps to 1.0', () {
      final habit = Habit(
        name: 'Test Habit',
        description: 'Test description',
        icon: '🧪',
        currentStreak: 10,
        goal: 7,
      );

      expect(habit.progressPercentage, equals(1.0));
    });

    test('Habit completion status works correctly', () {
      final today = DateTime.now();
      final habit = Habit(
        name: 'Test Habit',
        description: 'Test description',
        icon: '🧪',
        completedDates: [today],
      );

      expect(habit.isCompletedToday, isTrue);
    });

    test('Habit copyWith works correctly', () {
      final originalHabit = Habit(
        name: 'Original Habit',
        description: 'Original description',
        icon: '🧪',
        currentStreak: 5,
        goal: 7,
      );

      final updatedHabit = originalHabit.copyWith(
        name: 'Updated Habit',
        currentStreak: 10,
      );

      expect(updatedHabit.name, equals('Updated Habit'));
      expect(updatedHabit.description, equals('Original description'));
      expect(updatedHabit.currentStreak, equals(10));
      expect(updatedHabit.goal, equals(7));
    });

    test('Habit JSON serialization works correctly', () {
      final habit = Habit(
        name: 'Test Habit',
        description: 'Test description',
        icon: '🧪',
        currentStreak: 5,
        goal: 7,
      );

      final json = habit.toJson();
      expect(json['name'], equals('Test Habit'));
      expect(json['description'], equals('Test description'));
      expect(json['icon'], equals('🧪'));
      expect(json['currentStreak'], equals(5));
      expect(json['goal'], equals(7));

      // Test deserialization
      final deserializedHabit = Habit.fromJson(json);
      expect(deserializedHabit.name, equals(habit.name));
      expect(deserializedHabit.description, equals(habit.description));
      expect(deserializedHabit.icon, equals(habit.icon));
      expect(deserializedHabit.currentStreak, equals(habit.currentStreak));
      expect(deserializedHabit.goal, equals(habit.goal));
    });
  });

  group('Progress Bar Tests', () {
    testWidgets('Progress bar shows correct value', (WidgetTester tester) async {
      final habit = Habit(
        name: 'Test Habit',
        description: 'Test description',
        icon: '🧪',
        currentStreak: 3,
        goal: 5,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: const [
              NeumorphicColors(
                background: Color(0xFF2E2E2E),
                shadowDark: Color(0xFF1C1C1C),
                shadowLight: Color(0xFF4A4A4A),
                textColor: Colors.white70,
              ),
            ],
          ),
          home: Scaffold(
            body: HabitCard(
              habit: habit,
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Verify progress text is displayed correctly
      expect(find.text('3/5'), findsOneWidget);
      expect(find.text('60%'), findsOneWidget);
    });

    testWidgets('Progress bar shows 0 for zero streak', (WidgetTester tester) async {
      final habit = Habit(
        name: 'Test Habit',
        description: 'Test description',
        icon: '🧪',
        currentStreak: 0,
        goal: 5,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: const [
              NeumorphicColors(
                background: Color(0xFF2E2E2E),
                shadowDark: Color(0xFF1C1C1C),
                shadowLight: Color(0xFF4A4A4A),
                textColor: Colors.white70,
              ),
            ],
          ),
          home: Scaffold(
            body: HabitCard(
              habit: habit,
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Verify progress text shows 0
      expect(find.text('0/5'), findsOneWidget);
      expect(find.text('0%'), findsOneWidget);
    });

    testWidgets('Progress bar shows 100% for completed goal', (WidgetTester tester) async {
      final habit = Habit(
        name: 'Test Habit',
        description: 'Test description',
        icon: '🧪',
        currentStreak: 5,
        goal: 5,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: const [
              NeumorphicColors(
                background: Color(0xFF2E2E2E),
                shadowDark: Color(0xFF1C1C1C),
                shadowLight: Color(0xFF4A4A4A),
                textColor: Colors.white70,
              ),
            ],
          ),
          home: Scaffold(
            body: HabitCard(
              habit: habit,
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Verify progress text shows 100%
      expect(find.text('5/5'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
    });
  });

  group('Widget Integration Tests', () {
    testWidgets('HabitCard displays streak information correctly', (WidgetTester tester) async {
      final habit = Habit(
        name: 'Test Habit',
        description: 'Test description',
        icon: '🧪',
        currentStreak: 12,
        longestStreak: 15,
        goal: 7,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: const [
              NeumorphicColors(
                background: Color(0xFF2E2E2E),
                shadowDark: Color(0xFF1C1C1C),
                shadowLight: Color(0xFF4A4A4A),
                textColor: Colors.white70,
              ),
            ],
          ),
          home: Scaffold(
            body: HabitCard(
              habit: habit,
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Verify streak information is displayed
      expect(find.text('Test Habit'), findsOneWidget);
      expect(find.text('12/7'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget); // Clamped to 100%
    });

    testWidgets('HabitCard handles different priority levels', (WidgetTester tester) async {
      // Test high priority habit
      final highPriorityHabit = Habit(
        name: 'High Priority Habit',
        description: 'Important task',
        icon: '🔥',
        currentStreak: 3,
        goal: 7,
        priority: 3,
      );
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: const [
              NeumorphicColors(
                background: Color(0xFF2E2E2E),
                shadowDark: Color(0xFF1C1C1C),
                shadowLight: Color(0xFF4A4A4A),
                textColor: Colors.white70,
              ),
            ],
          ),
          home: Scaffold(
            body: HabitCard(
              habit: highPriorityHabit,
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Verify high priority habit is displayed
      expect(find.text('High Priority Habit'), findsOneWidget);
      expect(find.text('3/7'), findsOneWidget);
      expect(find.text('43%'), findsOneWidget);
    });
  });
}