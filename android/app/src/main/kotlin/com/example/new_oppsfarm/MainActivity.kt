package com.example.new_oppsfarm

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.hardware.usb.UsbDevice
import android.hardware.usb.UsbManager
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.TimeZone

class MainActivity : FlutterActivity() {
    private val USB_CHANNEL = "usb_permission_channel"
    private val TIMEZONE_CHANNEL = "com.example/timezone"
    private val ALARM_CHANNEL = "com.example/alarm"

    private lateinit var usbManager: UsbManager
    private lateinit var usbChannel: MethodChannel
    private lateinit var timezoneChannel: MethodChannel
    private lateinit var alarmChannel: MethodChannel

    private val USB_PERMISSION_ACTION = "com.example.new_oppsfarm.USB_PERMISSION"
    private val nativeLogs = mutableListOf<String>()

    private val usbPermissionReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            if (intent.action == USB_PERMISSION_ACTION) {
                val device = intent.getParcelableExtra<UsbDevice>(UsbManager.EXTRA_DEVICE)
                val granted = intent.getBooleanExtra(UsbManager.EXTRA_PERMISSION_GRANTED, false)
                if (device != null) {
                    log("Permission pour ${device.deviceName} : $granted")
                    usbChannel.invokeMethod("usbPermissionGranted", granted)
                    if (!granted) {
                        usbChannel.invokeMethod("permissionDenied", "Permission refusée")
                    }
                } else {
                    log("Erreur : appareil non trouvé dans l'intent")
                }
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        usbManager = getSystemService(Context.USB_SERVICE) as UsbManager

        usbChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, USB_CHANNEL)
        usbChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "requestUsbPermission" -> {
                    val devices = usbManager.deviceList.values.toList()
                    if (devices.isNotEmpty()) {
                        val device = devices.first()
                        if (usbManager.hasPermission(device)) {
                            log("Permission déjà accordée pour ${device.deviceName}")
                            result.success(true)
                        } else {
                            requestUsbPermission(device, result)
                        }
                    } else {
                        log("Aucun périphérique USB détecté")
                        result.error("NO_DEVICE", "Aucun capteur USB trouvé", null)
                    }
                }
                "getNativeLogs" -> result.success(nativeLogs.toList())
                else -> result.notImplemented()
            }
        }

        timezoneChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, TIMEZONE_CHANNEL)
        timezoneChannel.setMethodCallHandler { call, result ->
            if (call.method == "getLocalTimezone") {
                val timezone = TimeZone.getDefault().id
                result.success(timezone)
            } else {
                result.notImplemented()
            }
        }

        alarmChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ALARM_CHANNEL)
        alarmChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "canScheduleExactAlarms" -> {
                    val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
                    val canSchedule = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        alarmManager.canScheduleExactAlarms()
                    } else {
                        true
                    }
                    result.success(canSchedule)
                }
                "requestExactAlarmPermission" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        val intent = Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM)
                        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        startActivity(intent)
                        result.success(null)
                    } else {
                        result.success(true)
                    }
                }
                else -> result.notImplemented()
            }
        }

        val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            Context.RECEIVER_NOT_EXPORTED
        } else {
            0
        }
        registerReceiver(usbPermissionReceiver, IntentFilter(USB_PERMISSION_ACTION), flags)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleUsbIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleUsbIntent(intent)
    }

    override fun onDestroy() {
        unregisterReceiver(usbPermissionReceiver)
        super.onDestroy()
    }

    private fun handleUsbIntent(intent: Intent) {
        try {
            when (intent.action) {
                UsbManager.ACTION_USB_DEVICE_ATTACHED -> {
                    val device = intent.getParcelableExtra<UsbDevice>(UsbManager.EXTRA_DEVICE)
                    log("Périphérique attaché : ${device?.deviceName}")
                    if (device != null) {
                        if (usbManager.hasPermission(device)) {
                            usbChannel.invokeMethod("usbDeviceAttached", true)
                        } else {
                            requestUsbPermission(device, null)
                        }
                    }
                }
                UsbManager.ACTION_USB_DEVICE_DETACHED -> {
                    val device = intent.getParcelableExtra<UsbDevice>(UsbManager.EXTRA_DEVICE)
                    log("Périphérique déconnecté : ${device?.deviceName}")
                    usbChannel.invokeMethod("usbDeviceDetached", true)
                }
                else -> log("Intent inattendu : ${intent.action}")
            }
        } catch (e: Exception) {
            log("Erreur dans handleUsbIntent : $e")
        }
    }

    private fun requestUsbPermission(device: UsbDevice, result: MethodChannel.Result?) {
        log("Demande de permission pour ${device.deviceName}")
        val permissionIntent = PendingIntent.getBroadcast(
            this, 0, Intent(USB_PERMISSION_ACTION), PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        usbManager.requestPermission(device, permissionIntent)
        result?.success(false)
    }

    private fun log(message: String) {
        nativeLogs.add("${System.currentTimeMillis()}: $message")
        println(message)
    }
}