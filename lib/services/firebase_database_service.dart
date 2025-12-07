import 'package:firebase_database/firebase_database.dart';

class FirebaseDatabaseService {
  static final FirebaseDatabase _database = FirebaseDatabase.instance;

  // Temperature
  Stream<double> getTemperatureStream() {
    return _database
        .ref('ESP32C3/nhiet_do')
        .onValue
        .map((event) => double.tryParse(event.snapshot.value.toString()) ?? 0);
  }

  // Humidity
  Stream<double> getHumidityStream() {
    return _database
        .ref('ESP32C3/do_am')
        .onValue
        .map((event) => double.tryParse(event.snapshot.value.toString()) ?? 0);
  }

  // Smoke/Gas
  Stream<double> getSmokeStream() {
    return _database
        .ref('ESP32C3/mq135_raw')
        .onValue
        .map((event) => double.tryParse(event.snapshot.value.toString()) ?? 0);
  }

  // Dust - Voltage
  Stream<double> getDustVoltageStream() {
    return _database
        .ref('ESP32C3/dust_voltage')
        .onValue
        .map((event) => double.tryParse(event.snapshot.value.toString()) ?? 0);
  }

  // Dust - Density
  Stream<double> getDustDensityStream() {
    return _database
        .ref('ESP32C3/dust_density')
        .onValue
        .map((event) => double.tryParse(event.snapshot.value.toString()) ?? 0);
  }
}
