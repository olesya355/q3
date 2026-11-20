
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class RadarScreen extends StatelessWidget {
  const RadarScreen({super.key});

  Future<void> openRadar(BuildContext context) async {
    try {
      bool serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        showMessage(context, 'Включи геолокацию на устройстве');
        return;
      }

      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        showMessage(context, 'Разреши приложению доступ к геолокации');
        return;
      }

      Position position =
          await Geolocator.getCurrentPosition();

      final latitude = position.latitude;
      final longitude = position.longitude;

      final radarUrl = Uri.parse(
        'https://www.windy.com/?radar,$latitude,$longitude,7',
      );

      final opened = await launchUrl(
        radarUrl,
        mode: LaunchMode.externalApplication,
      );

      if (!opened) {
        showMessage(context, 'Не удалось открыть радар');
      }
    } catch (e) {
      showMessage(context, 'Ошибка открытия радара: $e');
    }
  }

  void showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.radar,
                  size: 85,
                  color: Colors.blue,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Радар осадков',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'На карте отображаются области дождя '
                  'и снега. Можно посмотреть интенсивность '
                  'осадков и проследить за их перемещением.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => openRadar(context),
                  icon: const Icon(Icons.map),
                  label: const Text('Открыть радар осадков'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
