import 'package:flutter/material.dart';
import 'package:easy_notify/easy_notify.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyNotify.init();
   await EasyNotifyPermissions.requestAll();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Easy Notify Example',
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Easy Notify Example')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                EasyNotify.showBasicNotification(
                  id: 1,
                  title: '🔔 Hello',
                  body: 'This is an instant notification!',
                );
              },
              child: const Text('Show Instant Notification'),
            ),
            ElevatedButton(
              onPressed: () {
                EasyNotify.showScheduledNotification(
                  id: 2,
                  title: '⏰ Scheduled',
                  body: 'This will appear in 5 seconds',
                  duration: const Duration(seconds: 5),
                );
              },
              child: const Text('Show Scheduled Notification'),
            ),
            ElevatedButton(
              onPressed: () {
                EasyNotify.showRepeatedNotification(
                  id: 3,
                  title: '🔁 Repeating',
                  body: 'This repeats every day',
                );
              },
              child: const Text('Show Repeating Notification'),
            ),
            ElevatedButton(
              onPressed: () {
                EasyNotify.cancelAll();
              },
              child: const Text('Cancel All Notifications'),
            ),
          ],
        ),
      ),
    );
  }
}
