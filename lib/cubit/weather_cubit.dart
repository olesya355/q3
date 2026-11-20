
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../models/weather.dart';
import '../requests/weather_api.dart';
import '../storage/hive_service.dart';
import 'weather_state.dart';

class WeatherCubit extends Cubit<WeatherState> {
  WeatherCubit() : super(WeatherInitial());

  Future<void> loadCurrentWeather() async {
    emit(WeatherLoading());

    try {
      final serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        throw Exception('Включите геолокацию на устройстве');
      }

      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception(
          'Нет разрешения на использование геолокации',
        );
      }

      Position? position;

      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 10),
          ),
        );
      } catch (_) {
        position = await Geolocator.getLastKnownPosition()
            .timeout(
          const Duration(seconds: 3),
          onTimeout: () => null,
        );
      }

      if (position == null) {
        throw Exception(
          'Не удалось определить местоположение',
        );
      }

      final location = await getCityName(
        position.latitude,
        position.longitude,
      );

      final weather = await WeatherApi.getWeather(
        latitude: position.latitude,
        longitude: position.longitude,
        location: location,
      );

      await _saveWeather(weather);

      emit(WeatherLoaded(weather));
    } catch (e) {
      emit(WeatherError(e.toString()));
    }
  }

  Future<String> getCityName(
    double latitude,
    double longitude,
  ) async {
    try {
      final url = Uri.https(
        'nominatim.openstreetmap.org',
        '/reverse',
        {
          'format': 'jsonv2',
          'lat': latitude.toString(),
          'lon': longitude.toString(),
          'zoom': '10',
          'addressdetails': '1',
        },
      );

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'Lab7WeatherApp/1.0',
          'Accept-Language': 'ru',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception('Не удалось определить город');
      }

      final data = jsonDecode(response.body);
      final address = data['address'];

      final city = address['city'] ??
          address['town'] ??
          address['village'] ??
          address['municipality'] ??
          address['county'];

      if (city == null) {
        return 'Моё местоположение';
      }

      return city.toString();
    } catch (e) {
      debugPrint('Ошибка определения города: $e');
      return 'Моё местоположение';
    }
  }

  Future<void> loadWeatherByCity(String cityName) async {
    emit(WeatherLoading());

    try {
      final weather =
          await WeatherApi.getWeatherByCity(cityName);

      await _saveWeather(weather);

      emit(WeatherLoaded(weather));
    } catch (e) {
      emit(WeatherError(e.toString()));
    }
  }

  Future<void> _saveWeather(Weather weather) async {
    await HiveService.saveWeather({
      'location': weather.location,
      'temperature': weather.temperature,
      'humidity': weather.humidity,
      'windSpeed': weather.windSpeed,
      'precipitationProbability':
          weather.precipitationProbability,
      'averagePrecipitationProbability':
          weather.averagePrecipitationProbability,
      'description': weather.description,
      'dateTime': weather.dateTime,
    });
  }
}
