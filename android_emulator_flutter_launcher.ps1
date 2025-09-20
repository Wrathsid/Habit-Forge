# Android Emulator Setup and Flutter App Launcher Script
# This script sets up Android emulator and runs Flutter app automatically
# Tested and verified for Windows PowerShell

param(
  [switch]$SkipFlutterRun = $false
)

Write-Host "Android Emulator Setup and Flutter App Launcher" -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Green

# Set Android SDK environment variables
$env:ANDROID_SDK_ROOT = "C:\Users\Siddharth\AppData\Local\Android\Sdk"
$env:ANDROID_HOME = $env:ANDROID_SDK_ROOT

# Update PATH with correct Android SDK tools
$androidPaths = @(
  "$env:ANDROID_SDK_ROOT\cmdline-tools\latest\bin",
  "$env:ANDROID_SDK_ROOT\platform-tools",
  "$env:ANDROID_SDK_ROOT\emulator"
)

foreach ($path in $androidPaths) {
  if (Test-Path $path) {
    $env:PATH = "$path;$env:PATH"
    Write-Host "Added to PATH: $path" -ForegroundColor Green
  }
  else {
    Write-Host "Path not found: $path" -ForegroundColor Yellow
  }
}

Write-Host "`nChecking Android SDK tools..." -ForegroundColor Yellow

# Check if SDK Manager exists
$sdkManager = "$env:ANDROID_SDK_ROOT\cmdline-tools\latest\bin\sdkmanager.bat"
if (-not (Test-Path $sdkManager)) {
  Write-Host "SDK Manager not found at: $sdkManager" -ForegroundColor Red
  Write-Host "Please ensure Android SDK cmdline-tools are installed." -ForegroundColor Red
  exit 1
}

# Check if AVD Manager exists
$avdManager = "$env:ANDROID_SDK_ROOT\cmdline-tools\latest\bin\avdmanager.bat"
if (-not (Test-Path $avdManager)) {
  Write-Host "AVD Manager not found at: $avdManager" -ForegroundColor Red
  Write-Host "Please ensure Android SDK cmdline-tools are installed." -ForegroundColor Red
  exit 1
}

Write-Host "Android SDK tools found" -ForegroundColor Green

# Step 1: Install system image if not already installed
Write-Host "`nChecking system image: system-images;android-33;google_apis;x86_64" -ForegroundColor Yellow

try {
  # Check if system image is already installed
  $installedPackages = & $sdkManager --list 2>$null | Out-String
  if ($installedPackages -match "system-images;android-33;google_apis;x86_64.*installed") {
    Write-Host "System image already installed" -ForegroundColor Green
  }
  else {
    Write-Host "Installing system image..." -ForegroundColor Yellow
    & $sdkManager "system-images;android-33;google_apis;x86_64" --no_https --sdk_root=$env:ANDROID_SDK_ROOT
    if ($LASTEXITCODE -eq 0) {
      Write-Host "System image installed successfully" -ForegroundColor Green
    }
    else {
      Write-Host "System image installation may have failed, but continuing..." -ForegroundColor Yellow
    }
  }
}
catch {
  Write-Host "Could not check system image status. Attempting to install..." -ForegroundColor Yellow
  try {
    & $sdkManager "system-images;android-33;google_apis;x86_64" --no_https --sdk_root=$env:ANDROID_SDK_ROOT
    Write-Host "System image installed successfully" -ForegroundColor Green
  }
  catch {
    Write-Host "System image installation failed, but continuing..." -ForegroundColor Yellow
  }
}

# Step 2: Create AVD if it doesn't exist
Write-Host "`nChecking AVD: Pixel_6_API_33" -ForegroundColor Yellow

try {
  $existingAvds = & $avdManager list avd 2>$null | Out-String
  if ($existingAvds -match "Pixel_6_API_33") {
    Write-Host "AVD 'Pixel_6_API_33' already exists" -ForegroundColor Green
  }
  else {
    Write-Host "Creating new AVD..." -ForegroundColor Yellow
    & $avdManager create avd -n "Pixel_6_API_33" -k "system-images;android-33;google_apis;x86_64" -d "pixel_6" --force
    if ($LASTEXITCODE -eq 0) {
      Write-Host "AVD 'Pixel_6_API_33' created successfully" -ForegroundColor Green
    }
    else {
      Write-Host "Failed to create AVD" -ForegroundColor Red
      exit 1
    }
  }
}
catch {
  Write-Host "Failed to create AVD: $($_.Exception.Message)" -ForegroundColor Red
  exit 1
}

