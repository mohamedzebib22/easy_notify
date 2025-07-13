
# 📦 Easy Notify

Easy Notify is a simple Flutter package for local notifications with support for scheduled, repeated, and instant notifications. It also provides a one-click setup script to add required permissions and Android/iOS configuration automatically.

---

## 🚀 Getting Started

### 1. Install the Package

In your `pubspec.yaml`:

```yaml
dependencies:
  easy_notify: ^1.0.0
```

Then run:

```bash
flutter pub get
```

---

### 2. Run One-Time Setup (Android + iOS)

To automatically insert all required permissions and receivers into your native files, run:

```bash
dart run easy_notify:install
```

This will:

- ✅ Add necessary permissions to `AndroidManifest.xml`
- ✅ Add notification receivers to Android
- ✅ Add background modes and permissions to iOS `Info.plist`

> 💡 **Important for Android (Desugaring Issue):**  
> If you're using a modern Flutter version (3.19+), you may need to enable core library desugaring to avoid build errors.

In `android/app/build.gradle.kts`, make sure you have:

```kotlin
android {
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
```

---

### 3. Initialize in `main()`

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyNotify.init();
  await EasyNotifyPermissions.requestAll();
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
| `dart run easy_notify:install` | Auto-inserts permissions and patches Android/iOS native files |

---

## 📄 Notes

- Make sure your project uses Kotlin for Android native code.
- iOS apps must run on real devices to test notifications (not simulator).
- You do NOT need to manually add dependencies like `flutter_local_notifications`, `timezone`, etc. — they are already bundled.

---

## 📦 License

MIT License.
