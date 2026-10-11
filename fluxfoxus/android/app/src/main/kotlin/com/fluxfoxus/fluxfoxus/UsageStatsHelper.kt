package com.fluxfoxus.fluxfoxus

import android.app.AppOpsManager
import android.app.usage.UsageStats
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.os.Build
import android.os.Process

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

            result.add(
                mapOf(
                    "packageName" to pkgName,
                    "appName" to appName,
                    "foregroundTimeMs" to timeMs,
                    "lastTimeUsed" to (lastUsedMap[pkgName] ?: 0L),
                    "isSystemApp" to isSystemApp
                )
            )
        }

        // Sort descending by foreground time
        result.sortByDescending { (it["foregroundTimeMs"] as? Long) ?: 0L }
        return result
    }
}
