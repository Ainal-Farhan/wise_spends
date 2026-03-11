package com.my.aftechlabs.wise.spends

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.wisespends.app/widget"
    private var methodChannel: MethodChannel? = null  // store it

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel!!.setMethodCallHandler { call, result ->
            when (call.method) {
                "getQuickTransactionType" -> {
                    val type = intent.getStringExtra("quick_transaction_type")
                    result.success(type)
                    intent.removeExtra("quick_transaction_type")
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)  // ⚠️ CRITICAL: update the intent reference!
        val type = intent.getStringExtra("quick_transaction_type")
        if (type != null) {
            methodChannel?.invokeMethod("quickTransactionRequested", type)
        }
    }
}
