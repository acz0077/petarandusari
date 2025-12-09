package com.randusari.peta_randusari

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkManager
import com.google.android.gms.tasks.Tasks
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor

class BootCompletedReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        if (intent?.action == Intent.ACTION_BOOT_COMPLETED) {
            context?.let {
                // Trigger background service initialization
                val workRequest = OneTimeWorkRequestBuilder<BackgroundWorker>().build()
                WorkManager.getInstance(it).enqueue(workRequest)
            }
        }
    }
}
