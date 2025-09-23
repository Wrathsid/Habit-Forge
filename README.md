# 🎯 HabitForge - Advanced Habit Tracker

<div align="center">
  <img src="assets/icons/logo.svg" alt="HabitForge Logo" width="120" height="120">
  
  <h3>Build Better Habits with Advanced Neumorphic Design</h3>
  
  [![GitHub release](https://img.shields.io/github/release/Wrathsid/habit-tracker-app.svg)](https://github.com/Wrathsid/habit-tracker-app/releases)
  [![Flutter](https://img.shields.io/badge/Flutter-3.24.0-blue.svg)](https://flutter.dev/)
  [![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
  [![Android](https://img.shields.io/badge/Android-5.0%2B-green.svg)](https://www.android.com/)
</div>

## 📱 About HabitForge

HabitForge is a cutting-edge habit tracking application that combines beautiful neumorphic design with powerful habit-building features. Built with Flutter, it offers a seamless experience across Android devices with advanced analytics, social features, and gamification elements.

### ✨ Key Features

- **🎨 Advanced Neumorphic Design**: Beautiful, modern UI with floating effects, glow animations, and glass morphism
- **📊 Comprehensive Analytics**: Track your progress with detailed insights and visualizations
- **🏆 Gamification System**: Level up, earn achievements, and maintain streaks
- **👥 Social Features**: Connect with friends, share progress, and participate in challenges
- **🎯 Smart Notifications**: Contextual reminders and celebration notifications
- **💭 Mood Tracking**: Monitor your emotional well-being alongside habit progress
- **🌙 Dark/Light Themes**: Multiple theme options including cyberpunk mode
- **📱 Responsive Design**: Optimized for all screen sizes and orientations

## 🚀 Quick Start

### 📥 Download & Install

1. **Download the latest APK** from the [Releases](https://github.com/Wrathsid/habit-tracker-app/releases) page
2. **Enable Unknown Sources**:
   - Go to Settings → Security → Unknown Sources
   - Enable installation from unknown sources
3. **Install the APK**:
   - Tap the downloaded APK file
   - Follow the installation prompts
4. **Launch HabitForge** and start building better habits!

### 📋 System Requirements

- **Android**: 5.0 (API level 21) or higher
- **Storage**: 50MB free space
- **RAM**: 2GB recommended
- **Internet**: Required for social features and cloud sync

## 🛠️ Development Setup

### Prerequisites

- Flutter SDK 3.24.0 or higher
- Android Studio or VS Code
- Git
- Java 17 or higher

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Wrathsid/habit-tracker-app.git
   cd habit-tracker-app
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the app**:
   ```bash
   flutter run
   ```

### Building APK Locally

1. **Generate keystore** (first time only):
   ```bash
   keytool -genkey -v -keystore android/app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. **Update key.properties**:
   ```bash
   cp android/key.properties.example android/key.properties
   # Edit android/key.properties with your keystore details
   ```

3. **Build release APK**:
   ```bash
   flutter build apk --release
   ```

4. **Find your APK**:
   ```
   build/app/outputs/flutter-apk/app-release.apk
   ```

## 🏗️ Architecture

### Backend
- **FastAPI**: High-performance Python web framework
- **Supabase**: Real-time database and authentication
- **PostgreSQL**: Primary database
- **Redis**: Caching and session management

### Frontend
- **Flutter**: Cross-platform mobile framework
- **Neumorphic Design**: Custom UI components with advanced effects
- **State Management**: Provider pattern with custom services
- **Local Storage**: SQLite for offline functionality

### Key Components

```
lib/
├── config/          # Environment configuration
├── models/          # Data models
├── screens/         # UI screens
├── services/        # Business logic
├── widgets/         # Reusable UI components
└── main.dart        # App entry point
```

## 🎨 Design System

HabitForge features a comprehensive neumorphic design system with:

- **8 Effect Types**: Convex, Concave, Floating, Glass, Gradient, Embossed, Pressed, Flat
- **3 Color Themes**: Light, Dark, Cyberpunk
- **Advanced Animations**: Floating effects, glow animations, micro-interactions
- **Responsive Components**: Adaptive layouts for all screen sizes

## 📊 Features Overview

### 🎯 Habit Tracking
- Create and manage multiple habits
- Set custom frequencies and goals
- Track progress with visual indicators
- Export data for analysis

### 📈 Analytics & Insights
- Detailed progress charts
- Habit correlation analysis
- Streak tracking and statistics
- Performance trends

### 🏆 Gamification
- Level system with XP rewards
- Achievement badges
- Streak celebrations
- Social challenges

### 👥 Social Features
- Friend connections
- Progress sharing
- Group challenges
- Leaderboards

### 🎨 Customization
- Multiple theme options
- Custom habit categories
- Personalized notifications
- Flexible layouts

## 🔧 Configuration

### Environment Variables

Create a `.env` file in the root directory:

```env
# Supabase Configuration
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key

# FastAPI Backend
API_BASE_URL=http://localhost:8000

# App Configuration
APP_NAME=HabitForge
APP_VERSION=1.0.0
```

### GitHub Secrets

For automated builds, configure these secrets in your GitHub repository:

- `STORE_PASSWORD`: Keystore password
- `KEY_PASSWORD`: Key password
- `SUPABASE_URL`: Supabase project URL
- `SUPABASE_ANON_KEY`: Supabase anonymous key

## 🚀 Deployment

### Automated Releases

The app uses GitHub Actions for automated builds and releases:

1. **Create a new tag**:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

2. **GitHub Actions will**:
   - Build the APK and AAB
   - Create a GitHub release
   - Upload the files as release assets

### Manual Release

1. **Build the APK**:
   ```bash
   flutter build apk --release
   ```

2. **Create a GitHub release**:
   - Go to the Releases page
   - Click "Create a new release"
   - Upload the APK file

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Development Workflow

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

### Getting Help

- **Documentation**: Check this README and inline code comments
- **Issues**: Report bugs on [GitHub Issues](https://github.com/Wrathsid/habit-tracker-app/issues)
- **Discussions**: Join our [GitHub Discussions](https://github.com/Wrathsid/habit-tracker-app/discussions)

### Common Issues

**Q: App won't install on my device**
A: Make sure you have Android 5.0+ and have enabled "Unknown Sources" in settings.

**Q: Notifications not working**
A: Check that notification permissions are granted and the app is not in battery optimization.

**Q: Can't sync data**
A: Ensure you have an internet connection and check your Supabase configuration.

## 🗺️ Roadmap

### Upcoming Features

- [ ] iOS version
- [ ] Apple Watch integration
- [ ] Advanced analytics dashboard
- [ ] Habit templates marketplace
- [ ] Voice commands
- [ ] Widget support
- [ ] Wear OS companion app

### Version History

- **v1.0.0**: Initial release with core features
- **v1.1.0**: Enhanced neumorphic design
- **v1.2.0**: Social features and challenges
- **v2.0.0**: Advanced analytics and AI insights (planned)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Supabase for backend services
- The open-source community for inspiration
- All beta testers and contributors

---

<div align="center">
  <p>Made with ❤️ by the HabitForge Team</p>
  <p>
    <a href="https://github.com/Wrathsid/habit-tracker-app">GitHub</a> •
    <a href="https://twitter.com/habitforge">Twitter</a> •
    <a href="mailto:support@habitforge.app">Email</a>
  </p>
</div>