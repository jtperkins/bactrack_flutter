package com.wellcentiv.bactrack_flutter

import android.content.Context
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

import BreathalyzerSDK.API.BACtrackAPI
import BreathalyzerSDK.API.BACtrackAPICallbacks
import BreathalyzerSDK.Constants.BACTrackDeviceType
import BreathalyzerSDK.Constants.BACtrackUnit
import BreathalyzerSDK.Exceptions.BluetoothLENotSupportedException
import BreathalyzerSDK.Exceptions.BluetoothNotEnabledException
import BreathalyzerSDK.Exceptions.LocationServicesNotEnabledException

/** BactrackFlutterPlugin */
class BactrackFlutterPlugin : FlutterPlugin, MethodCallHandler, ActivityAware, EventChannel.StreamHandler {
    companion object {
        private const val TAG = "BactrackFlutter"
    }

    private lateinit var channel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private var eventSink: EventChannel.EventSink? = null
    private var context: Context? = null
    private var bactrackAPI: BACtrackAPI? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "bactrack_flutter")
        channel.setMethodCallHandler(this)
        
        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "bactrack_flutter/events")
        eventChannel.setStreamHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "initialize" -> {
                val apiKey = call.argument<String>("apiKey")
                if (apiKey == null) {
                    result.error("INVALID_ARGS", "API key required", null)
                    return
                }
                initializeSDK(apiKey, result)
            }
            "connectToNearestBreathalyzer" -> {
                val timeoutMs = call.argument<Int>("timeoutMs")
                connectToNearestBreathalyzer(timeoutMs, result)
            }
            "disconnect" -> {
                disconnect(result)
            }
            "startCountdown" -> {
                startCountdown(result)
            }
            "getBatteryVoltage" -> {
                getBatteryVoltage(result)
            }
            "getSerialNumber" -> {
                getSerialNumber(result)
            }
            "getFirmwareVersion" -> {
                getFirmwareVersion(result)
            }
            "getUseCount" -> {
                getUseCount(result)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    // SDK Methods
    
    private fun initializeSDK(apiKey: String, result: Result) {
        val ctx = context
        if (ctx == null) {
            result.error("NO_CONTEXT", "Application context not available", null)
            return
        }
        
        try {
            bactrackAPI = BACtrackAPI(ctx, bactrackCallbacks, apiKey)
            result.success(true)
        } catch (e: BluetoothLENotSupportedException) {
            sendEvent("bluetoothNotAvailable", "Bluetooth LE not supported")
            result.success(false)
        } catch (e: BluetoothNotEnabledException) {
            sendEvent("bluetoothOff", "Bluetooth is not enabled")
            result.success(false)
        } catch (e: LocationServicesNotEnabledException) {
            sendEvent("error", "Location services not enabled")
            result.success(false)
        } catch (e: Exception) {
            sendEvent("error", e.message ?: "Unknown error")
            result.success(false)
        }
    }

    private fun connectToNearestBreathalyzer(timeoutMs: Int?, result: Result) {
        val api = bactrackAPI
        if (api == null) {
            result.error("NOT_INITIALIZED", "SDK not initialized", null)
            return
        }
        
        api.connectToNearestBreathalyzer()
        result.success(null)
    }

    private fun disconnect(result: Result) {
        bactrackAPI?.disconnect()
        result.success(null)
    }

    private fun startCountdown(result: Result) {
        val api = bactrackAPI
        if (api == null) {
            result.error("NOT_INITIALIZED", "SDK not initialized", null)
            return
        }
        api.startCountdown()
        result.success(true)
    }

    private fun getBatteryVoltage(result: Result) {
        bactrackAPI?.getBreathalyzerBatteryVoltage()
        result.success(null)
    }

    private fun getSerialNumber(result: Result) {
        bactrackAPI?.getSerialNumber()
        result.success(null)
    }

    private fun getFirmwareVersion(result: Result) {
        bactrackAPI?.getFirmwareVersion()
        result.success(null)
    }

    private fun getUseCount(result: Result) {
        bactrackAPI?.getUseCount()
        result.success(null)
    }

    // Helper
    
    private fun sendEvent(state: String, message: String? = null) {
        val event = mutableMapOf<String, Any>("state" to state)
        message?.let { event["message"] = it }
        // Must dispatch to main thread for Flutter platform channel
        mainHandler.post {
            eventSink?.success(event)
        }
    }

    // BACtrack Callbacks
    
    private val bactrackCallbacks = object : BACtrackAPICallbacks {
        override fun BACtrackAPIKeyDeclined(errorMessage: String?) {
            sendEvent("apiKeyDeclined", errorMessage)
        }

        override fun BACtrackAPIKeyAuthorized() {
            sendEvent("apiKeyAuthorized")
        }

        override fun BACtrackConnected(deviceType: BACTrackDeviceType?) {
            sendEvent("connected", deviceType?.toString())
        }

        override fun BACtrackDidConnect(message: String?) {
            sendEvent("didConnect", message)
        }

        override fun BACtrackDisconnected() {
            sendEvent("disconnected")
        }

        override fun BACtrackConnectionTimeout() {
            sendEvent("connectionTimeout")
        }

        override fun BACtrackFoundBreathalyzer(device: BACtrackAPI.BACtrackDevice?) {
            sendEvent("foundBreathalyzer", device?.toString())
        }

        override fun BACtrackCountdown(currentCountdownCount: Int) {
            sendEvent("countdown", currentCountdownCount.toString())
        }

        override fun BACtrackStart() {
            sendEvent("start")
        }

        override fun BACtrackBlow(blowProgress: Float) {
            sendEvent("blow", blowProgress.toString())
        }

        override fun BACtrackAnalyzing() {
            sendEvent("analyzing")
        }

        override fun BACtrackResults(measuredBac: Float) {
            sendEvent("result", String.format("%.4f", measuredBac))
        }

        override fun BACtrackFirmwareVersion(version: String?) {
            sendEvent("firmwareVersion", version)
        }

        override fun BACtrackSerial(serialNumber: String?) {
            sendEvent("serialNumber", serialNumber)
        }

        override fun BACtrackBatteryVoltage(voltage: Float) {
            sendEvent("batteryVoltage", voltage.toString())
        }

        override fun BACtrackBatteryLevel(level: Int) {
            sendEvent("batteryLevel", level.toString())
        }

        override fun BACtrackUseCount(useCount: Int) {
            sendEvent("useCount", useCount.toString())
        }

        override fun BACtrackError(errorCode: Int) {
            sendEvent("error", "Error code: $errorCode")
        }

        override fun BACtrackUnits(units: BACtrackUnit?) {
            val unitsString = when (units) {
                BACtrackUnit.BACtrackUnit_bac -> "BAC%"
                BACtrackUnit.BACtrackUnit_permille -> "permille"
                BACtrackUnit.BACtrackUnit_mgL -> "mg/L"
                BACtrackUnit.BACtrackUnit_mg -> "mg/dL"
                BACtrackUnit.BACtrackUnit_permilleByMass -> "permille"
                else -> "unknown"
            }
            sendEvent("units", unitsString)
        }
    }

    // EventChannel.StreamHandler
    
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    // ActivityAware
    
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {}
    override fun onDetachedFromActivityForConfigChanges() {}
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {}
    override fun onDetachedFromActivity() {}

    // FlutterPlugin
    
    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        bactrackAPI?.disconnect()
        bactrackAPI = null
        context = null
    }
}
