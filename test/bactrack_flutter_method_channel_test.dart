import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bactrack_flutter/bactrack_flutter_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelBactrackFlutter platform = MethodChannelBactrackFlutter();
  const MethodChannel channel = MethodChannel('bactrack_flutter');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'initialize':
              return true;
            case 'startCountdown':
              return true;
            case 'connectToNearestBreathalyzer':
            case 'disconnect':
            case 'getBatteryVoltage':
            case 'getSerialNumber':
            case 'getFirmwareVersion':
            case 'getUseCount':
              return null;
            default:
              return null;
          }
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('initialize returns true', () async {
    expect(await platform.initialize('test-api-key'), true);
  });

  test('startCountdown returns true', () async {
    expect(await platform.startCountdown(), true);
  });

  test('connectToNearestBreathalyzer completes without error', () async {
    await expectLater(platform.connectToNearestBreathalyzer(), completes);
  });

  test('disconnect completes without error', () async {
    await expectLater(platform.disconnect(), completes);
  });
}
