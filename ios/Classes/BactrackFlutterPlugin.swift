import Flutter
import UIKit
import BreathalyzerSDK

public class BactrackFlutterPlugin: NSObject, FlutterPlugin {
    private var channel: FlutterMethodChannel?
    private var eventChannel: FlutterEventChannel?
    private var eventSink: FlutterEventSink?
    private var bacTrackAPI: BacTrackAPI?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "bactrack_flutter", binaryMessenger: registrar.messenger())
        let eventChannel = FlutterEventChannel(name: "bactrack_flutter/events", binaryMessenger: registrar.messenger())
        
        let instance = BactrackFlutterPlugin()
        instance.channel = channel
        instance.eventChannel = eventChannel
        
        registrar.addMethodCallDelegate(instance, channel: channel)
        eventChannel.setStreamHandler(instance)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize":
            guard let args = call.arguments as? [String: Any],
                  let apiKey = args["apiKey"] as? String else {
                result(FlutterError(code: "INVALID_ARGS", message: "API key required", details: nil))
                return
            }
            initializeSDK(apiKey: apiKey, result: result)
            
        case "connectToNearestBreathalyzer":
            connectToNearestBreathalyzer(result: result)
            
        case "disconnect":
            disconnect(result: result)
            
        case "startCountdown":
            startCountdown(result: result)
            
        case "getBatteryVoltage":
            getBatteryVoltage(result: result)
            
        case "getSerialNumber":
            getSerialNumber(result: result)
            
        case "getFirmwareVersion":
            // SDK doesn't have this method - return not supported
            result(nil)
            
        case "getUseCount":
            // SDK doesn't have this method - return not supported
            result(nil)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // MARK: - SDK Methods
    
    private func initializeSDK(apiKey: String, result: @escaping FlutterResult) {
        bacTrackAPI = BacTrackAPI(delegate: self, andAPIKey: apiKey)
        result(true)
    }
    
    private func connectToNearestBreathalyzer(result: @escaping FlutterResult) {
        guard let api = bacTrackAPI else {
            result(FlutterError(code: "NOT_INITIALIZED", message: "SDK not initialized", details: nil))
            return
        }
        api.connectToNearestBreathalyzer()
        result(nil)
    }
    
    private func disconnect(result: @escaping FlutterResult) {
        bacTrackAPI?.disconnect()
        result(nil)
    }
    
    private func startCountdown(result: @escaping FlutterResult) {
        guard let api = bacTrackAPI else {
            result(FlutterError(code: "NOT_INITIALIZED", message: "SDK not initialized", details: nil))
            return
        }
        let success = api.startCountdown()
        result(success)
    }
    
    private func getBatteryVoltage(result: @escaping FlutterResult) {
        bacTrackAPI?.getBreathalyzerBatteryLevel()
        result(nil)
    }
    
    private func getSerialNumber(result: @escaping FlutterResult) {
        bacTrackAPI?.getBreathalyzerSerialNumber()
        result(nil)
    }
    
    // MARK: - Helper
    
    private func sendEvent(state: String, message: String? = nil) {
        var event: [String: Any] = ["state": state]
        if let msg = message {
            event["message"] = msg
        }
        eventSink?(event)
    }
}

// MARK: - FlutterStreamHandler

extension BactrackFlutterPlugin: FlutterStreamHandler {
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
}

// MARK: - BacTrackAPIDelegate

extension BactrackFlutterPlugin: BacTrackAPIDelegate {
    
    // Required delegate method
    public func bacTrackAPIKeyDeclined(_ errorMessage: String!) {
        sendEvent(state: "apiKeyDeclined", message: errorMessage ?? "Unknown error")
    }
    
    // Optional delegate methods
    public func bacTrackAPIKeyAuthorized() {
        sendEvent(state: "apiKeyAuthorized")
    }
    
    public func bacTrackConnected(_ device: BACtrackDeviceType) {
        sendEvent(state: "connected", message: String(device.rawValue))
    }
    
    public func bacTrackDisconnected() {
        sendEvent(state: "disconnected")
    }
    
    public func bacTrackConnectTimeout() {
        sendEvent(state: "connectionTimeout")
    }
    
    public func bacTrackCountdown(_ seconds: NSNumber!, executionFailure error: Bool) {
        if error {
            sendEvent(state: "error", message: "Countdown execution failure")
        } else {
            sendEvent(state: "countdown", message: seconds?.stringValue ?? "0")
        }
    }
    
    public func bacTrackStart() {
        sendEvent(state: "start")
    }
    
    public func bacTrackBlow(_ breathFractionRemaining: NSNumber!) {
        sendEvent(state: "blow", message: breathFractionRemaining?.stringValue)
    }
    
    public func bacTrackAnalyzing() {
        sendEvent(state: "analyzing")
    }
    
    public func bacTrackResults(_ bac: CGFloat) {
        sendEvent(state: "result", message: String(format: "%.4f", bac))
    }
    
    public func bacTrackError(_ error: Error!) {
        sendEvent(state: "error", message: error?.localizedDescription ?? "Unknown error")
    }
    
    public func bacTrackBatteryLevel(_ number: NSNumber!) {
        sendEvent(state: "batteryLevel", message: number?.stringValue ?? "0")
    }
    
    public func bacTrackSerial(_ serial_hex: String!) {
        sendEvent(state: "serialNumber", message: serial_hex ?? "")
    }
    
    public func bacTrackFoundBreathalyzer(_ breathalyzer: Breathalyzer!) {
        sendEvent(state: "foundBreathalyzer", message: breathalyzer?.uuid ?? "")
    }
}
