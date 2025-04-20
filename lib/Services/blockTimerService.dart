import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class TimerService {
  static const String blockStartKey = 'blockStartTime';
  static const int blockDuration = 1 * 60; // 10 minutes in seconds

  static Future<bool> isBlocked() async {
    final prefs = await SharedPreferences.getInstance();
    int? blockStartTime = prefs.getInt(blockStartKey);

    if (blockStartTime == null) return false;

    int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000; // In seconds
    int elapsedTime = currentTime - blockStartTime;

    return elapsedTime < blockDuration;
  }

  static Future<void> startBlockTimer() async {
    print("start block timer called");
    final prefs = await SharedPreferences.getInstance();
    int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000; // In seconds
    prefs.setInt(blockStartKey, currentTime);
  }

  static Future<void> clearBlockTimer() async {
    print("clearblocktimer called");
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(blockStartKey);
  }

  static Future<int> getRemainingTime() async {
    final prefs = await SharedPreferences.getInstance();
    int? blockStartTime = prefs.getInt(blockStartKey);

    if (blockStartTime == null) return 0;

    int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000; // In seconds
    int elapsedTime = currentTime - blockStartTime;

    return blockDuration - elapsedTime;
  }
}
