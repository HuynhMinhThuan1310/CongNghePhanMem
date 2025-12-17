import 'dart:async';
import 'package:firebase_database/firebase_database.dart';

class FirebaseDatabaseService {
  static final FirebaseDatabase _database = FirebaseDatabase.instance;

  // ===== TIMEOUT: quá thời gian này mà không có data => MẤT TÍN HIỆU
  static const Duration disconnectTimeout = Duration(seconds: 10);

  DateTime? _lastUpdate;

  // ===== PUBLIC: UI dùng để check trạng thái
  bool get isDisconnected {
    if (_lastUpdate == null) return true;
    return DateTime.now().difference(_lastUpdate!) > disconnectTimeout;
  }

  // ===== INTERNAL: parse + update timestamp
  double _mapEvent(DatabaseEvent event) {
    _lastUpdate = DateTime.now(); // ⭐ CỐT LÕI SỬA LỖI
    final v = event.snapshot.value;
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  // ===== STREAMS =====

  Stream<double> getTemperatureStream() {
    return _database.ref('ESP32C3/nhiet_do').onValue.map(_mapEvent);
  }

  Stream<double> getHumidityStream() {
    return _database.ref('ESP32C3/do_am').onValue.map(_mapEvent);
  }

  Stream<double> getSmokeStream() {
    return _database.ref('ESP32C3/mq135_raw').onValue.map(_mapEvent);
  }

  Stream<double> getDustVoltageStream() {
    return _database.ref('ESP32C3/dust_voltage').onValue.map(_mapEvent);
  }

  Stream<double> getDustDensityStream() {
    return _database.ref('ESP32C3/dust_density').onValue.map(_mapEvent);
  }
}
