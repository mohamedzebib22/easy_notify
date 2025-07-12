import 'dart:io';

void main() async {
  final androidPath = 'android/app/src/main/AndroidManifest.xml';
  final iosPath = 'ios/Runner/Info.plist';

  await _updateAndroidManifest(androidPath);
  await _updateIOSPlist(iosPath);
}

Future<void> _updateAndroidManifest(String path) async {
  final file = File(path);
  if (!file.existsSync()) {
    print('❌ AndroidManifest.xml not found.');
    return;
  }

  final content = await file.readAsString();
  if (content.contains('android.permission.POST_NOTIFICATIONS')) {
    print('✅ Android permission already exists.');
    return;
  }

  final updated = content.replaceFirst(
    '</manifest>',
    '  <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />\n</manifest>',
  );

  await file.writeAsString(updated);
  print('✅ Added POST_NOTIFICATIONS to AndroidManifest.xml');
}

Future<void> _updateIOSPlist(String path) async {
  final file = File(path);
  if (!file.existsSync()) {
    print('❌ Info.plist not found.');
    return;
  }

  final content = await file.readAsString();
  if (content.contains('NSUserNotificationAlertUsageDescription')) {
    print('✅ iOS permission already exists.');
    return;
  }

  final updated = content.replaceFirst(
    '</dict>',
    '  <key>NSUserNotificationAlertUsageDescription</key>\n'
    '  <string>Allow notifications</string>\n</dict>',
  );

  await file.writeAsString(updated);
  print('✅ Added notification description to Info.plist');
}
