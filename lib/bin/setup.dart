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

  String content = await file.readAsString();
  final permissionsToAdd = <String, String>{
    'POST_NOTIFICATIONS': '<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />',
    'SCHEDULE_EXACT_ALARM': '<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />',
  };

  bool updated = false;

  for (var entry in permissionsToAdd.entries) {
    final keyword = entry.value;
    if (!content.contains(keyword)) {
      content = content.replaceFirst('</manifest>', '  ${entry.value}\n</manifest>');
      print('✅ Added ${entry.key} permission.');
      updated = true;
    } else {
      print('ℹ️ ${entry.key} permission already exists.');
    }
  }

  if (updated) {
    await file.writeAsString(content);
    print('✅ AndroidManifest.xml updated.');
  } else {
    print('ℹ️ No changes made to AndroidManifest.xml.');
  }
}

Future<void> _updateIOSPlist(String path) async {
  final file = File(path);
  if (!file.existsSync()) {
    print('❌ Info.plist not found.');
    return;
  }

  final content = await file.readAsString();
  if (content.contains('NSUserNotificationAlertUsageDescription')) {
    print('ℹ️ iOS permission already exists.');
    return;
  }

  final updated = content.replaceFirst(
    '</dict>',
    '  <key>NSUserNotificationAlertUsageDescription</key>\n'
    '  <string>Allow notifications</string>\n</dict>',
  );

  await file.writeAsString(updated);
  print('✅ Added iOS notification description to Info.plist.');
}
