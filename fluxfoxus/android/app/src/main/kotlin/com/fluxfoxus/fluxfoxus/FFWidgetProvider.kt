package com.fluxfoxus.fluxfoxus

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.BitmapFactory
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * AppWidgetProvider for the 4x2 FluxFoxus Home Screen Widget.
 * Coordinates with Dart HomeWidget plugin to reflect screen time breakdown.
 */
class FFWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.ff_widget).apply {
                val totalTime = widgetData.getString("total_time", "--:--")
                val prodTime = widgetData.getString("prod_time", "--")
                val semiTime = widgetData.getString("semi_time", "--")
                val distTime = widgetData.getString("dist_time", "--")
                val otherTime = widgetData.getString("other_time", "--")
                val isLive = widgetData.getBoolean("is_live", false)

                setTextViewText(R.id.widget_total_time, totalTime)
                setTextViewText(R.id.widget_prod_time, prodTime)
                setTextViewText(R.id.widget_semi_time, semiTime)
                setTextViewText(R.id.widget_dist_time, distTime)
                setTextViewText(R.id.widget_other_time, otherTime)

                setViewVisibility(
                    R.id.widget_live_container,
                    if (isLive) View.VISIBLE else View.GONE
                )

                val imagePath = widgetData.getString("donut_ring", null)
                if (imagePath != null) {
                    val bitmap = BitmapFactory.decodeFile(imagePath)
                    if (bitmap != null) {
                        setImageViewBitmap(R.id.widget_donut_image, bitmap)
                    }
                }
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
