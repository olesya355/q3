
import 'package:flutter/material.dart';

import '../models/weather.dart';
import '../requests/weather_api.dart';
import '../storage/hive_service.dart';

class CityWeatherScreen extends StatefulWidget {
  const CityWeatherScreen({super.key});

  @override
  State<CityWeatherScreen> createState() =>
      _CityWeatherScreenState();
}

class _CityWeatherScreenState extends State<CityWeatherScreen> {
  final TextEditingController cityController =
      TextEditingController();

  Weather? weather;
  bool isLoading = false;
  String? errorMessage;

  Future<void> searchWeather() async {
    final cityName = cityController.text.trim();

    if (cityName.isEmpty) {
      setState(() {
        errorMessage = 'Введите название города';
        weather = null;
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
      weather = null;
    });

    try {
      final result =
          await WeatherApi.getWeatherByCity(cityName);

      await HiveService.saveWeather({
        'location': result.location,
        'temperature': result.temperature,
        'humidity': result.humidity,
        'windSpeed': result.windSpeed,
        'precipitationProbability':
            result.precipitationProbability,
        'averagePrecipitationProbability':
            result.averagePrecipitationProbability,
        'description': result.description,
        'dateTime': result.dateTime,
      });

      if (!mounted) return;

      setState(() {
        weather = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString().replaceFirst(
          'Exception: ',
          '',
        );
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Погода в городе'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: cityController,
              enabled: !isLoading,
              keyboardType: TextInputType.text,
              textCapitalization:
                  TextCapitalization.sentences,
              textInputAction: TextInputAction.search,
              autocorrect: false,
              enableSuggestions: false,
              onSubmitted: (_) => searchWeather(),
              decoration: InputDecoration(
                labelText: 'Название города',
                hintText: 'Например, Москва',
                prefixIcon: const Icon(Icons.location_city),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: isLoading ? null : searchWeather,
              child: const Text('Найти погоду'),
            ),
            const SizedBox(height: 20),
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
            if (errorMessage != null)
              Text(
                errorMessage!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            if (weather != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        weather!.location,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${weather!.temperature.toStringAsFixed(1)} °C',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        weather!.description,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const Divider(height: 28),
                      _weatherInfo(
                        Icons.water_drop,
                        'Влажность',
                        '${weather!.humidity}%',
                      ),
                      _weatherInfo(
                        Icons.air,
                        'Скорость ветра',
                        '${weather!.windSpeed} км/ч',
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _weatherInfo(
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 12),
          Expanded(child: Text(title)),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