# Step 3: Start the emulator
Write-Host "`nStarting Android Emulator..." -ForegroundColor Yellow

$emulator = "$env:ANDROID_SDK_ROOT\emulator\emulator.exe"
if (-not (Test-Path $emulator)) {
  Write-Host "Emulator not found at: $emulator" -ForegroundColor Red
  exit 1
}

# Check if emulator is already running
try {
  $runningDevices = & "$env:ANDROID_SDK_ROOT\platform-tools\adb.exe" devices 2>$null | Out-String
  if ($runningDevices -match "emulator-5554.*device") {
    Write-Host "Emulator is already running" -ForegroundColor Green
    $emulatorReady = $true
  }
  else {
    Write-Host "Starting emulator in background..." -ForegroundColor Yellow
    Start-Process -FilePath $emulator -ArgumentList "-avd", "Pixel_6_API_33" -WindowStyle Minimized
        
    Write-Host "Waiting for emulator to boot (this may take 2-3 minutes)..." -ForegroundColor Yellow
        
    # Wait for emulator to be ready
    $maxWaitTime = 300 # 5 minutes
    $waitTime = 0
    $emulatorReady = $false
        
    while ($waitTime -lt $maxWaitTime -and -not $emulatorReady) {
      Start-Sleep -Seconds 15
      $waitTime += 15
            
      try {
        $devices = & "$env:ANDROID_SDK_ROOT\platform-tools\adb.exe" devices 2>$null | Out-String
        if ($devices -match "emulator-5554.*device") {
          $emulatorReady = $true
          Write-Host "Emulator is ready!" -ForegroundColor Green
        }
        else {
          $waitMessage = "Still waiting for emulator... ($waitTime seconds)"
          Write-Host $waitMessage -ForegroundColor Yellow
        }
      }
      catch {
        $waitMessage = "Still waiting for emulator... ($waitTime seconds)"
        Write-Host $waitMessage -ForegroundColor Yellow
      }
    }
        
    if (-not $emulatorReady) {
      Write-Host "Emulator took too long to start. You may need to start it manually." -ForegroundColor Red
      Write-Host "Manual command: $emulator -avd Pixel_6_API_33" -ForegroundColor Yellow
    }
  }
}
catch {
  Write-Host "Could not check emulator status. Starting emulator..." -ForegroundColor Yellow
  Start-Process -FilePath $emulator -ArgumentList "-avd", "Pixel_6_API_33" -WindowStyle Minimized
  Start-Sleep -Seconds 30
  $emulatorReady = $true
}

# Step 4: Run Flutter app
if (-not $SkipFlutterRun) {
  Write-Host "`nRunning Flutter app on emulator..." -ForegroundColor Yellow
    
  # Check if Flutter is available
  try {
    $flutterVersion = flutter --version 2>$null
    if ($flutterVersion) {
      Write-Host "Flutter is available" -ForegroundColor Green
            
      # Run Flutter app on emulator
      Write-Host "Launching Flutter app..." -ForegroundColor Green
      flutter run -d emulator-5554
    }
    else {
      Write-Host "Flutter not found. Please ensure Flutter is installed and in PATH." -ForegroundColor Red
    }
  }
  catch {
    Write-Host "Flutter not found. Please ensure Flutter is installed and in PATH." -ForegroundColor Red
    Write-Host "You can manually run: flutter run -d emulator-5554" -ForegroundColor Yellow
  }
}
else {
  Write-Host "`nSkipping Flutter app launch (use -SkipFlutterRun to skip)" -ForegroundColor Yellow
}

Write-Host "`nScript execution complete!" -ForegroundColor Green
Write-Host "If the emulator didn't start automatically, you can run:" -ForegroundColor Yellow
Write-Host "$emulator -avd Pixel_6_API_33" -ForegroundColor Cyan
Write-Host "Then run: flutter run -d emulator-5554" -ForegroundColor Cyan