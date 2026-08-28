.PHONY: help run-debug run-release install-device build-apk-release build-apk-debug install-release clean analyze

help:
	@echo === Safe News Flutter Commands ===
	@echo   make install-device     - Build and install Release mode directly to connected phone (Unplug USB safely)
	@echo   make run-debug          - Run in Debug mode with Hot Reload
	@echo   make run-release        - Run in Release mode
	@echo   make build-apk-release  - Build standalone Release APK
	@echo   make build-apk-debug    - Build standalone Debug APK
	@echo   make install-release    - Build and install Release APK
	@echo   make analyze            - Run static analysis
	@echo   make clean              - Clean build cache and get packages

# Cai dat truc tiep ban Release len dien thoai (rut cap dung doc lap)
install-device:
	flutter run --release

# Chay che do Debug (ho tro Hot Reload phim r)
run-debug:
	flutter run

# Chay che do Release
run-release:
	flutter run --release

# Build APK Release doc lap (file nam tai build/app/outputs/flutter-apk/app-release.apk)
build-apk-release:
	flutter clean
	flutter pub get
	flutter build apk --release

# Build APK Debug
build-apk-debug:
	flutter clean
	flutter pub get
	flutter build apk --debug

# Build va nap APK Release vao thiet bi
install-release: build-apk-release
	flutter install --release

# Phan tich tinh code
analyze:
	flutter analyze

# Don dep cache
clean:
	flutter clean
	flutter pub get