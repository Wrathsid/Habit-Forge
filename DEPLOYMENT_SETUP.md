# 🚀 HabitForge Deployment Setup Guide

This guide will help you set up automated APK builds and releases for HabitForge.

## 📋 Prerequisites

- GitHub repository
- Flutter SDK 3.24.0+
- Java JDK 17+
- Android Studio (optional)

## 🔐 Step 1: Generate Keystore

### Windows
```bash
# Run the keystore generation script
scripts\generate-keystore.bat
```

### Linux/Mac
```bash
# Make script executable and run
chmod +x scripts/generate-keystore.sh
./scripts/generate-keystore.sh
```

### Manual Generation
```bash
keytool -genkey -v -keystore android/app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload -dname "CN=HabitForge, OU=Development, O=HabitForge, L=City, S=State, C=US"
```

## 🔧 Step 2: Configure Keystore Properties

1. **Copy the example file**:
   ```bash
   cp android/key.properties.example android/key.properties
   ```

2. **Edit `android/key.properties`** with your actual values:
   ```properties
   storePassword=your_actual_store_password
   keyPassword=your_actual_key_password
   keyAlias=upload
   storeFile=../app/upload-keystore.jks
   ```

## 🔑 Step 3: Set Up GitHub Secrets

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Add the following secrets:

   | Secret Name | Description | Example |
   |-------------|-------------|---------|
   | `STORE_PASSWORD` | Keystore password | `your_store_password` |
   | `KEY_PASSWORD` | Key password | `your_key_password` |
   | `SUPABASE_URL` | Supabase project URL | `https://xxx.supabase.co` |
   | `SUPABASE_ANON_KEY` | Supabase anonymous key | `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...` |

## 📱 Step 4: Update App Configuration

1. **Update `pubspec.yaml`** with your app details:
   ```yaml
   name: habitforge
   description: Advanced Habit Tracker with Neumorphic Design
   version: 1.0.0+1
   ```

2. **Update `android/app/build.gradle.kts`** if needed:
   ```kotlin
   applicationId = "com.yourcompany.habitforge"
   ```

## 🚀 Step 5: Create Your First Release

### Automatic Release (Recommended)

1. **Create and push a tag**:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

2. **GitHub Actions will automatically**:
   - Build the APK and AAB
   - Create a GitHub release
   - Upload the files as release assets

### Manual Release

1. **Build APK locally**:
   ```bash
   # Windows
   scripts\build-apk.bat
   
   # Linux/Mac
   flutter build apk --release
   ```

2. **Create GitHub release**:
   - Go to your repository's Releases page
   - Click "Create a new release"
   - Upload the APK file

## 📊 Step 6: Monitor Builds

1. **Check GitHub Actions**:
   - Go to the "Actions" tab in your repository
   - Monitor build progress and logs

2. **Verify Release**:
   - Check that APK and AAB files are uploaded
   - Test the APK on a device

## 🔍 Troubleshooting

### Common Issues

**❌ Build fails with "keystore not found"**
- Ensure `upload-keystore.jks` exists in `android/app/`
- Check that GitHub Secrets are set correctly

**❌ "Signing config not found"**
- Verify `android/key.properties` exists and has correct values
- Check that `build.gradle.kts` references the signing config

**❌ APK won't install**
- Ensure the APK is signed correctly
- Check that the app ID matches your keystore

**❌ GitHub Actions fails**
- Verify all required secrets are set
- Check the Actions logs for specific error messages

### Debug Commands

```bash
# Check Flutter installation
flutter doctor

# Verify keystore
keytool -list -v -keystore android/app/upload-keystore.jks

# Test local build
flutter build apk --debug
```

## 📈 Step 7: Set Up Monitoring

1. **Enable GitHub Pages** (optional):
   - Go to repository Settings → Pages
   - Enable GitHub Pages for documentation

2. **Set up issue templates**:
   - Create `.github/ISSUE_TEMPLATE/` directory
   - Add bug report and feature request templates

3. **Configure branch protection**:
   - Protect main branch
   - Require status checks for PRs

## 🎯 Step 8: User Distribution

### Direct Download
- Users can download APKs directly from GitHub Releases
- No app store approval required
- Instant distribution

### App Store (Future)
- Use the generated AAB file for Google Play Store
- Follow Google Play Console guidelines
- Set up app store optimization

## 🔄 Continuous Integration

The GitHub Actions workflow automatically:
- ✅ Builds APK and AAB on every tag
- ✅ Creates GitHub releases
- ✅ Uploads files as release assets
- ✅ Generates release notes
- ✅ Caches dependencies for faster builds

## 📚 Additional Resources

- [Flutter Build and Release](https://docs.flutter.dev/deployment/android)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Android App Signing](https://developer.android.com/studio/publish/app-signing)
- [ProGuard Configuration](https://developer.android.com/studio/build/shrink-code)

## 🆘 Support

If you encounter issues:
1. Check the troubleshooting section above
2. Review GitHub Actions logs
3. Open an issue on the repository
4. Check Flutter and Android documentation

---

🎉 **Congratulations!** Your HabitForge app is now ready for automated deployment!
