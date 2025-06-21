import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../model/weather_model.dart';

class WeatherRepository {
  // Lấy API key từ .env file
  static String get _apiKey => dotenv.env['WEATHER_API_KEY'] ?? '';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  Future<WeatherModel?> getCurrentWeather() async {
    try {
      print('Debug: Starting weather fetch...');

      // Lấy vị trí hiện tại
      Position position = await _getCurrentPosition();
      print('Debug: Got location: ${position.latitude}, ${position.longitude}');

      // Gọi API thời tiết
      final url =
          '$_baseUrl/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$_apiKey&units=metric&lang=vi';

      print('Debug: Calling weather API...');
      final response = await http.get(Uri.parse(url));
      print('Debug: API response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(
          'Debug: Weather data received: ${data['name']}, ${data['main']['temp']}°C',
        );
        return WeatherModel.fromJson(data);
      } else {
        print('Debug: API error: ${response.statusCode} - ${response.body}');
      }
      return null;
    } on PlatformException catch (e) {
      print('Platform error getting location: ${e.message}');
      // Trả về thời tiết mặc định cho Hà Nội
      return _getDefaultWeather();
    } catch (e) {
      print('Error fetching weather: $e');
      // Trả về thời tiết mặc định cho Hà Nội
      return _getDefaultWeather();
    }
  }

  Future<WeatherModel?> _getDefaultWeather() async {
    try {
      print('Debug: Using default location (Hanoi)...');
      // Sử dụng tọa độ mặc định của Hà Nội
      const double defaultLat = 21.0285;
      const double defaultLon = 105.8542;

      final url =
          '$_baseUrl/weather?lat=$defaultLat&lon=$defaultLon&appid=$_apiKey&units=metric&lang=vi';

      print('Debug: Calling default weather API...');
      final response = await http.get(Uri.parse(url));
      print('Debug: Default API response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(
          'Debug: Default weather data: ${data['name']}, ${data['main']['temp']}°C',
        );
        return WeatherModel.fromJson(data);
      } else {
        print(
          'Debug: Default API error: ${response.statusCode} - ${response.body}',
        );
      }
      return null;
    } catch (e) {
      print('Error fetching default weather: $e');
      return null;
    }
  }

  Future<Position> _getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Kiểm tra GPS có bật không
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition();
  }

  IconData getWeatherIcon(String iconCode) {
    switch (iconCode) {
      case '01d':
      case '01n':
        return Icons.wb_sunny;
      case '02d':
      case '02n':
      case '03d':
      case '03n':
        return Icons.wb_cloudy;
      case '04d':
      case '04n':
        return Icons.cloud;
      case '09d':
      case '09n':
      case '10d':
      case '10n':
        return Icons.grain;
      case '11d':
      case '11n':
        return Icons.flash_on;
      case '13d':
      case '13n':
        return Icons.ac_unit;
      case '50d':
      case '50n':
        return Icons.foggy;
      default:
        return Icons.wb_sunny;
    }
  }
}
