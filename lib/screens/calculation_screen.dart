
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/weather_cubit.dart';
import '../cubit/weather_state.dart';
import '../models/weather.dart';
import '../storage/hive_service.dart';

class CalculationScreen extends StatefulWidget {
  const CalculationScreen({super.key});

  @override
  State<CalculationScreen> createState() =>
      _CalculationScreenState();
}

class _CalculationScreenState extends State<CalculationScreen> {
  String? lastSavedKey;

  String getProbabilityDescription(double probability) {
    if (probability <= 30) {
      return 'Низкая вероятность осадков';
    } else if (probability <= 60) {
      return 'Умеренная вероятность осадков';
    } else {
      return 'Высокая вероятность осадков';
    }
  }

  Color getProbabilityColor(double probability) {
    if (probability <= 30) {
      return Colors.green;
    } else if (probability <= 60) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Future<void> saveCalculation(Weather weather) async {
    final probability =
        weather.averagePrecipitationProbability;

    final saveKey =
        '${weather.location}_${weather.dateTime}_$probability';

    if (lastSavedKey == saveKey) return;

    await HiveService.saveCalculation({
      'probability': probability,
      'description': getProbabilityDescription(probability),
      'location': weather.location,
      'dateTime': DateTime.now().toString(),
    });

    if (!mounted) return;

    setState(() {
      lastSavedKey = saveKey;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Результат сохранён'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeatherCubit, WeatherState>(
      builder: (context, state) {
        if (state is WeatherInitial ||
            state is WeatherLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is WeatherError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Не удалось получить данные погоды.\n'
                '${state.message}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        if (state is WeatherLoaded) {
          return buildCalculation(state.weather);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget buildCalculation(Weather weather) {
    final probability =
        weather.averagePrecipitationProbability;

    final description =
        getProbabilityDescription(probability);

    final color = getProbabilityColor(probability);

    final saveKey =
        '${weather.location}_${weather.dateTime}_$probability';

    final isSaved = lastSavedKey == saveKey;

    final history = HiveService.getCalculationHistory();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 15),
        const Icon(
          Icons.water_drop,
          size: 60,
          color: Colors.blue,
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              children: [
                Text(
                  weather.location,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                Text(
                  '${probability.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Вероятность осадков',
                  style: TextStyle(fontSize: 17),
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: isSaved
                      ? null
                      : () => saveCalculation(weather),
                  icon: const Icon(Icons.save),
                  label: Text(
                    isSaved
                        ? 'Сохранено'
                        : 'Сохранить результат',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 25),
        const Text(
          'История расчётов',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        if (history.isEmpty)
          const Text('История расчётов пока пуста'),
        ...history.map((item) {
          final value =
              (item['probability'] as num).toDouble();

          return Card(
            child: ListTile(
              leading: const Icon(
                Icons.water_drop,
                color: Colors.blue,
              ),
              title: Text(
                '${value.toStringAsFixed(1)}%',
              ),
              subtitle: Text(
                '${item['description'] ?? getProbabilityDescription(value)}\n'
                '${item['location'] ?? ''}\n'
                '${item['dateTime'] ?? ''}',
              ),
            ),
          );
        }),
      ],
    );
  }
}
