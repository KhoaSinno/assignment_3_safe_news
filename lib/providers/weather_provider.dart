import 'package:assignment_3_safe_news/features/home/model/weather_model.dart';
import 'package:assignment_3_safe_news/features/home/repository/weather_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  return WeatherRepository();
});

final weatherProvider = FutureProvider<WeatherModel?>((ref) async {
  final repository = ref.watch(weatherRepositoryProvider);
  return await repository.getCurrentWeather();
});
