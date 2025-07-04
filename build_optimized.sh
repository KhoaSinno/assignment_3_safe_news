#!/bin/bash

# Script build tối ưu cho Android
echo "🚀 Bắt đầu build tối ưu..."

# Clean build
echo "🧹 Cleaning previous builds..."
flutter clean
flutter pub get

# Build với tối ưu
echo "🔨 Building optimized APK..."
flutter build apk \
  --release \
  --split-per-abi \
  --target-platform android-arm,android-arm64,android-x64 \
  --obfuscate \
  --split-debug-info=./debug-info \
  --dart-define=flutter.inspector.structuredErrors=false

echo "✅ Build hoàn thành!"
echo "📱 APK files được tạo trong build/app/outputs/flutter-apk/"
echo "📊 Check kích thước:"
ls -lh build/app/outputs/flutter-apk/*.apk
