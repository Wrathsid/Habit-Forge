#!/bin/bash

# HabitForge Keystore Generation Script
# This script generates a keystore for signing the Android APK

set -e

echo "🔐 HabitForge Keystore Generator"
echo "================================"

# Check if keytool is available
if ! command -v keytool &> /dev/null; then
    echo "❌ Error: keytool not found. Please install Java JDK."
    exit 1
fi

# Set default values
KEYSTORE_PATH="android/app/upload-keystore.jks"
KEY_ALIAS="upload"
VALIDITY_DAYS="10000"
KEY_ALG="RSA"
KEY_SIZE="2048"

echo "📝 Keystore Configuration:"
echo "   Path: $KEYSTORE_PATH"
echo "   Alias: $KEY_ALIAS"
echo "   Algorithm: $KEY_ALG"
echo "   Key Size: $KEY_SIZE"
echo "   Validity: $VALIDITY_DAYS days"
echo ""

# Check if keystore already exists
if [ -f "$KEYSTORE_PATH" ]; then
    echo "⚠️  Warning: Keystore already exists at $KEYSTORE_PATH"
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Keystore generation cancelled."
        exit 1
    fi
    rm "$KEYSTORE_PATH"
fi

# Create android/app directory if it doesn't exist
mkdir -p android/app

echo "🔑 Generating keystore..."
echo "Please provide the following information:"
echo ""

# Generate keystore
keytool -genkey -v \
    -keystore "$KEYSTORE_PATH" \
    -keyalg "$KEY_ALG" \
    -keysize "$KEY_SIZE" \
    -validity "$VALIDITY_DAYS" \
    -alias "$KEY_ALIAS" \
    -dname "CN=HabitForge, OU=Development, O=HabitForge, L=City, S=State, C=US"

echo ""
echo "✅ Keystore generated successfully!"
echo ""
echo "📋 Next steps:"
echo "1. Update android/key.properties with your keystore details"
echo "2. Add the keystore passwords to GitHub Secrets:"
echo "   - STORE_PASSWORD: Your keystore password"
echo "   - KEY_PASSWORD: Your key password"
echo "3. Commit the keystore to your repository (if using GitHub Actions)"
echo ""
echo "⚠️  Important: Keep your keystore and passwords secure!"
echo "   - Never commit passwords to version control"
echo "   - Store passwords in GitHub Secrets for CI/CD"
echo "   - Keep a backup of your keystore in a secure location"
echo ""
echo "🎉 You're ready to build signed APKs!"
