package com.example.phokat_to_focus

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.provider.Settings
import android.net.Uri

import android.widget.Toast

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.phokat_to_focus/strict_mode"
    private var isStrictModeActive = false

    override fun onPause() {
        super.onPause()
        if (isStrictModeActive) {
            // If Strict Mode is on and the user tries to leave the app (home button, recents),
            // we immediately pull them back by relaunching the intent.
            val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
            if (launchIntent != null) {
                launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
                startActivity(launchIntent)
            }
        }
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startStrictMode" -> {
                    if (Settings.canDrawOverlays(this)) {
                        isStrictModeActive = true
                        // In a full production build, this is where we would start a Foreground Service
                        // and an Accessibility Service to monitor running packages.
                        // For MVP, we simulate success if permissions are granted.
                        Toast.makeText(this, "Strict Mode Activated! Get back to studying.", Toast.LENGTH_SHORT).show()
                        result.success(true)
                    } else {
                        result.success(false) // Needs permission first
                    }
                }
                "stopStrictMode" -> {
                    isStrictModeActive = false
                    Toast.makeText(this, "Strict Mode Disabled.", Toast.LENGTH_SHORT).show()
                    result.success(true)
                }
                "requestOverlayPermission" -> {
                    if (!Settings.canDrawOverlays(this)) {
                        val intent = Intent(
                            Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                            Uri.parse("package:$packageName")
                        )
                        startActivity(intent)
                        result.success(false)
                    } else {
                        result.success(true)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
