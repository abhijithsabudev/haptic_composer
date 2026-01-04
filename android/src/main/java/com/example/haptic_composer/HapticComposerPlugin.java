package com.example.haptic_composer;

import android.content.Context;
import android.os.Build;
import android.os.VibrationEffect;
import android.os.Vibrator;
import android.os.VibratorManager;
import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodCall;

public class HapticComposerPlugin implements FlutterPlugin {
    private static final String CHANNEL = "com.example.haptic_composer/haptic";
    private MethodChannel channel;
    private Context context;
    private Vibrator vibrator;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        context = binding.getApplicationContext();
        channel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL);
        channel.setMethodCallHandler(((call, result) -> {
            switch (call.method) {
                case "initialize":
                    initialize(result);
                    break;
                case "triggerEffect":
                    triggerEffect(call, result);
                    break;
                case "isSupported":
                    isSupported(result);
                    break;
                case "dispose":
                    dispose(result);
                    break;
                default:
                    result.notImplemented();
            }
        }));
        initializeVibrator();
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    private void initialize(MethodChannel.Result result) {
        try {
            initializeVibrator();
            result.success(vibrator != null && vibrator.hasVibrator());
        } catch (Exception e) {
            result.success(false);
        }
    }

    private void initializeVibrator() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            VibratorManager vibratorManager = (VibratorManager) context.getSystemService(Context.VIBRATOR_MANAGER_SERVICE);
            vibrator = vibratorManager != null ? vibratorManager.getDefaultVibrator() : null;
        } else {
            vibrator = (Vibrator) context.getSystemService(Context.VIBRATOR_SERVICE);
        }
    }

    private void triggerEffect(MethodCall call, MethodChannel.Result result) {
        Double intensity = call.argument("intensity");
        Integer duration = call.argument("duration");

        if (intensity == null) intensity = 0.5;
        if (duration == null) duration = 100;

        try {
            if (vibrator == null) {
                initializeVibrator();
            }

            if (vibrator != null && vibrator.hasVibrator()) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    int amplitude = (int) (intensity * 255);
                    amplitude = Math.max(0, Math.min(255, amplitude));
                    VibrationEffect effect = VibrationEffect.createOneShot(duration.longValue(), amplitude);
                    vibrator.vibrate(effect);
                } else {
                    vibrator.vibrate(duration.longValue());
                }
                result.success(null);
            } else {
                result.error("NO_VIBRATOR", "Device does not support vibration", null);
            }
        } catch (Exception e) {
            result.error("VIBRATION_ERROR", "Failed to trigger vibration: " + e.getMessage(), null);
        }
    }

    private void isSupported(MethodChannel.Result result) {
        try {
            boolean supported = vibrator != null && vibrator.hasVibrator();
            result.success(supported);
        } catch (Exception e) {
            result.success(false);
        }
    }

    private void dispose(MethodChannel.Result result) {
        try {
            if (vibrator != null) {
                vibrator.cancel();
            }
            result.success(null);
        } catch (Exception e) {
            result.error("DISPOSE_ERROR", "Failed to dispose: " + e.getMessage(), null);
        }
    }
}
