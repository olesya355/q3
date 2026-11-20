
import 'package:flutter/material.dart';
import '../storage/hive_service.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = HiveService.getWeatherHistory();

    if (history.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 60,
              color: Colors.grey,
            ),
            SizedBox(height: 10),
            Text(
              'История пока пуста',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final item = history[index];

        final temperature =
            (item['temperature'] as num).toStringAsFixed(1);
        final humidity = item['humidity'];
        final windSpeed = item['windSpeed'];
        final probability = item['precipitationProbability'];
        final description = item['description'];
        final location = item['location'];
        final dateTime = item['dateTime'];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '$location',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '$temperature °C — $description',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text('Влажность: $humidity%'),
                Text('Скорость ветра: $windSpeed км/ч'),
                Text('Вероятность дождя: $probability%'),
                const SizedBox(height: 8),
                Text(
                  'Время: $dateTime',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
