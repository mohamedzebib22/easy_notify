import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class EasyNotify {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  /// 📌 Call once at app start
  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(settings);

    await Permission.notification.request();
  }

  /// 🔔 Show instant notification
  static Future<void> showBasicNotification({
    required int id,
    required String title,
    required String body,
    String? imagePath,
  }) async {
    final androidDetails = await _buildAndroidDetails(title, body, imagePath);

    await _plugin.show(
      id,
      title,
      body,
      NotificationDetails(android: androidDetails),
    );
  }

  /// ⏰ Show notification after delay
  static Future<void> showScheduledNotification({
    required int id,
    required String title,
    required String body,
    required Duration duration,
    String? imagePath,
  }) async {
    final androidDetails = await _buildAndroidDetails(title, body, imagePath);
    final scheduleTime = DateTime.now().add(duration);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduleTime, tz.local),
      NotificationDetails(android: androidDetails),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.inexact,
    );
  }

  /// 🔁 Show repeated notification
  static Future<void> showRepeatedNotification({
    required int id,
    required String title,
    required String body,
    RepeatInterval interval = RepeatInterval.daily,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'easy_notify_channel',
      'Easy Notify',
      importance: Importance.max,
      priority: Priority.high,
    );

    await _plugin.periodicallyShow(
      id,
      title,
      body,
      interval,
      const NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.inexact,
    );
  }

  /// ❌ Cancel single notification
  static Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }

  /// ❌ Cancel all notifications
  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// 🔧 Internal helper to handle optional image
  static Future<AndroidNotificationDetails> _buildAndroidDetails(
    String title,
    String body,
    String? imagePath,
  ) async {
    String? resolvedImagePath;

    if (imagePath != null) {
      try {
        if (!File(imagePath).existsSync()) {
          final byteData = await rootBundle.load(imagePath);
          final tempDir = await getTemporaryDirectory();
          final file = File('${tempDir.path}/${imagePath.split('/').last}');
          await file.writeAsBytes(byteData.buffer.asUint8List());
          resolvedImagePath = file.path;
        } else {
          resolvedImagePath = imagePath;
        }
      } catch (e) {
        print('⚠️ Failed to load image for notification: $e');
      }
    }

    if (resolvedImagePath != null && File(resolvedImagePath).existsSync()) {
      return AndroidNotificationDetails(
        'easy_notify_channel',
        'Easy Notify',
        styleInformation: BigPictureStyleInformation(
          FilePathAndroidBitmap(resolvedImagePath),
          contentTitle: title,
          summaryText: body,
        ),
        importance: Importance.max,
        priority: Priority.high,
      );
    } else {
      return const AndroidNotificationDetails(
        'easy_notify_channel',
        'Easy Notify',
        importance: Importance.max,
        priority: Priority.high,
      );
    }
  }
}
