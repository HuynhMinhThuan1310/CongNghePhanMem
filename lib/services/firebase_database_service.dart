import 'dart:async';
import 'package:firebase_database/firebase_database.dart';

class FirebaseDatabaseService {
  static final FirebaseDatabase _database = FirebaseDatabase.instance;
  final DatabaseReference _db = _database.ref();

  static const Duration disconnectTimeout = Duration(seconds: 10);

  static DateTime? _lastUpdate;

  static StreamSubscription<DatabaseEvent>? _hbSub;

  static final Stream<DatabaseEvent> _lastSeenEvents$ = _database
      .ref('ESP32C3/last_seen')
      .onValue
      .asBroadcastStream();

  FirebaseDatabaseService() {
    _ensureHeartbeat();
  }

  void _ensureHeartbeat() {
    if (_hbSub != null) return;

    _hbSub = _lastSeenEvents$.listen((event) {
      _lastUpdate = DateTime.now();
    });
  }

  bool get isDisconnected {
    final last = _lastUpdate;
    if (last == null) return true;
    return DateTime.now().difference(last) > disconnectTimeout;
  }

  Stream<DatabaseEvent> getLastSeenStream() => _lastSeenEvents$;

  double _mapEvent(DatabaseEvent event, {String? historyKey}) {
    _lastUpdate = DateTime.now();

    final v = event.snapshot.value;
    if (v == null) return 0;

    final value = v is num ? v.toDouble() : double.tryParse(v.toString()) ?? 0;

    if (historyKey != null) {
      _saveHistory(sensorKey: historyKey, value: value);
    }

    return value;
  }

  Future<void> _saveHistory({
    required String sensorKey,
    required double value,
  }) async {
    final now = DateTime.now();

    final dateKey =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    final timeKey =
        "${now.hour.toString().padLeft(2, '0')}:"
        "${now.minute.toString().padLeft(2, '0')}:"
        "${now.second.toString().padLeft(2, '0')}";

    await _db
        .child("history")
        .child(sensorKey)
        .child(dateKey)
        .child(timeKey)
        .set(value);
  }

  Stream<double> getTemperatureStream() {
    return _database
        .ref('ESP32C3/nhiet_do')
        .onValue
        .map((e) => _mapEvent(e, historyKey: "nhiet_do"));
  }

  Stream<double> getHumidityStream() {
    return _database
        .ref('ESP32C3/do_am')
        .onValue
        .map((e) => _mapEvent(e, historyKey: "do_am"));
  }

  Stream<double> getSmokeStream() {
    return _database
        .ref('ESP32C3/mq135_raw')
        .onValue
        .map((e) => _mapEvent(e, historyKey: "mq135"));
  }

  Stream<double> getDustDensityStream() {
    return _database
        .ref('ESP32C3/dust_density')
        .onValue
        .map((e) => _mapEvent(e, historyKey: "dust_density"));
  }

  Future<Map<String, double>> getHistoryByDate({
    required String sensorKey,
    required String dateKey, // yyyy-MM-dd
  }) async {
    final snapshot = await _db
        .child("history")
        .child(sensorKey)
        .child(dateKey)
        .get();

    if (!snapshot.exists) return {};

    final raw = Map<String, dynamic>.from(snapshot.value as Map);
    return raw.map((k, v) => MapEntry(k, (v as num).toDouble()));
  }

  static Future<void> disposeHeartbeat() async {
    await _hbSub?.cancel();
    _hbSub = null;
  }
}
