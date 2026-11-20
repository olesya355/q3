
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/weather.dart';

class WeatherApi {
  static Future<Weather> getWeatherByCity(String cityName) async {
    final url = Uri.https(
      'geocoding-api.open-meteo.com',
      '/v1/search',
      {
        'name': cityName,
        'count': '1',
        'language': 'ru',
        'format': 'json',
      },
    );

    final response = await http.get(url).timeout(
      const Duration(seconds: 15),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Ошибка поиска города: ${response.statusCode}',
      );
    }

    final data = jsonDecode(response.body);
    final results = data['results'];

    if (results == null || results.isEmpty) {
      throw Exception('Город не найден. Проверьте название.');
    }

    final city = results[0];

    final latitude = (city['latitude'] as num).toDouble();
    final longitude = (city['longitude'] as num).toDouble();

    final locationParts = [
      city['name'],
      city['admin1'],
      city['country'],
    ].where(
      (part) => part != null && part.toString().isNotEmpty,
    );

    return getWeather(
      latitude: latitude,
      longitude: longitude,
      location: locationParts.join(', '),
    );
  }

  static Future<Weather> getWeather({
    required double latitude,
    required double longitude,
    required String location,
  }) async {
    final url = Uri.https(
      'api.open-meteo.com',
      '/v1/forecast',
      {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'current':
            'temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m',
        'hourly': 'precipitation_probability',
        'forecast_days': '2',
        'timezone': 'auto',
      },
    );

    try {
      debugPrint('Отправляем запрос к Open-Meteo');
      debugPrint('URL: $url');

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 30),
      );

      debugPrint('HTTP STATUS: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw Exception(
          'Ошибка Open-Meteo: ${response.statusCode}',
        );
      }

      final data = jsonDecode(response.body);

      return Weather.fromJson(data, location);
    } catch (e) {
      debugPrint('ОШИБКА WeatherApi: $e');
      rethrow;
    }
  }
}
