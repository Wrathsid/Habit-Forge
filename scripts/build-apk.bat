@echo off
REM HabitForge APK Build Script for Windows
REM This script builds a signed release APK locally

echo 🚀 HabitForge APK Builder
echo =========================

REM Check if Flutter is available
where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ Error: Flutter not found. Please install Flutter SDK.
    pause
    exit /b 1
)

REM Check if keystore exists
if not exist "android\app\upload-keystore.jks" (
    echo ❌ Error: Keystore not found. Please run generate-keystore.bat first.
    pause
    exit /b 1
)

REM Check if key.properties exists
if not exist "android\key.properties" (
    echo ❌ Error: key.properties not found. Please create it with your keystore details.
    pause
    exit /b 1
)

echo 📱 Building release APK...
echo.

REM Clean previous builds
echo 🧹 Cleaning previous builds...
flutter clean

REM Get dependencies
echo 📦 Getting dependencies...
flutter pub get

REM Build APK
echo 🔨 Building APK...
flutter build apk --release

if %errorlevel% equ 0 (
    echo.
    echo ✅ APK built successfully!
    echo.
    echo 📍 APK Location: build\app\outputs\flutter-apk\app-release.apk
    echo.
    echo 📋 Next steps:
    echo 1. Test the APK on your device
    echo 2. Upload to GitHub Releases if needed
    echo 3. Share with users for testing
    echo.
) else (
    echo.
    echo ❌ APK build failed!
    echo Please check the error messages above.
    echo.
)

pause
