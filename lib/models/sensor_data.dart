class TemperatureData {
  final double temperature;
  final DateTime timestamp;

  TemperatureData({
    required this.temperature,
    required this.timestamp,
  });
}

class HumidityData {
  final double humidity;
  final DateTime timestamp;

  HumidityData({
    required this.humidity,
    required this.timestamp,
  });
}

class SmokeData {
  final double value;
  final DateTime timestamp;

  SmokeData({
    required this.value,
    required this.timestamp,
  });
}

class DustData {
  final double density;
  final double voltage;
  final DateTime timestamp;

  DustData({
    required this.density,
    required this.voltage,
    required this.timestamp,
  });
}

class SensorData {
  final TemperatureData? temperature;
  final HumidityData? humidity;
  final SmokeData? smoke;
  final DustData? dust;
  final DateTime timestamp;

  SensorData({
    this.temperature,
    this.humidity,
    this.smoke,
    this.dust,
    required this.timestamp,
  });
}
