import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../providers/weather_provider.dart';

class DebugPage extends ConsumerStatefulWidget {
  const DebugPage({super.key});

  @override
  ConsumerState<DebugPage> createState() => _DebugPageState();
}

class _DebugPageState extends ConsumerState<DebugPage> {
  String _debugInfo = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug - Weather & Location'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Debug Information',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),

            // API Key Status
            _buildSection(title: 'API Key Status', content: _getApiKeyStatus()),

            const SizedBox(height: 16),

            // Test Buttons
            Row(
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _testLocation,
                  child: const Text('Test Location'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _isLoading ? null : _testWeather,
                  child: const Text('Test Weather'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _clearDebugInfo,
                  child: const Text('Clear'),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Debug Output
            if (_debugInfo.isNotEmpty)
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      _debugInfo,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),

            if (_isLoading) const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(content, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  String _getApiKeyStatus() {
    final apiKey = dotenv.env['WEATHER_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      return '❌ API Key không được thiết lập trong file .env';
    } else if (apiKey == 'YOUR_OPENWEATHERMAP_API_KEY') {
      return '⚠️ API Key chưa được thay thế (vẫn là placeholder)';
    } else {
      return '✅ API Key đã được thiết lập: ${apiKey.substring(0, 6)}...';
    }
  }

  Future<void> _testLocation() async {
    setState(() {
      _isLoading = true;
      _debugInfo = 'Testing location services...\n\n';
    });

    try {
      _addDebugInfo('1. Checking location service enabled...');
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      _addDebugInfo('   Location service enabled: $serviceEnabled');

      if (!serviceEnabled) {
        _addDebugInfo('❌ Location services are disabled!');
        setState(() => _isLoading = false);
        return;
      }

      _addDebugInfo('\n2. Checking location permissions...');
      LocationPermission permission = await Geolocator.checkPermission();
      _addDebugInfo('   Current permission: $permission');

      if (permission == LocationPermission.denied) {
        _addDebugInfo('   Requesting permission...');
        permission = await Geolocator.requestPermission();
        _addDebugInfo('   Permission after request: $permission');
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _addDebugInfo('❌ Location permission denied!');
        setState(() => _isLoading = false);
        return;
      }

      _addDebugInfo('\n3. Getting current position...');
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      _addDebugInfo('✅ Location obtained successfully:');
      _addDebugInfo('   Latitude: ${position.latitude}');
      _addDebugInfo('   Longitude: ${position.longitude}');
      _addDebugInfo('   Accuracy: ${position.accuracy}m');
      _addDebugInfo('   Timestamp: ${position.timestamp}');
    } catch (e, stackTrace) {
      _addDebugInfo('❌ Error getting location: $e');
      _addDebugInfo('Stack trace: ${stackTrace.toString()}');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _testWeather() async {
    setState(() {
      _isLoading = true;
      _debugInfo = 'Testing weather API...\n\n';
    });

    try {
      final weatherRepository = ref.read(weatherRepositoryProvider);
      _addDebugInfo('1. Getting weather data...');

      final weather = await weatherRepository.getCurrentWeather();

      if (weather != null) {
        _addDebugInfo('✅ Weather data obtained successfully:');
        _addDebugInfo('   City: ${weather.cityName}');
        _addDebugInfo('   Temperature: ${weather.temperature}°C');
        _addDebugInfo('   Description: ${weather.description}');
        _addDebugInfo('   Icon: ${weather.icon}');
      } else {
        _addDebugInfo('❌ Failed to get weather data');
      }
    } catch (e, stackTrace) {
      _addDebugInfo('❌ Error getting weather: $e');
      _addDebugInfo('Stack trace: ${stackTrace.toString()}');
    }

    setState(() => _isLoading = false);
  }

  void _addDebugInfo(String info) {
    setState(() {
      _debugInfo += '$info\n';
    });
  }

  void _clearDebugInfo() {
    setState(() {
      _debugInfo = '';
    });
  }
}
