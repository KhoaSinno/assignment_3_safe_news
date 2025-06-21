import 'package:assignment_3_safe_news/providers/weather_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WeatherWidget extends ConsumerWidget {
  const WeatherWidget({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Kiểm tra API key trước - với xử lý safe cho test
    String apiKey = '';
    try {
      apiKey = (dotenv.env['WEATHER_API_KEY'] ?? '').trim();
      print(
        'Debug: API key loaded: ${apiKey.isNotEmpty ? "Yes (${apiKey.length} chars)" : "No"}',
      );
    } catch (e) {
      // dotenv chưa được khởi tạo (trong test hoặc lỗi khác)
      print('Debug: Failed to load dotenv: $e');
      apiKey = '';
    }

    if (apiKey.isEmpty || apiKey == 'YOUR_OPENWEATHERMAP_API_KEY') {
      print('Debug: API key is empty or placeholder: "$apiKey"');
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

    print('Debug: API key is valid, proceeding to weather provider');
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
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).iconTheme.color ?? Colors.grey,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Loading...',
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
