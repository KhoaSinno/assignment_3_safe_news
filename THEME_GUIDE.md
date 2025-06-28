# Theme System Documentation

## Tổng quan

Theme system đã được thiết lập với màu chủ đạo `Color(0xFF9F224E)` và hỗ trợ đầy đủ dark mode.

## Màu sắc chính

### Màu chủ đạo

- **Primary Color**: `Color(0xFF9F224E)` - Đỏ burgundy
- **Primary Color Dark**: `Color(0xFF7A1A3C)` - Đỏ burgundy đậm
- **Primary Color Light**: `Color(0xFFB83D65)` - Đỏ burgundy nhạt

### Màu phụ

- **Secondary Color**: `Color(0xFF577BD9)` - Xanh dương (light mode)
- **Secondary Color Dark**: `Color(0xFF8BB6FF)` - Xanh dương nhạt (dark mode)
- **Accent Color**: `Color(0xFFE9EEFA)` - Xanh nhạt cho AppBar

## Cách sử dụng

### 1. Trong MaterialApp (đã được setup)

```dart
MaterialApp(
  theme: AppTheme.lightTheme,
  darkTheme: AppTheme.darkTheme,
  themeMode: themeMode,
  // ...
)
```

### 2. Sử dụng trong widgets

```dart
// Lấy màu primary
Theme.of(context).primaryColor

// Lấy màu từ ColorScheme
Theme.of(context).colorScheme.primary
Theme.of(context).colorScheme.secondary

// Sử dụng text styles
Theme.of(context).textTheme.headlineLarge
Theme.of(context).textTheme.bodyLarge
```

### 3. Sử dụng custom widgets

```dart
// Primary Button với gradient
PrimaryButton(
  text: 'Đăng nhập',
  onPressed: () {},
)

// Card với theme nhất quán
ThemeCard(
  child: Text('Nội dung'),
)

// Text với màu primary
PrimaryText(
  text: 'Text quan trọng',
  fontSize: 16,
  fontWeight: FontWeight.bold,
)

// Container với màu primary
PrimaryContainer(
  child: Text('Nội dung'),
)

// Icon với màu primary
PrimaryIcon(
  icon: Icons.favorite,
  size: 24,
)

// Divider với theme
ThemeDivider()
```

## Widgets có sẵn

### ThemeCard

Container card với styling nhất quán theo theme.

### PrimaryContainer

Container với background màu primary.

### PrimaryText

Text widget với màu primary.

### PrimaryIcon

Icon widget với màu primary.

### ThemeDivider

Divider với màu theo theme.

### ThemeColorPreview

Widget để preview các màu theme (dùng cho development).

### ThemeDemo

Page demo để test tất cả components với theme mới.

## Dark Mode Support

Theme system tự động chuyển đổi giữa light và dark mode:

- Background colors
- Text colors
- Icon colors
- Card colors
- Divider colors

Màu primary `Color(0xFF9F224E)` được giữ nguyên trong cả 2 mode để đảm bảo brand consistency.

## Best Practices

1. **Luôn sử dụng Theme.of(context)** thay vì hard-code màu
2. **Sử dụng custom widgets** đã được tạo để đảm bảo consistency
3. **Test cả light và dark mode** khi phát triển UI
4. **Sử dụng ColorScheme** cho các màu semantic (primary, secondary, error, etc.)
5. **Sử dụng TextTheme** cho typography thay vì hard-code font styles

## Cập nhật theme

Để thay đổi màu chủ đạo, chỉ cần sửa trong `lib/theme/app_theme.dart`:

```dart
static const Color primaryColor = Color(0xFF9F224E); // Thay đổi ở đây
```

Tất cả components sẽ tự động cập nhật theo màu mới.
