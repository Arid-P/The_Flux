package com.fluxfoxus.fluxfoxus

import android.app.AppOpsManager
import android.app.usage.UsageStats
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.os.Build
import android.os.Process
import android.util.Base64
import java.io.ByteArrayOutputStream

/**
 * UsageStatsHelper provides utilities to verify usage access permissions
 * and query per-app foreground usage times from Android's UsageStatsManager.
 */
object UsageStatsHelper {

    fun hasUsageStatsPermission(context: Context): Boolean {
        val appOps = context.getSystemService(Context.APP_OPS_SERVICE) as? AppOpsManager
            ?: return false

        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                context.packageName
            )
        } else {
            @Suppress("DEPRECATION")
            appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                context.packageName
            )
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    fun queryUsageStats(
        context: Context,
        startTime: Long,
        endTime: Long
    ): List<Map<String, Any>> {
        val usageStatsManager = context.getSystemService(Context.USAGE_STATS_SERVICE) as? UsageStatsManager
            ?: return emptyList()

        val aggregatedTime = mutableMapOf<String, Long>()
        val lastUsedMap = mutableMapOf<String, Long>()

        // 1. Try queryUsageStats with INTERVAL_BEST / INTERVAL_DAILY
        val queryList: List<UsageStats>? = try {
            usageStatsManager.queryUsageStats(
                UsageStatsManager.INTERVAL_DAILY,
                startTime,
                endTime
            )
        } catch (_: Exception) {
            null
        }

        if (!queryList.isNullOrEmpty()) {
            for (stat in queryList) {
                val pkg = stat.packageName
                val existing = aggregatedTime.getOrDefault(pkg, 0L)
                aggregatedTime[pkg] = existing + stat.totalTimeInForeground

                val prevLast = lastUsedMap.getOrDefault(pkg, 0L)
                if (stat.lastTimeUsed > prevLast) {
                    lastUsedMap[pkg] = stat.lastTimeUsed
                }
            }
        } else {
            // Fallback to queryAndAggregateUsageStats
            try {
                val aggMap = usageStatsManager.queryAndAggregateUsageStats(startTime, endTime)
                for ((pkg, stat) in aggMap) {
                    aggregatedTime[pkg] = stat.totalTimeInForeground
                    lastUsedMap[pkg] = stat.lastTimeUsed
                }
            } catch (_: Exception) {
                // Return empty if permission not granted or service unavailable
            }
        }

        val pm = context.packageManager
        val result = mutableListOf<Map<String, Any>>()

        for ((pkgName, timeMs) in aggregatedTime) {
            if (timeMs <= 0) continue

            var appName = pkgName
            var isSystemApp = false
            try {
                val appInfo = pm.getApplicationInfo(pkgName, 0)
                appName = pm.getApplicationLabel(appInfo).toString()
                isSystemApp = (appInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0
            } catch (_: PackageManager.NameNotFoundException) {
                // Uninstalled or hidden package; keep package name as fallback
            }

            val iconBase64 = getAppIconBase64(context, pkgName) ?: ""

            result.add(
                mapOf(
                    "packageName" to pkgName,
                    "appName" to appName,
                    "foregroundTimeMs" to timeMs,
                    "lastTimeUsed" to (lastUsedMap[pkgName] ?: 0L),
                    "isSystemApp" to isSystemApp,
                    "appIcon" to iconBase64
                )
            )
        }

        // Sort descending by foreground time
        result.sortByDescending { (it["foregroundTimeMs"] as? Long) ?: 0L }
        return result
    }

    fun getAppIconBase64(context: Context, packageName: String): String? {
        return try {
            val pm = context.packageManager
            val appInfo = pm.getApplicationInfo(packageName, 0)
            val drawable = pm.getApplicationIcon(appInfo)
            val bitmap = drawableToBitmap(drawable)
            val stream = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.PNG, 90, stream)
            Base64.encodeToString(stream.toByteArray(), Base64.NO_WRAP)
        } catch (_: Exception) {
            null
        }
    }

    fun getInstalledApps(context: Context): List<Map<String, Any?>> {
        val pm = context.packageManager
        val intent = Intent(Intent.ACTION_MAIN, null).apply {
            addCategory(Intent.CATEGORY_LAUNCHER)
        }
        val resolveInfos = pm.queryIntentActivities(intent, 0)
        val list = mutableListOf<Map<String, Any?>>()
        val seen = mutableSetOf<String>()

        for (ri in resolveInfos) {
            val pkg = ri.activityInfo.packageName
            if (seen.contains(pkg)) continue
            seen.add(pkg)
            val appName = ri.loadLabel(pm).toString()
            val isSystemApp = (ri.activityInfo.applicationInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0
            val iconBase64 = try {
                val drawable = ri.loadIcon(pm)
                val bitmap = drawableToBitmap(drawable)
                val stream = ByteArrayOutputStream()
                bitmap.compress(Bitmap.CompressFormat.PNG, 90, stream)
                Base64.encodeToString(stream.toByteArray(), Base64.NO_WRAP)
            } catch (_: Exception) {
                null
            }
            list.add(
                mapOf(
                    "packageName" to pkg,
                    "appName" to appName,
                    "isSystemApp" to isSystemApp,
                    "appIcon" to (iconBase64 ?: "")
                )
            )
        }
        list.sortBy { (it["appName"] as? String)?.lowercase() ?: "" }
        return list
    }

    private fun drawableToBitmap(drawable: Drawable): Bitmap {
        if (drawable is BitmapDrawable && drawable.bitmap != null) {
            return drawable.bitmap
        }
        val width = if (drawable.intrinsicWidth > 0) Math.min(drawable.intrinsicWidth, 96) else 48
        val height = if (drawable.intrinsicHeight > 0) Math.min(drawable.intrinsicHeight, 96) else 48
        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        drawable.setBounds(0, 0, canvas.width, canvas.height)
        drawable.draw(canvas)
        return bitmap
    }
}
