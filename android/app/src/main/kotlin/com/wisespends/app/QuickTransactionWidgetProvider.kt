package com.my.aftechlabs.wise.spends

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

/**
 * Quick Transaction Widget Provider
 * Handles home screen widget updates and interactions
 */
class QuickTransactionWidgetProvider : AppWidgetProvider() {

    companion object {
        const val ACTION_QUICK_EXPENSE = "com.wisespends.app.QUICK_EXPENSE"
        const val ACTION_QUICK_INCOME = "com.wisespends.app.QUICK_INCOME"
        const val ACTION_OPEN_APP = "com.wisespends.app.OPEN_APP"
        const val ACTION_TOGGLE_VISIBILITY = "com.wisespends.app.TOGGLE_VISIBILITY"
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        
        when (intent.action) {
            ACTION_QUICK_EXPENSE -> {
                val openAppIntent = Intent(context, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                    putExtra("quick_transaction_type", "expense")
                }
                context.startActivity(openAppIntent)
            }
            ACTION_QUICK_INCOME -> {
                val openAppIntent = Intent(context, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                    putExtra("quick_transaction_type", "income")
                }
                context.startActivity(openAppIntent)
            }
            ACTION_OPEN_APP -> {
                val openAppIntent = Intent(context, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                }
                context.startActivity(openAppIntent)
            }
            ACTION_TOGGLE_VISIBILITY -> {
                val widgetPrefs = HomeWidgetPlugin.getData(context)
                val currentHide = widgetPrefs.getBoolean("hide_details", false)
                widgetPrefs.edit().putBoolean("hide_details", !currentHide).apply()

                // Refresh all widgets
                val manager = AppWidgetManager.getInstance(context)
                val ids = manager.getAppWidgetIds(
                    android.content.ComponentName(context, QuickTransactionWidgetProvider::class.java)
                )
                ids.forEach { updateAppWidget(context, manager, it) }
            }
        }
    }

    override fun onEnabled(context: Context) {
        // Enter relevant functionality for your app's widget
    }

    override fun onDisabled(context: Context) {
        // Enter relevant functionality for your app's widget
    }
}

/**
 * Update the widget UI
 */
internal fun updateAppWidget(
    context: Context,
    appWidgetManager: AppWidgetManager,
    appWidgetId: Int,
) {
    val prefs = HomeWidgetPlugin.getData(context)

    val hideDetails = prefs.getBoolean("hide_details", false)
    val lastTransactionTitle = prefs.getString("last_transaction_title", "No transactions") ?: "No transactions"
    val lastTransactionAmount = prefs.getString("last_transaction_amount", "0.00") ?: "0.00"
    val lastTransactionType = prefs.getString("last_transaction_type", "none") ?: "none"

    val views = RemoteViews(context.packageName, R.layout.quick_transaction_widget)

    // Hide/show logic
    val displayTitle  = if (hideDetails) "••••••" else lastTransactionTitle
    val displayAmount = if (hideDetails) "RM ****" else "RM $lastTransactionAmount"

    views.setTextViewText(R.id.widget_last_transaction_title, displayTitle)
    views.setTextViewText(R.id.widget_last_transaction_amount, displayAmount)

    // Transaction type icon
    val typeIconResId = when (lastTransactionType) {
        "income"  -> R.drawable.ic_income
        "expense" -> R.drawable.ic_expense
        else      -> R.drawable.ic_transaction
    }
    views.setImageViewResource(R.id.widget_transaction_icon, typeIconResId)

    // Expense button
    val expensePendingIntent = android.app.PendingIntent.getBroadcast(
        context, 0,
        Intent(context, QuickTransactionWidgetProvider::class.java).apply {
            action = QuickTransactionWidgetProvider.ACTION_QUICK_EXPENSE
        },
        android.app.PendingIntent.FLAG_UPDATE_CURRENT or android.app.PendingIntent.FLAG_IMMUTABLE
    )
    views.setOnClickPendingIntent(R.id.widget_expense_button, expensePendingIntent)

    // Income button
    val incomePendingIntent = android.app.PendingIntent.getBroadcast(
        context, 1,
        Intent(context, QuickTransactionWidgetProvider::class.java).apply {
            action = QuickTransactionWidgetProvider.ACTION_QUICK_INCOME
        },
        android.app.PendingIntent.FLAG_UPDATE_CURRENT or android.app.PendingIntent.FLAG_IMMUTABLE
    )
    views.setOnClickPendingIntent(R.id.widget_income_button, incomePendingIntent)

    val toggleIntent = android.app.PendingIntent.getBroadcast(
        context, 2,
        Intent(context, QuickTransactionWidgetProvider::class.java).apply {
            action = QuickTransactionWidgetProvider.ACTION_TOGGLE_VISIBILITY
        },
        android.app.PendingIntent.FLAG_UPDATE_CURRENT or android.app.PendingIntent.FLAG_IMMUTABLE
    )
    views.setOnClickPendingIntent(R.id.widget_toggle_visibility, toggleIntent)

    val toggleIconRes = if (hideDetails) R.drawable.ic_visibility_off else R.drawable.ic_visibility
    views.setImageViewResource(R.id.widget_toggle_visibility, toggleIconRes)

    appWidgetManager.updateAppWidget(appWidgetId, views)
}
