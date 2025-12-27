# bactrack_flutter

A Flutter plugin for [BACtrack Bluetooth breathalyzers](https://www.bactrack.com/). This plugin wraps the official BACtrack SDK for both iOS and Android.

## Features

- Connect to the nearest BACtrack breathalyzer
- Take BAC (Blood Alcohol Content) readings
- Get device information (battery, serial number, firmware version)
- Stream-based API for real-time status updates

## Getting Started

### 1. Get an API Key

Register at [developer.bactrack.com](https://developer.bactrack.com) to obtain a free API key.

### 2. Install the Plugin

Add to your `pubspec.yaml`:

```yaml
dependencies:
  bactrack_flutter:
    git:
      url: https://github.com/jtperkins/bactrack_flutter.git
```

### 3. Platform Setup

#### Android

Add the following permissions to your `AndroidManifest.xml`:

```xml
<manifest>
    <uses-permission android:name="android.permission.BLUETOOTH" />
    <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
    <uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
    <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
</manifest>
```

#### iOS

Add to your `Info.plist`:

```xml
<dict>
    <key>NSBluetoothAlwaysUsageDescription</key>
    <string>This app needs Bluetooth to connect to the BACtrack breathalyzer</string>
    <key>NSBluetoothPeripheralUsageDescription</key>
    <string>This app needs Bluetooth to connect to the BACtrack breathalyzer</string>
</dict>
```

## Usage

### Initialize the SDK

```dart
import 'package:bactrack_flutter/bactrack_flutter.dart';

final bactrack = BactrackFlutter.instance;

// Initialize with your API key
final success = await bactrack.initialize('YOUR_API_KEY');
```

### Listen to Status Updates

```dart
bactrack.statusStream.listen((status) {
  switch (status.state) {
    case BactrackState.connected:
      print('Connected to device: ${status.message}');
      break;
    case BactrackState.countdown:
      print('Countdown: ${status.message}');
      break;
    case BactrackState.blow:
      print('Blow now!');
      break;
    case BactrackState.result:
      print('BAC Result: ${status.message}');
      break;
    case BactrackState.error:
      print('Error: ${status.message}');
      break;
    default:
      break;
  }
});
```

### Connect and Take a Reading

```dart
// Connect to nearest breathalyzer
await bactrack.connectToNearestBreathalyzer(
  timeout: Duration(seconds: 30),
);

// After receiving 'connected' status, start the test
await bactrack.startCountdown();

// The user will be guided through:
// 1. countdown - wait for device to warm up
// 2. start - device is ready
// 3. blow - user should blow into device
// 4. analyzing - processing the sample
// 5. result - BAC value is ready
```

### Get Device Info

```dart
await bactrack.getBatteryVoltage();  // Result via statusStream
await bactrack.getSerialNumber();    // Result via statusStream
await bactrack.getFirmwareVersion(); // Result via statusStream
```

### Disconnect

```dart
await bactrack.disconnect();
```

## API Reference

### BactrackFlutter

| Method | Description |
|--------|-------------|
| `initialize(apiKey)` | Initialize the SDK with your API key |
| `connectToNearestBreathalyzer({timeout})` | Connect to the nearest breathalyzer |
| `disconnect()` | Disconnect from the current device |
| `startCountdown()` | Start taking a BAC reading |
| `getBatteryVoltage()` | Request battery voltage |
| `getSerialNumber()` | Request device serial number |
| `getFirmwareVersion()` | Request firmware version |
| `getUseCount()` | Request device use count |

### BactrackState

| State | Description |
|-------|-------------|
| `apiKeyAuthorized` | API key validated successfully |
| `apiKeyDeclined` | API key was rejected |
| `connected` | Connected to a breathalyzer |
| `disconnected` | Disconnected from the device |
| `countdown` | Countdown before blowing (message = count) |
| `start` | Device ready, user should start blowing |
| `blow` | User is blowing |
| `analyzing` | Analyzing the breath sample |
| `result` | BAC result ready (message = BAC value) |
| `error` | An error occurred |

## License

MIT License - see [LICENSE](LICENSE) file.

## Credits

This plugin wraps the official BACtrack SDKs:
- [iOS SDK](https://github.com/BACtrack/breathalyzer-sdk-ios)
- [Android SDK](https://github.com/BACtrack/breathalyzer-sdk-android)
