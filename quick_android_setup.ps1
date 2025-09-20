# Quick Android Emulator Setup - Copy Paste Commands
# Run these commands one by one in PowerShell

Write-Host "Setting up Android Emulator for Flutter..." -ForegroundColor Green

# 1. Set environment variables
$env:ANDROID_SDK_ROOT = "C:\Users\Siddharth\AppData\Local\Android\Sdk"
$env:ANDROID_HOME = $env:ANDROID_SDK_ROOT
$env:PATH += ";$env:ANDROID_SDK_ROOT\cmdline-tools\latest\bin;$env:ANDROID_SDK_ROOT\platform-tools;$env:ANDROID_SDK_ROOT\emulator"

# 2. Install system image
& "$env:ANDROID_SDK_ROOT\cmdline-tools\latest\bin\sdkmanager.bat" "system-images;android-33;google_apis;x86_64"

# 3. Create AVD
& "$env:ANDROID_SDK_ROOT\cmdline-tools\latest\bin\avdmanager.bat" create avd -n "Pixel_6_API_33" -k "system-images;android-33;google_apis;x86_64" -d "pixel_6" --force

# 4. Start emulator
& "$env:ANDROID_SDK_ROOT\emulator\emulator.exe" -avd "Pixel_6_API_33"

Write-Host "Emulator started! Now run: flutter run -d emulator-5554" -ForegroundColor Green
