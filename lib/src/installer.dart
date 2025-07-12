import 'dart:io';

class EasyNotifyInstaller {
  static Future<void> run() async {
    await _updateAndroidManifest();
    await _updateMainActivity();
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

  static Future<void> _updateMainActivity() async {
    final dir = Directory('android/app/src/main/kotlin/');
    if (!dir.existsSync()) {
      print('❌ Kotlin source folder not found.');
      return;
    }

    final ktFile = dir
        .listSync(recursive: true)
        .whereType<File>()
        .firstWhere((f) => f.path.endsWith('MainActivity.kt'), orElse: () => File(''));

    if (!ktFile.existsSync()) {
      print('❌ MainActivity.kt not found.');
      return;
    }

    String content = await ktFile.readAsString();
    if (content.contains('getSdkInt') && content.contains('openBatterySettings')) {
      print('ℹ️ MainActivity.kt already patched.');
      return;
    }

    final newContent = '''
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "easy_notify_permissions"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->
            when (call.method) {
                "getSdkInt" -> result.success(Build.VERSION.SDK_INT)
                "openBatterySettings" -> {
                    val intent = Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)
                    intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    startActivity(intent)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }
}
''';

    await ktFile.writeAsString(newContent);
    print('✅ MainActivity.kt replaced with patched version.');
  }
}
