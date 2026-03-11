package com.my.aftechlabs.wise.spends

import android.service.quicksettings.Tile
import android.service.quicksettings.TileService
import android.content.Intent
import android.os.Build
import androidx.annotation.RequiresApi

/**
 * Quick Settings Tile for Quick Transaction
 * Provides one-tap access to add transactions from the notification shade
 *
 * Usage:
 * 1. Pull down notification shade
 * 2. Tap edit (pencil icon)
 * 3. Drag "Quick Transaction" tile to active tiles
 * 4. Tap tile to quickly add transactions
 */
@RequiresApi(Build.VERSION_CODES.N)
class QuickTransactionTileService : TileService() {

    companion object {
        const val ACTION_QUICK_TRANSACTION = "com.my.aftechlabs.wise.spends.QUICK_TRANSACTION"
    }

    override fun onStartListening() {
        super.onStartListening()
        // Update tile state when user opens quick settings
        updateTileState()
    }

    override fun onClick() {
        super.onClick()

        // Launch app with quick transaction intent
        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra("quick_transaction_type", "expense") // Default to expense
            action = ACTION_QUICK_TRANSACTION
        }

        startActivityAndCollapse(intent)
    }

    private fun updateTileState() {
        qsTile?.apply {
            label = "Quick Transaction"
            subtitle = "Add expense/income"
            icon = android.graphics.drawable.Icon.createWithResource(
                this@QuickTransactionTileService,
                R.drawable.ic_quick_transaction
            )
            state = Tile.STATE_INACTIVE
            updateTile()
        }
    }
}
