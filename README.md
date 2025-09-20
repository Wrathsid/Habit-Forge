# Neumorphic Habit Tracker 🎯

A beautiful Flutter app with neumorphic design for tracking daily habits.

## ✨ Features

- **🎨 Neumorphic Design**: Beautiful soft UI with depth and shadows
- **🌓 Theme Toggle**: Switch between light and dark modes
- **📊 Progress Tracking**: Visual progress bars for each habit
- **🎯 Habit Management**: Track multiple habits with streak counters
- **📱 Responsive**: Works on all screen sizes

## 🚀 Getting Started

### Prerequisites

- Flutter 3.10.0 or higher
- Dart 3.0.0 or higher

### Installation

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd habit_tracker
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 🎨 Design System

### Neumorphic Colors

The app uses a custom theme extension for neumorphic colors:

- **Background**: Base color for neumorphic elements
- **Shadow Dark**: Dark shadow for depth
- **Shadow Light**: Light shadow for highlights
- **Text Color**: Primary text color

### Theme Modes

- **Dark Mode**: Deep gray background with green accents
- **Light Mode**: Light gray background with green accents

## 🏗️ Architecture

### Components

- **HabitTrackerApp**: Root app widget with theme management
- **AppThemes**: Theme configuration for light and dark modes
- **NeumorphicColors**: Custom theme extension for neumorphic styling
- **NeumorphicBox**: Reusable neumorphic container widget
- **HomePage**: Main screen with habit cards

### Key Features

1. **Theme Toggle**: Tap the sun icon to switch between light and dark modes
2. **Habit Cards**: Each habit shows progress with a visual progress bar
3. **Neumorphic Effects**: Soft shadows and highlights create depth
4. **Responsive Design**: Adapts to different screen sizes

## 📱 Screenshots

The app features:
- Clean neumorphic design
- Smooth theme transitions
- Visual progress indicators
- Intuitive user interface

## 🛠️ Customization

### Adding New Habits

To add new habits, modify the `_HomePageState` class:

```dart
_buildHabitCard("Your Habit", currentStreak, goal, colors)
```

### Customizing Colors

Modify the `AppThemes` class to change colors:

```dart
static final ThemeData darkTheme = ThemeData(
  // Your custom colors here
);
```

### Adjusting Neumorphic Effects

Modify the `NeumorphicBox` widget to adjust shadow effects:

```dart
boxShadow: [
  BoxShadow(
    color: colors.shadowDark,
    offset: const Offset(6, 6), // Adjust offset
    blurRadius: 12, // Adjust blur
  ),
  // ...
]
```

## 📦 Dependencies

- **flutter**: Flutter SDK
- **lucide_icons**: Beautiful icon set

## 🧪 Testing

Run tests with:
```bash
flutter test
```

## 📄 License

This project is licensed under the MIT License.

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Lucide for the beautiful icons
- Neumorphism design inspiration