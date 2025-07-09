@echo off
echo 🚀 Bắt đầu build tối ưu cho production...

echo 🧹 Cleaning previous builds...
flutter clean
flutter pub get

echo 🔨 Building optimized APK...
flutter build apk --release --split-per-abi --dart-define=flutter.inspector.structuredErrors=false

echo ✅ Build hoàn thành!
echo 📱 APK files:
dir build\app\outputs\flutter-apk\*.apk /B

echo.
echo 📊 Kích thước APK:
for %%f in (build\app\outputs\flutter-apk\*.apk) do echo   %%~nxf: %%~zf bytes

echo.
echo 🎯 Sử dụng APK phù hợp với thiết bị:
echo   - app-arm64-v8a-release.apk: Cho thiết bị Android 64-bit (khuyên dùng)
echo   - app-armeabi-v7a-release.apk: Cho thiết bị Android 32-bit (cũ hơn)
echo   - app-release.apk: Universal APK (tương thích tất cả)
pause
