package com.fluxfoxus.fluxfoxus

import android.accessibilityservice.AccessibilityService
import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper
import android.view.accessibility.AccessibilityEvent
import io.flutter.plugin.common.MethodChannel

/**
 * Native Android Accessibility Service for foreground application monitoring
 * and distraction interception per TRD §5.2.
 */
class FluxFoxusAccessibilityService : AccessibilityService() {

    companion object {
        @Volatile
        var instance: FluxFoxusAccessibilityService? = null
            private set

        @Volatile
        var methodChannel: MethodChannel? = null

        @Volatile
        var isSessionActive: Boolean = false

        @Volatile
        var blockedPackages: Set<String> = emptySet()

        private val mainHandler = Handler(Looper.getMainLooper())

        fun isRunning(): Boolean = instance != null

        /**
         * Triggers an immediate redirect back to FluxFoxus.
         */
        fun redirectToFluxFoxus(context: Context? = null) {
            val ctx = instance ?: context ?: return
            val launchIntent = ctx.packageManager.getLaunchIntentForPackage(ctx.packageName)?.apply {
                addFlags(
                    Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_REORDER_TO_FRONT or
                    Intent.FLAG_ACTIVITY_RESET_TASK_IF_NEEDED
                )
            }
            if (launchIntent != null) {
                ctx.startActivity(launchIntent)
            }
        }
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        instance = this
    }

    override fun onDestroy() {
        super.onDestroy()
        if (instance == this) {
            instance = null
        }
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null || event.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            return
        }

        val pkg = event.packageName?.toString() ?: return

        // Filter out own package, system UI, and framework events
        if (pkg == packageName || pkg == "com.android.systemui" || pkg == "android") {
            return
        }

        // Forward foreground app change to Flutter/Dart runtime
        mainHandler.post {
            methodChannel?.invokeMethod("onAppChanged", mapOf("packageName" to pkg))
        }

        // Instant native redirection if active session blocks this package
        if (isSessionActive && blockedPackages.contains(pkg)) {
            redirectToFluxFoxus(this)
        }
    }

    override fun onInterrupt() {
        // Required callback when system interrupts the service
    }
}
