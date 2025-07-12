import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class EasyNotifyPermissions {
  static Future<void> requestAll() async {
    // 📢 Notification Permission
    final notif = await Permission.notification.request();
    debugPrint("✅ Notification Permission: $notif");

    // 🔋 Battery Optimization (تفتح له إعدادات توفير البطارية)
    if (Platform.isAndroid) {
      await _openBatterySettings();
    }

    // ⏰ Exact Alarm Permission (Android 12+)
    if (Platform.isAndroid && await _isAndroid12OrHigher()) {
      final allowed = await _isExactAlarmAllowed();
      debugPrint("⏰ Exact Alarm Allowed: $allowed");
      if (!allowed) {
        await _openExactAlarmSettings();
      }
    }
  }

  static Future<bool> _isAndroid12OrHigher() async {
    const MethodChannel _channel = MethodChannel('easy_notify_permissions');
    try {
      final sdkInt = await _channel.invokeMethod<int>('getSdkInt');
      return (sdkInt ?? 0) >= 31;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> _isExactAlarmAllowed() async {
    const MethodChannel _channel = MethodChannel('flutter_local_notifications_plugin');
    try {
      return await _channel.invokeMethod('areExactAlarmsPermitted') ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> _openExactAlarmSettings() async {
    const MethodChannel _channel = MethodChannel('flutter_local_notifications_plugin');
    try {
      await _channel.invokeMethod('requestExactAlarmsPermission');
    } catch (e) {
      debugPrint('⚠️ Failed to open exact alarm settings: $e');
    }
  }

  static Future<void> _openBatterySettings() async {
    const MethodChannel _channel = MethodChannel('easy_notify_permissions');
    try {
      await _channel.invokeMethod('openBatterySettings');
    } catch (e) {
      debugPrint('⚠️ Failed to open battery settings: $e');
    }
  }
}
