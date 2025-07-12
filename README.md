
# 📦 Easy Notify

Easy Notify is a simple Flutter package for local notifications with support for scheduled, repeated, and instant notifications. It also provides a one-click setup script to add required permissions and Android configuration automatically.

## ✨ Features

- 🔔 Instant Notifications
- ⏰ Scheduled Notifications
- 🔁 Repeated Notifications
- ✅ Handles Android permissions automatically
- 📦 One-time setup via CLI

---

## 🚀 Getting Started

### 1. Add Dependency

In your `pubspec.yaml`:

```yaml
dependencies:
  flutter_local_notifications: ^17.1.0
  timezone: ^0.9.0
  permission_handler: ^12.0.1
  path_provider: ^2.1.2
```

---

### 2. Install Setup Files

Run this command to auto-insert permissions and required configuration into your Android project:

```bash
dart run easy_notify:install
```

This will:
- Add permissions to `AndroidManifest.xml`
- Add required receivers
- Replace `MainActivity.kt` with a version that supports exact alarms and battery optimization access

---

### 3. Initialize in `main()`

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyNotify.init();
  runApp(MyApp());
}
```

---

### 4. Usage

#### 📢 Show instant notification:

```dart
EasyNotify.showBasicNotification(
  id: 1,
  title: 'Hello',
  body: 'This is an instant notification',
);
```

#### ⏳ Scheduled Notification:

```dart
EasyNotify.showScheduledNotification(
  id: 2,
  title: 'Reminder',
  body: 'This will appear after 10 seconds',
  duration: Duration(seconds: 10),
);
```

#### 🔁 Repeating Notification:

```dart
EasyNotify.showRepeatedNotification(
  id: 3,
  title: 'Daily',
  body: 'This will repeat daily',
);
```

---

## 🛠 CLI Commands

| Command | Description |
|--------|-------------|
| `dart run easy_notify:install` | Auto-inserts permissions and patches Android files |

---

## 📄 Notes

- Make sure your `MainActivity.kt` file is backed up before running the install command.
- The patching works only with Kotlin-based Android apps.
- For Android 13+, exact alarms require special permissions.

---

## 📦 License

MIT License.
