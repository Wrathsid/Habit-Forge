# Complete App Launcher Script
# This script runs both backend and frontend

Write-Host "🚀 Starting Habit Tracker App (Backend + Frontend)" -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Green

# Function to check if a port is in use
function Test-Port {
  param([int]$Port)
  try {
    $connection = New-Object System.Net.Sockets.TcpClient
    $connection.Connect("localhost", $Port)
    $connection.Close()
    return $true
  }
  catch {
    return $false
  }
}

# Start Backend
Write-Host "`n🔧 Starting FastAPI Backend..." -ForegroundColor Yellow

if (Test-Port 8000) {
  Write-Host "⚠️  Port 8000 is already in use. Backend might already be running." -ForegroundColor Yellow
}
else {
  Write-Host "Starting backend on http://localhost:8000" -ForegroundColor Green
  Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd backend; python main.py" -WindowStyle Normal
  Start-Sleep -Seconds 3
}

# Wait for backend to start
Write-Host "Waiting for backend to start..." -ForegroundColor Yellow
$backendReady = $false
$maxWait = 30
$waitTime = 0

while (-not $backendReady -and $waitTime -lt $maxWait) {
  Start-Sleep -Seconds 2
  $waitTime += 2
  if (Test-Port 8000) {
    $backendReady = $true
    Write-Host "✅ Backend is ready!" -ForegroundColor Green
  }
  else {
    Write-Host "⏳ Waiting for backend... ($waitTime seconds)" -ForegroundColor Yellow
  }
}

if (-not $backendReady) {
  Write-Host "⚠️  Backend didn't start in time, but continuing..." -ForegroundColor Yellow
}

# Start Frontend
Write-Host "`n📱 Starting Flutter Frontend..." -ForegroundColor Yellow

# Check if Android emulator is running
$flutterDevices = flutter devices 2>$null | Out-String
if ($flutterDevices -match "emulator-5554") {
  Write-Host "✅ Android emulator detected" -ForegroundColor Green
  Write-Host "Starting Flutter app on Android emulator..." -ForegroundColor Green
  flutter run -d emulator-5554
}
elseif ($flutterDevices -match "windows") {
  Write-Host "✅ Windows desktop detected" -ForegroundColor Green
  Write-Host "Starting Flutter app on Windows desktop..." -ForegroundColor Green
  flutter run -d windows
}
elseif ($flutterDevices -match "chrome") {
  Write-Host "✅ Chrome browser detected" -ForegroundColor Green
  Write-Host "Starting Flutter app on Chrome..." -ForegroundColor Green
  flutter run -d chrome
}
else {
  Write-Host "⚠️  No suitable device found. Available devices:" -ForegroundColor Yellow
  flutter devices
  Write-Host "`nYou can manually run: flutter run -d <device-id>" -ForegroundColor Yellow
}

Write-Host "`n🎉 App launcher complete!" -ForegroundColor Green
Write-Host "Backend: http://localhost:8000" -ForegroundColor Cyan
Write-Host "Frontend: Running on selected device" -ForegroundColor Cyan
