import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:bactrack_flutter/bactrack_flutter.dart';
import 'package:bactrack_flutter/bactrack_flutter_platform_interface.dart';
import 'package:bactrack_flutter/bactrack_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockBactrackFlutterPlatform
    with MockPlatformInterfaceMixin
    implements BactrackFlutterPlatform {
  final StreamController<BactrackStatus> _statusController =
      StreamController<BactrackStatus>.broadcast();

  @override
  Stream<BactrackStatus> get statusStream => _statusController.stream;

  @override
  Future<bool> initialize(String apiKey) => Future.value(true);

  @override
  Future<void> connectToNearestBreathalyzer({Duration? timeout}) =>
      Future.value();

  @override
  Future<void> disconnect() => Future.value();

  @override
  Future<bool> startCountdown() => Future.value(true);

  @override
  Future<void> getBatteryVoltage() => Future.value();

  @override
  Future<void> getSerialNumber() => Future.value();

  @override
  Future<void> getFirmwareVersion() => Future.value();

  @override
  Future<void> getUseCount() => Future.value();

  void emitStatus(BactrackStatus status) {
    _statusController.add(status);
  }

  void dispose() {
    _statusController.close();
  }
}

void main() {
  final BactrackFlutterPlatform initialPlatform =
      BactrackFlutterPlatform.instance;

  test('$MethodChannelBactrackFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelBactrackFlutter>());
  });

  test('initialize returns true on success', () async {
    final fakePlatform = MockBactrackFlutterPlatform();
    BactrackFlutterPlatform.instance = fakePlatform;

    final result = await BactrackFlutter.instance.initialize('test-api-key');
    expect(result, true);

    fakePlatform.dispose();
  });

  test('statusStream emits status updates', () async {
    final fakePlatform = MockBactrackFlutterPlatform();
    BactrackFlutterPlatform.instance = fakePlatform;

    final statuses = <BactrackStatus>[];
    final subscription = BactrackFlutter.instance.statusStream.listen(
      statuses.add,
    );

    fakePlatform.emitStatus(
      const BactrackStatus(state: BactrackState.connected, message: 'device-1'),
    );
    fakePlatform.emitStatus(
      const BactrackStatus(state: BactrackState.result, message: '0.0000'),
    );

    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(statuses.length, 2);
    expect(statuses[0].state, BactrackState.connected);
    expect(statuses[1].state, BactrackState.result);
    expect(statuses[1].message, '0.0000');

    await subscription.cancel();
    fakePlatform.dispose();
  });
}
