class Weather {
  final String location;
  final double temperature;
  final int humidity;
  final double windSpeed;
  final int precipitationProbability;
  final List<int> hourlyPrecipitationProbabilities;
  final double averagePrecipitationProbability;
  final String description;
  final String dateTime;

  Weather({
    required this.location,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.precipitationProbability,
    required this.hourlyPrecipitationProbabilities,
    required this.averagePrecipitationProbability,
    required this.description,
    required this.dateTime,
  });

  factory Weather.fromJson(
    Map<String, dynamic> json,
    String location,
  ) {
    final current = json['current'];
    final hourly = json['hourly'];

    final times = List<String>.from(hourly['time']);
    final allProbabilities =
        (hourly['precipitation_probability'] as List)
            .map((value) => (value as num?)?.toInt() ?? 0)
            .toList();

    final currentTime = DateTime.parse(current['time']);

    int startIndex = times.indexWhere((time) {
      return !DateTime.parse(time).isBefore(currentTime);
    });

    if (startIndex < 0) {
      throw Exception('Не удалось получить почасовой прогноз');
    }

    final endIndex = (startIndex + 24).clamp(
      0,
      allProbabilities.length,
    );

    final next24Hours = allProbabilities.sublist(
      startIndex,
      endIndex,
    );

    if (next24Hours.isEmpty) {
      throw Exception('Нет данных для расчёта осадков');
    }

    final averageProbability =
        next24Hours.reduce((a, b) => a + b) /
        next24Hours.length;

    return Weather(
      location: location,
      temperature:
          (current['temperature_2m'] as num).toDouble(),
      humidity:
          (current['relative_humidity_2m'] as num).toInt(),
      windSpeed:
          (current['wind_speed_10m'] as num).toDouble(),
      precipitationProbability: next24Hours.first,
      hourlyPrecipitationProbabilities: next24Hours,
      averagePrecipitationProbability: averageProbability,
      description: getWeatherDescription(
        (current['weather_code'] as num).toInt(),
      ),
      dateTime: current['time'],
    );
  }

  static String getWeatherDescription(int code) {
    if (code == 0) return 'Ясно';
    if (code == 1) return 'Преимущественно ясно';
    if (code == 2) return 'Переменная облачность';
    if (code == 3) return 'Пасмурно';
    if (code == 45 || code == 48) return 'Туман';
    if (code >= 51 && code <= 57) return 'Морось';
    if (code >= 61 && code <= 67) return 'Дождь';
    if (code >= 71 && code <= 77) return 'Снег';
    if (code >= 80 && code <= 82) return 'Ливень';
    if (code >= 85 && code <= 86) return 'Снегопад';
    if (code >= 95) return 'Гроза';

    return 'Неизвестные погодные условия';
  }
}
