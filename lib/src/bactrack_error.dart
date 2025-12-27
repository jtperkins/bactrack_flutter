/// Exception thrown when BACtrack operations fail.
class BactrackException implements Exception {
  /// The error message
  final String message;

  /// The error code (if available)
  final String? code;

  const BactrackException(this.message, {this.code});

  @override
  String toString() =>
      'BactrackException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Exception thrown when the API key is invalid or declined.
class BactrackApiKeyException extends BactrackException {
  const BactrackApiKeyException([super.message = 'API key was declined'])
    : super(code: 'API_KEY_DECLINED');
}

/// Exception thrown when Bluetooth is not available or off.
class BactrackBluetoothException extends BactrackException {
  const BactrackBluetoothException([
    super.message = 'Bluetooth is not available',
  ]) : super(code: 'BLUETOOTH_UNAVAILABLE');
}

/// Exception thrown when connection times out.
class BactrackConnectionTimeoutException extends BactrackException {
  const BactrackConnectionTimeoutException([
    super.message = 'Connection timed out',
  ]) : super(code: 'CONNECTION_TIMEOUT');
}

/// Exception thrown when not connected to a device.
class BactrackNotConnectedException extends BactrackException {
  const BactrackNotConnectedException([
    super.message = 'Not connected to a device',
  ]) : super(code: 'NOT_CONNECTED');
}
