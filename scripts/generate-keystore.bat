@echo off
REM HabitForge Keystore Generation Script for Windows
REM This script generates a keystore for signing the Android APK

echo 🔐 HabitForge Keystore Generator
echo ================================

REM Check if keytool is available
where keytool >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ Error: keytool not found. Please install Java JDK.
    pause
    exit /b 1
)

REM Set default values
set KEYSTORE_PATH=android\app\upload-keystore.jks
set KEY_ALIAS=upload
set VALIDITY_DAYS=10000
set KEY_ALG=RSA
set KEY_SIZE=2048

echo 📝 Keystore Configuration:
echo    Path: %KEYSTORE_PATH%
echo    Alias: %KEY_ALIAS%
echo    Algorithm: %KEY_ALG%
echo    Key Size: %KEY_SIZE%
echo    Validity: %VALIDITY_DAYS% days
echo.

REM Check if keystore already exists
if exist "%KEYSTORE_PATH%" (
    echo ⚠️  Warning: Keystore already exists at %KEYSTORE_PATH%
    set /p OVERWRITE="Do you want to overwrite it? (y/N): "
    if /i not "%OVERWRITE%"=="y" (
        echo ❌ Keystore generation cancelled.
        pause
        exit /b 1
    )
    del "%KEYSTORE_PATH%"
)

REM Create android\app directory if it doesn't exist
if not exist "android\app" mkdir "android\app"

echo 🔑 Generating keystore...
echo Please provide the following information:
echo.

REM Generate keystore
keytool -genkey -v -keystore "%KEYSTORE_PATH%" -keyalg "%KEY_ALG%" -keysize %KEY_SIZE% -validity %VALIDITY_DAYS% -alias "%KEY_ALIAS%" -dname "CN=HabitForge, OU=Development, O=HabitForge, L=City, S=State, C=US"

echo.
echo ✅ Keystore generated successfully!
echo.
echo 📋 Next steps:
echo 1. Update android\key.properties with your keystore details
echo 2. Add the keystore passwords to GitHub Secrets:
echo    - STORE_PASSWORD: Your keystore password
echo    - KEY_PASSWORD: Your key password
echo 3. Commit the keystore to your repository (if using GitHub Actions)
echo.
echo ⚠️  Important: Keep your keystore and passwords secure!
echo    - Never commit passwords to version control
echo    - Store passwords in GitHub Secrets for CI/CD
echo    - Keep a backup of your keystore in a secure location
echo.
echo 🎉 You're ready to build signed APKs!
pause
