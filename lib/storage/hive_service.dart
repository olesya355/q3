
import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String weatherBoxName = 'weather_history';
  static const String calculationBoxName = 'calculation_history';

  static Future<void> init() async {
    await Hive.initFlutter();

    await Hive.openBox(weatherBoxName);
    await Hive.openBox(calculationBoxName);
  }

  static Box get weatherBox => Hive.box(weatherBoxName);

  static Box get calculationBox => Hive.box(calculationBoxName);

  static Future<void> saveWeather(Map<String, dynamic> weather) async {
    await weatherBox.add(weather);
  }

  static List<Map> getWeatherHistory() {
    return weatherBox.values.cast<Map>().toList().reversed.toList();
  }

  static Future<void> saveCalculation(Map<String, dynamic> calculation) async {
    await calculationBox.add(calculation);
  }

  static List<Map> getCalculationHistory() {
    return calculationBox.values.cast<Map>().toList().reversed.toList();
  }
}
