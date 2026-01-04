package com.example.haptic_composer

import android.content.Context
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import androidx.annotation.RequiresApi
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodChannel

class HapticComposerPlugin: FlutterPlugin {
    private val CHANNEL = "com.example.haptic_composer/haptic"
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var vibrator: Vibrator? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, CHANNEL)
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "initialize" -> initialize(result)
                "triggerEffect" -> triggerEffect(call, result)
                "isSupported" -> isSupported(result)
                "dispose" -> dispose(result)
                else -> result.notImplemented()
            }
        }
        initializeVibrator()
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private fun initialize(result: MethodChannel.Result) {
        try {
            initializeVibrator()
            result.success(vibrator != null && vibrator!!.hasVibrator())
        } catch (e: Exception) {
            result.success(false)
        }
    }

    private fun initializeVibrator() {
        vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val vibratorManager = context.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as? VibratorManager
            vibratorManager?.defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            context.getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator
        }
    }

    private fun triggerEffect(call: MethodChannel.MethodCall, result: MethodChannel.Result) {
        val intensity = call.argument<Double>("intensity") ?: 0.5
        val duration = call.argument<Int>("duration") ?: 100

        try {
            if (vibrator == null) {
                initializeVibrator()
            }

            if (vibrator?.hasVibrator() == true) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    // Use VibrationEffect for Android O and above
                    val amplitude = (intensity * 255).toInt().coerceIn(0, 255)
                    val effect = VibrationEffect.createOneShot(duration.toLong(), amplitude)
                    vibrator?.vibrate(effect)
                } else {
                    // Fallback for older Android versions
                    @Suppress("DEPRECATION")
                    vibrator?.vibrate(duration.toLong())
                }
                result.success(null)
            } else {
                result.error("NO_VIBRATOR", "Device does not support vibration", null)
            }
        } catch (e: Exception) {
            result.error("VIBRATION_ERROR", "Failed to trigger vibration: ${e.message}", null)
        }
    }

    private fun isSupported(result: MethodChannel.Result) {
        try {
            val supported = vibrator?.hasVibrator() ?: false
            result.success(supported)
        } catch (e: Exception) {
            result.success(false)
        }
    }

    private fun dispose(result: MethodChannel.Result) {
        try {
            vibrator?.cancel()
            result.success(null)
        } catch (e: Exception) {
            result.error("DISPOSE_ERROR", "Failed to dispose: ${e.message}", null)
        }
    }
}
