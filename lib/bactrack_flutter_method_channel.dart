import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'bactrack_flutter_platform_interface.dart';
import 'src/bactrack_state.dart';

/// An implementation of [BactrackFlutterPlatform] that uses method channels.
class MethodChannelBactrackFlutter extends BactrackFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('bactrack_flutter');

  /// The event channel used to receive status updates from native platform.
  @visibleForTesting
  final eventChannel = const EventChannel('bactrack_flutter/events');

  StreamController<BactrackStatus>? _statusController;

  @override
  Stream<BactrackStatus> get statusStream {
    _statusController ??= StreamController<BactrackStatus>.broadcast(
      onListen: _startListening,
      onCancel: _stopListening,
    );
    return _statusController!.stream;
  }

  void _startListening() {
    eventChannel.receiveBroadcastStream().listen(
      (dynamic event) {
        if (event is Map) {
          final state = _parseState(event['state'] as String?);
          final message = event['message'] as String?;
          _statusController?.add(
            BactrackStatus(state: state, message: message),
          );
        }
      },
      onError: (dynamic error) {
        _statusController?.add(
          BactrackStatus(state: BactrackState.error, message: error.toString()),
        );
      },
    );
  }

  void _stopListening() {
    _statusController?.close();
    _statusController = null;
  }

  BactrackState _parseState(String? state) {
    switch (state) {
      case 'apiKeyAuthorized':
        return BactrackState.apiKeyAuthorized;
      case 'apiKeyDeclined':
        return BactrackState.apiKeyDeclined;
      case 'didConnect':
        return BactrackState.didConnect;
      case 'connected':
        return BactrackState.connected;
      case 'disconnected':
        return BactrackState.disconnected;
      case 'connectionTimeout':
        return BactrackState.connectionTimeout;
      case 'countdown':
        return BactrackState.countdown;
      case 'start':
        return BactrackState.start;
      case 'blow':
        return BactrackState.blow;
      case 'analyzing':
        return BactrackState.analyzing;
      case 'result':
        return BactrackState.result;
      case 'error':
        return BactrackState.error;
      case 'bluetoothOff':
        return BactrackState.bluetoothOff;
      case 'bluetoothNotAvailable':
        return BactrackState.bluetoothNotAvailable;
      case 'firmwareVersion':
        return BactrackState.firmwareVersion;
      case 'serialNumber':
        return BactrackState.serialNumber;
      case 'batteryVoltage':
        return BactrackState.batteryVoltage;
      case 'batteryLevel':
        return BactrackState.batteryLevel;
      case 'useCount':
        return BactrackState.useCount;
      case 'units':
        return BactrackState.units;
      case 'foundBreathalyzer':
        return BactrackState.foundBreathalyzer;
      default:
        return BactrackState.unknown;
    }
  }

  @override
  Future<bool> initialize(String apiKey) async {
    final result = await methodChannel.invokeMethod<bool>('initialize', {
      'apiKey': apiKey,
    });
    return result ?? false;
  }

  @override
  Future<void> connectToNearestBreathalyzer({Duration? timeout}) async {
    await methodChannel.invokeMethod<void>('connectToNearestBreathalyzer', {
      'timeoutMs': timeout?.inMilliseconds,
    });
  }

  @override
  Future<void> disconnect() async {
    await methodChannel.invokeMethod<void>('disconnect');
  }

  @override
  Future<bool> startCountdown() async {
    final result = await methodChannel.invokeMethod<bool>('startCountdown');
    return result ?? false;
  }

  @override
  Future<void> getBatteryVoltage() async {
    await methodChannel.invokeMethod<void>('getBatteryVoltage');
  }

  @override
  Future<void> getSerialNumber() async {
    await methodChannel.invokeMethod<void>('getSerialNumber');
  }

  @override
  Future<void> getFirmwareVersion() async {
    await methodChannel.invokeMethod<void>('getFirmwareVersion');
  }

  @override
  Future<void> getUseCount() async {
    await methodChannel.invokeMethod<void>('getUseCount');
  }
}
