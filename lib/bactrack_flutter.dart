import 'bactrack_flutter_platform_interface.dart';
import 'src/bactrack_state.dart';

export 'src/bactrack_state.dart';
export 'src/bactrack_device.dart';
export 'src/bactrack_error.dart';

/// Flutter plugin for BACtrack Bluetooth breathalyzers.
///
/// Use [initialize] to set up the SDK with your API key, then listen to
/// [statusStream] for state updates while calling connection and reading methods.
class BactrackFlutter {
  BactrackFlutter._();

  static final BactrackFlutter _instance = BactrackFlutter._();

  /// Returns the singleton instance of the BactrackFlutter plugin.
  static BactrackFlutter get instance => _instance;

  bool _initialized = false;

  /// Whether the SDK has been initialized.
  bool get isInitialized => _initialized;

  /// Stream of status updates from the BACtrack SDK.
  ///
  /// Listen to this stream to receive all callbacks from the native SDK,
  /// including connection status, countdown progress, and BAC results.
  Stream<BactrackStatus> get statusStream =>
      BactrackFlutterPlatform.instance.statusStream;

  /// Initialize the BACtrack SDK with your API key.
  ///
  /// You must call this before any other methods. Get your API key from
  /// https://developer.bactrack.com
  ///
  /// Returns `true` if initialization was successful.
  Future<bool> initialize(String apiKey) async {
    final result = await BactrackFlutterPlatform.instance.initialize(apiKey);
    _initialized = result;
    return result;
  }

  /// Connect to the nearest available BACtrack breathalyzer.
  ///
  /// Optionally specify a [timeout] duration. If no device is found within
  /// the timeout, a `connectionTimeout` status will be emitted.
  ///
  /// Listen to [statusStream] for connection status updates.
  Future<void> connectToNearestBreathalyzer({Duration? timeout}) {
    return BactrackFlutterPlatform.instance.connectToNearestBreathalyzer(
      timeout: timeout,
    );
  }

  /// Disconnect from the currently connected breathalyzer.
  Future<void> disconnect() {
    return BactrackFlutterPlatform.instance.disconnect();
  }

  /// Start the countdown to take a BAC reading.
  ///
  /// Call this after receiving a `connected` status. The SDK will emit
  /// `countdown`, `start`, `blow`, `analyzing`, and finally `result` statuses.
  ///
  /// Returns `true` if the countdown was started successfully.
  Future<bool> startCountdown() {
    return BactrackFlutterPlatform.instance.startCountdown();
  }

  /// Request the battery voltage of the connected breathalyzer.
  ///
  /// The result will be emitted via [statusStream] as a `batteryVoltage` status.
  Future<void> getBatteryVoltage() {
    return BactrackFlutterPlatform.instance.getBatteryVoltage();
  }

  /// Request the serial number of the connected breathalyzer.
  ///
  /// The result will be emitted via [statusStream] as a `serialNumber` status.
  Future<void> getSerialNumber() {
    return BactrackFlutterPlatform.instance.getSerialNumber();
  }

  /// Request the firmware version of the connected breathalyzer.
  ///
  /// The result will be emitted via [statusStream] as a `firmwareVersion` status.
  Future<void> getFirmwareVersion() {
    return BactrackFlutterPlatform.instance.getFirmwareVersion();
  }

  /// Request the use count of the connected breathalyzer.
  ///
  /// The result will be emitted via [statusStream] as a `useCount` status.
  Future<void> getUseCount() {
    return BactrackFlutterPlatform.instance.getUseCount();
  }
}
