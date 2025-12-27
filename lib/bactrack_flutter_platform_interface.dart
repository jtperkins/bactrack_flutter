import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'bactrack_flutter_method_channel.dart';
import 'src/bactrack_state.dart';

abstract class BactrackFlutterPlatform extends PlatformInterface {
  /// Constructs a BactrackFlutterPlatform.
  BactrackFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static BactrackFlutterPlatform _instance = MethodChannelBactrackFlutter();

  /// The default instance of [BactrackFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelBactrackFlutter].
  static BactrackFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [BactrackFlutterPlatform] when
  /// they register themselves.
  static set instance(BactrackFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Stream of status updates from the BACtrack SDK
  Stream<BactrackStatus> get statusStream {
    throw UnimplementedError('statusStream has not been implemented.');
  }

  /// Initialize the SDK with the given API key
  Future<bool> initialize(String apiKey) {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  /// Connect to the nearest available breathalyzer
  Future<void> connectToNearestBreathalyzer({Duration? timeout}) {
    throw UnimplementedError(
      'connectToNearestBreathalyzer() has not been implemented.',
    );
  }

  /// Disconnect from the currently connected breathalyzer
  Future<void> disconnect() {
    throw UnimplementedError('disconnect() has not been implemented.');
  }

  /// Start the countdown to take a BAC reading
  Future<bool> startCountdown() {
    throw UnimplementedError('startCountdown() has not been implemented.');
  }

  /// Get the battery voltage of the connected breathalyzer
  Future<void> getBatteryVoltage() {
    throw UnimplementedError('getBatteryVoltage() has not been implemented.');
  }

  /// Get the serial number of the connected breathalyzer
  Future<void> getSerialNumber() {
    throw UnimplementedError('getSerialNumber() has not been implemented.');
  }

  /// Get the firmware version of the connected breathalyzer
  Future<void> getFirmwareVersion() {
    throw UnimplementedError('getFirmwareVersion() has not been implemented.');
  }

  /// Get the use count of the connected breathalyzer
  Future<void> getUseCount() {
    throw UnimplementedError('getUseCount() has not been implemented.');
  }
}
