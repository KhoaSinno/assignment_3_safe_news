class WeatherModel {
  final double temperature;
  final String description;
  final String icon;
  final String cityName;

  WeatherModel({
    required this.temperature,
    required this.description,
    required this.icon,
    required this.cityName,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      temperature: json['main']['temp'].toDouble(),
      description: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
      cityName: json['name'],
    );
  }
}