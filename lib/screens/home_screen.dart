
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/weather_cubit.dart';
import '../cubit/weather_state.dart';
import '../models/weather.dart';
import 'history_screen.dart';
import 'city_weather_screen.dart';
import 'calculation_screen.dart';
import 'radar_screen.dart';
import 'developer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final titles = [
      'Погода',
      'Погода в городе',
      'История погоды',
      'Расчёты',
      'Радар осадков',
      'Разработчик',
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FA),
      appBar: AppBar(
        title: Text(
          titles[selectedIndex],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (selectedIndex == 0)
            IconButton(
              onPressed: () {
                context.read<WeatherCubit>().loadCurrentWeather();
              },
              icon: const Icon(Icons.refresh),
              tooltip: 'Обновить погоду',
            ),
        ],
      ),
      body: IndexedStack(
        index: selectedIndex,
        children: [
          buildWeatherScreen(),
          const CityWeatherScreen(),
          const HistoryScreen(),
          const CalculationScreen(),
          const RadarScreen(),
          const DeveloperScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.cloud),
            label: 'Погода',
          ),
          NavigationDestination(
            icon: Icon(Icons.location_city),
            label: 'Город',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: 'История',
          ),
          NavigationDestination(
            icon: Icon(Icons.calculate),
            label: 'Расчёты',
          ),
          NavigationDestination(
            icon: Icon(Icons.radar),
            label: 'Радар',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Разработчик',
          ),
        ],
      ),
    );
  }

  Widget buildWeatherScreen() {
    return BlocBuilder<WeatherCubit, WeatherState>(
      builder: (context, state) {
        if (state is WeatherInitial || state is WeatherLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is WeatherError) {
          final message = state.message.replaceFirst(
            'Exception: ',
            '',
          );

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.cloud_off,
                    size: 60,
                    color: Colors.blueGrey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      context
                          .read<WeatherCubit>()
                          .loadCurrentWeather();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Попробовать снова'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is WeatherLoaded) {
          return buildWeatherContent(state.weather);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget buildWeatherContent(Weather weather) {
    return RefreshIndicator(
      onRefresh: () {
        return context
            .read<WeatherCubit>()
            .loadCurrentWeather();
      },
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF2196F3),
                  Color(0xFF64B5F6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  weather.location,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                const Icon(
                  Icons.cloud,
                  color: Colors.white,
                  size: 65,
                ),
                const SizedBox(height: 12),
                Text(
                  '${weather.temperature.toStringAsFixed(1)} °C',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 46,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  weather.description,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Показатели погоды',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: WeatherInfoCard(
                  icon: Icons.water_drop,
                  title: 'Влажность',
                  value: '${weather.humidity}%',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: WeatherInfoCard(
                  icon: Icons.air,
                  title: 'Скорость ветра',
                  value: '${weather.windSpeed} км/ч',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Последнее обновление: ${weather.dateTime}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Потяните экран вниз, чтобы обновить погоду',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class WeatherInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const WeatherInfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 22,
        horizontal: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.blue,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
