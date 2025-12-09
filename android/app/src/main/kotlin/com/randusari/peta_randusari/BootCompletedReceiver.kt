package com.randusari.peta_randusari

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class BootCompletedReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        // Broadcast receiver for device boot completion
        // Background tasks are auto-registered by Dart workmanager on app startup
        // This receiver just ensures the system knows the app should run after boot
        if (intent?.action == Intent.ACTION_BOOT_COMPLETED) {
            // WorkManager tasks will automatically restart after device reboot
            // No additional action needed here
        }
    }
}
