// lib/services/sensor_status.dart
import 'package:flutter/material.dart';

class SensorStatus {
  // ---------- Temperature ----------
  static String tempStatus(double t) {
    if (t < 20) return "Lạnh";
    if (t < 25) return "Mát mẻ";
    if (t < 30) return "Ấm áp";
    return "Nóng";
  }

  static Color tempColor(double t) {
    if (t < 20) return Colors.blue;
    if (t < 25) return Colors.green;
    if (t < 30) return Colors.orange;
    return Colors.red;
  }

  // ---------- Humidity ----------
  static String humStatus(double h) {
    if (h < 30) return "Quá khô";
    if (h < 40) return "Khô";
    if (h < 60) return "Thoải mái";
    if (h < 70) return "Hơi ẩm";
    return "Quá ẩm";
  }

  static Color humColor(double h) {
    if (h < 30) return Colors.red;
    if (h < 40) return Colors.orange;
    if (h < 60) return Colors.green;
    if (h < 70) return Colors.blue;
    return Colors.purple;
  }

  // ---------- Dust ----------
  static String dustStatus(double d) {
    if (d < 50) return "Tốt";
    if (d < 100) return "Trung bình";
    if (d < 150) return "Kém";
    return "Nguy hiểm";
  }

  static Color dustColor(double d) {
    if (d < 50) return Colors.green;
    if (d < 100) return Colors.yellow;
    if (d < 150) return Colors.orange;
    return Colors.red;
  }

  // ---------- Smoke / Gas ----------
  static String smokeStatus(double v) {
    if (v < 600) return "An toàn";
    if (v < 1000) return "Nhẹ";
    if (v < 2000) return "Trung bình";
    return "Nguy hiểm";
  }

  static Color smokeColor(double v) {
    if (v < 500) return Colors.green;
    if (v < 1000) return Colors.yellow;
    if (v < 2000) return Colors.orange;
    return Colors.red;
  }
}