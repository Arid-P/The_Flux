package com.fluxfoxus.fluxfoxus

import android.content.Context
import android.content.Intent
import android.provider.Settings
import android.text.TextUtils
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val accessibilityChannelName = "com.fluxfoxus/accessibility_service"
    private val usageStatsChannelName = "com.fluxfoxus/usage_stats"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 1. Accessibility Service Channel
        val accChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, accessibilityChannelName)
        FluxFoxusAccessibilityService.methodChannel = accChannel

        accChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "isAccessibilityServiceEnabled" -> {
                    result.success(isAccessibilityServiceEnabled(context))
                }
                "setSessionActive" -> {
                    val active = call.argument<Boolean>("isActive") ?: false
                    FluxFoxusAccessibilityService.isSessionActive = active
                    result.success(true)
                }
                "updateBlockedPackages" -> {
                    val packages = call.argument<List<String>>("packages") ?: emptyList()
                    FluxFoxusAccessibilityService.blockedPackages = packages.toSet()
                    result.success(true)
                }
                "redirectToApp" -> {
                    val pkg = call.argument<String>("packageName")
                    if (pkg.isNullOrEmpty() || pkg == context.packageName) {
                        bringAppToFront()
                    } else {
                        val launchIntent = packageManager.getLaunchIntentForPackage(pkg)?.apply {
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_REORDER_TO_FRONT)
                        }
                        if (launchIntent != null) {
                            startActivity(launchIntent)
                        }
                    }
                    result.success(true)
                }
                "openAccessibilitySettings" -> {
                    val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS).apply {
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    }
                    startActivity(intent)
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        // 2. Usage Stats Channel
        val usageChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, usageStatsChannelName)
        usageChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "hasUsageStatsPermission" -> {
                    result.success(UsageStatsHelper.hasUsageStatsPermission(context))
                }
                "openUsageAccessSettings" -> {
                    val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS).apply {
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    }
                    startActivity(intent)
                    result.success(true)
                }
                "getUsageStats" -> {
                    val startTime = (call.argument<Number>("startTime"))?.toLong() ?: 0L
                    val endTime = (call.argument<Number>("endTime"))?.toLong() ?: System.currentTimeMillis()
                    val stats = UsageStatsHelper.queryUsageStats(context, startTime, endTime)
                    result.success(stats)
                }
                "getInstalledApps" -> {
                    val apps = UsageStatsHelper.getInstalledApps(context)
                    result.success(apps)
                }
                "getAppIcon" -> {
                    val pkg = call.argument<String>("packageName") ?: ""
                    val icon = UsageStatsHelper.getAppIconBase64(context, pkg)
                    result.success(icon)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        // 3. FD Integration Channel (queries for app packages, labels, icons, stats)
        val fdChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.fluxfoxus/fd_integration")
        fdChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "getInstalledApps" -> {
                    val apps = UsageStatsHelper.getInstalledApps(context)
                    result.success(apps)
                }
                "getAppIcon" -> {
                    val pkg = call.argument<String>("packageName") ?: ""
                    val icon = UsageStatsHelper.getAppIconBase64(context, pkg)
                    result.success(icon)
                }
                "getUsageStats" -> {
                    val startTime = (call.argument<Number>("startTime"))?.toLong() ?: 0L
                    val endTime = (call.argument<Number>("endTime"))?.toLong() ?: System.currentTimeMillis()
                    val stats = UsageStatsHelper.queryUsageStats(context, startTime, endTime)
                    result.success(stats)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        FluxFoxusAccessibilityService.methodChannel = null
        super.cleanUpFlutterEngine(flutterEngine)
    }

    private fun bringAppToFront() {
        val intent = Intent(context, MainActivity::class.java).apply {
            addFlags(
                Intent.FLAG_ACTIVITY_NEW_TASK or
                Intent.FLAG_ACTIVITY_REORDER_TO_FRONT or
                Intent.FLAG_ACTIVITY_SINGLE_TOP
            )
        }
        startActivity(intent)
    }

    private fun isAccessibilityServiceEnabled(context: Context): Boolean {
        if (FluxFoxusAccessibilityService.isRunning()) {
            return true
        }
        val expectedComponentName = "${context.packageName}/${FluxFoxusAccessibilityService::class.java.canonicalName}"
        val enabledServices = Settings.Secure.getString(
            context.contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
        ) ?: return false

        val colonSplitter = TextUtils.SimpleStringSplitter(':')
        colonSplitter.setString(enabledServices)
        while (colonSplitter.hasNext()) {
            val componentName = colonSplitter.next()
            if (componentName.equals(expectedComponentName, ignoreCase = true)) {
                return true
            }
        }
        return false
    }
}
