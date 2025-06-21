# Hướng dẫn sửa lỗi Weather và Geolocator

## 🔧 Lỗi hiện tại

```
MissingPluginException(No implementation found for method isLocationServiceEnabled on channel flutter.baseflow.com/geolocator_android)
```

## ⚠️ Nguyên nhân

1. Plugin geolocator chưa được cài đặt đúng cách
2. Thiếu quyền truy cập vị trí trong Android manifest
3. Cần hot restart sau khi thêm plugin mới
4. API key OpenWeatherMap chưa được thiết lập

## 🛠️ Giải pháp đã thực hiện

### 1. Cập nhật Android Manifest

Đã thêm các quyền cần thiết vào `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
```

### 2. Cải thiện xử lý lỗi

- Thêm fallback để sử dụng vị trí mặc định (Hà Nội) khi không lấy được GPS
- Cải thiện thông báo lỗi trong WeatherWidget
- Thêm xử lý PlatformException riêng biệt

### 3. Quản lý API Key an toàn

- Sử dụng file `.env` để lưu API key
- Kiểm tra API key trước khi gọi API

### 4. Tạo trang Debug

- Thêm trang debug để kiểm tra location và weather API
- Truy cập từ Profile → Debug - Weather & Location

## 📋 Các bước cần thực hiện

### Bước 1: Thiết lập API Key

1. Đăng ký tài khoản miễn phí tại [OpenWeatherMap](https://openweathermap.org/api)
2. Lấy API key từ dashboard
3. Mở file `.env` và thay thế:

```
WEATHER_API_KEY=your_actual_api_key_here
```

### Bước 2: Clean và Rebuild

```bash
flutter clean
flutter pub get
flutter run
```

### Bước 3: Test trên thiết bị thật

- Emulator có thể không hỗ trợ GPS đầy đủ
- Thử chạy trên thiết bị Android thật

### Bước 4: Kiểm tra quyền

- Khi chạy app lần đầu, cho phép truy cập vị trí
- Nếu từ chối, vào Settings → Apps → Safe News → Permissions để bật lại

### Bước 5: Sử dụng trang Debug

1. Mở app → Tab Profile
2. Chọn "Debug - Weather & Location"
3. Test từng chức năng riêng biệt:
   - "Test Location" - Kiểm tra GPS
   - "Test Weather" - Kiểm tra API thời tiết

## 🔍 Kiểm tra kết quả

### Thành công

- WeatherWidget hiển thị nhiệt độ thực tế
- Không có lỗi MissingPluginException
- Trang debug hiển thị thông tin chi tiết

### Vẫn lỗi

1. Kiểm tra API key trong `.env`
2. Thử chạy trên thiết bị thật thay vì emulator
3. Kiểm tra kết nối internet
4. Xem log chi tiết trong trang debug

## 🚀 Fallback hiện tại

Nếu không lấy được vị trí GPS, app sẽ:

- Tự động sử dụng tọa độ Hà Nội (21.0285, 105.8542)
- Hiển thị thời tiết của Hà Nội
- Không crash app

## 📞 Hỗ trợ

Nếu vẫn gặp lỗi, hãy:

1. Chụp màn hình trang debug
2. Copy log lỗi từ terminal
3. Kiểm tra thiết bị có bật GPS không
