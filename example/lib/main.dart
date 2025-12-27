import 'dart:async';

import 'package:flutter/material.dart';
import 'package:bactrack_flutter/bactrack_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _bactrack = BactrackFlutter.instance;
  StreamSubscription<BactrackStatus>? _statusSubscription;

  String _status = 'Not initialized';
  String _lastResult = '-';
  bool _isConnected = false;
  bool _isInitialized = false;

  // TODO: Replace with your BACtrack API key from https://developer.bactrack.com
  static const String _apiKey = 'YOUR_API_KEY_HERE';

  @override
  void initState() {
    super.initState();
    _setupStatusListener();
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    super.dispose();
  }

  void _setupStatusListener() {
    _statusSubscription = _bactrack.statusStream.listen((status) {
      setState(() {
        _status =
            '${status.state.name}${status.message != null ? ': ${status.message}' : ''}';

        switch (status.state) {
          case BactrackState.apiKeyAuthorized:
            _isInitialized = true;
            break;
          case BactrackState.connected:
            _isConnected = true;
            break;
          case BactrackState.disconnected:
            _isConnected = false;
            break;
          case BactrackState.result:
            _lastResult = status.message ?? '-';
            break;
          default:
            break;
        }
      });
    });
  }

  Future<void> _initialize() async {
    setState(() => _status = 'Initializing...');
    final success = await _bactrack.initialize(_apiKey);
    if (!success) {
      setState(() => _status = 'Initialization failed');
    }
  }

  Future<void> _connect() async {
    setState(() => _status = 'Connecting...');
    await _bactrack.connectToNearestBreathalyzer(
      timeout: const Duration(seconds: 30),
    );
  }

  Future<void> _disconnect() async {
    await _bactrack.disconnect();
  }

  Future<void> _startTest() async {
    setState(() => _status = 'Starting test...');
    await _bactrack.startCountdown();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('BACtrack Flutter Example')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status: $_status'),
                      const SizedBox(height: 8),
                      Text('Connected: ${_isConnected ? 'Yes' : 'No'}'),
                      const SizedBox(height: 8),
                      Text('Last BAC Result: $_lastResult'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isInitialized ? null : _initialize,
                child: const Text('Initialize SDK'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _isInitialized && !_isConnected ? _connect : null,
                child: const Text('Connect to Breathalyzer'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _isConnected ? _disconnect : null,
                child: const Text('Disconnect'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _isConnected ? _startTest : null,
                child: const Text('Start BAC Test'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isConnected
                    ? () async {
                        await _bactrack.getBatteryVoltage();
                        await _bactrack.getSerialNumber();
                        await _bactrack.getFirmwareVersion();
                      }
                    : null,
                child: const Text('Get Device Info'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
