package app.flowlife.flowlifemobile

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import org.json.JSONArray
import org.json.JSONObject

class FlowLifeWidget : AppWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_layout)

            // 1. Setup Click Intent for entire widget (Open App)
            val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java
            )
            views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

            // 2. Setup Click Intent for Add Button
            val addIntent = HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java,
                android.net.Uri.parse("flowlife://add_task")
            )
            views.setOnClickPendingIntent(R.id.widget_add_button, addIntent)

            // 3. Load Data from SharedPreferences
            val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
            val tasksJson = prefs.getString("today_tasks", "[]")
            
            try {
                val tasks = JSONArray(tasksJson)
                val taskCount = tasks.length()

                if (taskCount > 0) {
                    views.setViewVisibility(R.id.widget_empty_text, View.GONE)
                } else {
                    views.setViewVisibility(R.id.widget_empty_text, View.VISIBLE)
                }

                // Hide all rows initially
                views.setViewVisibility(R.id.task_row_1, View.GONE)
                views.setViewVisibility(R.id.task_row_2, View.GONE)
                views.setViewVisibility(R.id.task_row_3, View.GONE)

                // Populate up to 3 rows
                for (i in 0 until minOf(taskCount, 3)) {
                    val task = tasks.getJSONObject(i)
                    val rowId = when(i) {
                        0 -> R.id.task_row_1
                        1 -> R.id.task_row_2
                        else -> R.id.task_row_3
                    }
                    val titleId = when(i) {
                        0 -> R.id.task_title_1
                        1 -> R.id.task_title_2
                        else -> R.id.task_title_3
                    }
                    val dotId = when(i) {
                        0 -> R.id.task_dot_1
                        1 -> R.id.task_dot_2
                        else -> R.id.task_dot_3
                    }

                    views.setViewVisibility(rowId, View.VISIBLE)
                    views.setTextViewText(titleId, task.getString("title"))
                    
                    val colorHex = task.optString("color", "#355070")
                    try {
                        val color = Color.parseColor(colorHex)
                        // Use setInt to call setBackgroundColor on the TextView
                        views.setInt(dotId, "setBackgroundColor", color)
                    } catch (e: Exception) {
                        views.setInt(dotId, "setBackgroundColor", Color.parseColor("#355070"))
                    }
                }
            } catch (e: Exception) {
                views.setViewVisibility(R.id.widget_empty_text, View.VISIBLE)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
