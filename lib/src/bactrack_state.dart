/// Represents the various states returned by the BACtrack SDK during operation.
enum BactrackState {
  /// API key has been validated successfully
  apiKeyAuthorized,

  /// API key was declined/invalid
  apiKeyDeclined,

  /// Found a breathalyzer device
  didConnect,

  /// Successfully connected to a breathalyzer
  connected,

  /// Disconnected from the breathalyzer
  disconnected,

  /// Connection attempt timed out
  connectionTimeout,

  /// Countdown before blowing (message contains countdown number)
  countdown,

  /// User should start blowing
  start,

  /// Currently blowing into the device
  blow,

  /// Analyzing the breath sample
  analyzing,

  /// BAC result is ready (message contains BAC value)
  result,

  /// An error occurred (message contains error description)
  error,

  /// Bluetooth is powered off
  bluetoothOff,

  /// Bluetooth is not available on this device
  bluetoothNotAvailable,

  /// Breathalyzer firmware version received
  firmwareVersion,

  /// Serial number received
  serialNumber,

  /// Battery voltage received
  batteryVoltage,

  /// Battery level received (percentage)
  batteryLevel,

  /// Use count received
  useCount,

  /// Units setting received
  units,

  /// Found a device during scanning
  foundBreathalyzer,

  /// Unknown state
  unknown,
}

/// A status update from the BACtrack SDK.
class BactrackStatus {
  /// The current state
  final BactrackState state;

  /// Optional message containing additional data (BAC result, countdown number, error message, etc.)
  final String? message;

  const BactrackStatus({
    required this.state,
    this.message,
  });

  @override
  String toString() => 'BactrackStatus(state: $state, message: $message)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BactrackStatus &&
          runtimeType == other.runtimeType &&
          state == other.state &&
          message == other.message;

  @override
  int get hashCode => state.hashCode ^ message.hashCode;
}
