import 'package:assignment_3_safe_news/providers/weather_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WeatherWidget extends ConsumerStatefulWidget {
  const WeatherWidget({super.key});

  @override
  ConsumerState<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends ConsumerState<WeatherWidget> {
  bool _shouldLoadWeather = false;

  @override
  void initState() {
    super.initState();
    // Delay 3 giây trước khi bắt đầu load weather
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        setState(() {
          _shouldLoadWeather = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Kiểm tra API key trước - với xử lý safe cho test
    String apiKey = '';
    try {
      apiKey = (dotenv.env['WEATHER_API_KEY'] ?? '').trim();
    } catch (e) {
      // dotenv chưa được khởi tạo (trong test hoặc lỗi khác)
      apiKey = '';
    }

    if (apiKey.isEmpty || apiKey == 'YOUR_OPENWEATHERMAP_API_KEY') {
      return Row(
        children: [
          Icon(
            Icons.cloud_off,
            color: Theme.of(context).colorScheme.error,
            size: 24,
          ),
          const SizedBox(width: 5),
          Text(
            'No API Key',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      );
    }

    // Nếu chưa đến thời gian load weather, hiển thị trạng thái mặc định
    if (!_shouldLoadWeather) {
      return Row(
        children: [
          Icon(
            Icons.wb_sunny,
            color: Theme.of(context).iconTheme.color,
            size: 24,
          ),
          const SizedBox(width: 5),
          Text(
            '--°C',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    final weatherAsync = ref.watch(weatherProvider);
    final weatherRepository = ref.watch(weatherRepositoryProvider);

    return weatherAsync.when(
      data: (weather) {
        if (weather == null) {
          return Row(
            children: [
              Icon(
                Icons.wb_sunny,
                color: Theme.of(context).iconTheme.color,
                size: 24,
              ),
              const SizedBox(width: 5),
              Text(
                '--°C',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );
        }

        return Row(
          children: [
            Icon(
              weatherRepository.getWeatherIcon(weather.icon),
              color: Theme.of(context).iconTheme.color,
              size: 24,
            ),
            const SizedBox(width: 5),
            Text(
              '${weather.temperature.round()}°C',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      },
      loading:
          () => Row(
            children: [
              // Bỏ hiệu ứng xoay CircularProgressIndicator
              Icon(
                Icons.more_horiz,
                color: Theme.of(context).iconTheme.color,
                size: 24,
              ),
              const SizedBox(width: 5),
              Text(
                '',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
      error:
          (error, stack) => Row(
            children: [
              Icon(
                Icons.location_off,
                color: Theme.of(context).colorScheme.error,
                size: 24,
              ),
              const SizedBox(width: 5),
              Text(
                'Location Error',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
    );
  }
}
