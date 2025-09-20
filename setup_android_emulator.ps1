# Android Emulator Setup Script for Flutter Testing
# This script sets up and runs an Android emulator for Flutter development

Write-Host "🚀 Setting up Android Emulator for Flutter Testing..." -ForegroundColor Green

# Set Android SDK path
$env:ANDROID_SDK_ROOT = "C:\Users\Siddharth\AppData\Local\Android\Sdk"
$env:ANDROID_HOME = $env:ANDROID_SDK_ROOT

# Add SDK tools to PATH
$env:PATH += ";$env:ANDROID_SDK_ROOT\emulator;$env:ANDROID_SDK_ROOT\platform-tools;$env:ANDROID_SDK_ROOT\tools;$env:ANDROID_SDK_ROOT\tools\bin"

Write-Host "✅ Added Android SDK tools to PATH" -ForegroundColor Green

# Check if system image exists, if not install it
Write-Host "📱 Checking for system image: system-images;android-33;google_apis;x86_64" -ForegroundColor Yellow

$sdkManager = "$env:ANDROID_SDK_ROOT\tools\bin\sdkmanager.bat"
if (Test-Path $sdkManager) {
  Write-Host "Installing system image if missing..." -ForegroundColor Yellow
  & $sdkManager "system-images;android-33;google_apis;x86_64"
  Write-Host "✅ System image ready" -ForegroundColor Green
}
else {
  Write-Host "⚠️  SDK Manager not found at expected location. Please check your Android SDK installation." -ForegroundColor Red
  exit 1
}

# Create AVD if it doesn't exist
Write-Host "🔧 Creating AVD: Pixel_6_API_33" -ForegroundColor Yellow

$avdManager = "$env:ANDROID_SDK_ROOT\tools\bin\avdmanager.bat"
if (Test-Path $avdManager) {
  # Check if AVD already exists
  $existingAvds = & $avdManager list avd
  if ($existingAvds -match "Pixel_6_API_33") {
    Write-Host "✅ AVD 'Pixel_6_API_33' already exists" -ForegroundColor Green
  }
  else {
    Write-Host "Creating new AVD..." -ForegroundColor Yellow
    & $avdManager create avd -n "Pixel_6_API_33" -k "system-images;android-33;google_apis;x86_64" -d "pixel_6" --force
    Write-Host "✅ AVD 'Pixel_6_API_33' created successfully" -ForegroundColor Green
  }
}
else {
  Write-Host "⚠️  AVD Manager not found at expected location. Please check your Android SDK installation." -ForegroundColor Red
  exit 1
}

# Start the emulator
Write-Host "🎮 Starting Android Emulator..." -ForegroundColor Yellow

$emulator = "$env:ANDROID_SDK_ROOT\emulator\emulator.exe"
if (Test-Path $emulator) {
  # Start emulator in background
  Start-Process -FilePath $emulator -ArgumentList "-avd", "Pixel_6_API_33" -WindowStyle Minimized
    
  Write-Host "⏳ Waiting for emulator to boot (this may take 2-3 minutes)..." -ForegroundColor Yellow
    
  # Wait for emulator to be ready
  $maxWaitTime = 300 # 5 minutes
  $waitTime = 0
  $emulatorReady = $false
    
  while ($waitTime -lt $maxWaitTime -and -not $emulatorReady) {
    Start-Sleep -Seconds 10
    $waitTime += 10
        
    try {
      $devices = & "$env:ANDROID_SDK_ROOT\platform-tools\adb.exe" devices
      if ($devices -match "emulator.*device") {
        $emulatorReady = $true
        Write-Host "✅ Emulator is ready!" -ForegroundColor Green
      }
      else {
        Write-Host "⏳ Still waiting for emulator... ($waitTime seconds)" -ForegroundColor Yellow
      }
    }
    catch {
      Write-Host "⏳ Still waiting for emulator... ($waitTime seconds)" -ForegroundColor Yellow
    }
  }
    
  if (-not $emulatorReady) {
    Write-Host "⚠️  Emulator took too long to start. Please check manually." -ForegroundColor Red
  }
}
else {
  Write-Host "⚠️  Emulator not found at expected location. Please check your Android SDK installation." -ForegroundColor Red
  exit 1
}

# Run Flutter app
Write-Host "📱 Running Flutter app on emulator..." -ForegroundColor Yellow

if ($emulatorReady) {
  flutter run -d Pixel_6_API_33
}
else {
  Write-Host "⚠️  Emulator not ready. You can manually run: flutter run -d Pixel_6_API_33" -ForegroundColor Yellow
}

Write-Host "🎉 Setup complete! Your Flutter app should be running on the Android emulator." -ForegroundColor Green
