@echo off
echo ================================
echo    Safe News - Weather Debug
echo ================================
echo.

echo [1/5] Cleaning Flutter project...
flutter clean

echo.
echo [2/5] Getting dependencies...
flutter pub get

echo.
echo [3/5] Checking Flutter doctor...
flutter doctor

echo.
echo [4/5] Listing connected devices...
flutter devices

echo.
echo [5/5] Building APK (this may take a while)...
flutter build apk --debug

echo.
echo ================================
echo Build complete! Check the output above for any errors.
echo To run on device: flutter run
echo ================================
pause
