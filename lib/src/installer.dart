import 'dart:io';

class EasyNotifyInstaller {
  static Future<void> run() async {
    await _updateAndroidManifest();
    await _updateIOSInfoPlist(); // ✅ إضافة دعم iOS
  }

  static Future<void> _updateAndroidManifest() async {
    final path = 'android/app/src/main/AndroidManifest.xml';
    final file = File(path);

    if (!file.existsSync()) {
      print('❌ AndroidManifest.xml not found.');
      return;
    }

    String content = await file.readAsString();

    final permissions = [
      'POST_NOTIFICATIONS',
      'SCHEDULE_EXACT_ALARM',
      'USE_EXACT_ALARM',
      'RECEIVE_BOOT_COMPLETED',
      'WAKE_LOCK',
    ];

    final receivers = '''
        <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
        <receiver android:exported="true" android:enabled="true" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED"/>
                <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
                <action android:name="android.intent.action.QUICKBOOT_POWERON" />
                <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
            </intent-filter>
        </receiver>
        <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ActionBroadcastReceiver" />
    ''';

    bool updated = false;

    for (var permission in permissions) {
      final line = '<uses-permission android:name="android.permission.$permission" />';
      if (!content.contains(line)) {
        content = content.replaceFirst('</manifest>', '  $line\n</manifest>');
        print('✅ Added $permission permission.');
        updated = true;
      }
    }

    if (!content.contains('ScheduledNotificationReceiver')) {
      content = content.replaceFirst('</activity>', '</activity>\n$receivers');
      print('✅ Added receiver block.');
      updated = true;
    }

    if (updated) {
      await file.writeAsString(content);
      print('✅ AndroidManifest.xml updated.');
    } else {
      print('ℹ️ AndroidManifest.xml already up to date.');
    }
  }

  static Future<void> _updateIOSInfoPlist() async {
    final path = 'ios/Runner/Info.plist';
    final file = File(path);

    if (!file.existsSync()) {
      print('❌ Info.plist not found.');
      return;
    }

    String content = await file.readAsString();
    bool updated = false;

    // UIBackgroundModes
    if (!content.contains('<key>UIBackgroundModes</key>')) {
      final backgroundModes = '''
  <key>UIBackgroundModes</key>
  <array>
    <string>fetch</string>
    <string>remote-notification</string>
  </array>
''';
      content = content.replaceFirst('</dict>', '$backgroundModes\n</dict>');
      print('✅ Added UIBackgroundModes.');
      updated = true;
    }

    // NSUserTrackingUsageDescription
    if (!content.contains('<key>NSUserTrackingUsageDescription</key>')) {
      final trackingUsage = '''
  <key>NSUserTrackingUsageDescription</key>
  <string>This identifier will be used to deliver personalized ads to you.</string>
''';
      content = content.replaceFirst('</dict>', '$trackingUsage\n</dict>');
      print('✅ Added NSUserTrackingUsageDescription.');
      updated = true;
    }

    // NSCalendarsUsageDescription
    if (!content.contains('<key>NSCalendarsUsageDescription</key>')) {
      final calendarUsage = '''
  <key>NSCalendarsUsageDescription</key>
  <string>We use your calendar for scheduling notifications</string>
''';
      content = content.replaceFirst('</dict>', '$calendarUsage\n</dict>');
      print('✅ Added NSCalendarsUsageDescription.');
      updated = true;
    }

    // FirebaseAppDelegateProxyEnabled (اختياري)
    if (!content.contains('<key>FirebaseAppDelegateProxyEnabled</key>')) {
      final proxySetting = '''
  <key>FirebaseAppDelegateProxyEnabled</key>
  <false/>
''';
      content = content.replaceFirst('</dict>', '$proxySetting\n</dict>');
      print('✅ Added FirebaseAppDelegateProxyEnabled = false.');
      updated = true;
    }

    if (updated) {
      await file.writeAsString(content);
      print('✅ Info.plist updated.');
    } else {
      print('ℹ️ Info.plist already up to date.');
    }
  }
}
